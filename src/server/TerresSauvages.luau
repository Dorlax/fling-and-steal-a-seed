--!strict
-- Terres Sauvages : grand sol d'herbe devant les bases (côté +Z), où
-- atterrissent les graines, et dossier Workspace.Creatures.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local TerresSauvages = {}

-- Les 12 emplacements de Bases vont de X = -360 à +360 (sols de 40 studs) :
-- 800 studs de large les couvrent tous.
local LARGEUR = 800
local BORD_BASES = 20 -- bord des bases côté +Z
local MARGE_FOND = 40
local EPAISSEUR = 1

local COULEUR_HERBE = Color3.fromRGB(90, 200, 70)
local COULEURS_ZONES: { [string]: Color3 } = {
	Proche = Color3.fromRGB(120, 230, 120),
	Moyenne = Color3.fromRGB(255, 200, 60),
	Lointaine = Color3.fromRGB(255, 90, 90),
}

local function enfant(parent: Instance, nom: string, classe: string): Instance
	local existant = parent:FindFirstChild(nom)
	if existant and existant:IsA(classe) then
		return existant
	end
	if existant then
		existant:Destroy()
	end
	local nouveau: Instance = (Instance.new :: any)(classe)
	nouveau.Name = nom
	nouveau.Parent = parent
	return nouveau
end

local function creerBorne(sol: BasePart, nom: string, minimum: number)
	local couleur = COULEURS_ZONES[nom] or Color3.new(1, 1, 1)
	local z = BORD_BASES + minimum

	local ligne = enfant(sol, "Ligne" .. nom, "Part") :: Part
	ligne.Anchored = true
	ligne.CanCollide = false
	ligne.Size = Vector3.new(LARGEUR, 0.2, 2)
	ligne.Position = Vector3.new(0, 0.1, z)
	ligne.Color = couleur
	ligne.Material = Enum.Material.Neon

	local borne = enfant(sol, "Borne" .. nom, "Part") :: Part
	borne.Anchored = true
	borne.Size = Vector3.new(2, 8, 2)
	borne.Position = Vector3.new(0, 4, z)
	borne.Color = couleur
	borne.Material = Enum.Material.Neon

	local panneau = enfant(borne, "Panneau", "BillboardGui") :: BillboardGui
	panneau.Size = UDim2.fromOffset(220, 50)
	panneau.StudsOffset = Vector3.new(0, 6, 0)
	panneau.MaxDistance = 400
	local texte = enfant(panneau, "Texte", "TextLabel") :: TextLabel
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = couleur
	texte.TextStrokeTransparency = 0
	texte.Text = `Zone {nom} ({minimum} m)`
end

-- Crée (ou remet en état) le sol, les bornes de zones et Workspace.Creatures.
function TerresSauvages.creer(): BasePart
	local profondeur = Config.Lancer.DistanceMax + MARGE_FOND

	local sol = enfant(Workspace, "TerresSauvages", "Part") :: Part
	sol.Anchored = true
	sol.Size = Vector3.new(LARGEUR, EPAISSEUR, profondeur)
	-- Surface à Y = 0, de Z = +20 à +20 + DistanceMax + 40.
	sol.Position = Vector3.new(0, -EPAISSEUR / 2, BORD_BASES + profondeur / 2)
	sol.Color = COULEUR_HERBE
	sol.Material = Enum.Material.Grass
	sol.TopSurface = Enum.SurfaceType.Smooth

	for _, zone in Config.Lancer.Zones do
		creerBorne(sol, zone.Nom, zone.Min)
	end

	enfant(Workspace, "Creatures", "Folder")
	return sol
end

-- Dossier des créatures au sol (créé si besoin).
function TerresSauvages.dossierCreatures(): Folder
	return enfant(Workspace, "Creatures", "Folder") :: Folder
end

-- Z du bord des bases (départ des distances).
TerresSauvages.BordBases = BORD_BASES

return TerresSauvages
