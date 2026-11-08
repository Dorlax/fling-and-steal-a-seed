--!strict
-- Bases des joueurs : un emplacement libre par joueur, avec une Forge.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Raid = require(ReplicatedStorage.Shared.Raid)
local Revenus = require(ReplicatedStorage.Shared.Revenus)
local Bestiaire = require(ReplicatedStorage.Shared.Bestiaire)
local Fiche = require(ReplicatedStorage.Shared.Fiche)
local Modeleur = require(script.Parent.Modeleur)

local Bases = {}

-- Rappels des ProximityPrompts de raid (branchés par Principal sur Raids).
-- Le serveur ne fait confiance qu'aux objets fournis par Triggered.
type RappelVol = (declencheur: Player, proprietaire: any, numero: number) -> ()
type RappelVerrou = (declencheur: Player, proprietaire: any) -> ()
local rappelVol: RappelVol? = nil
local rappelVerrou: RappelVerrou? = nil

function Bases.surVol(rappel: RappelVol)
	rappelVol = rappel
end

function Bases.surVerrou(rappel: RappelVerrou)
	rappelVerrou = rappel
end

local reglagesRaid = Config.Raid

local raretes: any = Config.Raretes -- indexé par des noms dynamiques
local BORD_BASES = 20 -- bord des bases côté Terres Sauvages (Z)
local HAUTEUR_BASE = 12 -- « dans la base » : jusqu'à 12 studs au-dessus du sol
local TAILLE_EXPOSEE = 3 -- diamètre des créatures exposées (leur vraie taille)
local HAUTEUR_SOCLE = 1.4 -- les créatures exposées trônent sur un socle
local NOMBRE_EMPLACEMENTS = 12

local COULEUR_SOL = Color3.fromRGB(110, 215, 80)
local COULEUR_FORGE = Color3.fromRGB(214, 102, 38)
local COULEUR_POTEAU = Color3.fromRGB(255, 120, 200)
local COULEUR_LINTEAU = Color3.fromRGB(255, 220, 60)
local COULEUR_BOUTON = Color3.fromRGB(60, 200, 255)
local COULEUR_BOUCLIER = Color3.fromRGB(255, 50, 50)
local HAUTEUR_PORTE = 10
local LARGEUR_PORTE = 10
local TRANSPARENCE_BOUCLIER = 0.75

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

