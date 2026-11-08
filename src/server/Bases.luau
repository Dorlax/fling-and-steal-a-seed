--!strict
-- Bases des joueurs : un emplacement libre par joueur, avec une Forge.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Revenus = require(ReplicatedStorage.Shared.Revenus)

local Bases = {}

local raretes: any = Config.Raretes -- indexé par des noms dynamiques
local TAILLE_SOL = 40
local HAUTEUR_BASE = 12 -- « dans la base » : jusqu'à 12 studs au-dessus du sol
local TAILLE_EXPOSEE = 2 -- diamètre des créatures exposées dans la base
local BORD_EXPOSITION = 16 -- rangées à 16 studs du centre (sol de 40)
local ECART = 60 -- distance entre deux bases (studs)
local NOMBRE_EMPLACEMENTS = 12

local COULEUR_SOL = Color3.fromRGB(96, 128, 72)
local COULEUR_FORGE = Color3.fromRGB(214, 102, 38)

-- emplacement (numéro) -> joueur ; joueur -> { emplacement, modele }
local occupants: { [number]: any } = {}
local basesParJoueur: { [any]: { emplacement: number, modele: Model } } = {}

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

-- Les emplacements forment une ligne centrée sur l'origine : 0, +60, -60, +120…
local function centreEmplacement(numero: number): Vector3
	local rang = math.floor(numero / 2)
	local signe = if numero % 2 == 1 then 1 else -1
	return Vector3.new(signe * rang * ECART, 0, 0)
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
	local modele = construire(joueur, centreEmplacement(numero))
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

-- Petite créature exposée dans la base (couleur de rareté, yeux, « +N/s »).
local function creerCreatureExposee(rarete: string, position: Vector3): Model
	local rgb = raretes.Couleurs[rarete] or { 255, 255, 255 }
	local couleur = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
	local precieuse = (table.find(raretes.Ordre, rarete) or 1) >= 3

	local modele = Instance.new("Model")
	modele.Name = "Creature_" .. rarete

	local corps = Instance.new("Part")
	corps.Name = "Corps"
	corps.Shape = Enum.PartType.Ball
	corps.Size = Vector3.one * TAILLE_EXPOSEE
	corps.Anchored = true
	corps.CanCollide = false
	corps.Color = couleur
	corps.Material = if precieuse then Enum.Material.Neon else Enum.Material.SmoothPlastic
	-- Yeux tournés vers le centre de la base (axe X).
	local regard = if position.X > 0 then -1 else 1
	corps.CFrame = CFrame.lookAt(position, position + Vector3.new(regard, 0, 0))
	corps.Parent = modele

	for _, cote in { -1, 1 } do
		local oeil = Instance.new("Part")
		oeil.Name = "Oeil"
		oeil.Shape = Enum.PartType.Ball
		oeil.Size = Vector3.one * 0.4
		oeil.Anchored = true
		oeil.CanCollide = false
		oeil.Color = Color3.new(0.05, 0.05, 0.05)
		oeil.CFrame = corps.CFrame * CFrame.new(cote * 0.4, 0.3, -TAILLE_EXPOSEE / 2 + 0.05)
		oeil.Parent = modele
	end

	local panneau = Instance.new("BillboardGui")
	panneau.Name = "Panneau"
	panneau.Size = UDim2.fromOffset(90, 30)
	panneau.StudsOffset = Vector3.new(0, TAILLE_EXPOSEE, 0)
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
	texte.Text = `+{Revenus.parSeconde(rarete)}/s`
	texte.Parent = panneau

	modele.PrimaryPart = corps
	modele:SetAttribute("Rarete", rarete)
	return modele
end

-- Position (relative au centre de la base) de l'emplacement `numero` :
-- deux rangées le long des bords X, loin de la Forge (centre, Z +4..+12)
-- et du point d'apparition (centre, Z -8).
local function positionEmplacement(numero: number): Vector3
	local parRangee = math.ceil(Config.Creatures.MaxCreaturesBase / 2)
	local rangee = if numero <= parRangee then 0 else 1
	local rang = numero - rangee * parRangee - 1
	local x = (if rangee == 0 then -1 else 1) * BORD_EXPOSITION
	local pas = if parRangee > 1 then (2 * BORD_EXPOSITION) / (parRangee - 1) else 0
	local z = -BORD_EXPOSITION + rang * pas
	return Vector3.new(x, TAILLE_EXPOSEE / 2, z)
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
	for numero, rarete in liste do
		if numero > Config.Creatures.MaxCreaturesBase then
			break
		end
		if type(rarete) == "string" then
			creerCreatureExposee(rarete, centre + positionEmplacement(numero)).Parent = dossier
		end
	end
	dossier.Parent = base.modele
end

return Bases
