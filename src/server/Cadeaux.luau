--!strict
-- Cadeaux, côté serveur (le client ne fait que demander) :
--  * cadeau de connexion quotidien, série de 7 jours ;
--  * 3 défis du jour (progrès compté ici, récompense réclamée une fois) ;
--  * codes promo (une fois par joueur) ;
--  * réglages son / musique (simples préférences sauvegardées).
-- Tout passe par des attributs du joueur, sauvegardés par Sauvegarde.
-- Ce module ne dépend que de modules partagés : tout le monde peut le requérir.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Cadeau = require(ReplicatedStorage.Shared.Cadeaux)
local Config = require(ReplicatedStorage.Shared.Config)
local Nombres = require(ReplicatedStorage.Shared.Nombres)
local Revenus = require(ReplicatedStorage.Shared.Revenus)

local Cadeaux = {}

-- Horloge remplaçable par les tests.
local horloge: () -> number = os.time
function Cadeaux.fixerHorloge(f: (() -> number)?)
	horloge = f or os.time
end

local function message(joueur: any, texte: string)
	if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireClient(joueur, texte)
	end
end

local function nombre(joueur: any, nom: string): number
	local v = joueur:GetAttribute(nom)
	return if type(v) == "number" and v == v then v else 0
end

local function userId(joueur: any): number
	local ok, id = pcall(function()
		return joueur.UserId
	end)
	return if ok and type(id) == "number" then id else 0
end

local function lireListe(joueur: any, nom: string): { string }
	local texte = joueur:GetAttribute(nom)
	if type(texte) ~= "string" or texte == "" then
		return {}
	end
	return string.split(texte, ",")
end

-- Donne une récompense ({ Type, Minutes/Secondes/Id }) ; renvoie son texte.
function Cadeaux.donner(joueur: any, recompense: any): string
	if recompense.Type == "Pieces" then
		local gain = Cadeau.pieces(joueur:GetAttribute("RevenuParSeconde"), recompense.Minutes)
		joueur:SetAttribute("Pieces", Revenus.ajouter(joueur:GetAttribute("Pieces"), gain))
		return `+{Nombres.abreger(gain)} pièces`
	elseif recompense.Type == "Boost" then
		local maintenant = Workspace:GetServerTimeNow()
		local fin = math.max(nombre(joueur, "BoostJusqua"), maintenant) + recompense.Secondes
		joueur:SetAttribute("BoostJusqua", fin)
		return recompense.Texte
	elseif recompense.Type == "Roue" then
		joueur:SetAttribute("ProchaineRoue", 0)
		return recompense.Texte
	elseif recompense.Type == "Graine" then
		joueur:SetAttribute("LancerGraine", recompense.Id)
		return recompense.Texte
	end
	return ""
end

---------------------------------------------------------------------------
-- Cadeau de connexion

-- Réclame le cadeau du jour. Renvoie le numéro de la série, ou nil.
function Cadeaux.reclamerQuotidien(joueur: any): number?
	local aujourdhui = Cadeau.jour(horloge())
	local dispo, serie = Cadeau.quotidien(
		joueur:GetAttribute("QuotidienSerie"),
		joueur:GetAttribute("QuotidienJour"),
		aujourdhui
	)
	if not dispo then
		return nil
	end
	joueur:SetAttribute("QuotidienSerie", serie)
	joueur:SetAttribute("QuotidienJour", aujourdhui)
	local texte = Cadeaux.donner(joueur, Config.Quotidien.Recompenses[serie])
	message(joueur, `🎁 Jour {serie} : {texte} !`)
	return serie
end

---------------------------------------------------------------------------
-- Défis du jour

-- Remet les défis à zéro si on a changé de jour. Renvoie les défis du jour.
function Cadeaux.defis(joueur: any): { string }
	local aujourdhui = Cadeau.jour(horloge())
	if joueur:GetAttribute("DefisJour") ~= aujourdhui then
		local zeros = table.create(Config.Defis.Nombre, "0")
		joueur:SetAttribute("DefisJour", aujourdhui)
		joueur:SetAttribute("DefisProgres", table.concat(zeros, ","))
		joueur:SetAttribute("DefisReclames", table.concat(zeros, ","))
	end
	return Cadeau.defisDu(aujourdhui, userId(joueur))
