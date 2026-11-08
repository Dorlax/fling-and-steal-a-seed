--!strict
-- Récolte, portage et dépôt des créatures, et revenus de la base (serveur).
-- Le client n'envoie aucune valeur : la récolte passe par le ProximityPrompt
-- « Récolter » (Triggered côté serveur) et le dépôt est automatique en entrant
-- dans sa base. Tout est vérifié ici.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Fiche = require(ReplicatedStorage.Shared.Fiche)
local Revenus = require(ReplicatedStorage.Shared.Revenus)
local Bases = require(script.Parent.Bases)
local Entrainement = require(script.Parent.Entrainement)
local Lancers = require(script.Parent.Lancers)
local Sauvegarde = require(script.Parent.Sauvegarde)
local TerresSauvages = require(script.Parent.TerresSauvages)

type Portee = {
	creature: Model,
	fiche: string, -- « Rarete[:Taille[:Espece]] » (voir Shared.Fiche)
	connexions: { RBXScriptConnection },
	pleineSignalee: boolean, -- « Base pleine ! » déjà envoyé pour cette visite
}

local Portage = {}

local reglages = Config.Creatures
local NOM_SOUDURE = "SoudurePortage"
local HAUTEUR_PORTAGE = 4.5 -- studs au-dessus du centre du personnage
local DEMI_TAILLE_CREATURE = 1.5 -- rayon d'une créature de taille Normale

local portees: { [any]: Portee } = {}

-- Définie plus bas (partagée par `recolter` et `porterVolee`).
local mettreEnPortage: (
	joueur: any,
	modele: Model,
	fiche: string,
	racine: BasePart,
	humanoide: Humanoid,
	corps: BasePart
) -> ()

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

-- Désoude la créature et la pose au sol sous `position`, « Récolter » réactivé.
local function poserAuSol(creature: Model, position: Vector3)
	for _, objet in creature:GetDescendants() do
		if objet.Name == NOM_SOUDURE and objet:IsA("WeldConstraint") then
			objet:Destroy()
		elseif objet:IsA("BasePart") then
			objet.Anchored = true
			objet.Massless = false
		end
	end
	local corps = creature.PrimaryPart
	local demi = if corps then corps.Size.Y / 2 else DEMI_TAILLE_CREATURE
	local hauteur = math.max(position.Y - DEMI_TAILLE_CREATURE, demi)
	creature:PivotTo(CFrame.new(position.X, hauteur, position.Z))
	local prompt = promptDe(creature)
	if prompt then
		prompt.Enabled = true
	end
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
	poserAuSol(creature, position)
	Lancers.remettreAuSol(joueur, creature)
end

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

-- Vrai si le joueur porte une créature (état serveur et attribut).
function Portage.porte(joueur: any): boolean
	return portees[joueur] ~= nil and joueur:GetAttribute("Porte") ~= nil
end

-- Plaquage ou coup de monstre : la créature portée tombe à DistanceChute studs
-- du joueur, du côté opposé à `depuis` (position du plaqueur ou du monstre).
-- Elle devient « libre » : récoltable par n'importe qui, hors des créatures au
-- sol de tout joueur, et disparaît après DureeVieLachee si personne ne la
-- ramasse. Renvoie la créature, ou nil.
function Portage.lacher(joueur: any, depuis: Vector3?, maintenant: number?): Model?
	local racine = racineEtHumanoide(joueur)
	local porteeOuNil = oublier(joueur)
	if porteeOuNil == nil then
		return nil
	end
	local creature = (porteeOuNil :: Portee).creature
	local centre = if racine then racine.Position else creature:GetPivot().Position

	local direction: Vector3? = nil
	if depuis ~= nil then
		local ecart = centre - depuis
		local plat = Vector3.new(ecart.X, 0, ecart.Z)
		if plat.Magnitude > 0.01 then
			direction = plat.Unit
		end
	end
	if direction == nil and racine ~= nil then
		local regard = racine.CFrame.LookVector
		local plat = Vector3.new(-regard.X, 0, -regard.Z)
		if plat.Magnitude > 0.01 then
			direction = plat.Unit
		end
	end
	local sens = direction or Vector3.zAxis
	poserAuSol(creature, centre + sens * Config.Plaquage.DistanceChute)

	local duree = Config.Plaquage.DureeVieLachee
	local instant = if estNombreFini(maintenant)
		then maintenant :: number
		else Workspace:GetServerTimeNow()
	local disparaitA = instant + duree
	creature:SetAttribute("Libre", true)
	creature:SetAttribute("DisparaitA", disparaitA)
	creature.Parent = TerresSauvages.dossierCreatures()
	task.delay(duree, function()
		if
			creature.Parent == TerresSauvages.dossierCreatures()
			and creature:GetAttribute("Libre") == true
			and creature:GetAttribute("DisparaitA") == disparaitA
		then
			creature:Destroy()
		end
	end)
	return creature
end

