--!strict
-- Style de l'interface : constantes et calculs d'affichage (module pur).
-- Aucune instance Roblox ici : les couleurs sont des tables RGB { r, g, b } 0-255,
-- converties en Color3 par src/client/Habillage.luau.
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

export type RGB = { number }

local Style = {}

-- Couleurs franches du style cartoon.
local VERT: RGB = { 70, 220, 90 }
local JAUNE: RGB = { 255, 220, 40 }
local ORANGE: RGB = { 255, 140, 30 }
local ROUGE: RGB = { 240, 50, 50 }
local VIOLET: RGB = { 110, 70, 200 }
local BLEU: RGB = { 60, 150, 255 }
local BLANC: RGB = { 255, 255, 255 }

Style.Couleurs = {
	Vert = VERT,
	Jaune = JAUNE,
	Orange = ORANGE,
	Rouge = ROUGE,
	Violet = VIOLET,
	Bleu = BLEU,
	Blanc = BLANC,
	Gris = { 130, 130, 140 },
	Fond = { 30, 30, 45 },
	Pieces = { 255, 215, 60 },
}

-- Texte : une seule police ronde, contour noir épais.
Style.Police = "FredokaOne"
Style.PoliceSecondaire = "FredokaOne"
Style.Contour = { Gros = 5, Moyen = 4, Petit = 3 }
Style.TailleTexteMin = 18 -- pixels
Style.TailleBoutonMin = 90 -- pixels (côté le plus petit d'un bouton d'action)
Style.ArrondiBouton = 0.25 -- UICorner en échelle

-- Dégradé des jauges : vert -> jaune -> orange -> rouge.
-- Chaque point : { position (0-1), couleur RGB }.
local DEGRADE: { { any } } = {
	{ 0, VERT },
	{ 1 / 3, JAUNE },
	{ 2 / 3, ORANGE },
	{ 1, ROUGE },
}
Style.Degrade = DEGRADE

-- Animations (secondes, pixels).
Style.Flottant = { Duree = 0.9, Montee = 40 }
Style.Rebond = { Echelle = 0.85, Duree = 0.3 }
Style.Bandeau = { Duree = 2, Glisse = 0.3 }

local LONGUEUR_MAX = 80 -- caractères d'un bandeau
local ATTENTE_MAX = 3 -- messages en attente au plus

local function copie(rgb: RGB): RGB
	return { rgb[1], rgb[2], rgb[3] }
end

local function estNombre(valeur: any): boolean
	return type(valeur) == "number" and valeur == valeur
end

-- Couleur du dégradé pour `ratio` (borné à [0, 1] ; invalide -> Vert).
function Style.couleurJauge(ratio: number): RGB
	if not estNombre(ratio) then
		return copie(VERT)
	end
	local r = math.clamp(ratio, 0, 1)
	local points = DEGRADE
	for i = 1, #points - 1 do
		local a, b = points[i], points[i + 1]
		if r <= b[1] then
			if r == a[1] then
				return copie(a[2])
			elseif r == b[1] then
				return copie(b[2])
			end
			local t = (r - a[1]) / (b[1] - a[1])
			local resultat = {}
			for k = 1, 3 do
				resultat[k] = math.floor(a[2][k] + (b[2][k] - a[2][k]) * t + 0.5)
			end
			return resultat
		end
	end
	return copie(points[#points][2])
end

-- Part restante d'une recharge, dans [0, 1].
function Style.ratioRecharge(maintenant: number, pretA: number?, duree: number): number
	if not estNombre(maintenant) or not estNombre(pretA) or not estNombre(duree) then
		return 0
	end
	if duree <= 0 or (pretA :: number) <= maintenant then
		return 0
	end
	return math.clamp(((pretA :: number) - maintenant) / duree, 0, 1)
end

function Style.couleurRarete(rarete: string): RGB
	local rgb = (Config.Raretes.Couleurs :: any)[rarete]
	if type(rgb) ~= "table" then
		return copie(BLANC)
	end
	return copie(rgb)
end

local COULEURS_ZONES: { [string]: RGB } = {
	Proche = VERT,
	Moyenne = ORANGE,
	Lointaine = ROUGE,
}

-- Danger des monstres selon leur zone.
function Style.couleurZone(zone: string): RGB
	return copie(COULEURS_ZONES[zone] or BLANC)
end

function Style.texteRarete(rarete: string): string
	local nom = (Config.Raretes.Noms :: any)[rarete]
	if type(nom) == "string" then
		return nom
	end
	return rarete
end

-- Fond du bandeau selon le message (ordre de priorité fixe).
function Style.couleurBandeau(texte: string): RGB
	if type(texte) ~= "string" then
		return copie(BLEU)
	end
	local minuscule = string.lower(texte)
	if string.find(texte, "VOLÉ", 1, true) then
		return copie(ROUGE)
	elseif string.find(texte, "Base pleine", 1, true) then
		return copie(ORANGE)
	elseif string.find(texte, "Créature déposée", 1, true) then
		return copie(VERT)
	elseif string.find(minuscule, "nuit", 1, true) then
		return copie(VIOLET)
	elseif string.find(minuscule, "jour", 1, true) then
		return copie(JAUNE)
	end
	return copie(BLEU)
end

function Style.estBoum(texte: any): boolean
	return texte == "BOUM !"
end

-- File de bandeaux : un seul message affiché à la fois.
type Message = { texte: string, arrivee: number }
export type File = {
	attente: { Message },
	actuel: string?,
	fin: number,
	libreA: number,
}

local function dureeMessage(): number
	return Style.Bandeau.Duree + 2 * Style.Bandeau.Glisse
end

function Style.nouvelleFile(): File
	return { attente = {}, actuel = nil, fin = 0, libreA = -math.huge }
end

-- Fait avancer la file jusqu'à l'instant `maintenant`.
local function avancer(file: File, maintenant: number)
	if not estNombre(maintenant) then
		return
	end
	while true do
		if file.actuel ~= nil then
			if maintenant < file.fin then
				return
			end
			file.actuel = nil
			file.libreA = file.fin
		end
		local suivant = file.attente[1]
		if suivant == nil then
			return
		end
		local debut = math.max(file.libreA, suivant.arrivee)
		if maintenant < debut then
			return
		end
		table.remove(file.attente, 1)
		file.actuel = suivant.texte
		file.fin = debut + dureeMessage()
	end
end

local function tronquer(texte: string): string
	local longueur = utf8.len(texte)
	if longueur == nil then
		return string.sub(texte, 1, LONGUEUR_MAX)
	end
	if longueur <= LONGUEUR_MAX then
		return texte
	end
	local coupure = utf8.offset(texte, LONGUEUR_MAX + 1)
	return string.sub(texte, 1, (coupure or (LONGUEUR_MAX + 1)) - 1)
end

function Style.ajouter(file: File, texte: string, maintenant: number)
	if type(texte) ~= "string" or texte == "" then
		return
	end
	avancer(file, maintenant)
	local message = tronquer(texte)
	local dernier = file.attente[#file.attente]
	if dernier ~= nil then
		if dernier.texte == message then
			return
		end
	elseif file.actuel == message then
		return
	end
	local arrivee = if estNombre(maintenant) then maintenant else file.libreA
	table.insert(file.attente, { texte = message, arrivee = arrivee })
	while #file.attente > ATTENTE_MAX do
		table.remove(file.attente, 1)
	end
end

-- Message affiché à l'instant `maintenant` (ou nil).
function Style.courant(file: File, maintenant: number): string?
	avancer(file, maintenant)
	return file.actuel
end

return Style