end

local function progres(joueur: any): { number }
	local liste = {}
	for i, morceau in lireListe(joueur, "DefisProgres") do
		liste[i] = tonumber(morceau) or 0
	end
	for i = 1, Config.Defis.Nombre do
		liste[i] = liste[i] or 0
	end
	return liste
end

local function reclames(joueur: any): { string }
	local liste = lireListe(joueur, "DefisReclames")
	for i = 1, Config.Defis.Nombre do
		liste[i] = liste[i] or "0"
	end
	return liste
end

-- Fait avancer le défi « id » s'il fait partie des défis du jour.
function Cadeaux.progresser(joueur: any, id: string, quantite: number?)
	local nature = typeof(joueur)
	if
		(nature ~= "Instance" and nature ~= "table")
		or joueur:GetAttribute("DefisProgres") == nil
	then
		return -- données pas encore chargées
	end
	local ids = Cadeaux.defis(joueur)
	local trouve = table.find(ids, id)
	if trouve == nil then
		return
	end
	local numero = trouve :: number
	local defi = (Config.Defis.Liste :: any)[id]
	local liste = progres(joueur)
	local avant = liste[numero]
	if avant >= defi.Objectif then
		return
	end
	local apres = math.min(avant + (quantite or 1), defi.Objectif)
	-- Arrondi au quart (Forge : un tick = 0,25 s), pour un attribut court.
	liste[numero] = math.floor(apres * 4 + 0.5) / 4
	joueur:SetAttribute("DefisProgres", table.concat(liste, ","))
	if apres >= defi.Objectif then
		message(joueur, `✅ Défi réussi : {Cadeau.texteDefi(id)} ! Réclame ta récompense 🎁`)
	end
end

-- Réclame la récompense du défi n° numero (1..3). Renvoie true si donnée.
function Cadeaux.reclamerDefi(joueur: any, numero: any): boolean
	if
		type(numero) ~= "number"
		or numero ~= math.floor(numero)
		or numero < 1
		or numero > Config.Defis.Nombre
	then
		return false
	end
	local ids = Cadeaux.defis(joueur)
	local id = ids[numero]
	local defi = id and (Config.Defis.Liste :: any)[id]
	if defi == nil then
		return false
	end
	local faits = reclames(joueur)
	if faits[numero] == "1" or progres(joueur)[numero] < defi.Objectif then
		return false
	end
	faits[numero] = "1"
	joueur:SetAttribute("DefisReclames", table.concat(faits, ","))
	local texte = Cadeaux.donner(joueur, { Type = "Pieces", Minutes = defi.Minutes })
	message(joueur, `🏅 Défi : {texte} !`)
	return true
end

---------------------------------------------------------------------------
-- Codes promo

-- Utilise un code. Renvoie un message pour le joueur et si ça a marché.
function Cadeaux.utiliserCode(joueur: any, texte: any): (boolean, string)
	local valide = Cadeau.code(texte)
	if valide == nil then
		return false, "Code inconnu"
	end
	local code = valide :: string
	local utilises = lireListe(joueur, "CodesUtilises")
	if table.find(utilises, code) then
		return false, "Code déjà utilisé"
	end
	table.insert(utilises, code)
	joueur:SetAttribute("CodesUtilises", table.concat(utilises, ","))
	local recompense = (Config.Codes :: any)[code]
	local gain = Cadeaux.donner(joueur, recompense)
	local texteFinal = if recompense.Type == "Pieces" then `{recompense.Texte} {gain}` else gain
	message(joueur, `🎟️ {texteFinal}`)
	return true, texteFinal
end

---------------------------------------------------------------------------
-- Réglages

function Cadeaux.changerReglage(joueur: any, nom: any, valeur: any): boolean
	if (nom ~= "Son" and nom ~= "Musique") or type(valeur) ~= "boolean" then
		return false
	end
	joueur:SetAttribute("Reglage" .. nom, valeur)
	return true
end

return Cadeaux