-- Les emplacements forment une ligne centrée sur l'origine : 0, +90, -90…
-- Le bord avant de la base reste à Z = BORD_BASES, quelle que soit sa taille.
local function centreEmplacement(numero: number, taille: number): Vector3
	local rang = math.floor(numero / 2)
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
	forge.Position = centre + Vector3.new(0, 0.5, 8)
	forge.Color = COULEUR_FORGE
	forge.Material = Enum.Material.Neon
	forge.TopSurface = Enum.SurfaceType.Smooth
	forge.Parent = modele

	local panneau = Instance.new("BillboardGui")
	panneau.Name = "Panneau"
	panneau.Size = UDim2.fromOffset(200, 40)
	panneau.StudsOffset = Vector3.new(0, 5, 0)
	panneau.AlwaysOnTop = false
	panneau.Parent = forge
	local texte = Instance.new("TextLabel")
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.GothamBold
	texte.TextScaled = true
	texte.TextColor3 = Color3.new(1, 1, 1)
	texte.TextStrokeTransparency = 0.4
	texte.Text = "Forge de " .. tostring(joueur.Name)
	texte.Parent = panneau

	local apparition = Instance.new("Attachment")
	apparition.Name = "Apparition"
	apparition.Parent = sol
	apparition.Position = Vector3.new(0, 4, -8)

	-- Porte : arche cartoon au bord Z+ (côté Terres Sauvages).
	local bordZ = centre.Z + TAILLE_SOL / 2
	local porte = Instance.new("Model")
	porte.Name = "Porte"
	for _, cote in { -1, 1 } do
		local poteau = Instance.new("Part")
		poteau.Name = "Poteau"
		poteau.Anchored = true
		poteau.Size = Vector3.new(1.5, HAUTEUR_PORTE, 1.5)
		poteau.Position =
			Vector3.new(centre.X + cote * LARGEUR_PORTE / 2, centre.Y + HAUTEUR_PORTE / 2, bordZ)
		poteau.Color = COULEUR_POTEAU
		poteau.Material = Enum.Material.SmoothPlastic
		poteau.Parent = porte
	end
	local linteau = Instance.new("Part")
	linteau.Name = "Linteau"
	linteau.Anchored = true
	linteau.Size = Vector3.new(LARGEUR_PORTE + 3, 2, 2)
	linteau.Position = Vector3.new(centre.X, centre.Y + HAUTEUR_PORTE + 1, bordZ)
	linteau.Color = COULEUR_LINTEAU
	linteau.Material = Enum.Material.SmoothPlastic
	linteau.Parent = porte
	porte.PrimaryPart = linteau
	porte.Parent = modele

	local panneauVerrou = Instance.new("BillboardGui")
	panneauVerrou.Name = "PanneauVerrou"
	panneauVerrou.Size = UDim2.fromOffset(260, 50)
	panneauVerrou.StudsOffset = Vector3.new(0, 3, 0)
	panneauVerrou.MaxDistance = 150
	panneauVerrou.Parent = linteau
	local texteVerrou = Instance.new("TextLabel")
	texteVerrou.Name = "Texte"
	texteVerrou.Size = UDim2.fromScale(1, 1)
	texteVerrou.BackgroundTransparency = 1
	texteVerrou.Font = Enum.Font.FredokaOne
	texteVerrou.TextScaled = true
	texteVerrou.TextColor3 = Color3.new(1, 1, 1)
	texteVerrou.TextStrokeTransparency = 0
	texteVerrou.TextStrokeColor3 = Color3.new(0, 0, 0)
	texteVerrou.Text = Raid.texteVerrou(0, nil, nil)
	texteVerrou.Parent = panneauVerrou

	-- Bouton « Verrouiller » : socle près de la porte, côté intérieur.
	local bouton = Instance.new("Part")
	bouton.Name = "BoutonVerrou"
	bouton.Anchored = true
	bouton.Size = Vector3.new(3, 1.5, 3)
	bouton.Position = Vector3.new(centre.X + 8, centre.Y + 0.75, bordZ - 4)
	bouton.Color = COULEUR_BOUTON
	bouton.Material = Enum.Material.Neon
	bouton.TopSurface = Enum.SurfaceType.Smooth
	bouton.Parent = modele
	local promptVerrou = Instance.new("ProximityPrompt")
	promptVerrou.Name = "Verrouiller"
	promptVerrou.ActionText = "Verrouiller"
	promptVerrou.ObjectText = reglagesRaid.PrixVerrou .. " pièces"
	promptVerrou.MaxActivationDistance = reglagesRaid.DistanceVerrou
	promptVerrou.RequiresLineOfSight = false
	promptVerrou.KeyboardKeyCode = Enum.KeyCode.R
	promptVerrou.GamepadKeyCode = Enum.KeyCode.ButtonB
	promptVerrou.Parent = bouton
	promptVerrou.Triggered:Connect(function(declencheur: Player)
		local rappel = rappelVerrou
		if rappel then
			rappel(declencheur, joueur)
		end
	end)

	-- Bouclier : visible seulement pendant le verrou, ne bloque rien.
	local bouclier = Instance.new("Part")
	bouclier.Name = "Bouclier"
	bouclier.Anchored = true
	bouclier.CanCollide = false
	bouclier.CanQuery = false
	bouclier.CanTouch = false
	bouclier.CastShadow = false
	bouclier.Size = Vector3.new(TAILLE_SOL, HAUTEUR_BASE, TAILLE_SOL)
	bouclier.Position = centre + Vector3.new(0, HAUTEUR_BASE / 2, 0)
	bouclier.Color = COULEUR_BOUCLIER
	bouclier.Material = Enum.Material.Neon
	bouclier.Transparency = 1
	bouclier.Parent = modele

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

