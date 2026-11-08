--!strict
-- Terres Sauvages : grand sol d'herbe devant les bases (côté +Z), où
-- atterrissent les graines, et dossier Workspace.Creatures.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Biomes = require(ReplicatedStorage.Shared.Biomes)
local Config = require(ReplicatedStorage.Shared.Config)

local TerresSauvages = {}

-- Les 12 emplacements de Bases vont de X = -360 à +360 (sols de 40 studs) :
-- 800 studs de large les couvrent tous.
local LARGEUR = 1200 -- couvre les 12 bases (90 studs d'écart, jusqu'à 72 de large)
local BORD_BASES = 20 -- bord des bases côté +Z
local EPAISSEUR = 1

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

local function rgb(c: { number }): Color3
	return Color3.fromRGB(c[1], c[2], c[3])
end

local function creerBorne(parent: Instance, nom: string, z: number, texteBorne: string)
	local couleur = COULEURS_ZONES[nom] or Color3.new(1, 1, 1)

	local ligne = enfant(parent, "Ligne" .. nom, "Part") :: Part
	ligne.Anchored = true
	ligne.CanCollide = false
	ligne.Size = Vector3.new(LARGEUR, 0.2, 2)
	ligne.Position = Vector3.new(0, 0.1, z)
	ligne.Color = couleur
	ligne.Material = Enum.Material.Neon

	local borne = enfant(parent, "Borne" .. nom, "Part") :: Part
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
	texte.Text = texteBorne
end

-- Grande arche à l'entrée d'un biome (à partir du biome 2), avec son nom.
local function creerArche(parent: Instance, biome: Biomes.Biome, numero: number, z: number)
	local arche = enfant(parent, "Arche", "Model") :: Model
	local couleur = rgb(biome.Bordure)
	for _, x in { -40, 40 } do
		local pilier = Instance.new("Part")
		pilier.Name = "Pilier"
		pilier.Anchored = true
		pilier.Size = Vector3.new(8, 40, 8)
		pilier.Position = Vector3.new(x, 20, z)
		pilier.Color = couleur
		pilier.Material = Enum.Material.SmoothPlastic
		pilier.Parent = arche
	end
	local linteau = Instance.new("Part")
	linteau.Name = "Linteau"
	linteau.Anchored = true
	linteau.Size = Vector3.new(96, 8, 8)
	linteau.Position = Vector3.new(0, 44, z)
	linteau.Color = rgb(biome.Sol)
	linteau.Material = Enum.Material.SmoothPlastic
	linteau.Parent = arche
	local panneau = Instance.new("SurfaceGui")
	panneau.Name = "Nom"
	panneau.Face = Enum.NormalId.Front
	panneau.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	panneau.PixelsPerStud = 20
	panneau.Parent = linteau
	local texte = Instance.new("TextLabel")
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = Color3.new(1, 1, 1)
	texte.TextStrokeTransparency = 0
	texte.Text = `{numero} · {biome.Nom} · ×{Biomes.texteMultiplicateur(numero)}`
	texte.Parent = panneau
	local dos = panneau:Clone()
	dos.Face = Enum.NormalId.Back
	dos.Parent = linteau
end

-- Crée (ou remet en état) le sol de chaque biome, les bornes des sous-zones,
-- les arches d'entrée et Workspace.Creatures. Renvoie le sol du biome 1.
function TerresSauvages.creer(): BasePart
	local L = Biomes.Longueur
	local premier = Biomes.Liste[1]

	-- Biome 1 : Workspace.TerresSauvages (nom gardé pour la compatibilité).
	local sol = enfant(Workspace, "TerresSauvages", "Part") :: Part
	sol.Anchored = true
	sol.Size = Vector3.new(LARGEUR, EPAISSEUR, L)
	sol.Position = Vector3.new(0, -EPAISSEUR / 2, BORD_BASES + L / 2)
	sol.Color = rgb(premier.Sol)
	sol.Material = Enum.Material.Grass
	sol.TopSurface = Enum.SurfaceType.Smooth
	for _, zone in Config.Lancer.Zones do
		creerBorne(sol, zone.Nom, BORD_BASES + zone.Min, `Zone {zone.Nom} ({zone.Min} m)`)
	end

	-- Biomes suivants : un sol chacun (une pièce ne dépasse pas 2048 studs).
	local dossier = enfant(Workspace, "Biomes", "Folder")
	for numero = 2, Biomes.nombre() do
		local biome = Biomes.Liste[numero]
		local debut = BORD_BASES + Biomes.debut(numero)
		local segment = enfant(dossier, biome.Id, "Part") :: Part
		segment.Anchored = true
		segment.Size = Vector3.new(LARGEUR, EPAISSEUR, L)
		segment.Position = Vector3.new(0, -EPAISSEUR / 2, debut + L / 2)
		segment.Color = rgb(biome.Sol)
		segment.Material = (Enum.Material :: any)[biome.Materiau] or Enum.Material.Grass
		segment.TopSurface = Enum.SurfaceType.Smooth
		segment:SetAttribute("Biome", numero)
		for _, zone in Config.Lancer.Zones do
			creerBorne(
				segment,
				zone.Nom,
				debut + zone.Min,
				`{zone.Nom} · {math.floor(Biomes.debut(numero) + zone.Min)} m`
			)
		end
		creerArche(segment, biome, numero, debut + 2)
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
