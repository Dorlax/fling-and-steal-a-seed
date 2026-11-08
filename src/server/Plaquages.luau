--!strict
-- Plaquage d'un joueur qui porte une créature (serveur).
-- Le client envoie seulement « Plaquer » sans valeur utile : la cible, la
-- portée, les délais et la protection sont décidés et vérifiés ici.
-- `candidats` et `maintenant` (optionnels) servent uniquement aux tests en jeu ;
-- le gestionnaire du RemoteEvent ne les transmet jamais.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Plaquage = require(ReplicatedStorage.Shared.Plaquage)
local Bases = require(script.Parent.Bases)
local Portage = require(script.Parent.Portage)

local Plaquages = {}

local reglages = Config.Plaquage
local NB_ETOILES = 4
local RAYON_ETOILES = 46 -- pixels
local TOURS_PAR_SECONDE = 1.2

local pretA: { [any]: number } = {} -- fin du délai de chaque plaqueur
local protegeJusqua: { [any]: number } = {} -- fin de protection de chaque cible
local derniereRequete: { [any]: number } = {} -- anti-spam (os.clock)
local chutes: { [any]: number } = {} -- numéro de la dernière mise au sol

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

local function racineEtHumanoide(joueur: any): (BasePart?, Humanoid?)
	local personnage = joueur.Character
	if typeof(personnage) ~= "Instance" then
		return nil, nil
	end
	local racine = (personnage :: Instance):FindFirstChild("HumanoidRootPart")
	local humanoide = (personnage :: Instance):FindFirstChildOfClass("Humanoid")
	if racine == nil or not racine:IsA("BasePart") then
		return nil, humanoide
	end
	return racine :: BasePart, humanoide
end

local function estVivant(joueur: any): boolean
	local racine, humanoide = racineEtHumanoide(joueur)
	return racine ~= nil and humanoide ~= nil and humanoide.Health > 0
end

local function envoyerMessage(joueur: any, texte: string)
	if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireClient(joueur, texte)
	end
end

local function contour(element: GuiObject, epaisseur: number)
	local trait = Instance.new("UIStroke")
	trait.Thickness = epaisseur
	trait.Color = Color3.new(0, 0, 0)
	trait.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	trait.Parent = element
end

-- « BOUM ! » et étoiles qui tournent au-dessus de la tête, puis disparition.
local function afficherEffet(cible: any)
	local personnage = cible.Character
	if typeof(personnage) ~= "Instance" then
		return
	end
	local support = (personnage :: Instance):FindFirstChild("Head")
		or (personnage :: Instance):FindFirstChild("HumanoidRootPart")
	if support == nil or not support:IsA("BasePart") then
		return
	end
	local ancien = (personnage :: Instance):FindFirstChild("EffetPlaquage", true)
	if ancien then
		ancien:Destroy()
	end

	local effet = Instance.new("BillboardGui")
	effet.Name = "EffetPlaquage"
	effet.Size = UDim2.fromOffset(200, 140)
	effet.StudsOffset = Vector3.new(0, 3, 0)
	effet.AlwaysOnTop = true
	effet.MaxDistance = 150

	local boum = Instance.new("TextLabel")
	boum.Name = "Boum"
	boum.AnchorPoint = Vector2.new(0.5, 0.5)
	boum.Position = UDim2.fromScale(0.5, 0.35)
	boum.Size = UDim2.fromScale(1, 0.5)
	boum.BackgroundTransparency = 1
	boum.Font = Enum.Font.FredokaOne
	boum.TextScaled = true
	boum.TextColor3 = Color3.fromRGB(255, 220, 40)
	boum.Rotation = -8
	boum.Text = "BOUM !"
	boum.Parent = effet
	contour(boum, 4)

	local etoiles: { TextLabel } = {}
	for i = 1, NB_ETOILES do
		local etoile = Instance.new("TextLabel")
		etoile.Name = "Etoile" .. i
		etoile.AnchorPoint = Vector2.new(0.5, 0.5)
		etoile.Size = UDim2.fromOffset(32, 32)
		etoile.BackgroundTransparency = 1
		etoile.Font = Enum.Font.GothamBlack
		etoile.TextScaled = true
		etoile.TextColor3 = Color3.fromRGB(255, 245, 120)
		etoile.Text = "★"
		etoile.Parent = effet
		contour(etoile, 2)
		table.insert(etoiles, etoile)
	end

	local function placerEtoiles(ecoule: number)
		local angleBase = ecoule * TOURS_PAR_SECONDE * 2 * math.pi
		for i, etoile in etoiles do
			local angle = angleBase + (i - 1) * 2 * math.pi / NB_ETOILES
			-- Ellipse aplatie : on dirait un cercle vu de biais au-dessus de la tête.
			etoile.Position = UDim2.new(
				0.5,
				math.cos(angle) * RAYON_ETOILES,
				0.8,
				math.sin(angle) * RAYON_ETOILES * 0.35
			)
			etoile.Rotation = math.deg(angle)
		end
	end
	placerEtoiles(0)
	effet.Parent = support

	local debut = os.clock()
	task.spawn(function()
		while effet.Parent ~= nil do
			RunService.Heartbeat:Wait()
			placerEtoiles(os.clock() - debut)
		end
	end)
	task.delay(reglages.DureeAuSol, function()
		effet:Destroy()
	end)