-- Nombre d'étages achetés par le joueur (1 à EtagesMax).
function Bases.etagesDe(joueur: any): number
	local etages = joueur:GetAttribute("Etages")
	if type(etages) ~= "number" or etages ~= etages or etages < 1 then
		return 1
	end
	return math.min(math.floor(etages), Config.Bases.EtagesMax)
end

-- Hauteur « dans la base » : le rez-de-chaussée et chaque étage acheté.
local function hauteurBase(proprietaire: any): number
	return HAUTEUR_BASE + (Bases.etagesDe(proprietaire) - 1) * Config.Bases.HauteurEtage
end

-- Vrai si le personnage du joueur est vivant et au-dessus du sol de SA base
-- (étages compris).
function Bases.estDansSaBase(joueur: any): boolean
	return estAuDessusDe(joueur, Bases.solDe(joueur), hauteurBase(joueur))
end

-- Vrai si le personnage du joueur est vivant et au-dessus du sol de la base
-- de `proprietaire` (étages compris).
function Bases.estDansBaseDe(joueur: any, proprietaire: any): boolean
	return estAuDessusDe(joueur, Bases.solDe(proprietaire), hauteurBase(proprietaire))
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

-- Point devant la porte, DistanceExpulsion studs à l'extérieur du bord Z+.
function Bases.pointExpulsion(proprietaire: any): CFrame?
	local solOuNil = Bases.solDe(proprietaire)
	if solOuNil == nil then
		return nil
	end
	local sol = solOuNil :: BasePart
	local dessus = sol.Position + Vector3.new(0, sol.Size.Y / 2, 0)
	local position = dessus + Vector3.new(0, 3, sol.Size.Z / 2 + reglagesRaid.DistanceExpulsion)
	return CFrame.lookAt(position, position + Vector3.zAxis)
end

-- Met à jour le panneau de la porte et le bouclier selon les attributs
-- VerrouJusqua / VerrouPretA du propriétaire (écrits par le serveur).
function Bases.afficherVerrou(proprietaire: any, maintenant: number)
	local base = basesParJoueur[proprietaire]
	if base == nil then
		return
	end
	local jusqua = proprietaire:GetAttribute("VerrouJusqua")
	local pretA = proprietaire:GetAttribute("VerrouPretA")
	local verrouJusqua = if type(jusqua) == "number" then jusqua else nil
	local pret = if type(pretA) == "number" then pretA else nil
	local verrouillee = Raid.estVerrouillee(maintenant, verrouJusqua)

	local bouclier = base.modele:FindFirstChild("Bouclier")
	if bouclier and bouclier:IsA("BasePart") then
		bouclier.Transparency = if verrouillee then TRANSPARENCE_BOUCLIER else 1
	end
	local panneau = base.modele:FindFirstChild("PanneauVerrou", true)
	local texte = panneau and panneau:FindFirstChild("Texte")
	if texte and texte:IsA("TextLabel") then
		texte.Text = Raid.texteVerrou(maintenant, verrouJusqua, pret)
		texte.TextColor3 = if verrouillee
			then Color3.fromRGB(255, 80, 80)
			elseif pret ~= nil and maintenant < pret then Color3.fromRGB(255, 200, 60)
			else Color3.fromRGB(120, 255, 120)
	end
end

