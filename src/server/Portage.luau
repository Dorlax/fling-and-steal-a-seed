--!strict
-- Récolte, portage et dépôt des créatures, et revenus de la base (serveur).
-- Le client n'envoie aucune valeur : la récolte passe par le ProximityPrompt
-- « Récolter » (Triggered côté serveur) et le dépôt est automatique en entrant
-- dans sa base. Tout est vérifié ici.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Revenus = require(ReplicatedStorage.Shared.Revenus)
local Bases = require(script.Parent.Bases)
local Entrainement = require(script.Parent.Entrainement)
local Lancers = require(script.Parent.Lancers)
local Sauvegarde = require(script.Parent.Sauvegarde)
local TerresSauvages = require(script.Parent.TerresSauvages)

type Portee = {
	creature: Model,
	rarete: string,
	connexions: { RBXScriptConnection },
	pleineSignalee: boolean, -- « Base pleine ! » déjà envoyé pour cette visite
}

local Portage = {}

local reglages = Config.Creatures
local NOM_SOUDURE = "SoudurePortage"
local HAUTEUR_PORTAGE = 4.5 -- studs au-dessus du centre du personnage
local DEMI_TAILLE_CREATURE = 1.5 -- rayon de la créature au sol

local portees: { [any]: Portee } = {}

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

local function promptDe(creature: Model): ProximityPrompt?
	local prompt = creature:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt and prompt:IsA("ProximityPrompt") then
		return prompt
	end
	return nil
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

-- Oublie la créature portée (connexions, attribut, vitesse) et la renvoie.
local function oublier(joueur: any): Portee?
	local portee = portees[joueur]
	if portee == nil then
		return nil
	end
	portees[joueur] = nil
	for _, connexion in portee.connexions do
		connexion:Disconnect()
	end
	joueur:SetAttribute("Porte", nil)
	Entrainement.appliquerVitesse(joueur)
	return portee
end

-- La créature retombe au sol à la position du personnage et redevient
-- récoltable par son propriétaire.
local function lacherAuSol(joueur: any)
	local racine = racineEtHumanoide(joueur)
	local porteeOuNil = oublier(joueur)
	if porteeOuNil == nil then
		return
	end
	local creature = (porteeOuNil :: Portee).creature
	local position = if racine then racine.Position else creature:GetPivot().Position
	for _, objet in creature:GetDescendants() do
		if objet.Name == NOM_SOUDURE and objet:IsA("WeldConstraint") then
			objet:Destroy()
		elseif objet:IsA("BasePart") then
			objet.Anchored = true
			objet.Massless = false
		end
	end
	local hauteur = math.max(position.Y - DEMI_TAILLE_CREATURE, DEMI_TAILLE_CREATURE)
	creature:PivotTo(CFrame.new(position.X, hauteur, position.Z))
	local prompt = promptDe(creature)
	if prompt then
		prompt.Enabled = true
	end
	Lancers.remettreAuSol(joueur, creature)
end

-- Récolte une créature au sol. Renvoie true si le joueur la porte désormais.
function Portage.recolter(joueur: any, creature: any): boolean
	if typeof(creature) ~= "Instance" or not creature:IsA("Model") then
		return false
	end
	local modele = creature :: Model
	if modele.Parent ~= TerresSauvages.dossierCreatures() then
		return false -- déjà portée ou disparue
	end
	if modele:GetAttribute("Proprietaire") ~= joueur.UserId then
		return false
	end
	if portees[joueur] ~= nil or joueur:GetAttribute("Porte") ~= nil then
		return false
	end
	local attributRarete = modele:GetAttribute("Rarete")
	if type(attributRarete) ~= "string" or not table.find(Config.Raretes.Ordre, attributRarete) then
		return false
	end
	local rarete = attributRarete :: string
	local racineOuNil, humanoideOuNil = racineEtHumanoide(joueur)
	if racineOuNil == nil or humanoideOuNil == nil then
		return false
	end
	local racine = racineOuNil :: BasePart
	local humanoide = humanoideOuNil :: Humanoid
	if humanoide.Health <= 0 then
		return false
	end
	local corps = modele.PrimaryPart
	if corps == nil then
		return false
	end
	if (racine.Position - modele:GetPivot().Position).Magnitude > reglages.DistanceRecolte then
		return false
	end

	-- Portage : au-dessus de la tête, soudée au personnage.
	Lancers.retirerDuSol(joueur, modele)
	local prompt = promptDe(modele)
	if prompt then
		prompt.Enabled = false
	end
	modele:PivotTo(racine.CFrame * CFrame.new(0, HAUTEUR_PORTAGE, 0))
	for _, objet in modele:GetDescendants() do
		if objet:IsA("BasePart") then
			objet.CanCollide = false
			objet.Massless = true
			local soudure = Instance.new("WeldConstraint")
			soudure.Name = NOM_SOUDURE
			soudure.Part0 = objet
			soudure.Part1 = if objet == corps then racine else corps
			soudure.Parent = objet
		end
	end
	for _, objet in modele:GetDescendants() do
		if objet:IsA("BasePart") then
			objet.Anchored = false
		end
	end
	-- Hors du personnage : elle survit à sa destruction et peut retomber.
	modele.Parent = Workspace

	local portee: Portee = {
		creature = modele,
		rarete = rarete,
		connexions = {},
		pleineSignalee = false,
	}
	portees[joueur] = portee
	joueur:SetAttribute("Porte", rarete)
	Entrainement.appliquerVitesse(joueur)

	-- Mort (ou personnage retiré) en portant : la créature retombe.
	local hum = humanoide :: Humanoid
	local function surMort()
		if portees[joueur] == portee then
			lacherAuSol(joueur)
		end
	end
	table.insert(portee.connexions, hum.Died:Connect(surMort))
	table.insert(
		portee.connexions,
		hum:GetPropertyChangedSignal("Health"):Connect(function()
			if hum.Health <= 0 then
				surMort()
			end
		end)
	)
	local personnage = racine.Parent :: Instance
	table.insert(
		portee.connexions,
		personnage.AncestryChanged:Connect(function()
			if personnage.Parent == nil then
				surMort()
			end
		end)
	)
	return true
end

-- Dépose la créature portée si le joueur est dans SA base (appelé à chaque tick).
function Portage.verifierDepot(joueur: any)
	local portee = portees[joueur]
	if portee == nil then
		return
	end
	if not Bases.estDansSaBase(joueur) then
		portee.pleineSignalee = false
		return
	end
	if not Sauvegarde.ajouterCreature(joueur, portee.rarete) then
		if not portee.pleineSignalee then
			portee.pleineSignalee = true
			envoyerMessage(joueur, "Base pleine !")
		end
		return
	end
	oublier(joueur)
	portee.creature:Destroy()
	Bases.afficherCreatures(joueur, Sauvegarde.creaturesDe(joueur))
	envoyerMessage(joueur, "Créature déposée !")
end

-- Un tick de revenus : Pieces += somme des revenus des créatures de la base.
function Portage.tickRevenus(joueur: any)
	local gain = Revenus.total(Sauvegarde.creaturesDe(joueur))
	if gain <= 0 then
		return
	end
	joueur:SetAttribute("Pieces", Revenus.ajouter(joueur:GetAttribute("Pieces"), gain))
end

-- Départ du joueur : la créature portée disparaît.
function Portage.nettoyer(joueur: any)
	local portee = portees[joueur]
	if portee == nil then
		return
	end
	portees[joueur] = nil
	for _, connexion in portee.connexions do
		connexion:Disconnect()
	end
	portee.creature:Destroy()
end

return Portage
