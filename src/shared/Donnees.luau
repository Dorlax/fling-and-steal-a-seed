--!strict
-- Logique pure des données joueur : valeurs par défaut et nettoyage.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")
-- selene: allow(incorrect_standard_library_use)
local Forge = if script then require(script.Parent.Forge) else (require :: any)("./Forge")
-- selene: allow(incorrect_standard_library_use)
local Fiche = if script then require(script.Parent.Fiche) else (require :: any)("./Fiche")
-- selene: allow(incorrect_standard_library_use)
local Collection = if script
	then require(script.Parent.Collection)
	else (require :: any)("./Collection")

export type DonneesJoueur = {
	Force: number,
	Vitesse: number,
	ModeForge: string,
	NiveauForge: number,
	Etages: number,
	Agrandissement: number,
	RecordBiome: number,
	Decouvertes: { string }, -- espèces de créatures déjà récoltées (Bestiaire)
	Pieces: number,
	CreaturesBase: { string },
}

local Donnees = {}

function Donnees.parDefaut(): DonneesJoueur
	return {
		Force = 0,
		Vitesse = 0,
		ModeForge = Config.Forge.ModeParDefaut,
		NiveauForge = 1,
		Etages = 1,
		Agrandissement = 1,
		RecordBiome = 1,
		Decouvertes = {},
		Pieces = 0,
		CreaturesBase = {},
	}
end

-- Stat valide : nombre fini, entre 0 et PlafondStat.
local function nettoyerStat(valeur: any): number
	if type(valeur) ~= "number" or valeur ~= valeur or valeur < 0 then
		return 0
	end
	return math.min(valeur, Config.Forge.PlafondStat)
end

-- Pièces valides : entier fini, entre 0 et PiecesMax.
local function nettoyerPieces(valeur: any): number
	if type(valeur) ~= "number" or valeur ~= valeur or valeur < 0 or valeur == math.huge then
		return 0
	end
	return math.min(math.floor(valeur), Config.Creatures.PiecesMax)
end

-- Liste de fiches valides, tronquée à la capacité maximale (tous étages).
local function nettoyerCreatures(valeur: any): { string }
	local liste = {}
	if type(valeur) ~= "table" then
		return liste
	end
	for _, rarete in ipairs(valeur) do
		if #liste >= Config.Creatures.MaxCreaturesBase * Config.Bases.EtagesMax then
			break
		end
		if Fiche.valide(rarete) then
			table.insert(liste, rarete)
		end
	end
	return liste
end

-- Corrige des données chargées (ou reçues) : jamais de confiance aveugle.
function Donnees.nettoyer(brut: any): DonneesJoueur
	local donnees = Donnees.parDefaut()
	if type(brut) ~= "table" then
		return donnees
	end
	donnees.Force = nettoyerStat(brut.Force)
	donnees.Vitesse = nettoyerStat(brut.Vitesse)
	if Forge.estModeValide(brut.ModeForge) then
		donnees.ModeForge = brut.ModeForge
	end
	local niveau = brut.NiveauForge
	if type(niveau) == "number" and niveau == niveau and niveau >= 1 and niveau < math.huge then
		donnees.NiveauForge = math.floor(niveau)
	end
	local etages = brut.Etages
	if type(etages) == "number" and etages == etages and etages >= 1 then
		donnees.Etages = math.min(math.floor(etages), Config.Bases.EtagesMax)
	end
	local agrandissement = brut.Agrandissement
	if
		type(agrandissement) == "number"
		and agrandissement == agrandissement
		and agrandissement >= 1
	then
		donnees.Agrandissement = math.min(math.floor(agrandissement), #Config.Bases.Tailles)
	end
	local record = brut.RecordBiome
	if type(record) == "number" and record == record and record >= 1 and record < math.huge then
		donnees.RecordBiome = math.floor(record)
	end
	donnees.Decouvertes = Collection.nettoyer(brut.Decouvertes)
	donnees.Pieces = nettoyerPieces(brut.Pieces)
	donnees.CreaturesBase = nettoyerCreatures(brut.CreaturesBase)
	return donnees
end

return Donnees