end

-- La cible tombe au sol pendant DureeAuSol, puis se relève.
local function mettreAuSol(cible: any)
	local numero = (chutes[cible] or 0) + 1
	chutes[cible] = numero
	local _, humanoide = racineEtHumanoide(cible)
	cible:SetAttribute("AuSol", true)
	if humanoide then
		humanoide.PlatformStand = true
	end
	task.delay(reglages.DureeAuSol, function()
		if chutes[cible] ~= numero then
			return -- replaquée entre-temps : la nouvelle chute décide
		end
		chutes[cible] = nil
		cible:SetAttribute("AuSol", nil)
		if humanoide and humanoide.Parent ~= nil then
			humanoide.PlatformStand = false
		end
	end)
end

-- Plaque le porteur valide le plus proche. Renvoie la cible plaquée, ou nil.
function Plaquages.plaquer(plaqueur: any, candidats: { any }?, maintenant: number?): any?
	local instant = if estNombreFini(maintenant)
		then maintenant :: number
		else Workspace:GetServerTimeNow()
	local liste: { any } = candidats or Players:GetPlayers()

	local racinePlaqueur = racineEtHumanoide(plaqueur)
	local plaqueurVivant = estVivant(plaqueur)
	local plaqueurAuSol = plaqueur:GetAttribute("AuSol") == true
	local plaqueurDansSaBase = Bases.estDansSaBase(plaqueur)

	local options: { Plaquage.Candidat } = {}
	for indice, cible in liste do
		local racineCible = racineEtHumanoide(cible)
		local distance = math.huge
		if racinePlaqueur and racineCible then
			distance = (racinePlaqueur.Position - racineCible.Position).Magnitude
		end
		local valide = Plaquage.verifier({
			memeJoueur = cible == plaqueur,
			plaqueurVivant = plaqueurVivant,
			plaqueurAuSol = plaqueurAuSol,
			plaqueurDansSaBase = plaqueurDansSaBase,
			cibleVivante = estVivant(cible),
			ciblePorte = Portage.porte(cible),
			cibleDansSaBase = Bases.estDansSaBase(cible),
			distance = distance,
			maintenant = instant,
			pretA = pretA[plaqueur],
			protegeeJusqua = protegeJusqua[cible],
		})
		options[indice] = { distance = distance, valide = valide }
	end

	local choix = Plaquage.choisirCible(options)
	if choix == nil then
		envoyerMessage(plaqueur, "Personne à plaquer !")
		return nil
	end
	local cible = liste[choix :: number]

	Portage.lacherParPlaquage(
		cible,
		if racinePlaqueur then racinePlaqueur.Position else nil,
		instant
	)
	mettreAuSol(cible)

	protegeJusqua[cible] = instant + reglages.DureeProtection
	cible:SetAttribute("ProtegeJusqua", instant + reglages.DureeProtection)
	pretA[plaqueur] = instant + reglages.DelaiRecuperation
	plaqueur:SetAttribute("PlaquagePretA", instant + reglages.DelaiRecuperation)

	afficherEffet(cible)
	envoyerMessage(plaqueur, "BOUM !")
	envoyerMessage(cible, "Tu t'es fait plaquer !")
	return cible
end

-- Gestionnaire de Plaquer : tous les arguments du client sont ignorés.
-- (Le chargement des données est vérifié par Principal.)
-- selene: allow(unused_variable)
function Plaquages.traiterRequete(joueur: any, ...: any): any?
	local horloge = os.clock()
	local derniere = derniereRequete[joueur]
	if derniere ~= nil and horloge - derniere < reglages.IntervalleMinRequetes then
		return nil
	end
	derniereRequete[joueur] = horloge
	return Plaquages.plaquer(joueur)
end

-- Départ du joueur : ses délais et protections sont oubliés.
function Plaquages.nettoyer(joueur: any)
	pretA[joueur] = nil
	protegeJusqua[joueur] = nil
	derniereRequete[joueur] = nil
	chutes[joueur] = nil
end

return Plaquages