-- Petite créature exposée dans la base (couleur de rareté, yeux, « +N/s »)
-- avec le bouton « Voler » (pour les visiteurs, revérifié par le serveur).
local function creerCreatureExposee(
	proprietaire: any,
	numero: number,
	fiche: string,
	position: Vector3
): Model
	local infos = Fiche.lire(fiche) or { Rarete = "Commune", Taille = "Normale", Espece = nil }
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
	-- Yeux tournés vers le centre de la base (axe X).
	local regard = if position.X > 0 then -1 else 1
	corps.CFrame = CFrame.lookAt(position, position + Vector3.new(regard, 0, 0))
	corps.Parent = modele

	local espece = Bestiaire.especeCreature(rarete, infos.Espece)
	Modeleur.construire(modele, corps, espece, diametre, couleur)
	Modeleur.aura(corps, couleur, table.find(raretes.Ordre, rarete) or 1)

	local panneau = Instance.new("BillboardGui")
	panneau.Name = "Panneau"
	panneau.Size = UDim2.fromOffset(90, 30)
	panneau.StudsOffset = Vector3.new(0, diametre, 0)
	panneau.MaxDistance = 120
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
	prompt.ObjectText = Fiche.texte(rarete, infos.Taille)
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
	modele:SetAttribute("Emplacement", numero)
	return modele
end

-- Position (relative au centre de la base) de l'emplacement `numero` :
-- deux rangées le long des bords X, loin de la Forge (centre, Z +4..+12)
-- et du point d'apparition (centre, Z -8).
local function positionEmplacement(numeroGlobal: number, taille: number): Vector3
	local BORD_EXPOSITION = taille / 2 - 4
	-- 10 places par étage : l'étage est donné par le numéro.
	local parEtage = Config.Creatures.MaxCreaturesBase
	local etage = math.floor((numeroGlobal - 1) / parEtage)
	local numero = (numeroGlobal - 1) % parEtage + 1
	local parRangee = math.ceil(parEtage / 2)
	local rangee = if numero <= parRangee then 0 else 1
	local rang = numero - rangee * parRangee - 1
	local x = (if rangee == 0 then -1 else 1) * BORD_EXPOSITION
	local pas = if parRangee > 1 then (2 * BORD_EXPOSITION) / (parRangee - 1) else 0
	local z = -BORD_EXPOSITION + rang * pas
	return Vector3.new(x, etage * Config.Bases.HauteurEtage + HAUTEUR_SOCLE + TAILLE_EXPOSEE / 2, z)
end

-- Ascenseur (plaque lumineuse) : téléporte le personnage à un autre étage.
local function ascenseur(
	parent: Instance,
	position: Vector3,
	texte: string,
	cible: Vector3,
	proprietaire: any
)
	local plaque = Instance.new("Part")
	plaque.Name = "Ascenseur"
	plaque.Anchored = true
	plaque.CanCollide = false
	plaque.Size = Vector3.new(4, 0.3, 4)
	plaque.Position = position + Vector3.new(0, 0.15, 0)
	plaque.Color = Color3.fromRGB(80, 230, 255)
	plaque.Material = Enum.Material.Neon
	plaque.Parent = parent
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = texte
	prompt.ObjectText = "Ascenseur"
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 8
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.G
	prompt.GamepadKeyCode = Enum.KeyCode.DPadDown
	prompt.Parent = plaque
	prompt.Triggered:Connect(function(declencheur: Player)
		-- Le propriétaire et les visiteurs (raids) peuvent l'utiliser.
		local personnage = declencheur.Character
		if personnage and Bases.modeleDe(proprietaire) ~= nil then
			personnage:PivotTo(CFrame.new(cible + Vector3.new(0, 3, 0)))
		end
	end)
end

