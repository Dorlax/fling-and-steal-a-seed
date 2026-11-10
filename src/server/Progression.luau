--!strict
-- Progression du joueur, côté serveur (tout est vérifié ici, le client ne
-- fait que demander) :
--  * renaissance : 0 pièce contre des bonus permanents (Shared.Bonus) ;
--  * graines : achat (une fois pour toutes) et choix de la graine équipée ;
--  * roue gratuite : un lot toutes les 4 h (pièces, boost, graine, traînée) ;
--  * traînées cosmétiques : débloquées par renaissances, Bestiaire ou roue.
-- Les listes sont exposées en attributs texte (« A,B,C ») pour le client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Bonus = require(ReplicatedStorage.Shared.Bonus)
local Config = require(ReplicatedStorage.Shared.Config)
local Nombres = require(ReplicatedStorage.Shared.Nombres)
local Revenus = require(ReplicatedStorage.Shared.Revenus)
local Sauvegarde = require(script.Parent.Sauvegarde)

local Progression = {}

local hasard = Random.new()

local function message(joueur: any, texte: string)
	if typeof(joueur) ~= "Instance" then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireClient(joueur, texte)
	end
end

local function annoncer(texte: string)
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireAllClients(texte)
	end
end

local function nombre(joueur: any, nom: string): number
	local v = joueur:GetAttribute(nom)
	return if type(v) == "number" and v == v then v else 0
end

local function liste(joueur: any, nom: string): { string }
	local texte = joueur:GetAttribute(nom)
	if type(texte) ~= "string" or texte == "" then
		return {}
	end
	return string.split(texte, ",")
end

local function payer(joueur: any, prix: number): boolean
	local pieces = nombre(joueur, "Pieces")
	if prix < 0 or pieces < prix then
		return false
	end
	joueur:SetAttribute("Pieces", pieces - prix)
	return true
end

---------------------------------------------------------------------------
-- Traînées

-- Traînée visible derrière le personnage (couleurs de la traînée équipée).
function Progression.appliquerTrainee(joueur: any)
	if typeof(joueur) ~= "Instance" then
		return
	end
	local personnage = (joueur :: Player).Character
	local trouve = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if trouve == nil or not trouve:IsA("BasePart") then
		return
	end
	local racine = trouve :: BasePart
	for _, nom in { "TraineeJoueur", "TraineeHaut", "TraineeBas" } do
		local ancien = racine:FindFirstChild(nom)
		if ancien then
			ancien:Destroy()
		end
	end
	local infos = (Config.Trainees.Liste :: any)[joueur:GetAttribute("Trainee")]
	if infos == nil then
		return
	end
	local haut = Instance.new("Attachment")
	haut.Name = "TraineeHaut"
	haut.Position = Vector3.new(0, 0.8, 0.4)
	haut.Parent = racine
	local bas = Instance.new("Attachment")
	bas.Name = "TraineeBas"
	bas.Position = Vector3.new(0, -0.8, 0.4)
	bas.Parent = racine
	local points = {}
	for i, rgb in infos.Couleurs do
		local t = if #infos.Couleurs > 1 then (i - 1) / (#infos.Couleurs - 1) else 0
		table.insert(points, ColorSequenceKeypoint.new(t, Color3.fromRGB(rgb[1], rgb[2], rgb[3])))
	end
	if #points == 1 then
		table.insert(points, ColorSequenceKeypoint.new(1, points[1].Value))
	end
	local trace = Instance.new("Trail")
	trace.Name = "TraineeJoueur"
	trace.Attachment0 = haut
	trace.Attachment1 = bas
	trace.Lifetime = 0.6
	trace.LightEmission = 0.5
	trace.Color = ColorSequence.new(points)
	trace.Transparency = NumberSequence.new(0.15, 1)
	trace.Parent = racine
end

local function donnerTrainee(joueur: any, id: string): boolean
	local possedees = liste(joueur, "Trainees")
	if table.find(possedees, id) or (Config.Trainees.Liste :: any)[id] == nil then
		return false
	end
	table.insert(possedees, id)
	joueur:SetAttribute("Trainees", table.concat(possedees, ","))
	message(joueur, `Nouvelle traînée : {(Config.Trainees.Liste :: any)[id].Nom} ! (Boutique)`)
	return true
end

-- Débloque les traînées gagnées par renaissances ou pages du Bestiaire.
function Progression.verifierTrainees(joueur: any)
	local renaissances = nombre(joueur, "Renaissances")
	local pages = Sauvegarde.pagesCompletes(joueur)
	for _, id in Config.Trainees.Ordre do
		local t = (Config.Trainees.Liste :: any)[id]
		if
			(t.Renaissances and renaissances >= t.Renaissances) or (t.Pages and pages >= t.Pages)
		then
			donnerTrainee(joueur, id)
		end
	end
end

local function donnerSkin(joueur: any, id: string): boolean
	local possedes = liste(joueur, "Skins")
	if table.find(possedes, id) or (Config.Skins.Liste :: any)[id] == nil then
		return false
	end
	table.insert(possedes, id)
	joueur:SetAttribute("Skins", table.concat(possedes, ","))
	message(joueur, `Nouveau skin de graine : {(Config.Skins.Liste :: any)[id].Nom} ! (Boutique)`)
	return true
end

-- Débloque les skins de graine gagnés par renaissances ou pages du Bestiaire.
function Progression.verifierSkins(joueur: any)
	local renaissances = nombre(joueur, "Renaissances")
	local pages = Sauvegarde.pagesCompletes(joueur)
	for _, id in Config.Skins.Ordre do
		local s = (Config.Skins.Liste :: any)[id]
		if
			(s.Renaissances and renaissances >= s.Renaissances) or (s.Pages and pages >= s.Pages)
		then
			donnerSkin(joueur, id)
		end
	end