-- Plaquage : même comportement que `lacher`.
function Portage.lacherParPlaquage(joueur: any, depuis: Vector3?, maintenant: number?): Model?
	return Portage.lacher(joueur, depuis, maintenant)
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
	-- Créature libre (lâchée par un plaquage) : n'importe qui ; sinon le propriétaire.
	local libre = modele:GetAttribute("Libre") == true
	if not libre and modele:GetAttribute("Proprietaire") ~= joueur.UserId then
		return false
	end
	if portees[joueur] ~= nil or joueur:GetAttribute("Porte") ~= nil then
		return false
	end
	if modele:GetAttribute("EnCroissance") == true then
		return false -- elle sort encore de terre
	end
	local attributRarete = modele:GetAttribute("Rarete")
	local attributTaille = modele:GetAttribute("Taille")
	local attributEspece = modele:GetAttribute("Espece")
	if type(attributRarete) ~= "string" then
		return false
	end
	local fiche = Fiche.ecrire(
		attributRarete :: string,
		if type(attributTaille) == "string" then attributTaille :: string else nil,
		if type(attributEspece) == "string" then attributEspece :: string else nil
	)
	if not Fiche.valide(fiche) then
		return false
	end
	local racineOuNil, humanoideOuNil = racineEtHumanoide(joueur)
	if racineOuNil == nil or humanoideOuNil == nil then
		return false
	end
	local racine = racineOuNil :: BasePart
	local humanoide = humanoideOuNil :: Humanoid
	if humanoide.Health <= 0 then
		return false
	end
	local corpsOuNil = modele.PrimaryPart
	if corpsOuNil == nil then
		return false
	end
	local corps = corpsOuNil :: BasePart
	if (racine.Position - modele:GetPivot().Position).Magnitude > reglages.DistanceRecolte then
		return false
	end

	-- Portage : au-dessus de la tête, soudée au personnage.
	if libre then
		modele:SetAttribute("Libre", nil)
		modele:SetAttribute("DisparaitA", nil)
		modele:SetAttribute("Proprietaire", joueur.UserId)
	end
	Lancers.retirerDuSol(joueur, modele)
	mettreEnPortage(joueur, modele, fiche, racine, humanoide, corps)
	return true
end

-- Raid : le voleur porte aussitôt une créature identique à une créature
-- récoltée (attribut Volee). Refusé s'il porte déjà ou s'il est mort.
function Portage.porterVolee(voleur: any, fiche: any): boolean
	if not Fiche.valide(fiche) then
		return false
	end
	if portees[voleur] ~= nil or voleur:GetAttribute("Porte") ~= nil then
		return false
	end
	local racineOuNil, humanoideOuNil = racineEtHumanoide(voleur)
	if racineOuNil == nil or humanoideOuNil == nil or (humanoideOuNil :: Humanoid).Health <= 0 then
		return false
	end
	local racine = racineOuNil :: BasePart
	local modele = Lancers.creerCreaturePortable(voleur, fiche, racine.Position)
	local corps = modele.PrimaryPart
	if corps == nil then
		modele:Destroy()
		return false
	end
	mettreEnPortage(voleur, modele, fiche, racine, humanoideOuNil :: Humanoid, corps :: BasePart)
	return true
end

-- Soude la créature au-dessus de la tête du joueur et enregistre le portage
-- (connexions de mort, attribut Porte, vitesse réduite).
function mettreEnPortage(
	joueur: any,
	modele: Model,
	fiche: string,
	racine: BasePart,
	humanoide: Humanoid,
	corps: BasePart
)
	local prompt = promptDe(modele)
	if prompt then
		prompt.Enabled = false
	end
	-- Les grosses créatures sont portées plus haut (au-dessus de la tête).
	local hauteur = HAUTEUR_PORTAGE + corps.Size.Y / 2 - DEMI_TAILLE_CREATURE
	modele:PivotTo(racine.CFrame * CFrame.new(0, hauteur, 0))
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
	-- Créature récoltée : hors du personnage, elle survit à sa destruction et
	-- peut retomber. Créature volée : dans le personnage du voleur (visible
	-- comme portée par lui) ; elle est sortie du personnage dès qu'elle tombe.
	local personnage = racine.Parent :: Instance
	modele.Parent = if modele:GetAttribute("Volee") == true then personnage else Workspace

	local portee: Portee = {
		creature = modele,
		fiche = fiche,
		connexions = {},
		pleineSignalee = false,
	}
	portees[joueur] = portee
	-- Attribut Porte = rareté seule (la fiche complète reste côté serveur).
	local infos = Fiche.lire(fiche)
	joueur:SetAttribute("Porte", if infos then infos.Rarete else fiche)
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
	table.insert(
		portee.connexions,
		personnage.AncestryChanged:Connect(function()
			if personnage.Parent == nil then
				-- Créature volée détruite avec le personnage : on l'oublie seulement.
				if modele:IsDescendantOf(personnage) then
					if portees[joueur] == portee then
						oublier(joueur)
					end
					return
				end
				surMort()
			end
		end)
	)
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
	if not Sauvegarde.ajouterCreature(joueur, portee.fiche) then
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