-- (Re)crée les étages achetés : plateforme, garde-corps et ascenseurs.
local function afficherEtages(joueur: any, base: Base)
	local TAILLE_SOL = tailleDe(joueur)
	local ancien = base.modele:FindFirstChild("Etages")
	if ancien then
		ancien:Destroy()
	end
	local etages = Bases.etagesDe(joueur)
	local dossier = Instance.new("Folder")
	dossier.Name = "Etages"
	local sol = base.modele:GetPivot().Position + Vector3.new(0, 0.5, 0)
	local H = Config.Bases.HauteurEtage
	local pointAscenseur = Vector3.new(-6, 0, -15)
	for etage = 2, etages do
		local y = (etage - 1) * H
		local plancher = Instance.new("Part")
		plancher.Name = "Plancher" .. etage
		plancher.Anchored = true
		plancher.Size = Vector3.new(TAILLE_SOL, 1, TAILLE_SOL)
		plancher.Position = sol + Vector3.new(0, y - 0.5, 0)
		plancher.Color = if etage % 2 == 0
			then Color3.fromRGB(150, 210, 255)
			else Color3.fromRGB(255, 200, 140)
		plancher.Material = Enum.Material.SmoothPlastic
		plancher.TopSurface = Enum.SurfaceType.Smooth
		plancher.Parent = dossier
		for _, bord in
			{
				{ 0, TAILLE_SOL / 2 },
				{ 0, -TAILLE_SOL / 2 },
				{ TAILLE_SOL / 2, 0 },
				{ -TAILLE_SOL / 2, 0 },
			}
		do
			local garde = Instance.new("Part")
			garde.Name = "GardeCorps"
			garde.Anchored = true
			garde.Size = if bord[1] == 0
				then Vector3.new(TAILLE_SOL, 3, 1)
				else Vector3.new(1, 3, TAILLE_SOL)
			garde.Position = sol + Vector3.new(bord[1], y + 1.5, bord[2])
			garde.Color = Color3.fromRGB(255, 255, 255)
			garde.Transparency = 0.4
			garde.Parent = dossier
		end
		-- Piliers aux coins.
		for _, coin in { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } } do
			local pilier = Instance.new("Part")
			pilier.Name = "Pilier"
			pilier.Anchored = true
			pilier.Size = Vector3.new(2, H, 2)
			pilier.Position = sol
				+ Vector3.new(
					coin[1] * (TAILLE_SOL / 2 - 1),
					y - H / 2,
					coin[2] * (TAILLE_SOL / 2 - 1)
				)
			pilier.Color = Color3.fromRGB(240, 230, 255)
			pilier.Parent = dossier
		end
		-- Ascenseurs : monter depuis l'étage du dessous, descendre au rez-de-chaussée.
		local dessous = sol + pointAscenseur + Vector3.new(0, y - H, 0)
		local ici = sol + pointAscenseur + Vector3.new(0, y, 0)
		-- Monter : plaque de l'étage du dessous ; descendre : plaque voisine.
		local arrivee = Vector3.new(4, 0, 5)
		ascenseur(dossier, dessous, `Monter à l'étage {etage}`, ici + arrivee, joueur)
		ascenseur(
			dossier,
			ici + Vector3.new(10, 0, 0),
			"Descendre",
			sol + pointAscenseur + arrivee,
			joueur
		)
	end
	dossier.Parent = base.modele
	-- Le bouclier du verrou couvre tous les étages.
	local bouclier = base.modele:FindFirstChild("Bouclier")
	if bouclier and bouclier:IsA("BasePart") then
		local hauteur = HAUTEUR_BASE + (etages - 1) * H
		bouclier.Size = Vector3.new(TAILLE_SOL, hauteur, TAILLE_SOL)
		bouclier.Position = sol - Vector3.new(0, 0.5, 0) + Vector3.new(0, hauteur / 2, 0)
	end
end

-- Achat de l'agrandissement suivant (sol plus grand, socles plus espacés,
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

-- Achat de l'étage suivant avec des pièces (tout vérifié ici). Renvoie true
-- si l'étage a été acheté ; l'appelant réaffiche les créatures.
function Bases.acheterEtage(joueur: any): boolean
	local etages = Bases.etagesDe(joueur)
	if etages >= Config.Bases.EtagesMax or basesParJoueur[joueur] == nil then
		return false
	end
	local prix = Config.Bases.PrixEtages[etages]
	local pieces = joueur:GetAttribute("Pieces")
	if type(prix) ~= "number" or type(pieces) ~= "number" or pieces ~= pieces or pieces < prix then
		return false
	end
	joueur:SetAttribute("Pieces", pieces - prix)
	joueur:SetAttribute("Etages", etages + 1)
	return true
