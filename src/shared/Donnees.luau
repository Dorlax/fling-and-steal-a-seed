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
	DerniereConnexion: number, -- os.time() de la dernière sauvegarde (0 = jamais)
	Renaissances: number,
	Graines: { string }, -- graines achetées (la Simple est toujours là)
	Graine: string, -- graine équipée
	Trainees: { string }, -- traînées débloquées
	Trainee: string, -- traînée équipée ("" = aucune)
	ProchaineRoue: number, -- os.time() du prochain tour de roue gratuit
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
		DerniereConnexion = 0,
		Renaissances = 0,
		Graines = { "Simple" },
		Graine = "Simple",
		Trainees = {},
		Trainee = "",
		ProchaineRoue = 0,
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

-- Liste de noms connus (dans l'ordre de `ordre`), sans doublon, avec `toujours`.
local function nettoyerNoms(valeur: any, ordre: { string }, toujours: { string }): { string }
	local vus: { [string]: boolean } = {}
	for _, nom in toujours do
		vus[nom] = true
	end
	if type(valeur) == "table" then
		for _, nom in ipairs(valeur) do
			if type(nom) == "string" and table.find(ordre, nom) then
				vus[nom] = true
			end
		end
	end
	local liste = {}
	for _, nom in ordre do
		if vus[nom] then
			table.insert(liste, nom)
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
	local derniere = brut.DerniereConnexion
	if
		type(derniere) == "number"
		and derniere == derniere
		and derniere > 0
		and derniere < math.huge
	then
		donnees.DerniereConnexion = math.floor(derniere)
	end
	local renaissances = brut.Renaissances
	if
		type(renaissances) == "number"
		and renaissances == renaissances
		and renaissances >= 0
		and renaissances < 1e6
	then
		donnees.Renaissances = math.floor(renaissances)
	end
	donnees.Graines = nettoyerNoms(brut.Graines, Config.Graines.Ordre, { "Simple" })
	if type(brut.Graine) == "string" and table.find(donnees.Graines, brut.Graine) then
		donnees.Graine = brut.Graine
	end
	donnees.Trainees = nettoyerNoms(brut.Trainees, Config.Trainees.Ordre, {})
	if type(brut.Trainee) == "string" and table.find(donnees.Trainees, brut.Trainee) then
		donnees.Trainee = brut.Trainee
	end
	local roue = brut.ProchaineRoue
	if type(roue) == "number" and roue == roue and roue >= 0 and roue < math.huge then
		donnees.ProchaineRoue = math.floor(roue)
	end
	donnees.Pieces = nettoyerPieces(brut.Pieces)
	donnees.CreaturesBase = nettoyerCreatures(brut.CreaturesBase)
	return donnees
end

return Donnees
