--!strict
-- Bases des joueurs : un emplacement libre par joueur, avec une Forge.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local Bases = {}

local TAILLE_SOL = 40
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

-- Vrai si le personnage du joueur est vivant et au-dessus de SA Forge.
function Bases.estSurSaForge(joueur: Player): boolean
	local forgeTrouvee = Bases.forgeDe(joueur)
	local personnageTrouve = joueur.Character
	if forgeTrouvee == nil or personnageTrouve == nil then
		return false
	end
	local forge = forgeTrouvee :: BasePart
	local personnage = personnageTrouve :: Model
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
	local local_ = forge.CFrame:PointToObjectSpace(racine.Position)
	local demi = forge.Size / 2
	local hauteur = local_.Y - demi.Y
	return math.abs(local_.X) <= demi.X
		and math.abs(local_.Z) <= demi.Z
		and hauteur >= 0
		and hauteur <= Config.Forge.DistanceForge.Hauteur
end

return Bases