end

-- Socle d'exposition (façon vitrine) sous l'emplacement `numero` : bloc
-- sombre, plateau, liseré lumineux à la couleur de la créature posée (gris
-- si vide) et numéro de l'emplacement. Purement visuel.
local function creerSocle(numero: number, sol: Vector3, couleur: Color3?, parent: Instance)
	local modele = Instance.new("Model")
	modele.Name = "Socle" .. numero
	local function bloc(nom: string, taille: Vector3, y: number, c: Color3, neon: boolean?): Part
		local p = Instance.new("Part")
		p.Name = nom
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Size = taille
		p.Position = sol + Vector3.new(0, y, 0)
		p.Color = c
		p.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = modele
		return p
	end
	local occupe = couleur ~= nil
	bloc(
		"Pied",
		Vector3.new(3.4, HAUTEUR_SOCLE - 0.25, 3.4),
		(HAUTEUR_SOCLE - 0.25) / 2,
		Color3.fromRGB(70, 60, 90)
	)
	bloc(
		"Lisere",
		Vector3.new(3.6, 0.15, 3.6),
		HAUTEUR_SOCLE - 0.2,
		couleur or Color3.fromRGB(150, 150, 160),
		occupe
	)
	bloc(
		"Plateau",
		Vector3.new(3.2, 0.12, 3.2),
		HAUTEUR_SOCLE - 0.06,
		Color3.fromRGB(245, 240, 230)
	)
	local face = modele:FindFirstChild("Pied") :: Part
	for _, cote in
		{ Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right }
	do
		local panneau = Instance.new("SurfaceGui")
		panneau.Face = cote
		panneau.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		panneau.PixelsPerStud = 40
		panneau.Parent = face
		local texte = Instance.new("TextLabel")
		texte.Size = UDim2.fromScale(1, 1)
		texte.BackgroundTransparency = 1
		texte.Font = Enum.Font.FredokaOne
		texte.TextScaled = true
		texte.TextColor3 = Color3.new(1, 1, 1)
		texte.TextTransparency = if occupe then 0 else 0.5
		texte.Text = `#{numero}`
		texte.Parent = panneau
	end
	modele.Parent = parent
end

-- (Re)crée les créatures exposées de la base, une par emplacement.
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

	afficherEtages(joueur, base)
	local capacite = Config.Creatures.MaxCreaturesBase * Bases.etagesDe(joueur)

	-- Un socle par emplacement, coloré par la rareté de la créature posée.
	local anciensSocles = base.modele:FindFirstChild("Socles")
	if anciensSocles then
		anciensSocles:Destroy()
	end
	local socles = Instance.new("Folder")
	socles.Name = "Socles"
	for numero = 1, capacite do
		local fiche = liste[numero]
		local infos = if type(fiche) == "string" then Fiche.lire(fiche) else nil
		local couleur: Color3? = nil
		if infos then
			local rgb = raretes.Couleurs[infos.Rarete] or { 255, 255, 255 }
			couleur = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
		end
		local position = centre + positionEmplacement(numero, tailleDe(joueur))
		local etage = math.floor((numero - 1) / Config.Creatures.MaxCreaturesBase)
		local y = centre.Y + etage * Config.Bases.HauteurEtage
		creerSocle(numero, Vector3.new(position.X, y, position.Z), couleur, socles)
	end
	socles.Parent = base.modele

	for numero, rarete in liste do
		if numero > capacite then
			break
		end
		if type(rarete) == "string" then
			creerCreatureExposee(
				joueur,
				numero,
				rarete,
				centre + positionEmplacement(numero, tailleDe(joueur))
			).Parent =
				dossier
		end
	end
	dossier.Parent = base.modele
end

return Bases
