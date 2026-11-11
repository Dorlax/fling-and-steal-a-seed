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
-- Début des Terres Sauvages = ligne de la zone sûre (les bases sont à
-- Z = ZoneSure.BordBases, la bande entre les deux est la zone sûre).
local BORD_BASES = Config.Monstres.BordBases
local BORD_AVANT_BASES = Config.ZoneSure.BordBases
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

local function creerBorne(parent: Instance, nom: string, z: number, _texteBorne: string)
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

	-- Pas de texte : la couleur de la ligne suffit (ancien panneau retiré).
	local ancien = borne:FindFirstChild("Panneau")
	if ancien then
		ancien:Destroy()
	end
end

-- Grande arche à l'entrée d'un biome (à partir du biome 2), sans texte.
local function creerArche(parent: Instance, biome: Biomes.Biome, _numero: number, z: number)
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
end

-- Zone sûre : sol entre les bases et la ligne, et la ligne elle-même
-- (bande blanche et verte, rideau scintillant qui ne bloque rien, pancartes).
local function creerZoneSure()
	local modele = enfant(Workspace, "ZoneSure", "Model") :: Model
	modele:ClearAllChildren()
	local profondeur = BORD_BASES - BORD_AVANT_BASES
	local function bloc(nom: string, taille: Vector3, position: Vector3, couleur: Color3): Part
		local p = Instance.new("Part")
		p.Name = nom
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Size = taille
		p.Position = position
		p.Color = couleur
		p.Material = Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.Parent = modele
		return p
	end
	local sol = bloc(
		"Sol",
		Vector3.new(LARGEUR, EPAISSEUR, profondeur),
		Vector3.new(0, -EPAISSEUR / 2, BORD_AVANT_BASES + profondeur / 2),
		Color3.fromRGB(150, 215, 120)
	)
	sol.CanCollide = true
	sol.CanQuery = true
	sol.Material = Enum.Material.Grass
	-- Ligne : bande blanche bordée de vert, en tirets.
	bloc(
		"Ligne",
		Vector3.new(LARGEUR, 0.12, 3),
		Vector3.new(0, 0.06, BORD_BASES - 1.5),
		Color3.fromRGB(245, 250, 240)
	)
	local TIRET = 10
	for x = -LARGEUR / 2 + TIRET / 2, LARGEUR / 2 - TIRET / 2, 2 * TIRET do
		bloc(
			"Tiret",
			Vector3.new(TIRET, 0.14, 1),
			Vector3.new(x, 0.07, BORD_BASES - 3.4),
			Color3.fromRGB(90, 200, 110)
		)
	end
	-- Rideau translucide (visuel seulement) : on voit qu'on change de côté.
	local rideau = bloc(
		"Rideau",
		Vector3.new(LARGEUR, 7, 0.2),
		Vector3.new(0, 3.5, BORD_BASES),
		Color3.fromRGB(120, 230, 160)
	)
	rideau.Material = Enum.Material.ForceField
	rideau.Transparency = 0.35
	-- Pancartes « ZONE SÛRE » réparties sur la ligne, lisibles des deux côtés.
	for x = -LARGEUR / 2 + 75, LARGEUR / 2 - 75, 150 do
		local pied = bloc(
			"Pied",
			Vector3.new(0.8, 8, 0.8),
			Vector3.new(x, 4, BORD_BASES - 1.5),
			Color3.fromRGB(240, 240, 240)
		)
		pied.CastShadow = true
		local planche = bloc(
			"Pancarte",
			Vector3.new(14, 4, 0.6),
			Vector3.new(x, 9, BORD_BASES - 1.5),
			Color3.fromRGB(90, 200, 110)
		)
		for _, face in { Enum.NormalId.Front, Enum.NormalId.Back } do
			local gui = Instance.new("SurfaceGui")
			gui.Face = face
			gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			gui.PixelsPerStud = 20
			gui.Parent = planche
			local texte = Instance.new("TextLabel")
			texte.Size = UDim2.fromScale(1, 1)
			texte.BackgroundTransparency = 1
			texte.Font = Enum.Font.FredokaOne
			texte.TextScaled = true
			texte.TextColor3 = Color3.new(1, 1, 1)
			texte.TextStrokeTransparency = 0
			-- Face avant (-Z) vue depuis les bases, arrière depuis les Terres Sauvages.
			texte.Text = if face == Enum.NormalId.Front then "TERRES SAUVAGES" else "ZONE SÛRE"
			texte.Parent = gui
		end
	end
end

-- Crée (ou remet en état) le sol de chaque biome, les bornes des sous-zones,
-- les arches d'entrée et Workspace.Creatures. Renvoie le sol du biome 1.
function TerresSauvages.creer(): BasePart
	local L = Biomes.Longueur
	local premier = Biomes.Liste[1]

	-- Rayures de pelouse tondue : une bande plus claire tous les 2 x PAS_RAYURE
	-- studs, posée sur le sol (visuel seulement, ne bloque ni ne touche rien).
	local PAS_RAYURE = 8
	local function rayures(nom: string, debut: number, couleur: Color3, materiau: Enum.Material)
		local dossier = enfant(enfant(Workspace, "Rayures", "Folder"), nom, "Folder")
		dossier:ClearAllChildren()
		local clair = couleur:Lerp(Color3.new(1, 1, 1), 0.12)
		for k = 0, math.floor(Biomes.Longueur / (2 * PAS_RAYURE)) - 1 do
			local bande = Instance.new("Part")
			bande.Name = "Rayure"
			bande.Anchored = true
			bande.CanCollide = false
			bande.CanQuery = false
			bande.CanTouch = false
			bande.CastShadow = false
			bande.Size = Vector3.new(LARGEUR, 0.06, PAS_RAYURE)
			bande.Position = Vector3.new(0, 0.03, debut + (2 * k + 0.5) * PAS_RAYURE)
			bande.Color = clair
			bande.Material = materiau
			bande.TopSurface = Enum.SurfaceType.Smooth
			bande.Parent = dossier
		end
	end

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
	rayures(premier.Id, BORD_BASES, sol.Color, sol.Material)

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
		rayures(biome.Id, debut, segment.Color, segment.Material)
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

	creerZoneSure()
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
