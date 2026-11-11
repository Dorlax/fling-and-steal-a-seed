--!strict
-- Décor cartoon (serveur) : éclairage coloré, place de sable sous les bases,
-- chemins, arbres, rochers, fleurs, champignons, nuages, collines de bordure,
-- et ornements des bases. Purement visuel : aucune règle de jeu ne change.
-- Les pièces ne sont pas « interrogeables » (CanQuery = false) et, sauf les
-- troncs et les collines de bordure, ne bloquent rien.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Bestiaire = require(ReplicatedStorage.Shared.Bestiaire)
local Biomes = require(ReplicatedStorage.Shared.Biomes)
local Config = require(ReplicatedStorage.Shared.Config)
local Modeleur = require(script.Parent.Modeleur)

local Decor = {}

-- Doit rester cohérent avec Bases (bord avant à Z = 20, emplacements tous
-- les 90 studs) et TerresSauvages (1 200 de large ; zone sûre de Z = 20 à la
-- ligne, puis les biomes).
local DEMI_LARGEUR = 600
local BORD_BASES = Config.ZoneSure.BordBases -- bord avant des bases
local DEBUT_SAUVAGE = Config.Monstres.BordBases -- ligne de la zone sûre
local FOND_SAUVAGE = DEBUT_SAUVAGE + Biomes.Longueur -- fond du biome 1 (Prairie)
local HAUTEUR_PAROI = 80 -- murs du bord de la carte (chaque biome est une « boîte » sans plafond)
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
	-- Optimisation : les petits éléments ne projettent pas d'ombre.
	p.CastShadow = math.max(taille.X, taille.Y, taille.Z) >= 4
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
	if z > DEBUT_SAUVAGE + 10 then
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
	-- Lumière adoucie : les sols clairs (neige, sable, nuages) n'éblouissent
	-- plus ; chaque biome règle encore son exposition côté client (Ambiances).
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(130, 122, 140)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 145, 170)
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
	couleurs.Saturation = 0.22
	couleurs.Contrast = 0.1
	couleurs.Brightness = -0.03

	-- Halo réservé aux vraies sources de lumière (néons, yeux, auras).
	local eclat = enfantLighting("EclatCartoon", "BloomEffect") :: BloomEffect
	eclat.Intensity = 0.25
	eclat.Size = 20
	eclat.Threshold = 1.6

	local rayons = enfantLighting("RayonsCartoon", "SunRaysEffect") :: SunRaysEffect
	rayons.Intensity = 0.02
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

