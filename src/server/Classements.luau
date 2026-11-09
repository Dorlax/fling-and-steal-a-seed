--!strict
-- Classements :
--  * liste des joueurs Roblox (leaderstats) : Biome record, Revenu / s, Pièces ;
--  * record de biome de chaque joueur (sauvegardé), annoncé à tout le serveur ;
--  * classement mondial (OrderedDataStore), publié pour les clients dans
--    l'attribut « ClassementMonde » de ReplicatedStorage (JSON).
-- Le classement du serveur est calculé par chaque client depuis les attributs
-- des joueurs (Pieces, RevenuParSeconde, RecordBiome), écrits par le serveur.
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Biomes = require(ReplicatedStorage.Shared.Biomes)
local Classement = require(ReplicatedStorage.Shared.Classement)
local Config = require(ReplicatedStorage.Shared.Config)
local Nombres = require(ReplicatedStorage.Shared.Nombres)

local Classements = {}

local reglages = Config.Classement

local function annoncer(texte: string)
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireAllClients(texte)
	end
end

local function nombre(joueur: any, nom: string): number
	local valeur = joueur:GetAttribute(nom)
	if type(valeur) == "number" and valeur == valeur then
		return valeur
	end
	return 0
end

---------------------------------------------------------------------------
-- Liste des joueurs (leaderstats)

local function valeur(dossier: Folder, classe: string, nom: string): ValueBase
	local v = Instance.new(classe) :: ValueBase
	v.Name = nom
	v.Parent = dossier
	return v
end

-- Crée les colonnes de la liste des joueurs et les tient à jour.
function Classements.suivre(joueur: Player)
	if joueur:FindFirstChild("leaderstats") then
		return
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "leaderstats"
	-- Biome en premier : la liste des joueurs trie sur la première colonne.
	local biome = valeur(dossier, "IntValue", "Biome") :: IntValue
	local revenu = valeur(dossier, "StringValue", "Revenu/s") :: StringValue
	local pieces = valeur(dossier, "StringValue", "Pièces") :: StringValue
	dossier.Parent = joueur

	local function maj()
		pieces.Value = Nombres.abreger(nombre(joueur, "Pieces"))
		revenu.Value = Nombres.abreger(nombre(joueur, "RevenuParSeconde"))
		biome.Value = math.max(1, math.floor(nombre(joueur, "RecordBiome")))
	end
	maj()
	for _, nom in { "Pieces", "RevenuParSeconde", "RecordBiome" } do
		joueur:GetAttributeChangedSignal(nom):Connect(maj)
	end
end

-- Un lancer a atterri dans `biome` : bat le record du joueur s'il le dépasse
-- et l'annonce à tout le serveur. Renvoie true si le record est battu.
function Classements.noterBiome(joueur: any, biome: number): boolean
	local record, battu = Classement.record(joueur:GetAttribute("RecordBiome"), biome)
	if not battu then
		return false
	end
	joueur:SetAttribute("RecordBiome", record)
	local infos = Biomes.biome(record)
	if typeof(joueur) == "Instance" and infos then
		annoncer(`{joueur.Name} a atteint le biome {record} : {infos.Nom} !`)
	end
	return true
end

---------------------------------------------------------------------------
-- Classement mondial

local function magasin(nom: string): OrderedDataStore?
	local ok, resultat = pcall(function()
		return DataStoreService:GetOrderedDataStore(nom)
	end)
	return if ok then resultat else nil
end

local noms: { [number]: string } = {}
local function nomDe(userId: number): string
	local connu = noms[userId]
	if connu then
		return connu
	end
	local present = Players:GetPlayerByUserId(userId)
	local nom = if present then present.Name else nil
	if nom == nil then
		local ok, resultat = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		nom = if ok then resultat else "Joueur"
	end
	noms[userId] = nom :: string
	return nom :: string
end

local derniersEnvois: { [string]: { [number]: number } } = {}

-- Envoie le score de chaque joueur (seulement s'il a changé).
local function envoyer(store: OrderedDataStore, cle: string, score: (Player) -> number)
	local envoyes = derniersEnvois[cle]
	if envoyes == nil then
		envoyes = {}
		derniersEnvois[cle] = envoyes
	end
	for _, joueur in Players:GetPlayers() do
		local s = score(joueur)
		if joueur.UserId > 0 and s > 0 and envoyes[joueur.UserId] ~= s then
			local ok = pcall(function()
				store:UpdateAsync(tostring(joueur.UserId), function(ancien: any): any
					if type(ancien) == "number" and ancien >= s then
						return nil -- garde le meilleur score
					end
					return s
				end)
			end)
			if ok then
				envoyes[joueur.UserId] = s
			end
		end
	end
end

-- Meilleurs scores : { {Nom, Valeur} }, valeur passée par `convertir`.
local function lire(store: OrderedDataStore, convertir: (number) -> number): { Classement.Entree }?
	local ok, page = pcall(function()
		return store:GetSortedAsync(false, reglages.Taille):GetCurrentPage()
	end)
	if not ok then
		return nil
	end
	local entrees = {}
	for _, ligne in page do
		local userId = tonumber(ligne.key)
		if userId then
			table.insert(entrees, { Nom = nomDe(userId), Valeur = convertir(ligne.value) })
		end
	end
	return entrees
end

local function majMonde()
	local magasinRevenus = magasin(reglages.NomRevenus)
	local magasinBiomes = magasin(reglages.NomBiomes)
	if magasinRevenus == nil or magasinBiomes == nil then
		return
	end
	local revenus = magasinRevenus :: OrderedDataStore
	local biomes = magasinBiomes :: OrderedDataStore
	envoyer(revenus, "Revenus", function(joueur)
		return Classement.scoreRevenus(nombre(joueur, "RevenuParSeconde"))
	end)
	envoyer(biomes, "Biomes", function(joueur)
		return math.floor(nombre(joueur, "RecordBiome"))
	end)
	local topRevenus = lire(revenus, Classement.revenusDeScore)
	local topBiomes = lire(biomes, function(v)
		return v
	end)
	if topRevenus == nil or topBiomes == nil then
		return
	end
	ReplicatedStorage:SetAttribute(
		"ClassementMonde",
		HttpService:JSONEncode({ Revenus = topRevenus, Biomes = topBiomes })
	)
end

function Classements.demarrer()
	Players.PlayerRemoving:Connect(function(joueur)
		noms[joueur.UserId] = joueur.Name
	end)
	task.spawn(function()
		task.wait(20) -- laisse les données des premiers joueurs se charger
		while true do
			local ok, erreur = pcall(function()
				majMonde()
			end)
			if not ok then
				warn("Classements : " .. tostring(erreur))
			end
			task.wait(reglages.IntervalleMonde)
		end
	end)
end

return Classements
