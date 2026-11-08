--!strict
-- Décor cartoon (serveur) : éclairage coloré, place de sable sous les bases,
-- chemins, arbres, rochers, fleurs, champignons, nuages, collines de bordure,
-- et ornements des bases. Purement visuel : aucune règle de jeu ne change.
-- Les pièces ne sont pas « interrogeables » (CanQuery = false) et, sauf les
-- troncs et les collines de bordure, ne bloquent rien.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Biomes = require(ReplicatedStorage.Shared.Biomes)

local Decor = {}

-- Doit rester cohérent avec Bases (sol de 40, emplacements tous les 60 studs,
-- de -360 à +360) et TerresSauvages (800 de large, de Z = 20 à Z = 600).
local DEMI_LARGEUR = 600
local BORD_BASES = 20
local FOND_SAUVAGE = 600 -- fond du biome 1 (Prairie)
local ECART_BASES = 90
local LARGEUR_PORTE = 10
local GRAINE = 20261108 -- même décor à chaque serveur

local COULEURS = {
	Sable = Color3.fromRGB(255, 196, 112),
	SableFonce = Color3.fromRGB(240, 160, 80),
	Chemin = Color3.fromRGB(255, 214, 140),
	Tronc = Color3.fromRGB(150, 92, 50),
	Rocher = Color3.fromRGB(170, 160, 200),
	Nuage = Color3.fromRGB(255, 255, 255),
	Colline = Color3.fromRGB(80, 190, 70),
	CollineClaire = Color3.fromRGB(130, 220, 90),
	ChapeauChampignon = Color3.fromRGB(240, 60, 70),
	PiedChampignon = Color3.fromRGB(255, 240, 215),
}

local FEUILLAGES = {
	Color3.fromRGB(70, 200, 70),
	Color3.fromRGB(110, 225, 80),
	Color3.fromRGB(40, 175, 95),
	Color3.fromRGB(255, 150, 200), -- arbre bonbon rose
	Color3.fromRGB(255, 210, 70), -- arbre d'or
}

local FLEURS = {
	Color3.fromRGB(255, 80, 120),
	Color3.fromRGB(255, 220, 60),
	Color3.fromRGB(120, 170, 255),
	Color3.fromRGB(200, 110, 255),
	Color3.fromRGB(255, 140, 60),
	Color3.fromRGB(255, 255, 255),
}

local BORDURES_BASE = {
	Color3.fromRGB(255, 120, 200),
	Color3.fromRGB(255, 220, 60),
	Color3.fromRGB(60, 200, 255),
	Color3.fromRGB(120, 230, 120),
}

local function piece(
	parent: Instance,
	nom: string,
	forme: Enum.PartType,
	taille: Vector3,
	cadre: CFrame,
	couleur: Color3,
	bloquant: boolean?
): Part
	local p = Instance.new("Part")
	p.Name = nom
	p.Shape = forme
	p.Size = taille
	p.CFrame = cadre
	p.Color = couleur
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = true
	p.CanCollide = bloquant == true
	p.CanQuery = false
	p.CanTouch = false
	p.Parent = parent
	return p
end

local function dossier(parent: Instance, nom: string): Folder
	local existant = parent:FindFirstChild(nom)
	if existant then
		existant:Destroy()
	end
	local f = Instance.new("Folder")
	f.Name = nom
	f.Parent = parent
	return f
end

-- Centre X des emplacements de base (même calcul que Bases).
local function centresBases(): { number }
	local liste = {}
	for numero = 1, 12 do
		local rang = math.floor(numero / 2)
		local signe = if numero % 2 == 1 then 1 else -1
		table.insert(liste, signe * rang * ECART_BASES)
	end
	return liste
end

-- Un point est-il trop près d'un chemin de base (devant chaque porte) ?
local function surChemin(x: number, z: number, centres: { number }): boolean
	if z > BORD_BASES + 70 then
		return false
	end
	for _, cx in centres do
		if math.abs(x - cx) < 12 then
			return true
		end
	end
	return false
end

---------------------------------------------------------------------------
-- Éclairage

local function enfantLighting(nom: string, classe: string): Instance
	local existant = Lighting:FindFirstChild(nom)
	if existant and existant.ClassName == classe then
		return existant
	end
	if existant then
		existant:Destroy()
	end
	local nouveau: Instance = (Instance.new :: any)(classe)
	nouveau.Name = nom
	nouveau.Parent = Lighting
	return nouveau
end

function Decor.eclairer()
	Lighting.Brightness = 2.6
	Lighting.Ambient = Color3.fromRGB(150, 140, 160)
	Lighting.OutdoorAmbient = Color3.fromRGB(170, 165, 190)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 235, 200)
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 0.3
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.4

	local atmosphere = enfantLighting("AtmosphereCartoon", "Atmosphere") :: Atmosphere
	atmosphere.Density = 0.22
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(200, 230, 255)
	atmosphere.Decay = Color3.fromRGB(120, 170, 255)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 0.6

	local couleurs =
		enfantLighting("CouleursCartoon", "ColorCorrectionEffect") :: ColorCorrectionEffect
	couleurs.Saturation = 0.25
	couleurs.Contrast = 0.08
	couleurs.Brightness = 0.02

	local eclat = enfantLighting("EclatCartoon", "BloomEffect") :: BloomEffect
	eclat.Intensity = 0.5
	eclat.Size = 24
	eclat.Threshold = 0.95

	local rayons = enfantLighting("RayonsCartoon", "SunRaysEffect") :: SunRaysEffect
	rayons.Intensity = 0.04
	rayons.Spread = 0.6
end

---------------------------------------------------------------------------
-- Éléments du décor