-- Jungle : grand arbre tropical aux feuilles en éventail et lianes.
local function arbreTropical(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ArbreTropical"
	local e = hasard:NextNumber(1, 1.8)
	local h = 16 * e
	bloc(
		modele,
		"Tronc",
		Vector3.new(2.4, h, 2.4) * Vector3.new(e, 1, e),
		CFrame.new(position + Vector3.new(0, h / 2, 0)),
		Color3.fromRGB(110, 80, 55),
		true
	)
	local vert = teinte(Color3.fromRGB(40, 140, 60), 0, hasard:NextNumber(0, 0.2))
	for i = 0, 5 do
		local angle = math.rad(i * 60 + hasard:NextNumber(-10, 10))
		bloc(
			modele,
			"Palme",
			Vector3.new(2.6, 0.6, 8) * e,
			CFrame.new(position + Vector3.new(0, h, 0))
				* CFrame.Angles(0, angle, 0)
				* CFrame.new(0, 0, -3.6 * e)
				* CFrame.Angles(math.rad(-20), 0, 0),
			teinte(vert, 1, (i % 2) * 0.12)
		)
	end
	for _ = 1, hasard:NextInteger(1, 3) do
		local lh = hasard:NextNumber(4, 9) * e
		bloc(
			modele,
			"Liane",
			Vector3.new(0.4, lh, 0.4),
			CFrame.new(
				position
					+ Vector3.new(
						hasard:NextNumber(-4, 4) * e,
						h - lh / 2,
						hasard:NextNumber(-4, 4) * e
					)
			),
			Color3.fromRGB(70, 130, 60)
		)
	end
	modele.Parent = parent
end

-- Jungle : fleur géante aux pétales vifs.
local function fleurGeante(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "FleurGeante"
	local e = hasard:NextNumber(1, 2)
	local couleurs =
		{ Color3.fromRGB(255, 80, 120), Color3.fromRGB(255, 160, 40), Color3.fromRGB(200, 90, 255) }
	local couleur = couleurs[hasard:NextInteger(1, #couleurs)]
	local h = 4 * e
	bloc(
		modele,
		"Tige",
		Vector3.new(0.6, h, 0.6),
		CFrame.new(position + Vector3.new(0, h / 2, 0)),
		Color3.fromRGB(70, 150, 60)
	)
	for i = 0, 4 do
		bloc(
			modele,
			"Petale",
			Vector3.new(1.6, 0.4, 2.6) * e,
			CFrame.new(position + Vector3.new(0, h, 0))
				* CFrame.Angles(0, math.rad(i * 72), 0)
				* CFrame.new(0, 0, -1.4 * e)
				* CFrame.Angles(math.rad(25), 0, 0),
			couleur
		)
	end
	bloc(
		modele,
		"Coeur",
		Vector3.new(1.4, 0.8, 1.4) * e,
		CFrame.new(position + Vector3.new(0, h + 0.2, 0)),
		Color3.fromRGB(255, 230, 80)
	)
	modele.Parent = parent
end

-- Jungle : morceau de ruine moussue.
local function ruine(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Ruine"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	local pierre = Color3.fromRGB(150, 150, 130)
	local h = hasard:NextNumber(5, 11)
	bloc(modele, "Pilier", Vector3.new(2.6, h, 2.6), base * CFrame.new(-3, h / 2, 0), pierre, true)
	bloc(
		modele,
		"Pilier2",
		Vector3.new(2.6, h * 0.6, 2.6),
		base * CFrame.new(3, h * 0.3, 0),
		pierre,
		true
	)
	if hasard:NextNumber() < 0.6 then
		bloc(
			modele,
			"Linteau",
			Vector3.new(9, 1.6, 2.8),
			base * CFrame.new(0, h + 0.4, 0) * CFrame.Angles(0, 0, math.rad(-8)),
			pierre,
			true
		)
	end
	bloc(
		modele,
		"Mousse",
		Vector3.new(2.8, 0.4, 2.8),
		base * CFrame.new(-3, h + 0.1, 0),
		Color3.fromRGB(100, 170, 90)
	)
	bloc(
		modele,
		"Glyphe",
		Vector3.new(1, 1, 0.2),
		base * CFrame.new(-3, h * 0.6, -1.35),
		Color3.fromRGB(90, 220, 200)
	).Material =
		Enum.Material.Neon
	modele.Parent = parent
end

-- Jungle : fougère basse.
local function fougere(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Fougere"
	for i = 0, 3 do
		bloc(
			modele,
			"Fronde",
			Vector3.new(0.8, 0.3, 3.2),
			CFrame.new(position)
				* CFrame.Angles(0, math.rad(i * 90 + hasard:NextNumber(0, 40)), 0)
				* CFrame.new(0, 0.8, -1.2)
				* CFrame.Angles(math.rad(30), 0, 0),
			Color3.fromRGB(60, 160, 70)
		)
	end
	modele.Parent = parent
end

-- Ciel : gros nuage posé au sol, sur lequel on peut grimper.
local function nuageSol(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "NuageSol"
	local e = hasard:NextNumber(1, 2.4)
	for _ = 1, hasard:NextInteger(3, 5) do
		local t = hasard:NextNumber(3, 6) * e
		bloc(
			modele,
			"Bouffee",
			Vector3.new(t, t * 0.6, t),
			CFrame.new(
				position
					+ Vector3.new(
						hasard:NextNumber(-3, 3) * e,
						t * 0.3 + hasard:NextNumber(0, 1.5) * e,
						hasard:NextNumber(-3, 3) * e
					)
			),
			Color3.fromRGB(250, 252, 255),
			true
		)
	end
	modele.Parent = parent
end

-- Ciel : colonne de marbre et de nuage.
local function colonne(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Colonne"
	local h = hasard:NextNumber(8, 16)
	local marbre = Color3.fromRGB(240, 238, 230)
	bloc(
		modele,
		"Base",
		Vector3.new(3.6, 1, 3.6),
		CFrame.new(position + Vector3.new(0, 0.5, 0)),
		marbre,
		true
	)
	bloc(
		modele,
		"Fut",
		Vector3.new(2.4, h, 2.4),
		CFrame.new(position + Vector3.new(0, h / 2 + 1, 0)),
		marbre,
		true
	)
	bloc(
		modele,
		"Chapiteau",
		Vector3.new(3.6, 1, 3.6),
		CFrame.new(position + Vector3.new(0, h + 1.5, 0)),
		Color3.fromRGB(255, 215, 120)
	)
	modele.Parent = parent
end

-- Ciel : arc-en-ciel en blocs.
local function arcEnCiel(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ArcEnCiel"
	local couleurs = {
		Color3.fromRGB(255, 90, 90),
		Color3.fromRGB(255, 170, 60),
		Color3.fromRGB(255, 230, 80),
		Color3.fromRGB(110, 220, 120),
		Color3.fromRGB(90, 170, 255),
		Color3.fromRGB(180, 120, 255),
	}
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	local rayon = hasard:NextNumber(10, 16)
	for i, couleur in couleurs do
		local r = rayon - i * 1.2
		for k = 0, 8 do
			local a = math.rad(k * 22.5)
			local p = bloc(
				modele,
				"Arc",
				Vector3.new(1.2, 1.2, 2.4),
				base * CFrame.new(math.cos(a) * r, math.sin(a) * r, 0) * CFrame.Angles(0, 0, a),
				couleur
			)
			p.Material = Enum.Material.Neon
			p.Transparency = 0.3
			p.CastShadow = false
		end
	end
	modele.Parent = parent
end

-- Ciel : plume dorée qui flotte.
local function plumeDoree(parent: Instance, position: Vector3, hasard: Random)
	local p = bloc(
		parent,
		"Plume",
		Vector3.new(0.3, 1.4, 0.5),
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(2, 14), 0))
			* CFrame.Angles(0, hasard:NextNumber(0, 6), math.rad(30)),
		Color3.fromRGB(255, 220, 110)
	)
	p.Material = Enum.Material.Neon
	p.CastShadow = false
end

-- Manoir : pierre tombale arrondie (penchée).
local function tombe(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Tombe"
	local base = CFrame.new(position)
		* CFrame.Angles(
			math.rad(hasard:NextNumber(-8, 8)),
			hasard:NextNumber(0, 6),
			math.rad(hasard:NextNumber(-8, 8))
		)
	local pierre = Color3.fromRGB(130, 130, 145)
	bloc(modele, "Stele", Vector3.new(3, 3.6, 0.8), base * CFrame.new(0, 1.8, 0), pierre, true)
	piece(
		modele,
		"Haut",
		Enum.PartType.Cylinder,
		Vector3.new(0.8, 3, 3),
		base * CFrame.new(0, 3.6, 0) * CFrame.Angles(0, math.rad(90), 0),
		pierre
	)
	bloc(
		modele,
		"Croix",
		Vector3.new(0.3, 1.4, 0.2),
		base * CFrame.new(0, 2.6, -0.45),
		Color3.fromRGB(90, 90, 105)
	)
	bloc(
		modele,
		"Croix2",
		Vector3.new(1, 0.3, 0.2),
		base * CFrame.new(0, 2.8, -0.45),
		Color3.fromRGB(90, 90, 105)
	)
	modele.Parent = parent
end

-- Manoir : arbre mort tordu, branches en griffes.
local function arbreTordu(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ArbreTordu"
	local e = hasard:NextNumber(1, 1.8)
	local ecorce = Color3.fromRGB(50, 40, 55)
	local cadre = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	for i = 0, 3 do
		local segment = 3.4 * e
		bloc(
			modele,
			"Tronc",
			Vector3.new(1.6, segment, 1.6) * Vector3.new(e, 1, e),
			cadre * CFrame.new(0, segment / 2, 0),
			ecorce,
			i < 2
		)
		cadre = cadre
			* CFrame.new(0, segment, 0)
			* CFrame.Angles(0, 0, math.rad(hasard:NextNumber(-18, 18)))
		if i >= 1 then
			bloc(
				modele,
				"Branche",
				Vector3.new(4 * e, 0.6, 0.6),
				cadre
					* CFrame.new((i % 2 * 2 - 1) * 2 * e, 0, 0)
					* CFrame.Angles(0, 0, math.rad((i % 2 * 2 - 1) * 25)),
				ecorce
			)
		end
	end
	modele.Parent = parent
end

-- Manoir : tas de citrouilles lumineuses.
local function citrouilles(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Citrouilles"
	for _ = 1, hasard:NextInteger(1, 3) do
		local t = hasard:NextNumber(1.6, 3.4)
		local pos = position
			+ Vector3.new(hasard:NextNumber(-2.5, 2.5), t * 0.4, hasard:NextNumber(-2.5, 2.5))
		local tour = CFrame.new(pos) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
		bloc(
			modele,
			"Citrouille",
			Vector3.new(t, t * 0.8, t),
			tour,
			Color3.fromRGB(255, 140, 40),
			true
		)
		local visage = bloc(
			modele,
			"Visage",
			Vector3.new(t * 0.6, t * 0.2, 0.1),
			tour * CFrame.new(0, -t * 0.08, -t / 2 - 0.02),
			Color3.fromRGB(255, 220, 90)
		)
		visage.Material = Enum.Material.Neon
		bloc(
			modele,
			"Tige",
			Vector3.new(0.3, 0.5, 0.3),
			tour * CFrame.new(0, t * 0.45, 0),
			Color3.fromRGB(90, 130, 60)
		)
	end
	modele.Parent = parent
end

-- Manoir : lanterne flottante bleutée.
local function lanterneFantome(parent: Instance, position: Vector3, hasard: Random)
	local p = bloc(
		parent,
		"Lanterne",
		Vector3.new(0.7, 0.9, 0.7),
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(3, 10), 0)),
		Color3.fromRGB(150, 190, 255)
	)
	p.Material = Enum.Material.Neon
	p.CastShadow = false
end

-- Savane : acacia au feuillage plat.
local function acacia(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Acacia"
	local e = hasard:NextNumber(1, 1.8)
	local h = 10 * e
	local ecorce = Color3.fromRGB(120, 85, 55)
	local penche = CFrame.new(position)
		* CFrame.Angles(0, hasard:NextNumber(0, 6), math.rad(hasard:NextNumber(-10, 10)))
	bloc(
		modele,
		"Tronc",
		Vector3.new(1.6, h, 1.6) * Vector3.new(e, 1, e),
		penche * CFrame.new(0, h / 2, 0),
		ecorce,
		true
	)
	local vert = teinte(Color3.fromRGB(110, 150, 60), 0, hasard:NextNumber(0, 0.2))
	bloc(
		modele,
		"Feuillage",
		Vector3.new(16, 2, 12) * e,
		penche * CFrame.new(0, h + 0.6 * e, 0),
		vert
	)
	bloc(
		modele,
		"Feuillage2",
		Vector3.new(10, 1.6, 8) * e,
		penche * CFrame.new(1.5 * e, h + 2.2 * e, 0),
		teinte(vert, 1, 0.1)
	)
	modele.Parent = parent
end

-- Savane : touffe d'herbes hautes dorées.
local function herbeHaute(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "HerbeHaute"
	for _ = 1, hasard:NextInteger(4, 7) do
		local h = hasard:NextNumber(2, 4)
		bloc(
			modele,
			"Brin",
			Vector3.new(0.3, h, 0.3),
			CFrame.new(
				position
					+ Vector3.new(hasard:NextNumber(-1.2, 1.2), h / 2, hasard:NextNumber(-1.2, 1.2))
			)
				* CFrame.Angles(
					math.rad(hasard:NextNumber(-12, 12)),
					0,
					math.rad(hasard:NextNumber(-12, 12))
				),
			Color3.fromRGB(230, 190, 100)
		)
	end
	modele.Parent = parent
end

-- Savane : termitière en tour.
local function termitiere(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Termitiere"
	local terre = Color3.fromRGB(180, 110, 70)
	local h = hasard:NextNumber(5, 10)
	for i = 0, 2 do
		local t = 4 - i * 1.1
		bloc(
			modele,
			"Etage",
			Vector3.new(t, h / 3, t),
			CFrame.new(position + Vector3.new(0, h / 6 + i * h / 3, 0))
				* CFrame.Angles(0, math.rad(i * 20), 0),
			teinte(terre, 1, i * 0.06),
			true
		)
	end
	modele.Parent = parent
end

-- Savane : rocher plat (sur lequel on peut grimper).
local function rocherPlat(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(8, 16)
	bloc(
		parent,
		"RocherPlat",
		Vector3.new(t, t * 0.3, t * 0.7),
		CFrame.new(position + Vector3.new(0, t * 0.12, 0))
			* CFrame.Angles(0, hasard:NextNumber(0, 6), 0),
		Color3.fromRGB(170, 140, 110),
		true
	)
end

-- Cité Mécanique : engrenage géant planté dans le sol.
local function engrenageGeant(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "EngrenageGeant"
	local r = hasard:NextNumber(4, 8)
	local couleur = if hasard:NextNumber() < 0.5
		then Color3.fromRGB(215, 170, 80)
		else Color3.fromRGB(200, 120, 70)
	local cadre = CFrame.new(position + Vector3.new(0, r * 0.8, 0))
		* CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	local disque = piece(
		modele,
		"Disque",
		Enum.PartType.Cylinder,
		Vector3.new(1.2, r * 2, r * 2),
		cadre,
		couleur,
		true
	)
	disque.Material = Enum.Material.Metal
	for k = 0, 9 do
		local a = math.rad(k * 36)
		local dent = bloc(
			modele,
			"Dent",
			Vector3.new(1.2, r * 0.3, r * 0.3),
			cadre * CFrame.new(0, math.cos(a) * r, math.sin(a) * r) * CFrame.Angles(a, 0, 0),
			couleur,
			true
		)
		dent.Material = Enum.Material.Metal
	end
	modele.Parent = parent
end

-- Cité Mécanique : tuyau coudé qui crache de la vapeur.
local function tuyau(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Tuyau"
	local h = hasard:NextNumber(5, 10)
	local cuivre = Color3.fromRGB(190, 110, 70)
	bloc(
		modele,
		"Montant",
		Vector3.new(1.6, h, 1.6),
		CFrame.new(position + Vector3.new(0, h / 2, 0)),
		cuivre,
		true
	).Material =
		Enum.Material.Metal
	bloc(
		modele,
		"Coude",
		Vector3.new(4, 1.6, 1.6),
		CFrame.new(position + Vector3.new(1.2, h, 0)),
		cuivre
	).Material =
		Enum.Material.Metal
	bloc(
		modele,
		"Bague",
		Vector3.new(2, 0.6, 2),
		CFrame.new(position + Vector3.new(0, h * 0.5, 0)),
		Color3.fromRGB(215, 170, 80)
	).Material =
		Enum.Material.Metal
	local vapeur = piece(
		modele,
		"Vapeur",
		Enum.PartType.Ball,
		Vector3.one * 2.2,
		CFrame.new(position + Vector3.new(3.6, h + 0.6, 0)),
		Color3.fromRGB(240, 240, 245)
	)
	vapeur.Transparency = 0.4
	vapeur.CastShadow = false
	modele.Parent = parent
end

-- Cité Mécanique : lampadaire à gaz.
local function lampadaireGaz(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "LampadaireGaz"
	local h = hasard:NextNumber(8, 11)
	bloc(
		modele,
		"Poteau",
		Vector3.new(0.6, h, 0.6),
		CFrame.new(position + Vector3.new(0, h / 2, 0)),
		Color3.fromRGB(50, 50, 60),
		true
	)
	local lampe = bloc(
		modele,
		"Lampe",
		Vector3.new(1.4, 1.6, 1.4),
		CFrame.new(position + Vector3.new(0, h + 0.8, 0)),
		Color3.fromRGB(255, 210, 120)
	)
	lampe.Material = Enum.Material.Neon
	bloc(
		modele,
		"Chapeau",
		Vector3.new(1.8, 0.4, 1.8),
		CFrame.new(position + Vector3.new(0, h + 1.8, 0)),
		Color3.fromRGB(50, 50, 60)
	)
	modele.Parent = parent
end

-- Cité Mécanique : caisse de pièces détachées.
local function caisse(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(2.5, 4.5)
	local c = bloc(
		parent,
		"Caisse",
		Vector3.one * t,
		CFrame.new(position + Vector3.new(0, t / 2, 0))
			* CFrame.Angles(0, hasard:NextNumber(0, 6), 0),
		Color3.fromRGB(150, 110, 70),
		true
	)
	c.Material = Enum.Material.WoodPlanks
end

-- Jardin Zen : cerisier en fleurs.
local function cerisier(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Cerisier"
	local e = hasard:NextNumber(1, 1.7)
	local h = 8 * e
	bloc(
		modele,
		"Tronc",
		Vector3.new(1.6, h, 1.6) * Vector3.new(e, 1, e),
		CFrame.new(position + Vector3.new(0, h / 2, 0))
			* CFrame.Angles(0, 0, math.rad(hasard:NextNumber(-8, 8))),
		Color3.fromRGB(90, 60, 55),
		true
	)
	local rose = teinte(Color3.fromRGB(255, 180, 205), 1, hasard:NextNumber(0, 0.2))
	for i = 0, 3 do
		local decal = Vector3.new(
			hasard:NextNumber(-3, 3),
			hasard:NextNumber(0, 2.5),
			hasard:NextNumber(-3, 3)
		) * e
		bloc(
			modele,
			"Fleurs",
			Vector3.new(6, 3.6, 6) * e,
			CFrame.new(position + Vector3.new(0, h, 0) + decal)
				* CFrame.Angles(0, math.rad(i * 25), 0),
			teinte(rose, 1, i * 0.05)
		)
	end
	modele.Parent = parent
end

-- Jardin Zen : bosquet de bambous.
local function bambous(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Bambous"
	for _ = 1, hasard:NextInteger(3, 6) do
		local h = hasard:NextNumber(8, 16)
		local pos = position + Vector3.new(hasard:NextNumber(-2, 2), 0, hasard:NextNumber(-2, 2))
		bloc(
			modele,
			"Tige",
			Vector3.new(0.7, h, 0.7),
			CFrame.new(pos + Vector3.new(0, h / 2, 0)),
			Color3.fromRGB(140, 200, 90),
			true
		)
		for k = 1, math.floor(h / 3) do
			bloc(
				modele,
				"Noeud",
				Vector3.new(0.85, 0.2, 0.85),
				CFrame.new(pos + Vector3.new(0, k * 3, 0)),
				Color3.fromRGB(100, 160, 60)
			)
		end
	end
	modele.Parent = parent
end

-- Jardin Zen : lanterne de pierre.
local function lanternePierre(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "LanternePierre"
	local pierre = Color3.fromRGB(150, 150, 145)
	local e = hasard:NextNumber(1, 1.5)
	bloc(
		modele,
		"Pied",
		Vector3.new(1.2, 3, 1.2) * e,
		CFrame.new(position + Vector3.new(0, 1.5 * e, 0)),
		pierre,
		true
	)
	local feu = bloc(
		modele,
		"Feu",
		Vector3.new(2, 1.6, 2) * e,
		CFrame.new(position + Vector3.new(0, 3.8 * e, 0)),
		Color3.fromRGB(255, 220, 140)
	)
	feu.Material = Enum.Material.Neon
	bloc(
		modele,
		"Toit",
		Vector3.new(3.4, 0.8, 3.4) * e,
		CFrame.new(position + Vector3.new(0, 5 * e, 0)),
		pierre
	)
	bloc(
		modele,
		"Pointe",
		Vector3.new(0.8, 0.8, 0.8) * e,
		CFrame.new(position + Vector3.new(0, 5.8 * e, 0)),
		pierre
	)
	modele.Parent = parent
end

-- Jardin Zen : portique rouge laqué.
local function portique(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Portique"
	local rouge = Color3.fromRGB(210, 50, 50)
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	for _, x in { -4, 4 } do
		bloc(modele, "Pilier", Vector3.new(1.2, 10, 1.2), base * CFrame.new(x, 5, 0), rouge, true)
	end
	bloc(
		modele,
		"Linteau",
		Vector3.new(12, 1, 1.6),
		base * CFrame.new(0, 10.4, 0),
		Color3.fromRGB(40, 35, 40),
		true
	)
	bloc(modele, "Traverse", Vector3.new(10, 0.7, 1), base * CFrame.new(0, 8.6, 0), rouge, true)
	modele.Parent = parent
end

-- Cavernes : grappe de cristaux lumineux.
local function grappeCristaux(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "GrappeCristaux"
	local couleurs = {
		Color3.fromRGB(120, 220, 255),
		Color3.fromRGB(190, 110, 255),
		Color3.fromRGB(140, 255, 200),
	}
	local couleur = couleurs[hasard:NextInteger(1, #couleurs)]
	for _ = 1, hasard:NextInteger(3, 6) do
		local h = hasard:NextNumber(3, 9)
		local p = bloc(
			modele,
			"Cristal",
			Vector3.new(h * 0.3, h, h * 0.3),
			CFrame.new(
				position + Vector3.new(hasard:NextNumber(-2, 2), h * 0.4, hasard:NextNumber(-2, 2))
			)
				* CFrame.Angles(
					math.rad(hasard:NextNumber(-30, 30)),
					math.rad(hasard:NextNumber(0, 90)),
					math.rad(hasard:NextNumber(-30, 30))
				),
			couleur,
			true
		)
		p.Material = Enum.Material.Neon
		p.Transparency = 0.2
	end
	modele.Parent = parent
end

-- Cavernes : stalagmite de roche.
local function stalagmite(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Stalagmite"
	local h = hasard:NextNumber(6, 16)
	local roche = Color3.fromRGB(95, 90, 110)
	for i = 0, 2 do
		local t = (3.4 - i) * h / 10
		bloc(
			modele,
			"Etage",
			Vector3.new(t, h / 3, t),
			CFrame.new(position + Vector3.new(0, h / 6 + i * h / 3, 0)),
			teinte(roche, 1, i * 0.08),
			true
		)
	end
	modele.Parent = parent
end

-- Cavernes : champignon phosphorescent.
local function champiLumineux(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ChampiLumineux"
	local e = hasard:NextNumber(1, 2.5)
	bloc(
		modele,
		"Pied",
		Vector3.new(0.8, 2.4, 0.8) * e,
		CFrame.new(position + Vector3.new(0, 1.2 * e, 0)),
		Color3.fromRGB(230, 225, 240)
	)
	local chapeau = bloc(
		modele,
		"Chapeau",
		Vector3.new(3, 1, 3) * e,
		CFrame.new(position + Vector3.new(0, 2.6 * e, 0)),
		Color3.fromRGB(80, 200, 220)
	)
	chapeau.Material = Enum.Material.Neon
	modele.Parent = parent
end

-- Cavernes : wagonnet de mine abandonné.
local function wagonnet(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Wagonnet"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	bloc(
		modele,
		"Caisse",
		Vector3.new(3, 2, 4.4),
		base * CFrame.new(0, 1.6, 0),
		Color3.fromRGB(110, 80, 60),
		true
	).Material =
		Enum.Material.WoodPlanks
	for _, x in { -1.6, 1.6 } do
		for _, z in { -1.4, 1.4 } do
			piece(
				modele,
				"Roue",
				Enum.PartType.Cylinder,
				Vector3.new(0.4, 1.2, 1.2),
				base * CFrame.new(x, 0.6, z),
				Color3.fromRGB(60, 60, 70)
			)
		end
	end
	local or_ = bloc(
		modele,
		"Pepites",
		Vector3.new(2.4, 0.8, 3.6),
		base * CFrame.new(0, 2.8, 0),
		Color3.fromRGB(255, 210, 80)
	)
	or_.Material = Enum.Material.Neon
	modele.Parent = parent
end

-- Coffre à Jouets : pile de cubes à lettres.
local function pileCubes(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "PileCubes"
	local couleurs = {
		Color3.fromRGB(230, 60, 60),
		Color3.fromRGB(60, 130, 230),
		Color3.fromRGB(255, 210, 50),
		Color3.fromRGB(80, 190, 90),
	}
	local t = hasard:NextNumber(2.5, 4)
	for i = 0, hasard:NextInteger(1, 4) do
		bloc(
			modele,
			"Cube",
			Vector3.one * t,
			CFrame.new(
				position
					+ Vector3.new(
						hasard:NextNumber(-0.4, 0.4),
						t / 2 + i * t,
						hasard:NextNumber(-0.4, 0.4)
					)
			) * CFrame.Angles(0, math.rad(hasard:NextNumber(-25, 25)), 0),
			couleurs[(i % #couleurs) + 1],
			true
		)
	end
	modele.Parent = parent
end

-- Coffre à Jouets : crayon de couleur géant planté.
local function crayon(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Crayon"
	local couleurs = {
		Color3.fromRGB(230, 60, 60),
		Color3.fromRGB(60, 130, 230),
		Color3.fromRGB(80, 190, 90),
		Color3.fromRGB(180, 90, 230),
	}
	local couleur = couleurs[hasard:NextInteger(1, #couleurs)]
	local h = hasard:NextNumber(8, 14)
	local penche = CFrame.new(position)
		* CFrame.Angles(
			math.rad(hasard:NextNumber(-12, 12)),
			hasard:NextNumber(0, 6),
			math.rad(hasard:NextNumber(-12, 12))
		)
	bloc(modele, "Corps", Vector3.new(1.4, h, 1.4), penche * CFrame.new(0, h / 2, 0), couleur, true)
	bloc(
		modele,
		"Bois",
		Vector3.new(1, 1.2, 1),
		penche * CFrame.new(0, h + 0.6, 0),
		Color3.fromRGB(240, 210, 160)
	)
	bloc(modele, "Mine", Vector3.new(0.5, 0.6, 0.5), penche * CFrame.new(0, h + 1.5, 0), couleur)
	modele.Parent = parent
end

-- Coffre à Jouets : ballon de plage rayé.
local function ballonPlage(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(3, 6)
	local couleurs =
		{ Color3.fromRGB(255, 90, 90), Color3.fromRGB(255, 220, 60), Color3.fromRGB(90, 170, 255) }
	piece(
		parent,
		"BallonPlage",
		Enum.PartType.Ball,
		Vector3.one * t,
		CFrame.new(position + Vector3.new(0, t / 2, 0)),
		couleurs[hasard:NextInteger(1, #couleurs)],
		true
	)
end

-- Coffre à Jouets : rails de petit train en arc.
local function arcTrain(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ArcTrain"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	for k = 0, 6 do
		local a = math.rad(k * 30)
		bloc(
			modele,
			"Rail",
			Vector3.new(3, 0.6, 1.4),
			base
				* CFrame.new(math.cos(a) * 6, math.sin(a) * 6, 0)
				* CFrame.Angles(0, 0, a + math.pi / 2),
			Color3.fromRGB(200, 120, 60),
			true
		)
	end
	modele.Parent = parent
end

-- Automne : arbre aux feuilles rousses.
local function arbreRoux(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ArbreRoux"
	local e = hasard:NextNumber(1, 1.7)
	local h = 10 * e
	bloc(
		modele,
		"Tronc",
		Vector3.new(2, h, 2) * Vector3.new(e, 1, e),
		CFrame.new(position + Vector3.new(0, h / 2, 0)),
		Color3.fromRGB(100, 70, 50),
		true
	)
	local couleurs =
		{ Color3.fromRGB(230, 90, 40), Color3.fromRGB(245, 170, 50), Color3.fromRGB(200, 60, 40) }
	local couleur = couleurs[hasard:NextInteger(1, #couleurs)]
	for i = 0, 2 do
		local largeur = (10 - i * 2.6) * e
		bloc(
			modele,
			"Feuillage",
			Vector3.new(largeur, 3.2 * e, largeur),
			CFrame.new(position + Vector3.new(0, h + i * 2.8 * e, 0))
				* CFrame.Angles(0, math.rad(i * 20), 0),
			teinte(couleur, 1, i * 0.08)
		)
	end
	modele.Parent = parent
end

-- Automne : tas de feuilles mortes.
local function tasFeuilles(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "TasFeuilles"
	local couleurs =
		{ Color3.fromRGB(230, 90, 40), Color3.fromRGB(245, 170, 50), Color3.fromRGB(200, 60, 40) }
	for _ = 1, hasard:NextInteger(4, 8) do
		local t = hasard:NextNumber(1.4, 2.6)
		bloc(
			modele,
			"Feuilles",
			Vector3.new(t, t * 0.4, t),
			CFrame.new(
				position + Vector3.new(hasard:NextNumber(-2, 2), t * 0.2, hasard:NextNumber(-2, 2))
			) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0),
			couleurs[hasard:NextInteger(1, #couleurs)]
		)
	end
	modele.Parent = parent
end

-- Automne : citrouille de champ et bottes de paille.
local function botteFoin(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "BotteFoin"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	bloc(
		modele,
		"Botte",
		Vector3.new(4, 2.4, 2.4),
		base * CFrame.new(0, 1.2, 0),
		Color3.fromRGB(235, 200, 100),
		true
	)
	bloc(
		modele,
		"Lien",
		Vector3.new(0.3, 2.5, 2.5),
		base * CFrame.new(-1, 1.2, 0),
		Color3.fromRGB(150, 110, 60)
	)
	bloc(
		modele,
		"Lien2",
		Vector3.new(0.3, 2.5, 2.5),
		base * CFrame.new(1, 1.2, 0),
		Color3.fromRGB(150, 110, 60)
	)
	if hasard:NextNumber() < 0.6 then
		bloc(
			modele,
			"Citrouille",
			Vector3.new(2, 1.6, 2),
			base * CFrame.new(0, 3.2, 0),
			Color3.fromRGB(255, 140, 40)
		)
	end
	modele.Parent = parent
end

-- Automne : champignon de sous-bois.
local function cepe(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Cepe"
	local e = hasard:NextNumber(0.8, 1.8)
	bloc(
		modele,
		"Pied",
		Vector3.new(1, 1.6, 1) * e,
		CFrame.new(position + Vector3.new(0, 0.8 * e, 0)),
		Color3.fromRGB(240, 225, 200)
	)
	bloc(
		modele,
		"Chapeau",
		Vector3.new(2.4, 0.9, 2.4) * e,
		CFrame.new(position + Vector3.new(0, 1.9 * e, 0)),
		Color3.fromRGB(150, 90, 50)
	)
	modele.Parent = parent
end

-- Ferme : petite grange rouge au toit en pente.
local function grange(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Grange"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	local rouge = Color3.fromRGB(200, 60, 50)
	bloc(modele, "Murs", Vector3.new(12, 8, 10), base * CFrame.new(0, 4, 0), rouge, true).Material =
		Enum.Material.WoodPlanks
	for _, cote in { -1, 1 } do
		bloc(
			modele,
			"Toit",
			Vector3.new(7.4, 0.8, 11),
			base * CFrame.new(cote * 3.1, 9.6, 0) * CFrame.Angles(0, 0, math.rad(-cote * 35)),
			Color3.fromRGB(90, 60, 50),
			true
		)
	end
	bloc(
		modele,
		"Porte",
		Vector3.new(5, 6, 0.3),
		base * CFrame.new(0, 3, -5.1),
		Color3.fromRGB(245, 240, 230)
	)
	bloc(
		modele,
		"Croix",
		Vector3.new(0.4, 7, 0.32),
		base * CFrame.new(0, 3, -5.12) * CFrame.Angles(0, 0, math.rad(40)),
		rouge
	)
	modele.Parent = parent
end

-- Ferme : barrière de pré et bottes.
local function enclos(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Enclos"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	local bois = Color3.fromRGB(245, 240, 230)
	for k = 0, 3 do
		bloc(
			modele,
			"Piquet",
			Vector3.new(0.6, 3, 0.6),
			base * CFrame.new(-6 + k * 4, 1.5, 0),
			bois,
			true
		)
	end
	for _, y in { 1, 2.2 } do
		bloc(modele, "Planche", Vector3.new(12.6, 0.4, 0.3), base * CFrame.new(0, y, 0), bois, true)
	end
	modele.Parent = parent
end

-- Ferme : moulin à vent.
local function moulin(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Moulin"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	bloc(
		modele,
		"Tour",
		Vector3.new(5, 14, 5),
		base * CFrame.new(0, 7, 0),
		Color3.fromRGB(240, 230, 210),
		true
	)
	bloc(
		modele,
		"Toit",
		Vector3.new(6, 3, 6),
		base * CFrame.new(0, 15.5, 0) * CFrame.Angles(0, math.rad(45), 0),
		Color3.fromRGB(200, 60, 50)
	)
	for k = 0, 3 do
		bloc(
			modele,
			"Aile",
			Vector3.new(1.6, 9, 0.3),
			base
				* CFrame.new(0, 12, -2.8)
				* CFrame.Angles(0, 0, math.rad(k * 90 + 20))
				* CFrame.new(0, 4.5, 0),
			Color3.fromRGB(245, 245, 245)
		)
	end
	modele.Parent = parent
end

-- Ferme : potager de carottes.
local function potager(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Potager"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	bloc(
		modele,
		"Terre",
		Vector3.new(8, 0.5, 4),
		base * CFrame.new(0, 0.25, 0),
		Color3.fromRGB(120, 80, 55)
	)
	for k = 0, 4 do
		bloc(
			modele,
			"Fanes",
			Vector3.new(0.6, 1, 0.6),
			base * CFrame.new(-3 + k * 1.5, 1, 0),
			Color3.fromRGB(90, 180, 70)
		)
		bloc(
			modele,
			"Carotte",
			Vector3.new(0.5, 0.4, 0.5),
			base * CFrame.new(-3 + k * 1.5, 0.6, 0),
			Color3.fromRGB(255, 140, 40)
		)
	end
	modele.Parent = parent
end

-- Rêves : nuage-lit avec un oreiller.
local function nuageLit(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "NuageLit"
	local e = hasard:NextNumber(1, 1.8)
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	bloc(
		modele,
		"Matelas",
		Vector3.new(8, 2, 5) * e,
		base * CFrame.new(0, 1 * e, 0),
		Color3.fromRGB(200, 190, 255),
		true
	)
	bloc(
		modele,
		"Oreiller",
		Vector3.new(3, 1, 2) * e,
		base * CFrame.new(0, 2.4 * e, -1.4 * e),
		Color3.fromRGB(255, 255, 255)
	)
	bloc(
		modele,
		"Couverture",
		Vector3.new(8.2, 0.4, 3) * e,
		base * CFrame.new(0, 2.1 * e, 1 * e),
		Color3.fromRGB(130, 110, 220)
	)
	modele.Parent = parent
end

-- Rêves : lune en croissant posée au sol.
local function luneSol(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "LuneSol"
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	local r = hasard:NextNumber(5, 9)
	for k = 0, 6 do
		local a = math.rad(-90 + k * 30)
		local p = bloc(
			modele,
			"Croissant",
			Vector3.new(2.4, 2.4, 2),
			base * CFrame.new(math.cos(a) * r, r + math.sin(a) * r, 0),
			Color3.fromRGB(255, 240, 150),
			true
		)
		p.Material = Enum.Material.Neon
	end
	modele.Parent = parent
end

-- Rêves : étoile tombée qui brille.
local function etoileTombee(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(1.5, 3)
	local p = bloc(
		parent,
		"EtoileTombee",
		Vector3.new(t, t, t * 0.4),
		CFrame.new(position + Vector3.new(0, t * 0.5, 0))
			* CFrame.Angles(0, hasard:NextNumber(0, 6), math.rad(45)),
		Color3.fromRGB(255, 230, 120)
	)
	p.Material = Enum.Material.Neon
end

-- Rêves : bulle de rêve qui flotte.
local function bulleReve(parent: Instance, position: Vector3, hasard: Random)
	local t = hasard:NextNumber(1, 3)
	local p = piece(
		parent,
		"BulleReve",
		Enum.PartType.Ball,
		Vector3.one * t,
		CFrame.new(position + Vector3.new(0, hasard:NextNumber(3, 16), 0)),
		Color3.fromRGB(220, 200, 255)
	)
	p.Material = Enum.Material.Glass
	p.Transparency = 0.5
	p.CastShadow = false
end

-- Plage : palmier à noix de coco.
local function palmierCoco(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "PalmierCoco"
	local e = hasard:NextNumber(1, 1.6)
	local cadre = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	for k = 0, 4 do
		bloc(
			modele,
			"Tronc",
			Vector3.new(1.4, 2.6, 1.4) * Vector3.new(e, e, e),
			cadre
				* CFrame.new(k * 0.35 * e, (1.3 + k * 2.5) * e, 0)
				* CFrame.Angles(0, 0, math.rad(-6)),
			Color3.fromRGB(170, 130, 80),
			true
		)
	end
	local sommet = cadre * CFrame.new(1.8 * e, 13.4 * e, 0)
	for k = 0, 5 do
		bloc(
			modele,
			"Palme",
			Vector3.new(1.8, 0.4, 7) * e,
			sommet
				* CFrame.Angles(0, math.rad(k * 60), 0)
				* CFrame.new(0, 0, -3 * e)
				* CFrame.Angles(math.rad(-25), 0, 0),
			Color3.fromRGB(60, 170, 70)
		)
	end
	for k = 0, 2 do
		piece(
			modele,
			"Coco",
			Enum.PartType.Ball,
			Vector3.one * 1.2 * e,
			sommet * CFrame.Angles(0, math.rad(k * 120), 0) * CFrame.new(0, -0.8 * e, -0.9 * e),
			Color3.fromRGB(110, 75, 45)
		)
	end
	modele.Parent = parent
end

-- Plage : parasol rayé et serviette.
local function parasol(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "Parasol"
	local couleurs =
		{ Color3.fromRGB(255, 90, 90), Color3.fromRGB(90, 170, 255), Color3.fromRGB(255, 210, 60) }
	local couleur = couleurs[hasard:NextInteger(1, #couleurs)]
	bloc(
		modele,
		"Mat",
		Vector3.new(0.4, 7, 0.4),
		CFrame.new(position + Vector3.new(0, 3.5, 0)),
		Color3.fromRGB(240, 240, 240),
		true
	)
	for k = 0, 7 do
		bloc(
			modele,
			"Toile",
			Vector3.new(1.8, 0.3, 4),
			CFrame.new(position + Vector3.new(0, 7, 0))
				* CFrame.Angles(0, math.rad(k * 45), 0)
				* CFrame.new(0, -0.6, -1.8)
				* CFrame.Angles(math.rad(-18), 0, 0),
			if k % 2 == 0 then couleur else Color3.fromRGB(255, 255, 255)
		)
	end
	bloc(
		modele,
		"Serviette",
		Vector3.new(3, 0.1, 6),
		CFrame.new(position + Vector3.new(3, 0.05, 0)),
		couleur
	)
	modele.Parent = parent
end

-- Plage : château de sable.
local function chateauSable(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "ChateauSable"
	local sable = Color3.fromRGB(240, 210, 145)
	local base = CFrame.new(position) * CFrame.Angles(0, hasard:NextNumber(0, 6), 0)
	bloc(modele, "Base", Vector3.new(8, 2, 8), base * CFrame.new(0, 1, 0), sable, true)
	for _, x in { -3, 3 } do
		for _, z in { -3, 3 } do
			bloc(modele, "Tour", Vector3.new(2, 4, 2), base * CFrame.new(x, 3, z), sable, true)
		end
	end
	bloc(modele, "Donjon", Vector3.new(3, 6, 3), base * CFrame.new(0, 4, 0), sable, true)
	bloc(
		modele,
		"Drapeau",
		Vector3.new(1.4, 0.8, 0.1),
		base * CFrame.new(0.7, 8, 0),
		Color3.fromRGB(255, 90, 90)
	)
	modele.Parent = parent
end

-- Plage : étoile de mer et coquillage géant posés sur le sable.
local function etoileMer(parent: Instance, position: Vector3, hasard: Random)
	local modele = Instance.new("Model")
	modele.Name = "EtoileMer"
	local couleur = if hasard:NextNumber() < 0.5
		then Color3.fromRGB(255, 130, 100)
		else Color3.fromRGB(255, 180, 70)
	for k = 0, 4 do
		bloc(
			modele,
			"Bras",
			Vector3.new(0.8, 0.3, 2.2),
			CFrame.new(position + Vector3.new(0, 0.15, 0))
				* CFrame.Angles(0, math.rad(k * 72), 0)
				* CFrame.new(0, 0, -1),
			couleur
		)
	end
	modele.Parent = parent
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
	Jungle = {
		{ fonction = arbreTropical, nombre = 55 },
		{ fonction = fleurGeante, nombre = 30 },
		{ fonction = ruine, nombre = 8 },
		{ fonction = fougere, nombre = 60 },
	},
	Ciel = {
		{ fonction = nuageSol, nombre = 40 },
		{ fonction = colonne, nombre = 18 },
		{ fonction = arcEnCiel, nombre = 3 },
		{ fonction = plumeDoree, nombre = 70 },
	},
	Manoir = {
		{ fonction = tombe, nombre = 45 },
		{ fonction = arbreTordu, nombre = 35 },
		{ fonction = citrouilles, nombre = 25 },
		{ fonction = lanterneFantome, nombre = 60 },
	},
	Savane = {
		{ fonction = acacia, nombre = 35 },
		{ fonction = herbeHaute, nombre = 80 },
		{ fonction = termitiere, nombre = 12 },
		{ fonction = rocherPlat, nombre = 10 },
	},
	Mecanique = {
		{ fonction = engrenageGeant, nombre = 25 },
		{ fonction = tuyau, nombre = 30 },
		{ fonction = lampadaireGaz, nombre = 30 },
		{ fonction = caisse, nombre = 35 },
	},
	Zen = {
		{ fonction = cerisier, nombre = 40 },
		{ fonction = bambous, nombre = 35 },
		{ fonction = lanternePierre, nombre = 25 },
		{ fonction = portique, nombre = 5 },
	},
	Cavernes = {
		{ fonction = grappeCristaux, nombre = 45 },
		{ fonction = stalagmite, nombre = 40 },
		{ fonction = champiLumineux, nombre = 40 },
		{ fonction = wagonnet, nombre = 6 },
	},
	Jouets = {
		{ fonction = pileCubes, nombre = 35 },
		{ fonction = crayon, nombre = 30 },
		{ fonction = ballonPlage, nombre = 25 },
		{ fonction = arcTrain, nombre = 6 },
	},
	Automne = {
		{ fonction = arbreRoux, nombre = 60 },
		{ fonction = tasFeuilles, nombre = 45 },
		{ fonction = botteFoin, nombre = 15 },
		{ fonction = cepe, nombre = 40 },
	},
	Ferme = {
		{ fonction = grange, nombre = 6 },
		{ fonction = enclos, nombre = 25 },
		{ fonction = moulin, nombre = 4 },
		{ fonction = potager, nombre = 20 },
		{ fonction = botteFoin, nombre = 20 },
	},
	Reves = {
		{ fonction = nuageLit, nombre = 20 },
		{ fonction = luneSol, nombre = 5 },
		{ fonction = etoileTombee, nombre = 40 },
		{ fonction = bulleReve, nombre = 70 },
	},
	Plage = {
		{ fonction = palmierCoco, nombre = 40 },
		{ fonction = parasol, nombre = 20 },
		{ fonction = chateauSable, nombre = 8 },
		{ fonction = etoileMer, nombre = 40 },
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
	local debut = DEBUT_SAUVAGE + Biomes.debut(numero)
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
-- Barrières du bord de la carte : un rempart décoré par biome (lisses
-- continues + poteaux réguliers + ornement), et des murs invisibles très
-- hauts derrière, pour qu'aucun joueur ne sorte ni ne tombe.

type Lisse = { y: number, h: number, e: number, c: { number }, m: string?, tr: number? }
type Poteau = {
	t: { number },
	ecart: number,
	c: { number },
	alterne: { number }?,
	m: string?,
	y: number?, -- bas du poteau (0 = au sol)
	neon: boolean?,
}
type Rempart = { lisses: { Lisse }, poteau: Poteau?, cime: Poteau? }

local BOIS_BLANC = { 245, 240, 230 }
local REMPARTS: { [string]: Rempart } = {
	Prairie = {
		lisses = {
			{ y = 2, h = 0.8, e = 0.6, c = BOIS_BLANC },
			{ y = 4.5, h = 0.8, e = 0.6, c = BOIS_BLANC },
		},
		poteau = { t = { 1.2, 6, 1.2 }, ecart = 10, c = BOIS_BLANC },
		cime = { t = { 1.5, 0.6, 1.5 }, ecart = 10, c = { 230, 70, 70 }, y = 6 },
	},
	BoisMoussu = {
		lisses = {
			{ y = 3, h = 6, e = 4, c = { 115, 115, 105 }, m = "Slate" },
			{ y = 6.4, h = 0.8, e = 4.4, c = { 90, 160, 80 }, m = "Grass" },
		},
		poteau = { t = { 3, 14, 3 }, ecart = 24, c = { 100, 70, 45 }, m = "Wood" },
		cime = { t = { 8, 5, 8 }, ecart = 24, c = { 50, 130, 75 }, y = 13 },
	},
	Dunes = {
		lisses = { { y = 5, h = 10, e = 4, c = { 225, 185, 120 }, m = "Sandstone" } },
		poteau = { t = { 3, 3, 4.4 }, ecart = 6, c = { 210, 165, 100 }, m = "Sandstone", y = 10 },
	},
	Glacier = {
		lisses = { { y = 6, h = 12, e = 3, c = { 175, 220, 255 }, m = "Ice", tr = 0.15 } },
		poteau = { t = { 2.4, 17, 2.4 }, ecart = 18, c = { 230, 245, 255 }, m = "Ice" },
		cime = { t = { 1.6, 1.6, 1.6 }, ecart = 18, c = { 150, 230, 255 }, y = 17, neon = true },
	},
	Volcan = {
		lisses = {
			{ y = 7, h = 14, e = 6, c = { 50, 40, 45 }, m = "Basalt" },
			{ y = 4, h = 0.6, e = 6.2, c = { 255, 110, 30 }, m = "Neon" },
		},
		poteau = { t = { 4, 18, 4 }, ecart = 30, c = { 35, 28, 32 }, m = "Basalt" },
		cime = { t = { 2, 2, 2 }, ecart = 30, c = { 255, 150, 40 }, y = 18, neon = true },
	},
	Galaxie = {
		lisses = { { y = 10, h = 20, e = 0.4, c = { 170, 120, 255 }, m = "ForceField", tr = 0.3 } },
		poteau = { t = { 2, 12, 2 }, ecart = 30, c = { 90, 230, 255 }, neon = true },
		cime = { t = { 1.6, 1.6, 1.6 }, ecart = 30, c = { 255, 120, 220 }, y = 12, neon = true },
	},
	Marais = {
		lisses = {
			{ y = 2.5, h = 0.8, e = 0.6, c = { 90, 75, 60 }, m = "Wood" },
			{ y = 5, h = 0.8, e = 0.6, c = { 90, 75, 60 }, m = "Wood" },
		},
		poteau = {
			t = { 1, 7, 1 },
			ecart = 6,
			c = { 75, 60, 50 },
			alterne = { 100, 130, 75 },
			m = "Wood",
		},
	},
	Recif = {
		lisses = { { y = 3, h = 6, e = 4, c = { 255, 140, 130 }, m = "Slate" } },
		poteau = {
			t = { 1.6, 11, 1.6 },
			ecart = 8,
			c = { 255, 170, 70 },
			alterne = { 170, 110, 230 },
		},
		cime = { t = { 2.4, 1.2, 2.4 }, ecart = 16, c = { 80, 210, 200 }, y = 11 },
	},
	Bonbon = {
		lisses = { { y = 3.5, h = 1, e = 1, c = { 255, 255, 255 } } },
		poteau = {
			t = { 1.4, 7, 1.4 },
			ecart = 5,
			c = { 230, 50, 60 },
			alterne = { 255, 255, 255 },
		},
		cime = { t = { 2, 2, 2 }, ecart = 5, c = { 255, 150, 200 }, y = 7 },
	},
	Jungle = {
		lisses = { { y = 6, h = 12, e = 5, c = { 40, 110, 55 }, m = "Grass" } },
		poteau = { t = { 3, 16, 3 }, ecart = 26, c = { 105, 75, 50 }, m = "Wood" },
		cime = { t = { 9, 4, 9 }, ecart = 26, c = { 60, 160, 70 }, y = 15 },
	},
	Ciel = {
		lisses = { { y = 3, h = 6, e = 6, c = { 250, 252, 255 } } },
		poteau = { t = { 2.4, 12, 2.4 }, ecart = 20, c = { 240, 238, 230 }, m = "Marble" },
		cime = { t = { 3.2, 1, 3.2 }, ecart = 20, c = { 255, 215, 120 }, y = 12 },
	},
	Manoir = {
		lisses = {
			{ y = 1, h = 2, e = 1.4, c = { 110, 105, 120 }, m = "Cobblestone" },
			{ y = 9.5, h = 0.5, e = 0.5, c = { 40, 35, 45 }, m = "Metal" },
		},
		poteau = { t = { 0.4, 8, 0.4 }, ecart = 4, c = { 40, 35, 45 }, m = "Metal", y = 2 },
		cime = { t = { 0.8, 0.8, 0.8 }, ecart = 4, c = { 60, 55, 70 }, y = 10 },
	},
	Savane = {
		lisses = {
			{ y = 2.5, h = 0.6, e = 0.6, c = { 160, 120, 70 }, m = "Wood" },
			{ y = 5, h = 0.6, e = 0.6, c = { 160, 120, 70 }, m = "Wood" },
		},
		poteau = { t = { 1, 7, 1 }, ecart = 8, c = { 140, 100, 60 }, m = "Wood" },
		cime = { t = { 6, 1.2, 4 }, ecart = 48, c = { 120, 160, 60 }, y = 9 },
	},
	Mecanique = {
		lisses = {
			{ y = 4, h = 8, e = 2, c = { 120, 115, 110 }, m = "DiamondPlate" },
			{ y = 8.3, h = 0.6, e = 2.2, c = { 215, 170, 80 }, m = "Metal" },
		},
		poteau = { t = { 2, 10, 2 }, ecart = 16, c = { 200, 120, 70 }, m = "Metal" },
		cime = { t = { 1.4, 1.4, 1.4 }, ecart = 16, c = { 255, 210, 120 }, y = 10, neon = true },
	},
	Zen = {
		lisses = {
			{ y = 3, h = 6, e = 1.4, c = { 245, 240, 225 }, m = "Plaster" },
			{ y = 6.4, h = 0.8, e = 2.4, c = { 60, 55, 60 }, m = "Slate" },
		},
		poteau = { t = { 1.6, 7, 1.6 }, ecart = 14, c = { 210, 50, 50 } },
	},
	Cavernes = {
		lisses = { { y = 7, h = 14, e = 5, c = { 80, 75, 95 }, m = "Slate" } },
		poteau = {
			t = { 2, 6, 2 },
			ecart = 12,
			c = { 120, 220, 255 },
			alterne = { 190, 110, 255 },
			y = 14,
			neon = true,
		},
	},
	Jouets = {
		lisses = { { y = 2, h = 4, e = 3, c = { 60, 130, 230 } } },
		poteau = {
			t = { 3, 3, 3 },
			ecart = 3,
			c = { 230, 60, 60 },
			alterne = { 255, 210, 50 },
			y = 4,
		},
	},
	Automne = {
		lisses = {
			{ y = 1.2, h = 2.4, e = 2.6, c = { 130, 120, 110 }, m = "Cobblestone" },
			{ y = 2.7, h = 0.6, e = 3, c = { 230, 120, 40 }, m = "Grass" },
		},
		poteau = { t = { 2, 12, 2 }, ecart = 22, c = { 100, 70, 50 }, m = "Wood" },
		cime = { t = { 7, 4, 7 }, ecart = 22, c = { 230, 110, 40 }, y = 11 },
	},
	Ferme = {
		lisses = {
			{ y = 1.5, h = 0.5, e = 0.4, c = { 210, 60, 50 }, m = "Wood" },
			{ y = 3, h = 0.5, e = 0.4, c = { 210, 60, 50 }, m = "Wood" },
			{ y = 4.5, h = 0.5, e = 0.4, c = { 210, 60, 50 }, m = "Wood" },
		},
		poteau = { t = { 0.8, 5.5, 0.8 }, ecart = 8, c = { 245, 240, 230 }, m = "Wood" },
	},
	Reves = {
		lisses = { { y = 3, h = 6, e = 4, c = { 200, 190, 255 }, m = "Fabric" } },
		poteau = {
			t = { 1.6, 1.6, 1.6 },
			ecart = 10,
			c = { 255, 240, 150 },
			alterne = { 255, 200, 230 },
			y = 6.4,
			neon = true,
		},
	},
	Plage = {
		lisses = { { y = 1.5, h = 3, e = 3, c = { 240, 210, 145 }, m = "Sand" } },
		poteau = { t = { 1.4, 8, 1.4 }, ecart = 20, c = { 170, 130, 80 }, m = "Wood" },
		cime = { t = { 5, 1, 5 }, ecart = 20, c = { 60, 170, 70 }, y = 8 },
	},
}

local function materiau(nom: string?): Enum.Material
	if nom == nil then
		return Enum.Material.SmoothPlastic
	end
	local ok, m = pcall(function()
		return (Enum.Material :: any)[nom]
	end)
	return if ok and m then m else Enum.Material.SmoothPlastic
end

local function couleurRgb(c: { number }): Color3
	return Color3.fromRGB(c[1], c[2], c[3])
end

-- Rempart de `debut` à `fin` (au sol, en ligne droite), style `spec`.
local function rempart(parent: Instance, spec: Rempart, debut: Vector3, fin: Vector3)
	local longueur = (fin - debut).Magnitude
	if longueur < 1 then
		return
	end
	local axe = CFrame.lookAt(debut, fin) -- -Z = le long du rempart
	for i, lisse in spec.lisses do
		local p = bloc(
			parent,
			"Lisse" .. i,
			Vector3.new(lisse.e, lisse.h, longueur),
			axe * CFrame.new(0, lisse.y, -longueur / 2),
			couleurRgb(lisse.c),
			true
		)
		p.Material = materiau(lisse.m)
		if lisse.tr then
			p.Transparency = lisse.tr
		end
	end
	for _, serie in { spec.poteau, spec.cime } do
		if serie then
			local n = math.floor(longueur / serie.ecart)
			for k = 0, n do
				local c = if serie.alterne and k % 2 == 1 then serie.alterne else serie.c
				local p = bloc(
					parent,
					"Poteau",
					Vector3.new(serie.t[1], serie.t[2], serie.t[3]),
					axe * CFrame.new(0, (serie.y or 0) + serie.t[2] / 2, -k * serie.ecart),
					couleurRgb(c),
					true
				)
				p.Material = if serie.neon then Enum.Material.Neon else materiau(serie.m)
			end
		end
	end
end

-- Mur invisible et très haut (collision seulement), découpé en morceaux de
-- 2 000 studs au plus.
local function murInvisible(parent: Instance, debut: Vector3, fin: Vector3)
	local longueur = (fin - debut).Magnitude
	local morceaux = math.max(1, math.ceil(longueur / 2000))
	local pas = longueur / morceaux
	local axe = CFrame.lookAt(debut, fin)
	for k = 0, morceaux - 1 do
		local p = bloc(
			parent,
			"MurInvisible",
			Vector3.new(4, 1000, pas + 4),
			axe * CFrame.new(0, 500, -(k + 0.5) * pas),
			Color3.new(1, 1, 1),
			true
		)
		p.Transparency = 1
		p.CastShadow = false
	end
end

-- Murs du bord de la carte : chaque biome est une « boîte » ouverte sur le
-- ciel (pas de plafond), dont les murs portent un vrai décor à son image :
-- falaises et arbres, grès, glace, basalte et lave, cosmos et cristaux,
-- pierre hantée, coraux, bonbons, nuages, usine, bambous, grotte, jouets.
-- Tout est posé derrière le rempart (hors de la zone de jeu).

local MUR_X = DEMI_LARGEUR + 16 -- fond du mur (studs du centre)
local PAS_MOTIF = 30 -- studs entre deux motifs le long d'un mur

type Palette = { fond: Color3, roche: Color3, dessus: Color3, accent: Color3 }
type Motif = (parent: Instance, cote: number, z: number, h: Random, p: Palette) -> ()

local function fonce(c: Color3, part: number): Color3
	return c:Lerp(Color3.fromRGB(30, 26, 36), part)
end

local function clair(c: Color3, part: number): Color3
	return c:Lerp(Color3.new(1, 1, 1), part)
end

-- Bloc posé contre le mur : `x` = distance du mur vers l'intérieur.
local function contre(
	parent: Instance,
	cote: number,
	x: number,
	z: number,
	taille: Vector3,
	y: number,
	couleur: Color3,
	matiere: Enum.Material,
	forme: Enum.PartType?
): Part
	local p = piece(
		parent,
		"Mur",
		forme or Enum.PartType.Block,
		taille,
		CFrame.new(cote * (MUR_X - x), y, z),
		couleur
	)
	p.Material = matiere
	return p
end

-- Strates de roche irrégulières (falaise), dessus herbu ou neigeux.
local function strates(
	parent: Instance,
	cote: number,
	z: number,
	h: Random,
	p: Palette,
	matiere: Enum.Material,
)
	local y = 0
	local k = 0
	while y < HAUTEUR_PAROI - 4 do
		local hauteur = h:NextNumber(9, 16)
		local profondeur = h:NextNumber(6, 13) - k * 0.4
		local couleur = if k % 2 == 0 then p.roche else fonce(p.roche, 0.15)
		contre(
			parent,
			cote,
			math.max(2, profondeur) / 2,
			z + h:NextNumber(-3, 3),
			Vector3.new(math.max(2, profondeur), hauteur, PAS_MOTIF + h:NextNumber(0, 8)),
			y + hauteur / 2,
			couleur,
			matiere
		)
		y += hauteur
		k += 1
	end
	contre(
		parent,
		cote,
		3,
		z,
		Vector3.new(7, 2.5, PAS_MOTIF + 6),
		y + 1,
		p.dessus,
		Enum.Material.Grass,
	)
end

local function arbreSommet(parent: Instance, cote: number, z: number, h: Random, p: Palette)
	local y = HAUTEUR_PAROI
	contre(
		parent,
		cote,
		4,
		z,
		Vector3.new(2, 10, 2),
		y + 5,
		fonce(p.roche, 0.4),
		Enum.Material.Wood,
	)
	for k = 1, 3 do
		local d = h:NextNumber(9, 14)
		contre(
			parent,
			cote,
			4 + h:NextNumber(-3, 3),
			z + h:NextNumber(-4, 4),
			Vector3.one * d,
			y + 10 + k * 2,
			p.accent:Lerp(p.dessus, k / 4),
			Enum.Material.Grass,
			Enum.PartType.Ball
		)
	end
end

local MOTIFS: { [string]: Motif } = {}

function MOTIFS.Falaise(parent, cote, z, h, p)
	strates(parent, cote, z, h, p, Enum.Material.Slate)
	if h:NextNumber() < 0.6 then
		arbreSommet(parent, cote, z, h, p)
	end
	-- Lierre qui pend.
	for _ = 1, 2 do
		local longueur = h:NextNumber(12, 30)
		contre(
			parent,
			cote,
			13,
			z + h:NextNumber(-12, 12),
			Vector3.new(1, longueur, 3),
			HAUTEUR_PAROI - longueur / 2,
			p.dessus,
			Enum.Material.Grass
		)
	end
end

function MOTIFS.Gres(parent, cote, z, h, p)
	strates(parent, cote, z, h, p, Enum.Material.Sandstone)
	if h:NextNumber() < 0.4 then
		local y = HAUTEUR_PAROI
		contre(parent, cote, 4, z, Vector3.new(3, 12, 3), y + 6, p.accent, Enum.Material.Grass)
		contre(parent, cote, 4, z + 3, Vector3.new(2, 5, 6), y + 6, p.accent, Enum.Material.Grass)
	end
end

function MOTIFS.Glace(parent, cote, z, h, p)
	strates(parent, cote, z, h, p, Enum.Material.Glacier)
	for _ = 1, 3 do
		local longueur = h:NextNumber(6, 14)
		local pic = contre(
			parent,
			cote,
			12,
			z + h:NextNumber(-12, 12),
			Vector3.new(2.5, longueur, 2.5),
			HAUTEUR_PAROI - 2 - longueur / 2,
			clair(p.accent, 0.5),
			Enum.Material.Ice
		)
		pic.Transparency = 0.2
	end
end

function MOTIFS.Basalte(parent, cote, z, h, p)
	for i = -2, 2 do
		local hauteur = HAUTEUR_PAROI * h:NextNumber(0.7, 1.05)
		contre(
			parent,
			cote,
			h:NextNumber(3, 8),
			z + i * 6,
			Vector3.new(6, hauteur, 5.6),
			hauteur / 2,
			if i % 2 == 0 then p.roche else fonce(p.roche, 0.2),
			Enum.Material.Basalt
		)
	end
	-- Coulée de lave qui brille.
	local coulee = contre(
		parent,
		cote,
		10,
		z + h:NextNumber(-10, 10),
		Vector3.new(0.6, HAUTEUR_PAROI * 0.8, 2),
		HAUTEUR_PAROI * 0.4,
		p.accent,
		Enum.Material.Neon
	)
	coulee.Transparency = 0.1
end

function MOTIFS.Cosmos(parent, cote, z, h, p)
	contre(
		parent,
		cote,
		3,
		z,
		Vector3.new(6, HAUTEUR_PAROI, PAS_MOTIF),
		HAUTEUR_PAROI / 2,
		p.roche,
		Enum.Material.Slate,
	)
	for _ = 1, 3 do
		local d = h:NextNumber(3, 7)
		local cristal = contre(
			parent,
			cote,
			7,
			z + h:NextNumber(-12, 12),
			Vector3.new(d, d * 2.2, d),
			h:NextNumber(10, HAUTEUR_PAROI - 10),
			p.accent,
			Enum.Material.Neon
		)
		cristal.Transparency = 0.15
	end
	for _ = 1, 4 do
		contre(
			parent,
			cote,
			6.5,
			z + h:NextNumber(-14, 14),
			Vector3.one * h:NextNumber(0.8, 1.6),
			h:NextNumber(5, HAUTEUR_PAROI),
			Color3.new(1, 1, 1),
			Enum.Material.Neon,
			Enum.PartType.Ball
		)
	end
end

function MOTIFS.Pierre(parent, cote, z, h, p)
	contre(
		parent,
		cote,
		3,
		z,
		Vector3.new(6, HAUTEUR_PAROI - 10, PAS_MOTIF),
		(HAUTEUR_PAROI - 10) / 2,
		p.roche,
		Enum.Material.Brick,
	)
	-- Créneaux.
	for i = -1, 1 do
		contre(
			parent,
			cote,
			3,
			z + i * 10,
			Vector3.new(6, 8, 6),
			HAUTEUR_PAROI - 6,
			fonce(p.roche, 0.1),
			Enum.Material.Brick
		)
	end
	-- Fenêtre allumée, parfois.
	if h:NextNumber() < 0.5 then
		contre(
			parent,
			cote,
			6.2,
			z,
			Vector3.new(0.4, 7, 4),
			h:NextNumber(20, HAUTEUR_PAROI - 25),
			p.accent,
			Enum.Material.Neon
		)
	end
end

function MOTIFS.Corail(parent, cote, z, h, p)
	contre(
		parent,
		cote,
		2,
		z,
		Vector3.new(4, HAUTEUR_PAROI, PAS_MOTIF),
		HAUTEUR_PAROI / 2,
		p.roche,
		Enum.Material.Sand,
	)
	for _ = 1, 6 do
		local d = h:NextNumber(6, 14)
		contre(
			parent,
			cote,
			h:NextNumber(4, 8),
			z + h:NextNumber(-12, 12),
			Vector3.one * d,
			h:NextNumber(3, HAUTEUR_PAROI * 0.7),
			p.accent:Lerp(p.dessus, h:NextNumber()),
			Enum.Material.SmoothPlastic,
			Enum.PartType.Ball
		)
	end
end

function MOTIFS.Bonbon(parent, cote, z, h, p)
	local bandes = 6
	for i = 0, bandes - 1 do
		local hauteur = HAUTEUR_PAROI / bandes
		contre(
			parent,
			cote,
			3,
			z,
			Vector3.new(6, hauteur, PAS_MOTIF),
			(i + 0.5) * hauteur,
			if i % 2 == 0 then p.accent else clair(p.dessus, 0.4),
			Enum.Material.SmoothPlastic
		)
	end
	-- Glaçage qui coule, et sucette au sommet.
	for _ = 1, 3 do
		local longueur = h:NextNumber(5, 14)
		contre(
			parent,
			cote,
			6.2,
			z + h:NextNumber(-12, 12),
			Vector3.new(1, longueur, 3),
			HAUTEUR_PAROI - longueur / 2,
			Color3.fromRGB(255, 250, 245),
			Enum.Material.SmoothPlastic
		)
	end
	if h:NextNumber() < 0.5 then
		contre(
			parent,
			cote,
			4,
			z,
			Vector3.new(1.2, 14, 1.2),
			HAUTEUR_PAROI + 7,
			Color3.new(1, 1, 1),
			Enum.Material.SmoothPlastic,
		)
		contre(
			parent,
			cote,
			4,
			z,
			Vector3.new(3, 12, 12),
			HAUTEUR_PAROI + 16,
			p.dessus,
			Enum.Material.SmoothPlastic,
			Enum.PartType.Cylinder,
		)
	end
end

function MOTIFS.Nuages(parent, cote, z, h, p)
	for _ = 1, 7 do
		local d = h:NextNumber(14, 26)
		contre(
			parent,
			cote,
			h:NextNumber(4, 10),
			z + h:NextNumber(-12, 12),
			Vector3.one * d,
			h:NextNumber(4, HAUTEUR_PAROI),
			clair(p.roche, h:NextNumber(0.5, 0.9)),
			Enum.Material.SmoothPlastic,
			Enum.PartType.Ball
		)
	end
end

function MOTIFS.Usine(parent, cote, z, h, p)
	contre(
		parent,
		cote,
		3,
		z,
		Vector3.new(6, HAUTEUR_PAROI, PAS_MOTIF),
		HAUTEUR_PAROI / 2,
		p.roche,
		Enum.Material.DiamondPlate,
	)
	for _, y in { HAUTEUR_PAROI * 0.3, HAUTEUR_PAROI * 0.65 } do
		local tuyau = contre(
			parent,
			cote,
			7,
			z,
			Vector3.new(PAS_MOTIF + 1, 3, 3),
			y,
			fonce(p.accent, 0.2),
			Enum.Material.Metal,
			Enum.PartType.Cylinder
		)
		tuyau.CFrame *= CFrame.Angles(0, math.rad(90), 0)
	end
	local d = h:NextNumber(10, 18)
	local roue = contre(
		parent,
		cote,
		6.5,
		z,
		Vector3.new(1.5, d, d),
		h:NextNumber(20, HAUTEUR_PAROI - 15),
		p.accent,
		Enum.Material.Metal,
		Enum.PartType.Cylinder
	)
	roue.Name = "Engrenage"
end

function MOTIFS.Bambou(parent, cote, z, h, p)
	for i = -3, 3 do
		local hauteur = HAUTEUR_PAROI * h:NextNumber(0.75, 1.1)
		-- Cylindre debout : couché le long de X, puis redressé.
		local tige = contre(
			parent,
			cote,
			h:NextNumber(2, 6),
			z + i * 4,
			Vector3.new(hauteur, 2.4, 2.4),
			hauteur / 2,
			p.accent:Lerp(p.dessus, h:NextNumber(0, 0.4)),
			Enum.Material.SmoothPlastic,
			Enum.PartType.Cylinder
		)
		tige.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	end
	contre(
		parent,
		cote,
		2,
		z,
		Vector3.new(2, HAUTEUR_PAROI, PAS_MOTIF),
		HAUTEUR_PAROI / 2,
		fonce(p.roche, 0.3),
		Enum.Material.Wood,
	)
end

function MOTIFS.Grotte(parent, cote, z, h, p)
	strates(parent, cote, z, h, p, Enum.Material.Slate)
	for _ = 1, 2 do
		local d = h:NextNumber(3, 6)
		local cristal = contre(
			parent,
			cote,
			11,
			z + h:NextNumber(-10, 10),
			Vector3.new(d, d * 3, d),
			h:NextNumber(8, HAUTEUR_PAROI - 12),
			p.accent,
			Enum.Material.Neon
		)
		cristal.CFrame *= CFrame.Angles(0, 0, math.rad(h:NextNumber(-30, 30)))
	end
end

function MOTIFS.Jouets(parent, cote, z, h, p)
	local couleurs = {
		Color3.fromRGB(255, 80, 80),
		Color3.fromRGB(80, 160, 255),
		Color3.fromRGB(255, 210, 60),
		Color3.fromRGB(90, 210, 110),
		p.accent,
	}
	local y = 0
	while y < HAUTEUR_PAROI - 6 do
		local hauteur = h:NextNumber(8, 14)
		local cube = contre(
			parent,
			cote,
			h:NextNumber(4, 8),
			z + h:NextNumber(-6, 6),
			Vector3.new(h:NextNumber(8, 14), hauteur, h:NextNumber(12, 22)),
			y + hauteur / 2,
			couleurs[h:NextInteger(1, #couleurs)],
			Enum.Material.SmoothPlastic
		)
		cube.Name = "Cube"
		y += hauteur
	end
end

-- Style de mur par thème de décor.
local STYLES_MURS: { [string]: string } = {
	Prairie = "Falaise",
	Foret = "Falaise",
	Jungle = "Falaise",
	Savane = "Falaise",
	Automne = "Falaise",
	Ferme = "Falaise",
	Desert = "Gres",
	Plage = "Gres",
	Glace = "Glace",
	Volcan = "Basalte",
	Galaxie = "Cosmos",
	Reves = "Cosmos",
	Marais = "Pierre",
	Manoir = "Pierre",
	Recif = "Corail",
	Bonbon = "Bonbon",
	Ciel = "Nuages",
	Mecanique = "Usine",
	Zen = "Bambou",
	Cavernes = "Grotte",
	Jouets = "Jouets",
}

local function paletteBiome(biome: Biomes.Biome): Palette
	local bordure = couleurRgb(biome.Bordure)
	return {
		fond = fonce(bordure, 0.45),
		roche = fonce(bordure, 0.12),
		dessus = couleurRgb(biome.Sol),
		accent = bordure:Lerp(couleurRgb(biome.Brume), 0.35),
	}
end

-- Les deux murs d'un biome, de z1 à z2 : un fond uni (qui ferme la boîte)
-- et les motifs de son style tous les PAS_MOTIF studs.
local function paroisBiome(
	parent: Instance,
	biome: Biomes.Biome,
	numero: number,
	z1: number,
	z2: number,
)
	local palette = paletteBiome(biome)
	local motif = MOTIFS[STYLES_MURS[biome.Decor] or "Falaise"] or MOTIFS.Falaise
	local hasard = Random.new(GRAINE + numero * 131)
	local longueur = z2 - z1
	for _, cote in { -1, 1 } do
		local fond = bloc(
			parent,
			"Paroi",
			Vector3.new(4, HAUTEUR_PAROI, longueur),
			CFrame.new(cote * (MUR_X + 2), HAUTEUR_PAROI / 2, (z1 + z2) / 2),
			palette.fond,
			true
		)
		fond.Material = Enum.Material.Slate
		fond.CastShadow = false
		for z = z1 + PAS_MOTIF / 2, z2 - PAS_MOTIF / 4, PAS_MOTIF do
			motif(parent, cote, z, hasard, palette)
		end
	end
end

-- Mur plein d'un bout à l'autre de la largeur, au fond de la carte.
local function murFond(parent: Instance, biome: Biomes.Biome, z: number)
	local paroi = bloc(
		parent,
		"ParoiFond",
		Vector3.new(MUR_X * 2 + 8, HAUTEUR_PAROI, 4),
		CFrame.new(0, HAUTEUR_PAROI / 2, z),
		paletteBiome(biome).roche,
		true
	)
	paroi.Material = Enum.Material.Slate
	paroi.CastShadow = false
end

-- Remparts tout autour : chaque biome sur ses deux côtés, la Prairie derrière
-- les bases, le dernier biome au bout de la carte ; puis les murs invisibles.
-- Rempart d'un biome : le sien, sinon celui d'un biome au même décor.
local function specRempart(biome: Biomes.Biome): Rempart
	local spec = REMPARTS[biome.Id]
	if spec then
		return spec
	end
	for _, autre in Biomes.Liste do
		if autre.Decor == biome.Decor and REMPARTS[autre.Id] then
			return REMPARTS[autre.Id]
		end
	end
	return REMPARTS.Prairie
end

local function creerLimites(racine: Instance)
	local dossierLimites = dossier(racine, "Limites")
	local x = DEMI_LARGEUR - 2
	local arriere = BORD_BASES - 140
	local fin = DEBUT_SAUVAGE + Biomes.nombre() * Biomes.Longueur
	for numero, biome in Biomes.Liste do
		local spec = specRempart(biome)
		local z1 = if numero == 1 then arriere else DEBUT_SAUVAGE + Biomes.debut(numero)
		local z2 = DEBUT_SAUVAGE + Biomes.debut(numero) + Biomes.Longueur
		local groupe = dossier(dossierLimites, biome.Id)
		rempart(groupe, spec, Vector3.new(-x, 0, z1), Vector3.new(-x, 0, z2))
		rempart(groupe, spec, Vector3.new(x, 0, z1), Vector3.new(x, 0, z2))
		paroisBiome(groupe, biome, numero, z1, z2)
	end
	rempart(
		dossierLimites,
		REMPARTS.Prairie,
		Vector3.new(-x, 0, arriere),
		Vector3.new(x, 0, arriere)
	)
	local dernier = Biomes.Liste[Biomes.nombre()]
	rempart(
		dossierLimites,
		specRempart(dernier),
		Vector3.new(-x, 0, fin - 2),
		Vector3.new(x, 0, fin - 2)
	)
	-- Murs du fond (derrière les bases, au bout du dernier biome) : la boîte est fermée.
	murFond(dossierLimites, Biomes.Liste[1], arriere - 3)
	murFond(dossierLimites, dernier, fin + 1)
	local bord = DEMI_LARGEUR + 2
	murInvisible(dossierLimites, Vector3.new(-bord, 0, arriere - 4), Vector3.new(-bord, 0, fin + 4))
	murInvisible(dossierLimites, Vector3.new(bord, 0, arriere - 4), Vector3.new(bord, 0, fin + 4))
	murInvisible(
		dossierLimites,
		Vector3.new(-bord, 0, arriere - 4),
		Vector3.new(bord, 0, arriere - 4)
	)
	murInvisible(dossierLimites, Vector3.new(-bord, 0, fin + 2), Vector3.new(bord, 0, fin + 2))
end

---------------------------------------------------------------------------
-- Accueil du Pays des Graines : Pépin, la mascotte géante, et le panneau de
-- bienvenue, de part et d'autre du chemin de la base centrale.

local TAILLE_PEPIN = 16 -- studs (hauteur d'une unité du Bestiaire)

local function creerPepin(parent: Instance, position: Vector3)
	local espece = Bestiaire.Especes.Pepin
	if espece == nil then
		return
	end
	local modele = Instance.new("Model")
	modele.Name = "Pepin"
	local corps = Instance.new("Part")
	corps.Name = "Corps"
	corps.Size = Vector3.one * 2
	corps.Anchored = true
	corps.CanCollide = false
	corps.CanQuery = false
	corps.CanTouch = false
	-- Face avant (-Z) tournée vers les bases.
	corps.CFrame = CFrame.new(position + Vector3.new(0, TAILLE_PEPIN * 0.5, 0))
	corps.Parent = modele
	modele.PrimaryPart = corps
	Modeleur.construire(modele, corps, espece, TAILLE_PEPIN, Color3.fromRGB(255, 200, 80))
	modele:SetAttribute("Mascotte", true)
	-- Un socle de fleurs sous ses pieds.
	piece(
		modele,
		"Socle",
		Enum.PartType.Cylinder,
		Vector3.new(1, TAILLE_PEPIN * 0.75, TAILLE_PEPIN * 0.75),
		CFrame.new(position + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(120, 210, 90),
		true
	)
	for i = 0, 7 do
		local a = math.rad(i * 45)
		piece(
			modele,
			"Fleur",
			Enum.PartType.Ball,
			Vector3.one * 1.4,
			CFrame.new(
				position
					+ Vector3.new(
						math.cos(a) * TAILLE_PEPIN * 0.33,
						1.2,
						math.sin(a) * TAILLE_PEPIN * 0.33
					)
			),
			FLEURS[(i % #FLEURS) + 1]
		)
	end
	modele.Parent = parent
end

local function creerPanneauAccueil(parent: Instance, position: Vector3)
	local modele = Instance.new("Model")
	modele.Name = "PanneauAccueil"
	local bois = Color3.fromRGB(170, 115, 70)
	for _, x in { -6, 6 } do
		piece(
			modele,
			"Pied",
			Enum.PartType.Block,
			Vector3.new(1.2, 12, 1.2),
			CFrame.new(position + Vector3.new(x, 6, 0)),
			bois,
			true
		)
	end
	local planche = piece(
		modele,
		"Planche",
		Enum.PartType.Block,
		Vector3.new(16, 7, 1),
		CFrame.new(position + Vector3.new(0, 10, 0)),
		Color3.fromRGB(255, 225, 150),
		true
	)
	piece(
		modele,
		"Cadre",
		Enum.PartType.Block,
		Vector3.new(17, 7.8, 0.8),
		CFrame.new(position + Vector3.new(0, 10, 0.2)),
		bois
	)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.PixelsPerStud = 30
	gui.LightInfluence = 0.3
	gui.Parent = planche
	local titre = Instance.new("TextLabel")
	titre.Size = UDim2.fromScale(1, 0.55)
	titre.BackgroundTransparency = 1
	titre.Font = Enum.Font.FredokaOne
	titre.TextScaled = true
	titre.TextColor3 = Color3.fromRGB(255, 120, 60)
	titre.TextStrokeTransparency = 0
	titre.TextStrokeColor3 = Color3.fromRGB(90, 50, 30)
	titre.Text = "Bienvenue au Pays des Graines !"
	titre.Parent = gui
	local sous = titre:Clone()
	sous.Position = UDim2.fromScale(0.05, 0.55)
	sous.Size = UDim2.fromScale(0.9, 0.4)
	sous.TextColor3 = Color3.fromRGB(70, 140, 60)
	sous.Text = "Lance. Récolte. Collectionne. Va plus loin."
	sous.Parent = gui
	-- Petite pousse sur le panneau.
	piece(
		modele,
		"Pousse",
		Enum.PartType.Block,
		Vector3.new(0.6, 2.4, 0.6),
		CFrame.new(position + Vector3.new(7, 14.6, 0)),
		Color3.fromRGB(90, 160, 60)
	)
	piece(
		modele,
		"Feuille",
		Enum.PartType.Block,
		Vector3.new(2.4, 0.4, 1.2),
		CFrame.new(position + Vector3.new(8, 15.6, 0)) * CFrame.Angles(0, 0, math.rad(25)),
		Color3.fromRGB(110, 200, 80)
	)
	modele.Parent = parent
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
			local z = hasard:NextNumber(DEBUT_SAUVAGE + 12, FOND_SAUVAGE - 10)
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
	local fin = DEBUT_SAUVAGE + Biomes.nombre() * Biomes.Longueur
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
		local biome = Biomes.biome(Biomes.index(z - DEBUT_SAUVAGE))
		local couleur = if z < DEBUT_SAUVAGE + Biomes.Longueur
			then COULEURS.Colline
			else Color3.fromRGB(biome.Bordure[1], biome.Bordure[2], biome.Bordure[3])
		colline(bord, Vector3.new(-DEMI_LARGEUR - 15, 0, z), t, couleur)
		colline(bord, Vector3.new(DEMI_LARGEUR + 15, 0, z), t, couleur)
		z += 45
	end

	-- Remparts décorés et murs invisibles autour de toute la carte.
	creerLimites(racine)

	-- Accueil : Pépin et le panneau, entre la base centrale et ses voisines.
	local accueil = dossier(racine, "Accueil")
	creerPepin(accueil, Vector3.new(ECART_BASES / 2, 0, BORD_BASES + 40))
	creerPanneauAccueil(accueil, Vector3.new(-ECART_BASES / 2, 0, BORD_BASES + 34))

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

return Decor
