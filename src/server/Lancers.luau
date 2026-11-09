--!strict
-- Lancer de graine, côté serveur.
-- Flux en deux temps : DemarrerJauge puis LacherJauge. Le client n'envoie
-- AUCUNE valeur : temps, distance, zone et rareté sont calculés ici.
-- `maintenant` et `aleatoire` (optionnels) servent uniquement aux tests en jeu ;
-- les gestionnaires des RemoteEvents ne les transmettent jamais.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Jauge = require(ReplicatedStorage.Shared.Jauge)
local Lancer = require(ReplicatedStorage.Shared.Lancer)
local Bases = require(script.Parent.Bases)
local TerresSauvages = require(script.Parent.TerresSauvages)
local Bestiaire = require(ReplicatedStorage.Shared.Bestiaire)
local Fiche = require(ReplicatedStorage.Shared.Fiche)
local Bonus = require(ReplicatedStorage.Shared.Bonus)
local Biomes = require(ReplicatedStorage.Shared.Biomes)
local Modeleur = require(script.Parent.Modeleur)
local Classements = require(script.Parent.Classements)
local Evenements = require(script.Parent.Evenements)
local Evenement = require(ReplicatedStorage.Shared.Evenement)

export type Resultat = {
	Distance: number,
	Couleur: string,
	Message: string,
	Zone: string,
	Rarete: string,
	Taille: string?, -- Normale, Grande, Geante, Colossale ou Titan
	Espece: string?,
	Mutation: string?, -- Doree, Cristal, Arcenciel (rare)
	Graine: string?, -- graine lancée
}

type Etat = {
	debut: number?, -- jauge en cours depuis ce moment
	dernierLacher: number?, -- pour DelaiEntreLancers
	creatures: { Model },
}

local Lancers = {}

