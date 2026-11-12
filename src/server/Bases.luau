--!strict
-- Bases des joueurs : un emplacement libre par joueur, avec une Forge.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local DecorBase = require(script.Parent.DecorBase)
local MachineForge = require(script.Parent.MachineForge)
local Revenus = require(ReplicatedStorage.Shared.Revenus)
local Bestiaire = require(ReplicatedStorage.Shared.Bestiaire)
local Fiche = require(ReplicatedStorage.Shared.Fiche)
local Promenade = require(ReplicatedStorage.Shared.Promenade)
local Donnees = require(ReplicatedStorage.Shared.Donnees)
local Modeleur = require(script.Parent.Modeleur)

local Bases = {}

-- Rappels des ProximityPrompts de raid (branchés par Principal sur Raids).
-- Le serveur ne fait confiance qu'aux objets fournis par Triggered.
type RappelVol = (declencheur: Player, proprietaire: any, numero: number) -> ()
local rappelVol: RappelVol? = nil

function Bases.surVol(rappel: RappelVol)
	rappelVol = rappel
end

local reglagesRaid = Config.Raid

local raretes: any = Config.Raretes -- indexé par des noms dynamiques
local BORD_BASES = 20 -- bord des bases côté Terres Sauvages (Z)
local HAUTEUR_BASE = 12 -- « dans la base » : jusqu'à 12 studs au-dessus du sol
local TAILLE_EXPOSEE = 3 -- diamètre des créatures exposées (leur vraie taille)
local NOMBRE_EMPLACEMENTS = 12

local COULEUR_SOL = Color3.fromRGB(110, 215, 80)
local COULEUR_FORGE = Color3.fromRGB(214, 102, 38)
local COULEUR_POTEAU = Color3.fromRGB(196, 190, 178) -- pierre, comme le muret
local COULEUR_LINTEAU = Color3.fromRGB(150, 98, 56) -- poutre en bois
local HAUTEUR_PORTE = 10
local LARGEUR_PORTE = 10

-- emplacement (numéro) -> joueur ; joueur -> { emplacement, modele }
local occupants: { [number]: any } = {}
type Base = { emplacement: number, modele: Model }
local basesParJoueur: { [any]: Base } = {}