end

-- Reçu du client : seul un skin possédé (ou "" = classique) est accepté.
function Progression.equiperSkin(joueur: any, id: any): boolean
	if id ~= "" and (type(id) ~= "string" or not table.find(liste(joueur, "Skins"), id)) then
		return false
	end
	joueur:SetAttribute("Skin", id)
	return true
end

function Progression.equiperTrainee(joueur: any, id: any): boolean
	if id ~= "" and (type(id) ~= "string" or not table.find(liste(joueur, "Trainees"), id)) then
		return false
	end
	joueur:SetAttribute("Trainee", id)
	Progression.appliquerTrainee(joueur)
	return true
end

---------------------------------------------------------------------------
-- Renaissance

function Progression.renaitre(joueur: any): boolean
	local n = nombre(joueur, "Renaissances")
	if not payer(joueur, Bonus.prixRenaissance(n)) then
		return false
	end
	joueur:SetAttribute("Pieces", 0)
	joueur:SetAttribute("Renaissances", n + 1)
	Sauvegarde.recalculer(joueur)
	Progression.verifierTrainees(joueur)
	Progression.verifierSkins(joueur)
	if typeof(joueur) == "Instance" then
		annoncer(
			`{joueur.Name} renaît ! Renaissance {n + 1} : revenus × {Nombres.abreger(
				Bonus.revenusRenaissance(n + 1)
			)}`
		)
	end
	return true
end

---------------------------------------------------------------------------
-- Graines

function Progression.acheterGraine(joueur: any, id: any): boolean
	local infos = if type(id) == "string" then (Config.Graines.Liste :: any)[id] else nil
	if infos == nil then
		return false
	end
	local possedees = liste(joueur, "Graines")
	if table.find(possedees, id) then
		return false
	end
	if not payer(joueur, infos.Prix) then
		return false
	end
	table.insert(possedees, id)
	joueur:SetAttribute("Graines", table.concat(possedees, ","))
	joueur:SetAttribute("Graine", id)
	message(joueur, `{infos.Nom} achetée et équipée !`)
	return true
end

function Progression.equiperGraine(joueur: any, id: any): boolean
	if type(id) ~= "string" or not table.find(liste(joueur, "Graines"), id) then
		return false
	end
	joueur:SetAttribute("Graine", id)
	return true
end

---------------------------------------------------------------------------
-- Roue

-- Lot tiré avec `tirage` dans [0, 1[ (selon les poids de Config.Roue).
function Progression.lot(tirage: number): (number, any)
	local total = 0
	for _, lot in Config.Roue.Lots do
		total += lot.Poids
	end
	local seuil = math.clamp(tirage, 0, 0.999999) * total
	local cumul = 0
	for i, lot in Config.Roue.Lots do
		cumul += lot.Poids
		if seuil < cumul then
			return i, lot
		end
	end
	return #Config.Roue.Lots, Config.Roue.Lots[#Config.Roue.Lots]
end

-- Tourne la roue si c'est l'heure. Renvoie le numéro du lot, ou nil.
function Progression.tournerRoue(joueur: any, tirage: number?): number?
	local maintenant = os.time()
	if maintenant < nombre(joueur, "ProchaineRoue") then
		return nil
	end
	joueur:SetAttribute("ProchaineRoue", maintenant + Config.Roue.Intervalle)
	local numero, lot = Progression.lot(tirage or hasard:NextNumber())
	local revenu = math.max(nombre(joueur, "RevenuParSeconde"), 1)
	if lot.Type == "Pieces" then
		local gain = math.max(100, revenu * lot.Valeur)
		joueur:SetAttribute("Pieces", Revenus.ajouter(joueur:GetAttribute("Pieces"), gain))
		message(joueur, `Roue : +{Nombres.abreger(gain)} pièces !`)
	elseif lot.Type == "Boost" then
		joueur:SetAttribute("BoostJusqua", Workspace:GetServerTimeNow() + Config.Roue.DureeBoost)
		message(joueur, "Roue : revenus × 2 pendant 10 minutes !")
	elseif lot.Type == "Lancer" then
		joueur:SetAttribute("LancerGraine", lot.Valeur)
		message(joueur, "Roue : ton prochain lancer utilise une graine cristal !")
	else
		local libres = {}
		for _, id in Config.Trainees.Ordre do
			local t = (Config.Trainees.Liste :: any)[id]
			if t.Roue and not table.find(liste(joueur, "Trainees"), id) then
				table.insert(libres, id)
			end
		end
		if #libres > 0 then
			donnerTrainee(joueur, libres[hasard:NextInteger(1, #libres)])
		else
			local gain = math.max(100, revenu * 900)
			joueur:SetAttribute("Pieces", Revenus.ajouter(joueur:GetAttribute("Pieces"), gain))
			message(
				joueur,
				`Roue : toutes les traînées déjà gagnées, +{Nombres.abreger(gain)} pièces !`
			)
		end
	end
	return numero
end

---------------------------------------------------------------------------

-- À l'arrivée (données chargées) : traînées gagnées et traînée affichée.
function Progression.suivre(joueur: Player)
	Progression.verifierTrainees(joueur)
	Progression.verifierSkins(joueur)
	Progression.appliquerTrainee(joueur)
	joueur.CharacterAdded:Connect(function()
		task.wait(0.5)
		Progression.appliquerTrainee(joueur)
	end)
	-- Une nouvelle page du Bestiaire peut débloquer une traînée.
	joueur:GetAttributeChangedSignal("PagesCompletes"):Connect(function()
		Progression.verifierTrainees(joueur)
		Progression.verifierSkins(joueur)
	end)
end

return Progression