-- Appelé quand un joueur active le bouton « Récolter » d'une créature
-- (branché par Principal sur Portage ; le joueur n'envoie aucune valeur).
type RappelRecolte = (joueur: Player, creature: Model) -> ()
local rappelRecolte: RappelRecolte? = nil

function Lancers.surRecolte(rappel: RappelRecolte)
	rappelRecolte = rappel
end

local reglages = Config.Lancer
local raretes: any = Config.Raretes -- indexé par des noms dynamiques
local DUREE_VOL = 1 -- secondes de vol de la graine (effet visuel)
local HAUTEUR_VOL = 25
local TAILLE_CREATURE = 3

local etats: { [any]: Etat } = {}
local hasard = Random.new()

local function etatDe(joueur: any): Etat
	local etat = etats[joueur]
	if etat == nil then
		etat = { debut = nil, dernierLacher = nil, creatures = {} }
		etats[joueur] = etat
	end
	return etat :: Etat
end

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

local function couleurRarete(rarete: string): Color3
	local rgb = raretes.Couleurs[rarete] or { 255, 255, 255 }
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local function pingDe(joueur: any): number
	local ok, ping = pcall(function()
		return joueur:GetNetworkPing()
	end)
	if ok and estNombreFini(ping) and ping > 0 then
		return ping
	end
	return 0
end

-- Point de départ : bord de la base côté +Z, au niveau du sol.
local function bordDeBase(modele: Model): Vector3
	local centre = modele:GetPivot().Position
	return Vector3.new(centre.X, 0, centre.Z + TerresSauvages.BordBases)
end

local function racineDe(joueur: any): BasePart?
	local personnage = joueur.Character
	if typeof(personnage) ~= "Instance" then
		return nil
	end
	local racine = (personnage :: Instance):FindFirstChild("HumanoidRootPart")
	if racine and racine:IsA("BasePart") then
		return racine
	end
	return nil
end

-- Garde au plus MaxCreaturesAuSol créatures : détruit les plus anciennes.
local function limiterCreatures(etat: Etat)
	local vivantes = {}
	for _, creature in etat.creatures do
		if creature.Parent ~= nil then
			table.insert(vivantes, creature)
		end
	end
	while #vivantes > reglages.MaxCreaturesAuSol do
		local ancienne = table.remove(vivantes, 1) :: Model
		ancienne:Destroy()
	end
	etat.creatures = vivantes
end

local function creerCreature(
	joueur: any,
	resultat: Resultat,
	point: Vector3,
	pousse: boolean?
): Model
	local couleur = couleurRarete(resultat.Rarete)
	local precieuse = (table.find(raretes.Ordre, resultat.Rarete) or 1) >= 3
	local taille = resultat.Taille or "Normale"
	local diametre = TAILLE_CREATURE * Fiche.echelle(taille)

	local modele = Instance.new("Model")
	modele.Name = "Creature"

	local corps = Instance.new("Part")
	corps.Name = "Corps"
	corps.Shape = Enum.PartType.Ball
	corps.Size = Vector3.one * diametre
	corps.Anchored = true
	corps.CanCollide = false
	corps.Color = couleur
	corps.Material = if precieuse then Enum.Material.Neon else Enum.Material.SmoothPlastic
	corps.CFrame = CFrame.new(point + Vector3.new(0, diametre / 2, 0))
	corps.Parent = modele

	-- Forme en blocs de l'espèce (le Corps devient invisible), à sa taille.
	local espece = Bestiaire.especeCreature(resultat.Rarete, resultat.Espece)
	Modeleur.construire(modele, corps, espece, diametre, couleur)
	Modeleur.aura(corps, couleur, table.find(raretes.Ordre, resultat.Rarete) or 1)
	Modeleur.muter(modele, corps, resultat.Mutation)

	if precieuse then
		local lumiere = Instance.new("PointLight")
		lumiere.Color = couleur
		lumiere.Range = 12
		lumiere.Brightness = 2
		lumiere.Parent = corps
	end

	local panneau = Instance.new("BillboardGui")
	panneau.Name = "Panneau"
	panneau.Size = UDim2.fromOffset(160, 40)
	panneau.StudsOffset = Vector3.new(0, diametre + 1, 0)
	panneau.MaxDistance = 250
	panneau.Parent = corps
	local texte = Instance.new("TextLabel")
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = couleur
	texte.TextStrokeTransparency = 0
	texte.TextStrokeColor3 = Color3.new(0, 0, 0)
	texte.Text = Fiche.texte(resultat.Rarete, taille, resultat.Mutation)
	texte.Parent = panneau

	-- Bouton « Récolter » (tactile, touche, manette) ; validé par le serveur.
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Recolter"
	prompt.ActionText = "Récolter"
	prompt.ObjectText = texte.Text
	prompt.HoldDuration = Config.Creatures.DureeRecolte
	prompt.MaxActivationDistance = Config.Creatures.DistanceRecolte
	prompt.RequiresLineOfSight = false
	prompt.Parent = corps
	prompt.Triggered:Connect(function(declencheur: Player)
		local rappel = rappelRecolte
		if rappel then
			rappel(declencheur, modele)
		end
	end)

	modele.PrimaryPart = corps
	modele:SetAttribute("Rarete", resultat.Rarete)
	modele:SetAttribute("Taille", taille)
	modele:SetAttribute("Espece", espece.Nom)
	modele:SetAttribute("Mutation", resultat.Mutation)
	modele:SetAttribute("Zone", resultat.Zone)
	modele:SetAttribute("Proprietaire", joueur.UserId)
	modele:SetAttribute("Distance", resultat.Distance)
	modele.Parent = TerresSauvages.dossierCreatures()
	if pousse ~= false then
		Modeleur.pousser(modele)
	end
	return modele
end

-- Graine lumineuse qui vole en arc, puis créature au point d'atterrissage.
local function envoyerGraine(
	joueur: any,
	etat: Etat,
	resultat: Resultat,
	depart: Vector3,
	point: Vector3
)
	local graine = Instance.new("Part")
	graine.Name = "Graine"
	graine.Shape = Enum.PartType.Ball
	graine.Size = Vector3.one * 1.2
	graine.Anchored = true
	graine.CanCollide = false
	graine.CanQuery = false
	graine.Material = Enum.Material.Neon
	graine.Color = Color3.fromRGB(255, 240, 150)
	graine.Position = depart
	local lumiere = Instance.new("PointLight")
	lumiere.Color = graine.Color
	lumiere.Range = 10
	lumiere.Parent = graine
	graine.Parent = Workspace

	task.spawn(function()
		local ecoule = 0
		while ecoule < DUREE_VOL do
			ecoule += RunService.Heartbeat:Wait()
			local a = math.min(ecoule / DUREE_VOL, 1)
			local arc = 4 * a * (1 - a) * HAUTEUR_VOL
			graine.Position = depart:Lerp(point, a) + Vector3.new(0, arc, 0)
		end
		graine:Destroy()
		-- Joueur parti pendant le vol : pas de créature.
		if etats[joueur] ~= etat then
			return
		end
		table.insert(etat.creatures, creerCreature(joueur, resultat, point))
		limiterCreatures(etat)
	end)
end

-- Début de jauge. Renvoie true si la jauge démarre.
function Lancers.demarrer(joueur: any, maintenant: number?): boolean
	local instant = if estNombreFini(maintenant) then maintenant :: number else os.clock()
	if Bases.modeleDe(joueur) == nil then
		return false
	end
	local etat = etatDe(joueur)
	local debut = etat.debut
	if debut ~= nil then
		if instant - debut <= reglages.DureeMaxJauge then
			return false -- jauge déjà en cours
		end
		etat.debut = nil -- jauge abandonnée : annulée
	end
	local dernier = etat.dernierLacher
	if dernier ~= nil and instant - dernier < reglages.DelaiEntreLancers then
		return false
	end
	etat.debut = instant
	return true
end

-- Lâcher de jauge : calcule tout côté serveur. Renvoie le résultat, ou nil.
function Lancers.lacher(joueur: any, maintenant: number?, aleatoire: number?): Resultat?
	local etat = etats[joueur]
	if etat == nil or etat.debut == nil then
		return nil
	end
	local instant = if estNombreFini(maintenant) then maintenant :: number else os.clock()
	local debut = etat.debut :: number
	etat.debut = nil

	local t = instant - debut - math.min(pingDe(joueur), reglages.CompensationPingMax)
	if t > reglages.DureeMaxJauge then
		return nil
	end
	local modele = Bases.modeleDe(joueur)
	if modele == nil then
		return nil
	end
	etat.dernierLacher = instant

	local palier = Jauge.palier(Jauge.position(t))
	local evenement = Evenements.actuel()
	-- Vent porteur : studs en plus, sans dépasser la fin du dernier biome.
	local distance = math.min(
		Lancer.distance(joueur:GetAttribute("Force"), palier.Bonus)
			+ Evenement.bonusDistance(evenement),
		Biomes.distanceMax()
	)
	local zone = Lancer.zone(distance)
	local tirage = if estNombreFini(aleatoire) then aleatoire :: number else hasard:NextNumber()
	-- Graine équipée (ou celle offerte par la roue pour ce lancer, si meilleure).
	local offerte = joueur:GetAttribute("LancerGraine")
	local idGraine = Bonus.meilleureGraine(joueur:GetAttribute("Graine"), offerte)
	if offerte ~= nil then
		joueur:SetAttribute("LancerGraine", nil)
	end
	local graine = Bonus.graine(idGraine)
	local rarete = Lancer.tirerRareteChance(zone, tirage, graine.Chance)
	local biome = Biomes.index(distance)
	local bonusMutation = graine.Mutation
		* (if evenement ~= nil then Config.Mutations.BonusEvenement else 1)
	local resultat: Resultat = {
		Distance = distance,
		Couleur = palier.Couleur,
		Message = palier.Message,
		Zone = zone,
		Rarete = rarete,
		-- Taille et espèce : tirages serveur indépendants de la rareté.
		-- Graines géantes et graine équipée : taux de taille de biomes plus loin.
		Taille = Fiche.tirerTaille(
			hasard:NextNumber(),
			biome + Evenement.bonusTailles(evenement) + graine.Tailles
		),
		Espece = Bestiaire.tirerEspece(rarete, hasard:NextNumber(), biome).Nom,
		Mutation = Fiche.tirerMutation(hasard:NextNumber(), bonusMutation),
		Graine = idGraine,
	}

	Classements.noterBiome(joueur, biome)

	local bord = bordDeBase(modele :: Model)
	local point = bord + Vector3.new(0, 0, distance)
	local racine = racineDe(joueur)
	local depart = if racine then racine.Position else bord + Vector3.new(0, 5, 0)
	envoyerGraine(joueur, etat, resultat, depart, point)
	return resultat
end

-- Gestionnaire de DemarrerJauge : tout argument du client est ignoré.
-- (Le chargement des données est vérifié par Principal.)
function Lancers.traiterDemarrer(joueur: any): boolean
	local personnage = joueur.Character
	if typeof(personnage) ~= "Instance" then
		return false
	end
	local humanoide = (personnage :: Instance):FindFirstChildOfClass("Humanoid")
	if humanoide == nil or humanoide.Health <= 0 then
		return false
	end
	return Lancers.demarrer(joueur)
end

-- Gestionnaire de LacherJauge : tout argument du client est ignoré.
function Lancers.traiterLacher(joueur: any): Resultat?
	local resultat = Lancers.lacher(joueur)
	if resultat and typeof(joueur) == "Instance" and joueur:IsA("Player") then
		local remote = ReplicatedStorage:FindFirstChild("ResultatLancer")
		if remote and remote:IsA("RemoteEvent") then
			remote:FireClient(joueur, resultat)
		end
	end
	return resultat
end

-- Crée une créature identique à une créature récoltée (bouton « Récolter »,
-- Rarete, Proprietaire = joueur), marquée Volee, au point donné (raid).
-- Elle n'entre pas dans la liste « au sol » du joueur.
function Lancers.creerCreaturePortable(joueur: any, fiche: string, point: Vector3): Model
	local infos = Fiche.lire(fiche) or ({ Rarete = "Commune", Taille = "Normale" } :: Fiche.Infos)
	local modele = creerCreature(joueur, {
		Distance = 0,
		Couleur = "",
		Message = "",
		Zone = "Raid",
		Rarete = infos.Rarete,
		Taille = infos.Taille,
		Espece = infos.Espece,
		Mutation = infos.Mutation,
	}, point, false)
	modele:SetAttribute("Volee", true)
	return modele
end

-- Sort une créature de la liste « au sol » du joueur (elle est portée) :
-- elle n'est plus détruite par MaxCreaturesAuSol.
function Lancers.retirerDuSol(joueur: any, creature: Model)
	local etat = etats[joueur]
	if etat == nil then
		return
	end
	local index = table.find(etat.creatures, creature)
	if index then
		table.remove(etat.creatures, index)
	end
end

-- Remet une créature dans la liste « au sol » du joueur (et dans le dossier
-- des créatures). Joueur parti : la créature est détruite.
function Lancers.remettreAuSol(joueur: any, creature: Model)
	local etat = etats[joueur]
	if etat == nil then
		creature:Destroy()
		return
	end
	creature.Parent = TerresSauvages.dossierCreatures()
	if not table.find(etat.creatures, creature) then
		table.insert(etat.creatures, creature)
	end
	limiterCreatures(etat)
end

-- Départ du joueur : ses créatures au sol disparaissent.
function Lancers.nettoyer(joueur: any)
	local etat = etats[joueur]
	if etat == nil then
		return
	end
	etats[joueur] = nil
	for _, creature in etat.creatures do
		creature:Destroy()
	end
end

return Lancers