-- Niveau d'agrandissement (1 à 3) et côté du sol de la base du joueur.
local function agrandissementDe(joueur: any): number
	local niveau = joueur:GetAttribute("Agrandissement")
	if type(niveau) ~= "number" or niveau ~= niveau or niveau < 1 then
		return 1
	end
	return math.min(math.floor(niveau), #Config.Bases.Tailles)
end

local function tailleDe(joueur: any): number
	return Config.Bases.Tailles[agrandissementDe(joueur)]
end

-- Nombre de places de la base du joueur (selon son agrandissement).
function Bases.capacite(joueur: any): number
	return Donnees.capacite(agrandissementDe(joueur))
end

local function dossierBases(): Folder
	local dossier = Workspace:FindFirstChild("Bases")
	if dossier and dossier:IsA("Folder") then
		return dossier
	end
	local nouveau = Instance.new("Folder")
	nouveau.Name = "Bases"
	nouveau.Parent = Workspace
	return nouveau
end

-- Les emplacements forment une ligne symétrique autour de l'origine, remplie
-- du centre vers les bords : +E/2, -E/2, +3E/2, -3E/2… (12 bases tiennent
-- dans le monde de 1 200 studs). Le bord avant de la base reste à
-- Z = BORD_BASES, quelle que soit sa taille.
local function centreEmplacement(numero: number, taille: number): Vector3
	local rang = math.ceil(numero / 2) - 0.5
	local signe = if numero % 2 == 1 then 1 else -1
	return Vector3.new(signe * rang * Config.Bases.Ecart, 0, BORD_BASES - taille / 2)
end

local function emplacementLibre(): number?
	for numero = 1, NOMBRE_EMPLACEMENTS do
		if occupants[numero] == nil then
			return numero
		end
	end
	return nil
end

local function construire(joueur: any, centre: Vector3): Model
	local TAILLE_SOL = tailleDe(joueur)
	local modele = Instance.new("Model")
	modele.Name = "Base_" .. tostring(joueur.Name)

	local sol = Instance.new("Part")
	sol.Name = "Sol"
	sol.Anchored = true
	sol.Size = Vector3.new(TAILLE_SOL, 1, TAILLE_SOL)
	sol.Position = centre - Vector3.new(0, 0.5, 0)
	sol.Color = COULEUR_SOL
	sol.Material = Enum.Material.Grass
	sol.TopSurface = Enum.SurfaceType.Smooth
	sol.Parent = modele

	local largeur = Config.Forge.DistanceForge.Largeur
	local forge = Instance.new("Part")
	forge.Name = "Forge"
	forge.Anchored = true
	forge.Size = Vector3.new(largeur, 1, largeur)
	-- Devant l'enclos, face à la porte (même place pour tous les joueurs).
	local devant = centre.Z + TAILLE_SOL / 2 + 6 + largeur / 2
	forge.Position = Vector3.new(centre.X, centre.Y + 0.5, devant)
	forge.Color = COULEUR_FORGE
	forge.Material = Enum.Material.Neon
	forge.TopSurface = Enum.SurfaceType.Smooth
	forge.Parent = modele
	MachineForge.construire(forge, centre.Y, joueur.UserId, joueur:GetAttribute("NiveauForge"))
	-- L'agrès se modernise quand le niveau de Forge change de palier.
	if typeof(joueur) == "Instance" then
		local connexion
		connexion = joueur:GetAttributeChangedSignal("NiveauForge"):Connect(function()
			if forge.Parent == nil then
				connexion:Disconnect()
				return
			end
			MachineForge.mettreAJour(
				forge,
				(joueur :: any).UserId,
				joueur:GetAttribute("NiveauForge")
			)
		end)
	end

	local apparition = Instance.new("Attachment")
	apparition.Name = "Apparition"
	apparition.Parent = sol
	apparition.Position = Vector3.new(0, 4, -8)

	-- Porte : piliers de pierre et poutre en bois au bord Z+ (côté Terres Sauvages).
	local bordZ = centre.Z + TAILLE_SOL / 2
	local porte = Instance.new("Model")
	porte.Name = "Porte"
	for _, cote in { -1, 1 } do
		local poteau = Instance.new("Part")
		poteau.Name = "Poteau"
		poteau.Anchored = true
		poteau.Size = Vector3.new(2.4, HAUTEUR_PORTE, 2.4)
		poteau.Position =
			Vector3.new(centre.X + cote * LARGEUR_PORTE / 2, centre.Y + HAUTEUR_PORTE / 2, bordZ)
		poteau.Color = COULEUR_POTEAU
		poteau.Material = Enum.Material.Cobblestone
		poteau.Parent = porte
	end
	local linteau = Instance.new("Part")
	linteau.Name = "Linteau"
	linteau.Anchored = true
	linteau.Size = Vector3.new(LARGEUR_PORTE + 4, 1.6, 1.8)
	linteau.Position = Vector3.new(centre.X, centre.Y + HAUTEUR_PORTE + 1, bordZ)
	linteau.Color = COULEUR_LINTEAU
	linteau.Material = Enum.Material.Wood
	linteau.Parent = porte
	porte.PrimaryPart = linteau
	porte.Parent = modele

	DecorBase.habiller(
		modele,
		centre,
		TAILLE_SOL,
		LARGEUR_PORTE,
		forge.Position,
		apparition.WorldPosition
	)

	modele:SetAttribute("ProprietaireId", joueur.UserId)
	modele.PrimaryPart = sol
	modele.Parent = dossierBases()
	return modele
end

-- Crée la base du joueur (ou renvoie celle qui existe déjà).
function Bases.creer(joueur: any): Model?
	local existante = basesParJoueur[joueur]
	if existante then
		return existante.modele
	end
	local libre = emplacementLibre()
	if libre == nil then
		warn("Bases : aucun emplacement libre pour " .. tostring(joueur.Name))
		return nil
	end
	local numero = libre :: number
	occupants[numero] = joueur
	local modele = construire(joueur, centreEmplacement(numero, tailleDe(joueur)))
	basesParJoueur[joueur] = { emplacement = numero, modele = modele }
	return modele
end

-- Supprime la base et libère l'emplacement.
function Bases.liberer(joueur: any)
	local base = basesParJoueur[joueur]
	if base == nil then
		return
	end
	basesParJoueur[joueur] = nil
	occupants[base.emplacement] = nil
	base.modele:Destroy()
end

-- Modèle de la base du joueur (lecture seule), ou nil.
function Bases.modeleDe(joueur: any): Model?
	local base = basesParJoueur[joueur]
	return if base then base.modele else nil
end

function Bases.forgeDe(joueur: any): BasePart?
	local base = basesParJoueur[joueur]
	if base == nil then
		return nil
	end
	local forge = base.modele:FindFirstChild("Forge")
	if forge and forge:IsA("BasePart") then
		return forge
	end
	return nil
end

-- Position d'apparition du joueur dans sa base.
function Bases.apparitionDe(joueur: any): CFrame?
	local base = basesParJoueur[joueur]
	if base == nil or base.modele.PrimaryPart == nil then
		return nil
	end
	local point = (base.modele.PrimaryPart :: BasePart):FindFirstChild("Apparition")
	if point and point:IsA("Attachment") then
		return point.WorldCFrame
	end
	return nil
end

-- Sol de la base du joueur, ou nil.
function Bases.solDe(joueur: any): BasePart?
	local base = basesParJoueur[joueur]
	if base == nil then
		return nil
	end
	local sol = base.modele:FindFirstChild("Sol")
	if sol and sol:IsA("BasePart") then
		return sol
	end
	return nil
end

-- Vrai si le personnage du joueur est vivant et au-dessus de `partie`,
-- à au plus `hauteurMax` studs de sa face supérieure (test de boîte).
local function estAuDessusDe(joueur: any, partieTrouvee: BasePart?, hauteurMax: number): boolean
	local personnageTrouve = joueur.Character
	if partieTrouvee == nil or typeof(personnageTrouve) ~= "Instance" then
		return false
	end
	local partie = partieTrouvee :: BasePart
	local personnage = personnageTrouve :: Instance
	local humanoide = personnage:FindFirstChildOfClass("Humanoid")
	local racineTrouvee = personnage:FindFirstChild("HumanoidRootPart")
	if
		humanoide == nil
		or humanoide.Health <= 0
		or racineTrouvee == nil
		or not racineTrouvee:IsA("BasePart")
	then
		return false
	end
	local racine = racineTrouvee :: BasePart
	local local_ = partie.CFrame:PointToObjectSpace(racine.Position)
	local demi = partie.Size / 2
	local hauteur = local_.Y - demi.Y
	return math.abs(local_.X) <= demi.X
		and math.abs(local_.Z) <= demi.Z
		and hauteur >= 0
		and hauteur <= hauteurMax
end

-- Vrai si le personnage du joueur est vivant et au-dessus de SA Forge.
function Bases.estSurSaForge(joueur: any): boolean
	return estAuDessusDe(joueur, Bases.forgeDe(joueur), Config.Forge.DistanceForge.Hauteur)
end

-- Vrai si le personnage du joueur est vivant et au-dessus du sol de SA base.
function Bases.estDansSaBase(joueur: any): boolean
	return estAuDessusDe(joueur, Bases.solDe(joueur), HAUTEUR_BASE)
end

-- Vrai si le personnage du joueur est vivant et au-dessus du sol de la base
-- de `proprietaire`.
function Bases.estDansBaseDe(joueur: any, proprietaire: any): boolean
	return estAuDessusDe(joueur, Bases.solDe(proprietaire), HAUTEUR_BASE)
end

-- Propriétaire de la base dans laquelle se trouve le joueur, ou nil.
function Bases.proprietaireDeBaseOu(joueur: any): any?
	for proprietaire in basesParJoueur do
		if Bases.estDansBaseDe(joueur, proprietaire) then
			return proprietaire
		end
	end
	return nil
end

-- Joueurs qui ont une base (y compris les faux joueurs des tests).
function Bases.joueurs(): { any }
	local liste = {}
	for joueur in basesParJoueur do
		table.insert(liste, joueur)
	end
	return liste
end

-- Petite créature exposée dans la base (couleur de rareté, yeux, « +N/s »)
-- avec le bouton « Voler » (pour les visiteurs, revérifié par le serveur).
local function creerCreatureExposee(
	proprietaire: any,
	numero: number,
	fiche: string,
	position: Vector3
): Model
	local infos = Fiche.lire(fiche) or ({ Rarete = "Commune", Taille = "Normale" } :: Fiche.Infos)
	local rarete = infos.Rarete
	-- Les grosses sont réduites dans la base pour tenir dans leur emplacement.
	-- Les grosses ne sont réduites que si la base est trop petite pour elles.
	local echelleMax = Config.Bases.EchelleMax[agrandissementDe(proprietaire)]
	local diametre = TAILLE_EXPOSEE * math.min(Fiche.echelle(infos.Taille), echelleMax)
	position += Vector3.new(0, (diametre - TAILLE_EXPOSEE) / 2, 0)
	local rgb = raretes.Couleurs[rarete] or { 255, 255, 255 }
	local couleur = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
	local precieuse = (table.find(raretes.Ordre, rarete) or 1) >= 3

	local modele = Instance.new("Model")
	modele.Name = "Creature_" .. rarete

	local corps = Instance.new("Part")
	corps.Name = "Corps"
	corps.Shape = Enum.PartType.Ball
	corps.Size = Vector3.one * diametre
	corps.Anchored = true
	corps.CanCollide = false
	corps.Color = couleur
	corps.Material = if precieuse then Enum.Material.Neon else Enum.Material.SmoothPlastic
	-- Le client la fait se promener autour de cette position (Shared.Promenade).
	corps.CFrame = CFrame.new(position)
	corps.Parent = modele

	local espece = Bestiaire.especeCreature(rarete, infos.Espece)
	Modeleur.construire(modele, corps, espece, diametre, couleur)
	Modeleur.aura(corps, couleur, table.find(raretes.Ordre, rarete) or 1)
	Modeleur.muter(modele, corps, infos.Mutation)

	local panneau = Instance.new("BillboardGui")
	panneau.Name = "Panneau"
	panneau.Size = UDim2.fromOffset(90, 30)
	panneau.StudsOffset = Vector3.new(0, diametre, 0)
	panneau.MaxDistance = 35
	panneau.Parent = corps
	local texte = Instance.new("TextLabel")
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = couleur
	texte.TextStrokeTransparency = 0
	texte.TextStrokeColor3 = Color3.new(0, 0, 0)
	texte.Text = `+{Revenus.parSeconde(fiche)}/s`
	texte.Parent = panneau

	-- Bouton « Voler » (tactile, touche, manette).
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Voler"
	prompt.ActionText = "Voler"
	prompt.ObjectText = Fiche.texte(rarete, infos.Taille, infos.Mutation)
	prompt.HoldDuration = reglagesRaid.DureeVol
	prompt.MaxActivationDistance = reglagesRaid.DistanceVol
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Parent = corps
	prompt.Triggered:Connect(function(declencheur: Player)
		local rappel = rappelVol
		if rappel then
			rappel(declencheur, proprietaire, numero)
		end
	end)

	modele.PrimaryPart = corps
	modele:SetAttribute("Rarete", rarete)
	modele:SetAttribute("Taille", infos.Taille)
	modele:SetAttribute("Mutation", infos.Mutation)
	modele:SetAttribute("Emplacement", numero)
	-- Promenade libre dans la base : centre, rayon et graine (déterministe).
	modele:SetAttribute("PromenadeCentre", position)
	modele:SetAttribute("PromenadeRayon", Promenade.Rayon)
	modele:SetAttribute("Graine", numero * 3.17 + (proprietaire.UserId % 97) * 0.61)
	return modele
end

-- Position actuelle d'une créature qui se promène (même calcul que le client).
function Bases.positionCreature(modele: Model, t: number): Vector3
	local centre = modele:GetAttribute("PromenadeCentre")
	local graine = modele:GetAttribute("Graine")
	local rayon = modele:GetAttribute("PromenadeRayon")
	if typeof(centre) ~= "Vector3" or type(graine) ~= "number" then
		return modele:GetPivot().Position
	end
	local etat = Promenade.etat(graine :: number, t, if type(rayon) == "number" then rayon else nil)
	return (centre :: Vector3) + Vector3.new(etat.X, etat.Saut, etat.Z)
end

-- Position (relative au centre de la base) de l'emplacement `numero`, sur
-- un seul niveau : colonnes de 5 places le long des deux bords X, de
-- l'extérieur vers l'intérieur (une colonne de plus par tranche de 10 places),
-- loin de la Forge (centre, Z +4..+12) et du point d'apparition (Z -8).
local INTERIEUR_MIN = 13 -- |X| minimal d'une colonne (la Forge reste dégagée)
local function positionEmplacement(numero: number, taille: number, capacite: number): Vector3
	-- Assez loin du bord pour que la promenade reste sur le sol.
	local BORD_EXPOSITION = taille / 2 - 2 - Promenade.Rayon
	local parColonne = 5
	local colonnes = math.max(1, math.ceil(capacite / (2 * parColonne)))
	local indice = numero - 1
	local groupe = math.floor(indice / (2 * parColonne)) -- 0 = colonnes extérieures
	local dansGroupe = indice % (2 * parColonne)
	local cote = if dansGroupe < parColonne then -1 else 1
	local rang = dansGroupe % parColonne
	local ecartColonnes = if colonnes > 1
		then math.max(0, BORD_EXPOSITION - INTERIEUR_MIN) / (colonnes - 1)
		else 0
	local x = cote * (BORD_EXPOSITION - groupe * ecartColonnes)
	local pas = (2 * BORD_EXPOSITION) / (parColonne - 1)
	local z = -BORD_EXPOSITION + rang * pas
	return Vector3.new(x, TAILLE_EXPOSEE / 2, z)
end

-- Achat de l'agrandissement suivant (sol plus grand, plus de places,
-- créatures exposées plus grandes). La base est reconstruite au même
-- emplacement ; l'appelant réaffiche les créatures. Renvoie true si acheté.
function Bases.agrandir(joueur: any): boolean
	local base = basesParJoueur[joueur]
	local niveau = agrandissementDe(joueur)
	if base == nil or niveau >= #Config.Bases.Tailles then
		return false
	end
	local prix = Config.Bases.PrixAgrandissement[niveau]
	local pieces = joueur:GetAttribute("Pieces")
	if type(prix) ~= "number" or type(pieces) ~= "number" or pieces ~= pieces or pieces < prix then
		return false
	end
	joueur:SetAttribute("Pieces", pieces - prix)
	joueur:SetAttribute("Agrandissement", niveau + 1)
	-- Nouvelle base d'abord (personne ne tombe), puis l'ancienne disparaît.
	local ancienne = base.modele
	base.modele = construire(joueur, centreEmplacement(base.emplacement, tailleDe(joueur)))
	ancienne:Destroy()
	return true