local function arbre(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Arbre"
	local echelle = hasard:NextNumber(0.8, 1.5)
	local hauteur = 10 * echelle
	piece(
		modele,
		"Tronc",
		Enum.PartType.Cylinder,
		Vector3.new(hauteur, 2.2 * echelle, 2.2 * echelle),
		CFrame.new(position + Vector3.new(0, hauteur / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		COULEURS.Tronc,
		true
	)
	local feuillage = if hasard:NextNumber() < 0.15
		then FEUILLAGES[hasard:NextInteger(4, 5)]
		else FEUILLAGES[hasard:NextInteger(1, 3)]
	local sommet = position + Vector3.new(0, hauteur, 0)
	piece(
		modele,
		"Feuillage",
		Enum.PartType.Ball,
		Vector3.one * 9 * echelle,
		CFrame.new(sommet),
		feuillage
	)
	for i = 1, 2 do
		local angle = hasard:NextNumber(0, 2 * math.pi)
		local decalage = Vector3.new(math.cos(angle) * 3.5, -1 + i, math.sin(angle) * 3.5) * echelle
		piece(
			modele,
			"Feuillage",
			Enum.PartType.Ball,
			Vector3.one * 6 * echelle,
			CFrame.new(sommet + decalage),
			feuillage:Lerp(Color3.new(1, 1, 1), 0.12)
		)
	end
	modele.Parent = parent
end

local function rocher(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Rocher"
	local taille = hasard:NextNumber(2, 5)
	piece(
		modele,
		"Pierre",
		Enum.PartType.Ball,
		Vector3.one * taille,
		CFrame.new(position + Vector3.new(0, taille * 0.25, 0)),
		COULEURS.Rocher
	)
	piece(
		modele,
		"Pierre",
		Enum.PartType.Ball,
		Vector3.one * taille * 0.6,
		CFrame.new(position + Vector3.new(taille * 0.5, taille * 0.1, taille * 0.2)),
		COULEURS.Rocher:Lerp(Color3.new(1, 1, 1), 0.2)
	)
	modele.Parent = parent
end

local function fleur(parent: Instance, position: Vector3, hasard: Random)
	local couleur = FLEURS[hasard:NextInteger(1, #FLEURS)]
	local hauteur = hasard:NextNumber(1, 1.8)
	piece(
		parent,
		"Tige",
		Enum.PartType.Cylinder,
		Vector3.new(hauteur, 0.25, 0.25),
		CFrame.new(position + Vector3.new(0, hauteur / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(60, 160, 60)
	)
	piece(
		parent,
		"Fleur",
		Enum.PartType.Ball,
		Vector3.one * hasard:NextNumber(0.8, 1.2),
		CFrame.new(position + Vector3.new(0, hauteur, 0)),
		couleur
	)
end

local function champignon(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Champignon"
	local e = hasard:NextNumber(1, 2.2)
	piece(
		modele,
		"Pied",
		Enum.PartType.Cylinder,
		Vector3.new(3 * e, 1.6 * e, 1.6 * e),
		CFrame.new(position + Vector3.new(0, 1.5 * e, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		COULEURS.PiedChampignon
	)
	piece(
		modele,
		"Chapeau",
		Enum.PartType.Ball,
		Vector3.new(4.5 * e, 2.4 * e, 4.5 * e),
		CFrame.new(position + Vector3.new(0, 3.2 * e, 0)),
		COULEURS.ChapeauChampignon
	)
	for i = 1, 3 do
		local a = (i / 3) * 2 * math.pi
		piece(
			modele,
			"Pois",
			Enum.PartType.Ball,
			Vector3.one * 0.8 * e,
			CFrame.new(position + Vector3.new(math.cos(a) * 1.3 * e, 4 * e, math.sin(a) * 1.3 * e)),
			Color3.new(1, 1, 1)
		)
	end
	modele.Parent = parent
end

local function nuage(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Nuage"
	local e = hasard:NextNumber(1, 2)
	for i = -2, 2 do
		local taille = (14 - math.abs(i) * 3) * e
		local p = piece(
			modele,
			"Boule",
			Enum.PartType.Ball,
			Vector3.one * taille,
			CFrame.new(position + Vector3.new(i * 7 * e, 0, hasard:NextNumber(-2, 2))),
			COULEURS.Nuage
		)
		p.CastShadow = false
	end
	modele.Parent = parent
end

local function colline(parent: Instance, position: Vector3, taille: number, couleur: Color3)
	piece(
		parent,
		"Colline",
		Enum.PartType.Ball,
		Vector3.one * taille,
		CFrame.new(position - Vector3.new(0, taille * 0.3, 0)),
		couleur,
		true
	)
end

---------------------------------------------------------------------------
-- Décors des biomes suivants (style « jouet en blocs », comme les créatures)

local function bloc(
	parent: Instance,
	nom: string,
	taille: Vector3,
	cadre: CFrame,
	couleur: Color3,
	bloquant: boolean?
): Part
	return piece(parent, nom, Enum.PartType.Block, taille, cadre, couleur, bloquant)
end

local function teinte(c: Color3, vers: number, part: number): Color3
	return c:Lerp(Color3.new(vers, vers, vers), part)
end

-- Forêt : grand arbre carré à étages de feuillage.
local function arbreBloc(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ArbreBloc"
	local e = hasard:NextNumber(1, 1.8)
	local hauteur = 12 * e
	local ecorce = Color3.fromRGB(100, 70, 45)
	bloc(
		modele,
		"Tronc",
		Vector3.new(2.6, hauteur, 2.6) * Vector3.new(e, 1, e),
		CFrame.new(position + Vector3.new(0, hauteur / 2, 0)),
		ecorce,
		true
	)
	local verts =
		{ Color3.fromRGB(45, 120, 75), Color3.fromRGB(60, 150, 90), Color3.fromRGB(35, 105, 85) }
	local vert = verts[hasard:NextInteger(1, #verts)]
	for i = 0, 2 do
		local largeur = (12 - i * 3.2) * e
		bloc(
			modele,
			"Feuillage",
			Vector3.new(largeur, 3.4 * e, largeur),
			CFrame.new(position + Vector3.new(0, hauteur + i * 3 * e, 0))
				* CFrame.Angles(0, math.rad(i * 15), 0),
			teinte(vert, 1, i * 0.08)
		)
	end
	modele.Parent = parent
end

-- Forêt : champignon géant au chapeau violet et pois lumineux.
local function champignonGeant(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ChampignonGeant"
	local e = hasard:NextNumber(1, 2.4)
	bloc(
		modele,
		"Pied",
		Vector3.new(2, 5, 2) * e,
		CFrame.new(position + Vector3.new(0, 2.5 * e, 0)),
		Color3.fromRGB(240, 225, 200),
		true
	)
	local chapeau = if hasard:NextNumber() < 0.5
		then Color3.fromRGB(150, 60, 170)
		else Color3.fromRGB(60, 150, 190)
	bloc(
		modele,
		"Chapeau",
		Vector3.new(7, 2, 7) * e,
		CFrame.new(position + Vector3.new(0, 5.6 * e, 0)),
		chapeau
	)
	bloc(
		modele,
		"Sommet",
		Vector3.new(4.4, 1.2, 4.4) * e,
		CFrame.new(position + Vector3.new(0, 7 * e, 0)),
		chapeau
	)
	for i = 1, 4 do
		local a = (i / 4) * 2 * math.pi
		local pois = bloc(
			modele,
			"Pois",
			Vector3.new(0.9, 0.3, 0.9) * e,
			CFrame.new(
				position + Vector3.new(math.cos(a) * 2.2 * e, 6.65 * e, math.sin(a) * 2.2 * e)
			),
			Color3.fromRGB(200, 255, 230)
		)
		pois.Material = Enum.Material.Neon
	end
	modele.Parent = parent
end

-- Forêt : rocher moussu.
local function rocherMousse(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(2.5, 5)
	bloc(
		parent,
		"Pierre",
		Vector3.new(t * 1.3, t * 0.7, t),
		CFrame.new(position + Vector3.new(0, t * 0.35, 0))
			* CFrame.Angles(0, hasard:NextNumber(0, 6), 0),
		Color3.fromRGB(120, 130, 135)
	)
	bloc(
		parent,
		"Mousse",
		Vector3.new(t * 1.32, t * 0.18, t * 1.02),
		CFrame.new(position + Vector3.new(0, t * 0.66, 0))
			* CFrame.Angles(0, hasard:NextNumber(0, 6), 0),
		Color3.fromRGB(90, 170, 90)
	)
end

-- Forêt : luciole qui flotte (petit cube lumineux).
local function luciole(parent: Instance, position: Vector3, hasard: Random)
	local p = bloc(
		parent,
		"Luciole",
		Vector3.one * 0.5,
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(3, 12), 0)),
		Color3.fromRGB(210, 255, 120)
	)
	p.Material = Enum.Material.Neon
	p.CastShadow = false
end

-- Désert : cactus à bras.
local function cactusBloc(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Cactus"
	local e = hasard:NextNumber(1, 2)
	local vert = Color3.fromRGB(80, 170, 85)
	bloc(
		modele,
		"Tige",
		Vector3.new(2, 9, 2) * e,
		CFrame.new(position + Vector3.new(0, 4.5 * e, 0)),
		vert,
		true
	)
	for _, cote in { -1, 1 } do
		if hasard:NextNumber() < 0.75 then
			local y = hasard:NextNumber(3, 6) * e
			bloc(
				modele,
				"Bras",
				Vector3.new(2, 1.4, 1.4) * e,
				CFrame.new(position + Vector3.new(cote * 1.8 * e, y, 0)),
				vert
			)
			bloc(
				modele,
				"Coude",
				Vector3.new(1.4, 3, 1.4) * e,
				CFrame.new(position + Vector3.new(cote * 2.5 * e, y + 1.6 * e, 0)),
				teinte(vert, 1, 0.08)
			)
		end
	end
	if hasard:NextNumber() < 0.4 then
		bloc(
			modele,
			"Fleur",
			Vector3.new(1.2, 0.6, 1.2) * e,
			CFrame.new(position + Vector3.new(0, 9.2 * e, 0)),
			Color3.fromRGB(255, 120, 180)
		)
	end
	modele.Parent = parent
end

-- Désert : mesa de grès en couches.
local function mesa(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Mesa"
	local e = hasard:NextNumber(1, 2.2)
	local couleurs = {
		Color3.fromRGB(215, 120, 75),
		Color3.fromRGB(235, 160, 100),
		Color3.fromRGB(200, 100, 65),
	}
	local y = 0
	for i = 1, 3 do
		local largeur = (16 - i * 3) * e
		local hauteur = hasard:NextNumber(3, 5) * e
		bloc(
			modele,
			"Couche",
			Vector3.new(largeur, hauteur, largeur * 0.8),
			CFrame.new(position + Vector3.new(0, y + hauteur / 2, 0)),
			couleurs[i],
			true
		)
		y += hauteur
	end
	modele.Parent = parent
end

-- Désert : dune douce (ne bloque pas).
local function dune(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(18, 34)
	piece(
		parent,
		"Dune",
		Enum.PartType.Ball,
		Vector3.new(t * 1.6, t * 0.5, t),
		CFrame.new(position - Vector3.new(0, t * 0.16, 0)),
		Color3.fromRGB(245, 210, 130)
	)
end

-- Désert : palmier d'oasis.
local function palmier(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Palmier"
	local e = hasard:NextNumber(1, 1.5)
	for i = 0, 4 do
		bloc(
			modele,
			"Tronc",
			Vector3.new(1.6, 2.6, 1.6) * e,
			CFrame.new(position + Vector3.new(i * 0.4 * e, (1.3 + i * 2.5) * e, 0)),
			teinte(Color3.fromRGB(160, 110, 60), 0, (i % 2) * 0.12),
			true
		)
	end
	local sommet = position + Vector3.new(2 * e, 13.5 * e, 0)
	for i = 1, 5 do
		local a = (i / 5) * 2 * math.pi
		bloc(
			modele,
			"Palme",
			Vector3.new(7, 0.6, 2) * e,
			CFrame.new(sommet + Vector3.new(math.cos(a) * 3 * e, -0.8 * e, math.sin(a) * 3 * e))
				* CFrame.Angles(0, -a, math.rad(-18)),
			Color3.fromRGB(70, 170, 80)
		)
	end
	modele.Parent = parent
end

-- Désert : petite pyramide en marches.
local function pyramide(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Pyramide"
	local e = hasard:NextNumber(1.4, 2.2)
	for i = 0, 5 do
		local largeur = (24 - i * 4) * e
		bloc(
			modele,
			"Marche",
			Vector3.new(largeur, 3 * e, largeur),
			CFrame.new(position + Vector3.new(0, (1.5 + i * 3) * e, 0)),
			teinte(Color3.fromRGB(225, 185, 115), 1, (i % 2) * 0.08),
			true
		)
	end
	local pointe = bloc(
		modele,
		"Pointe",
		Vector3.new(3, 2, 3) * e,
		CFrame.new(position + Vector3.new(0, 19 * e, 0)),
		Color3.fromRGB(255, 205, 50)
	)
	pointe.Material = Enum.Material.Foil
	modele.Parent = parent
end

-- Glace : sapin carré enneigé.
local function sapin(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Sapin"
	local e = hasard:NextNumber(1, 1.8)
	bloc(
		modele,
		"Tronc",
		Vector3.new(1.6, 4, 1.6) * e,
		CFrame.new(position + Vector3.new(0, 2 * e, 0)),
		Color3.fromRGB(110, 75, 55),
		true
	)
	for i = 0, 3 do
		local largeur = (10 - i * 2.4) * e
		local y = (4 + i * 3) * e
		bloc(
			modele,
			"Branches",
			Vector3.new(largeur, 2.6 * e, largeur),
			CFrame.new(position + Vector3.new(0, y, 0)),
			Color3.fromRGB(40, 110, 80)
		)
		bloc(
			modele,
			"Neige",
			Vector3.new(largeur * 0.9, 0.6 * e, largeur * 0.9),
			CFrame.new(position + Vector3.new(0, y + 1.5 * e, 0)),
			Color3.fromRGB(245, 250, 255)
		)
	end
	modele.Parent = parent
end

-- Glace : pics de glace translucides.
local function picGlace(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "PicGlace"
	for _ = 1, hasard:NextInteger(2, 4) do
		local h = hasard:NextNumber(5, 14)
		local p = bloc(
			modele,
			"Pic",
			Vector3.new(h * 0.3, h, h * 0.3),
			CFrame.new(
				position + Vector3.new(hasard:NextNumber(-3, 3), h * 0.45, hasard:NextNumber(-3, 3))
			)
				* CFrame.Angles(
					math.rad(hasard:NextNumber(-12, 12)),
					math.rad(hasard:NextNumber(0, 90)),
					math.rad(hasard:NextNumber(-12, 12))
				),
			Color3.fromRGB(150, 215, 255),
			true
		)
		p.Material = Enum.Material.Glass
		p.Transparency = 0.25
	end
	modele.Parent = parent
end

-- Glace : igloo en blocs.
local function igloo(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Igloo"
	local e = hasard:NextNumber(1.2, 1.8)
	for i = 0, 2 do
		local largeur = (12 - i * 3.4) * e
		bloc(
			modele,
			"Rang",
			Vector3.new(largeur, 2.6 * e, largeur),
			CFrame.new(position + Vector3.new(0, (1.3 + i * 2.6) * e, 0)),
			Color3.fromRGB(235, 245, 255),
			true
		)
	end
	bloc(
		modele,
		"Porte",
		Vector3.new(3, 3.4, 2) * e,
		CFrame.new(position + Vector3.new(0, 1.7 * e, -6 * e)),
		Color3.fromRGB(60, 80, 120)
	)
	modele.Parent = parent
end

-- Glace : congère de neige (ne bloque pas).
local function congere(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(10, 22)
	piece(
		parent,
		"Congere",
		Enum.PartType.Ball,
		Vector3.new(t * 1.4, t * 0.4, t),
		CFrame.new(position - Vector3.new(0, t * 0.12, 0)),
		Color3.fromRGB(240, 248, 255)
	)
end

-- Volcan : cône de volcan fumant, lave au sommet.
local function cone(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Cone"
	local e = hasard:NextNumber(1.2, 2.4)
	for i = 0, 4 do
		local largeur = (20 - i * 3.6) * e
		bloc(
			modele,
			"Roche",
			Vector3.new(largeur, 3 * e, largeur),
			CFrame.new(position + Vector3.new(0, (1.5 + i * 3) * e, 0)),
			teinte(Color3.fromRGB(70, 55, 60), 0, (i % 2) * 0.15),
			true
		)
	end
	local lave = bloc(
		modele,
		"Lave",
		Vector3.new(4, 1, 4) * e,
		CFrame.new(position + Vector3.new(0, 15.2 * e, 0)),
		Color3.fromRGB(255, 120, 30)
	)
	lave.Material = Enum.Material.Neon
	local fumee = Instance.new("ParticleEmitter")
	fumee.Color = ColorSequence.new(Color3.fromRGB(90, 80, 80))
	fumee.Size = NumberSequence.new(3, 8)
	fumee.Transparency = NumberSequence.new(0.4, 1)
	fumee.Lifetime = NumberRange.new(3, 5)
	fumee.Speed = NumberRange.new(4, 7)
	fumee.Rate = 3
	fumee.Parent = lave
	modele.Parent = parent
end

-- Volcan : mare de lave (lumineuse, ne bloque pas).
local function mareLave(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(8, 18)
	local mare = bloc(
		parent,
		"MareLave",
		Vector3.new(t, 0.3, t * 0.7),
		CFrame.new(position + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0),
		Color3.fromRGB(255, 110, 25)
	)
	mare.Material = Enum.Material.Neon
	bloc(
		parent,
		"Bord",
		Vector3.new(t + 2, 0.5, t * 0.7 + 2),
		CFrame.new(position + Vector3.new(0, 0.05, 0))
			* CFrame.Angles(0, mare.Orientation.Y * math.pi / 180, 0),
		Color3.fromRGB(45, 35, 40)
	)
end

-- Volcan : pilier d'obsidienne.
local function obsidienne(parent: Instance, position: Vector3, hasard: Random)
	local h = hasard:NextNumber(6, 16)
	local p = bloc(
		parent,
		"Obsidienne",
		Vector3.new(h * 0.35, h, h * 0.35),
		CFrame.new(position + Vector3.new(0, h * 0.45, 0))
			* CFrame.Angles(0, hasard:NextNumber(0, 6), math.rad(hasard:NextNumber(-10, 10))),
		Color3.fromRGB(30, 20, 45),
		true
	)
	p.Material = Enum.Material.Glass
end

-- Volcan : braise qui flotte.
local function braise(parent: Instance, position: Vector3, hasard: Random)
	local p = bloc(
		parent,
		"Braise",
		Vector3.one * 0.6,
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(2, 10), 0)),
		Color3.fromRGB(255, 180, 60)
	)
	p.Material = Enum.Material.Neon
	p.CastShadow = false
end

-- Galaxie : cristal géant lumineux.
local function cristal(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Cristal"
	local couleurs = {
		Color3.fromRGB(150, 90, 255),
		Color3.fromRGB(80, 230, 255),
		Color3.fromRGB(255, 120, 220),
	}
	local couleur = couleurs[hasard:NextInteger(1, #couleurs)]
	for _ = 1, hasard:NextInteger(2, 4) do
		local h = hasard:NextNumber(5, 16)
		local p = bloc(
			modele,
			"Eclat",
			Vector3.new(h * 0.28, h, h * 0.28),
			CFrame.new(
				position + Vector3.new(hasard:NextNumber(-3, 3), h * 0.45, hasard:NextNumber(-3, 3))
			)
				* CFrame.Angles(
					math.rad(hasard:NextNumber(-20, 20)),
					math.rad(hasard:NextNumber(0, 90)),
					math.rad(hasard:NextNumber(-20, 20))
				),
			couleur,
			true
		)
		p.Material = Enum.Material.Neon
		p.Transparency = 0.15
	end
	modele.Parent = parent
end

-- Galaxie : astéroïde qui flotte dans le ciel.
local function asteroide(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(4, 12)
	bloc(
		parent,
		"Asteroide",
		Vector3.new(t, t * 0.8, t * 0.9),
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(25, 70), 0))
			* CFrame.Angles(hasard:NextNumber(0, 6), hasard:NextNumber(0, 6), 0),
		Color3.fromRGB(100, 90, 120)
	)
end

-- Galaxie : plante extraterrestre à bulbe lumineux.
local function planteAlien(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "PlanteAlien"
	local h = hasard:NextNumber(3, 7)
	bloc(
		modele,
		"Tige",
		Vector3.new(0.6, h, 0.6),
		CFrame.new(position + Vector3.new(0, h / 2, 0)),
		Color3.fromRGB(90, 200, 160)
	)
	local bulbe = bloc(
		modele,
		"Bulbe",
		Vector3.one * hasard:NextNumber(1.4, 2.4),
		CFrame.new(position + Vector3.new(0, h + 0.8, 0)),
		Color3.fromRGB(255, 120, 220)
	)
	bulbe.Material = Enum.Material.Neon
	modele.Parent = parent
end

-- Galaxie : planète au loin (dans le ciel, ne bloque pas).
local function planete(parent: Instance, position: Vector3, hasard: Random)
	local couleurs = {
		Color3.fromRGB(255, 150, 90),
		Color3.fromRGB(120, 200, 255),
		Color3.fromRGB(200, 120, 255),
	}
	local t = hasard:NextNumber(40, 90)
	local centre = Vector3.new(position.X, hasard:NextNumber(140, 220), position.Z)
	piece(
		parent,
		"Planete",
		Enum.PartType.Ball,
		Vector3.one * t,
		CFrame.new(centre),
		couleurs[hasard:NextInteger(1, #couleurs)]
	)
	local anneau = bloc(
		parent,
		"Anneau",
		Vector3.new(t * 1.8, 1, t * 1.8),
		CFrame.new(centre) * CFrame.Angles(math.rad(hasard:NextNumber(10, 30)), 0, 0),
		Color3.fromRGB(255, 240, 160)
	)
	anneau.Material = Enum.Material.Neon
	anneau.Transparency = 0.4
end

-- Galaxie : étoile scintillante au ras du sol.
local function etoile(parent: Instance, position: Vector3, hasard: Random)
	local p = bloc(
		parent,
		"Etoile",
		Vector3.one * 0.5,
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(1, 14), 0))
			* CFrame.Angles(0, 0, math.rad(45)),
		Color3.fromRGB(255, 240, 160)
	)
	p.Material = Enum.Material.Neon
	p.CastShadow = false
end

-- Marais : arbre mort penché, couvert de mousse pendante.
local function arbreMort(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ArbreMort"
	local e = hasard:NextNumber(1, 1.7)
	local h = 11 * e
	local penche = math.rad(hasard:NextNumber(-12, 12))
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), penche)
	local ecorce = Color3.fromRGB(75, 65, 55)
	bloc(modele, "Tronc", Vector3.new(2, h, 2) * e, base * CFrame.new(0, h / 2, 0), ecorce, true)
	for i = 1, 2 do
		local cote = if i == 1 then 1 else -1
		bloc(
			modele,
			"Branche",
			Vector3.new(5 * e, 1, 1),
			base
				* CFrame.new(cote * 2.2 * e, h * (0.6 + i * 0.12), 0)
				* CFrame.Angles(0, 0, math.rad(cote * 25)),
			ecorce
		)
		bloc(
			modele,
			"Mousse",
			Vector3.new(0.6, 3 * e, 0.6),
			base * CFrame.new(cote * 3.6 * e, h * (0.6 + i * 0.12) - 1.4 * e, 0),
			Color3.fromRGB(110, 140, 80)
		)
	end
	modele.Parent = parent
end

-- Marais : flaque de vase avec un nénuphar fleuri.
local function flaque(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(7, 16)
	local angle = hasard:NextNumber(0, 6)
	local eau = bloc(
		parent,
		"Flaque",
		Vector3.new(t, 0.3, t * 0.75),
		CFrame.new(position + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, angle, 0),
		Color3.fromRGB(60, 95, 80)
	)
	eau.Material = Enum.Material.Glass
	eau.Transparency = 0.2
	bloc(
		parent,
		"Nenuphar",
		Vector3.new(2.4, 0.2, 2.4),
		CFrame.new(position + Vector3.new(t * 0.2, 0.35, 0)) * CFrame.Angles(0, angle, 0),
		Color3.fromRGB(100, 170, 90)
	)
	bloc(
		parent,
		"Fleur",
		Vector3.new(0.8, 0.6, 0.8),
		CFrame.new(position + Vector3.new(t * 0.2, 0.7, 0)) * CFrame.Angles(0, math.rad(45), 0),
		Color3.fromRGB(255, 170, 210)
	)
end

-- Marais : touffe de roseaux.
local function roseau(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Roseaux"
	for _ = 1, hasard:NextInteger(3, 6) do
		local h = hasard:NextNumber(3, 7)
		local pos = position
			+ Vector3.new(hasard:NextNumber(-1.5, 1.5), 0, hasard:NextNumber(-1.5, 1.5))
		local tige = CFrame.new(pos)
			* CFrame.Angles(
				math.rad(hasard:NextNumber(-10, 10)),
				0,
				math.rad(hasard:NextNumber(-10, 10))
			)
		bloc(
			modele,
			"Tige",
			Vector3.new(0.3, h, 0.3),
			tige * CFrame.new(0, h / 2, 0),
			Color3.fromRGB(110, 150, 70)
		)
		bloc(
			modele,
			"Epi",
			Vector3.new(0.6, 1.2, 0.6),
			tige * CFrame.new(0, h, 0),
			Color3.fromRGB(110, 75, 45)
		)
	end
	modele.Parent = parent
end

-- Marais : feu follet qui flotte dans la brume.
local function feuFollet(parent: Instance, position: Vector3, hasard: Random)
	local p = bloc(
		parent,
		"FeuFollet",
		Vector3.one * 0.7,
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(2, 8), 0)),
		Color3.fromRGB(170, 255, 190)
	)
	p.Material = Enum.Material.Neon
	p.CastShadow = false
end

-- Récif : corail branchu aux couleurs vives.
local function corail(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Corail"
	local couleurs = {
		Color3.fromRGB(255, 110, 120),
		Color3.fromRGB(255, 170, 70),
		Color3.fromRGB(190, 110, 230),
		Color3.fromRGB(80, 210, 200),
	}
	local couleur = couleurs[hasard:NextInteger(1, #couleurs)]
	local e = hasard:NextNumber(1, 2.2)
	for _ = 1, hasard:NextInteger(3, 6) do
		local h = hasard:NextNumber(2, 6) * e
		bloc(
			modele,
			"Branche",
			Vector3.new(0.9, h, 0.9) * Vector3.new(e, 1, e),
			CFrame.new(
				position
					+ Vector3.new(
						hasard:NextNumber(-1.5, 1.5) * e,
						h * 0.45,
						hasard:NextNumber(-1.5, 1.5) * e
					)
			)
				* CFrame.Angles(
					math.rad(hasard:NextNumber(-25, 25)),
					0,
					math.rad(hasard:NextNumber(-25, 25))
				),
			couleur,
			true
		)
	end
	modele.Parent = parent
end

-- Récif : grande algue qui monte vers la surface.
local function algue(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Algue"
	local n = hasard:NextInteger(4, 8)
	local vert = teinte(Color3.fromRGB(60, 150, 90), 0, hasard:NextNumber(0, 0.3))
	for i = 0, n - 1 do
		bloc(
			modele,
			"Segment",
			Vector3.new(0.8, 2, 0.4),
			CFrame.new(position + Vector3.new(math.sin(i * 0.9) * 0.6, 1 + i * 1.9, 0)),
			teinte(vert, 1, i * 0.04)
		)
	end
	modele.Parent = parent
end

-- Récif : coquillage géant entrouvert.
local function coquillage(parent: Instance, position: Vector3, hasard: Random)
	local e = hasard:NextNumber(1.5, 3)
	local angle = hasard:NextNumber(0, 6)
	local base = CFrame.new(position) * CFrame.Angles(0, angle, 0)
	local nacre = Color3.fromRGB(240, 215, 230)
	bloc(
		parent,
		"Valve",
		Vector3.new(4, 0.8, 3.4) * e,
		base * CFrame.new(0, 0.4 * e, 0),
		nacre,
		true
	)
	bloc(
		parent,
		"Couvercle",
		Vector3.new(4, 0.8, 3.4) * e,
		base * CFrame.new(0, 1.6 * e, 0.6 * e) * CFrame.Angles(math.rad(-30), 0, 0),
		nacre
	)
	local perle = piece(
		parent,
		"Perle",
		Enum.PartType.Ball,
		Vector3.one * 1.2 * e,
		base * CFrame.new(0, 1.3 * e, -0.3 * e),
		Color3.fromRGB(255, 255, 255)
	)
	perle.Material = Enum.Material.Neon
end

-- Récif : bulle qui flotte.
local function bulle(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(0.5, 1.4)
	local p = piece(
		parent,
		"Bulle",
		Enum.PartType.Ball,
		Vector3.one * t,
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(2, 16), 0)),
		Color3.fromRGB(200, 240, 255)
	)
	p.Material = Enum.Material.Glass
	p.Transparency = 0.5
	p.CastShadow = false
end

-- Bonbon : sucette géante plantée dans le sol.
local function sucette(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Sucette"
	local e = hasard:NextNumber(1, 2)
	local h = 9 * e
	bloc(
		modele,
		"Baton",
		Vector3.new(0.8, h, 0.8),
		CFrame.new(position + Vector3.new(0, h / 2, 0)),
		Color3.fromRGB(255, 255, 255),
		true
	)
	local couleurs =
		{ Color3.fromRGB(255, 90, 150), Color3.fromRGB(90, 200, 255), Color3.fromRGB(255, 200, 60) }
	local couleur = couleurs[hasard:NextInteger(1, #couleurs)]
	local disque = CFrame.new(position + Vector3.new(0, h + 2.5 * e, 0))
		* CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	bloc(modele, "Disque", Vector3.new(6, 6, 1) * e, disque, couleur, true)
	bloc(
		modele,
		"Spirale",
		Vector3.new(4, 4, 1.1) * e,
		disque * CFrame.Angles(0, 0, math.rad(45)),
		teinte(couleur, 1, 0.5)
	)
	bloc(modele, "Coeur", Vector3.new(2, 2, 1.2) * e, disque, couleur)
	modele.Parent = parent
end

-- Bonbon : sucre d'orge rayé.
local function sucreOrge(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "SucreOrge"
	local h = hasard:NextNumber(6, 12)
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	for i = 0, 5 do
		bloc(
			modele,
			"Segment",
			Vector3.new(1.2, h / 6, 1.2),
			base * CFrame.new(0, h / 12 + i * h / 6, 0),
			if i % 2 == 0 then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(230, 50, 60),
			true
		)
	end
	bloc(
		modele,
		"Crosse",
		Vector3.new(3, 1.2, 1.2),
		base * CFrame.new(1, h + 0.6, 0),
		Color3.fromRGB(230, 50, 60)
	)
	bloc(
		modele,
		"Bout",
		Vector3.new(1.2, 1.6, 1.2),
		base * CFrame.new(2, h - 0.2, 0),
		Color3.fromRGB(255, 255, 255)
	)
	modele.Parent = parent
end

-- Bonbon : champignon-cupcake au glaçage coulant.
local function cupcakeGeant(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "CupcakeGeant"
	local e = hasard:NextNumber(1, 2)
	bloc(
		modele,
		"Moule",
		Vector3.new(6, 4, 6) * e,
		CFrame.new(position + Vector3.new(0, 2 * e, 0)),
		Color3.fromRGB(120, 200, 240),
		true
	)
	local glacages = {
		Color3.fromRGB(255, 160, 210),
		Color3.fromRGB(170, 240, 200),
		Color3.fromRGB(255, 240, 200),
	}
	local glacage = glacages[hasard:NextInteger(1, #glacages)]
	bloc(
		modele,
		"Glacage",
		Vector3.new(7, 2, 7) * e,
		CFrame.new(position + Vector3.new(0, 5 * e, 0)),
		glacage,
		true
	)
	bloc(
		modele,
		"Glacage2",
		Vector3.new(4.6, 1.6, 4.6) * e,
		CFrame.new(position + Vector3.new(0, 6.6 * e, 0)),
		glacage
	)
	local cerise = piece(
		modele,
		"Cerise",
		Enum.PartType.Ball,
		Vector3.one * 1.6 * e,
		CFrame.new(position + Vector3.new(0, 8 * e, 0)),
		Color3.fromRGB(230, 40, 60)
	)
	cerise.Material = Enum.Material.SmoothPlastic
	modele.Parent = parent
end

-- Bonbon : dragée colorée qui flotte.
local function dragee(parent: Instance, position: Vector3, hasard: Random)
	local couleurs = {
		Color3.fromRGB(255, 120, 160),
		Color3.fromRGB(140, 220, 255),
		Color3.fromRGB(255, 230, 120),
		Color3.fromRGB(170, 240, 170),
	}
	local p = piece(
		parent,
		"Dragee",
		Enum.PartType.Ball,
		Vector3.new(1, 0.7, 0.7),
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(2, 12), 0))
			* CFrame.Angles(0, hasard:NextNumber(0, 6), 0),
		couleurs[hasard:NextInteger(1, #couleurs)]
	)
	p.CastShadow = false
end

local THEMES: { [string]: { { fonction: (Instance, Vector3, Random) -> (), nombre: number } } } = {
	Foret = {
		{ fonction = arbreBloc, nombre = 70 },
		{ fonction = champignonGeant, nombre = 22 },
		{ fonction = rocherMousse, nombre = 30 },
		{ fonction = luciole, nombre = 60 },
	},
	Glace = {
		{ fonction = sapin, nombre = 60 },
		{ fonction = picGlace, nombre = 25 },
		{ fonction = igloo, nombre = 5 },
		{ fonction = congere, nombre = 30 },
	},
	Volcan = {
		{ fonction = cone, nombre = 8 },
		{ fonction = mareLave, nombre = 22 },
		{ fonction = obsidienne, nombre = 30 },
		{ fonction = braise, nombre = 60 },
	},
	Galaxie = {
		{ fonction = cristal, nombre = 35 },
		{ fonction = asteroide, nombre = 30 },
		{ fonction = planteAlien, nombre = 40 },
		{ fonction = planete, nombre = 4 },
		{ fonction = etoile, nombre = 80 },
	},
	Desert = {
		{ fonction = cactusBloc, nombre = 50 },
		{ fonction = mesa, nombre = 12 },
		{ fonction = dune, nombre = 24 },
		{ fonction = palmier, nombre = 8 },
		{ fonction = pyramide, nombre = 2 },
	},
	Marais = {
		{ fonction = arbreMort, nombre = 40 },
		{ fonction = flaque, nombre = 30 },
		{ fonction = roseau, nombre = 50 },
		{ fonction = feuFollet, nombre = 60 },
	},
	Recif = {
		{ fonction = corail, nombre = 60 },
		{ fonction = algue, nombre = 45 },
		{ fonction = coquillage, nombre = 8 },
		{ fonction = bulle, nombre = 80 },
	},
	Bonbon = {
		{ fonction = sucette, nombre = 35 },
		{ fonction = sucreOrge, nombre = 35 },
		{ fonction = cupcakeGeant, nombre = 14 },
		{ fonction = dragee, nombre = 70 },
	},
}

-- Décor d'un biome, entre son entrée et sa fin (sauf l'allée de l'arche).
local function creerBiome(racine: Instance, numero: number)
	local biome = Biomes.Liste[numero]
	local theme = THEMES[biome.Decor]
	if theme == nil then
		return
	end
	local dossierBiome = dossier(racine, "Biome" .. numero)
	local hasard = Random.new(GRAINE + numero * 97)
	local debut = BORD_BASES + Biomes.debut(numero)
	for _, element in theme do
		for _ = 1, math.floor(element.nombre * 1.5) do
			local x = hasard:NextNumber(-DEMI_LARGEUR + 12, DEMI_LARGEUR - 12)
			local z = hasard:NextNumber(debut + 25, debut + Biomes.Longueur - 15)
			if math.abs(x) > 50 or z > debut + 60 then
				element.fonction(dossierBiome, Vector3.new(x, 0, z), hasard)
			end
		end
	end
end

---------------------------------------------------------------------------
-- Construction du monde

function Decor.creer(): Folder
	local racine = dossier(Workspace, "Decor")
	local hasard = Random.new(GRAINE)
	local centres = centresBases()

	-- Place de sable sous la rangée des bases (le sol des bases est posé dessus).
	local place = piece(
		racine,
		"Place",
		Enum.PartType.Block,
		Vector3.new(DEMI_LARGEUR * 2, 1, 140),
		CFrame.new(0, -0.55, BORD_BASES - 70),
		COULEURS.Sable,
		true
	)
	place.Material = Enum.Material.Sand

	-- Chemins de sable devant chaque porte.
	for _, cx in centres do
		piece(
			racine,
			"Chemin",
			Enum.PartType.Block,
			Vector3.new(LARGEUR_PORTE, 0.1, 60),
			CFrame.new(cx, 0.05, BORD_BASES + 30),
			COULEURS.Chemin
		)
	end

	-- Arbres, rochers, champignons et fleurs dans les Terres Sauvages.
	local nature = dossier(racine, "Nature")
	local function pointLibre(): Vector3
		for _ = 1, 20 do
			local x = hasard:NextNumber(-DEMI_LARGEUR + 10, DEMI_LARGEUR - 10)
			local z = hasard:NextNumber(BORD_BASES + 12, FOND_SAUVAGE - 10)
			if not surChemin(x, z, centres) then
				return Vector3.new(x, 0, z)
			end
		end
		return Vector3.new(
			hasard:NextNumber(-DEMI_LARGEUR + 10, DEMI_LARGEUR - 10),
			0,
			FOND_SAUVAGE - 20
		)
	end
	for _ = 1, 105 do
		arbre(nature, pointLibre(), hasard)
	end
	for _ = 1, 60 do
		rocher(nature, pointLibre(), hasard)
	end
	for _ = 1, 21 do
		champignon(nature, pointLibre(), hasard)
	end
	local fleurs = dossier(nature, "Fleurs")
	for _ = 1, 65 do
		-- Petits massifs de 3 à 5 fleurs.
		local centre = pointLibre()
		for _ = 1, hasard:NextInteger(3, 5) do
			fleur(
				fleurs,
				centre + Vector3.new(hasard:NextNumber(-3, 3), 0, hasard:NextNumber(-3, 3)),
				hasard
			)
		end
	end

	-- Arbres derrière les bases.
	for _ = 1, 45 do
		local x = hasard:NextNumber(-DEMI_LARGEUR + 10, DEMI_LARGEUR - 10)
		arbre(nature, Vector3.new(x, 0, hasard:NextNumber(-130, -75)), hasard)
	end

	-- Collines tout autour : derrière les bases, le long de chaque biome (à sa
	-- couleur) et au bout du dernier biome.
	local bord = dossier(racine, "Bordure")
	local fin = BORD_BASES + Biomes.nombre() * Biomes.Longueur
	local x = -DEMI_LARGEUR
	while x <= DEMI_LARGEUR do
		local t = hasard:NextNumber(50, 80)
		local dernier = Biomes.Liste[Biomes.nombre()]
		local couleurFin =
			Color3.fromRGB(dernier.Bordure[1], dernier.Bordure[2], dernier.Bordure[3])
		colline(bord, Vector3.new(x, 0, fin + 15), t, couleurFin)
		colline(bord, Vector3.new(x, 0, -150), t * 0.8, COULEURS.CollineClaire)
		x += 45
	end
	local z = -140
	while z <= fin do
		local t = hasard:NextNumber(50, 80)
		local biome = Biomes.biome(Biomes.index(z - BORD_BASES))
		local couleur = if z < BORD_BASES + Biomes.Longueur
			then COULEURS.Colline
			else Color3.fromRGB(biome.Bordure[1], biome.Bordure[2], biome.Bordure[3])
		colline(bord, Vector3.new(-DEMI_LARGEUR - 15, 0, z), t, couleur)
		colline(bord, Vector3.new(DEMI_LARGEUR + 15, 0, z), t, couleur)
		z += 45
	end

	-- Décor propre à chaque biome suivant (Forêt, Désert...).
	for numero = 2, Biomes.nombre() do
		creerBiome(racine, numero)
	end

	-- Nuages.
	local ciel = dossier(racine, "Ciel")
	for _ = 1, 18 do
		nuage(
			ciel,
			Vector3.new(
				hasard:NextNumber(-DEMI_LARGEUR, DEMI_LARGEUR),
				hasard:NextNumber(110, 160),
				hasard:NextNumber(-80, FOND_SAUVAGE)
			),
			hasard
		)
	end

	return racine
end

---------------------------------------------------------------------------
-- Ornements des bases (ajoutés quand une base apparaît)

function Decor.ornerBase(base: Model)
	local trouve = base:FindFirstChild("Sol")
	if not (trouve and trouve:IsA("BasePart")) or base:FindFirstChild("Ornements") then
		return
	end
	local sol = trouve :: BasePart
	local centre = sol.Position + Vector3.new(0, sol.Size.Y / 2, 0)
	local ornements = Instance.new("Folder")
	ornements.Name = "Ornements"

	-- Petite bordure colorée (ne bloque rien), ouverte devant la porte.
	local n = 0
	local function bordure(position: Vector3, taille: Vector3)
		n += 1
		piece(
			ornements,
			"Bordure",
			Enum.PartType.Block,
			taille,
			CFrame.new(position),
			BORDURES_BASE[(n - 1) % #BORDURES_BASE + 1]
		)
	end
	local d = (trouve :: BasePart).Size.X / 2
	local segment = 5
	for i = -d + segment / 2, d - segment / 2, segment do
		bordure(centre + Vector3.new(i, 0.4, -d), Vector3.new(segment - 0.3, 0.8, 1))
		bordure(centre + Vector3.new(-d, 0.4, i), Vector3.new(1, 0.8, segment - 0.3))
		bordure(centre + Vector3.new(d, 0.4, i), Vector3.new(1, 0.8, segment - 0.3))
		if math.abs(i) > LARGEUR_PORTE / 2 + 1 then
			bordure(centre + Vector3.new(i, 0.4, d), Vector3.new(segment - 0.3, 0.8, 1))
		end
	end

	-- Lampadaires-sucettes aux quatre coins.
	for _, cx in { -1, 1 } do
		for _, cz in { -1, 1 } do
			local pied = centre + Vector3.new(cx * (d - 1.5), 0, cz * (d - 1.5))
			piece(
				ornements,
				"Lampadaire",
				Enum.PartType.Cylinder,
				Vector3.new(7, 0.6, 0.6),
				CFrame.new(pied + Vector3.new(0, 3.5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
				Color3.new(1, 1, 1)
			)
			local boule = piece(
				ornements,
				"Lampe",
				Enum.PartType.Ball,
				Vector3.one * 1.8,
				CFrame.new(pied + Vector3.new(0, 7.5, 0)),
				BORDURES_BASE[(cx + cz + 4) % #BORDURES_BASE + 1]
			)
			boule.Material = Enum.Material.Neon
			local lumiere = Instance.new("PointLight")
			lumiere.Range = 14
			lumiere.Brightness = 1.2
			lumiere.Color = boule.Color
			lumiere.Parent = boule
		end
	end

	ornements.Parent = base
end

-- Orne les bases existantes et celles qui apparaîtront.
function Decor.suivreBases()
	local function brancher(dossierBases: Instance)
		for _, base in dossierBases:GetChildren() do
			if base:IsA("Model") then
				Decor.ornerBase(base)
			end
		end
		dossierBases.ChildAdded:Connect(function(base)
			if base:IsA("Model") then
				-- Laisse Bases finir de remplir le modèle.
				task.defer(Decor.ornerBase, base)
			end
		end)
	end
	local existant = Workspace:FindFirstChild("Bases")
	if existant then
		brancher(existant)
	else
		local connexion: RBXScriptConnection
		connexion = Workspace.ChildAdded:Connect(function(enfant)
			if enfant.Name == "Bases" and enfant:IsA("Folder") then
				connexion:Disconnect()
				brancher(enfant)
			end
		end)
	end
end

return Decor