end

-- (Re)crée les créatures de la base, une par emplacement, chacune libre de
-- se promener autour de sa place.
function Bases.afficherCreatures(joueur: any, liste: { string })
	local base = basesParJoueur[joueur]
	if base == nil then
		return
	end
	local ancien = base.modele:FindFirstChild("CreaturesBase")
	if ancien then
		ancien:Destroy()
	end
	local dossier = Instance.new("Folder")
	dossier.Name = "CreaturesBase"
	local centre = base.modele:GetPivot().Position + Vector3.new(0, 0.5, 0) -- surface du sol

	-- Plus d'étages : un ancien dossier « Etages » éventuel disparaît.
	local anciensEtages = base.modele:FindFirstChild("Etages")
	if anciensEtages then
		anciensEtages:Destroy()
	end
	local capacite = Bases.capacite(joueur)

	-- Plus de socles : les créatures se promènent librement (Shared.Promenade).
	local anciensSocles = base.modele:FindFirstChild("Socles")
	if anciensSocles then
		anciensSocles:Destroy()
	end

	for numero, rarete in liste do
		if numero > capacite then
			break
		end
		if type(rarete) == "string" then
			creerCreatureExposee(
				joueur,
				numero,
				rarete,
				centre + positionEmplacement(numero, tailleDe(joueur), capacite)
			).Parent =
				dossier
		end
	end
	dossier.Parent = base.modele
end

return Bases
