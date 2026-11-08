--!strict
-- Décor cartoon (serveur) : éclairage coloré, place de sable sous les bases,
-- chemins, arbres, rochers, fleurs, champignons, nuages, collines de bordure,
-- et ornements des bases. Purement visuel : aucune règle de jeu ne change.
-- Les pièces ne sont pas « interrogeables » (CanQuery = false) et, sauf les
-- troncs et les collines de bordure, ne bloquent rien.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local Decor = {}

-- Doit rester cohérent avec Bases (sol de 40, emplacements tous les 60 studs,
-- de -360 à +360) et TerresSauvages (800 de large, de Z = 20 à Z = 600).
local DEMI_LARGEUR = 400
local BORD_BASES = 20
local FOND_SAUVAGE = 600
local ECART_BASES = 60
local DEMI_SOL_BASE = 20
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
		Vector3.new(DEMI_LARGEUR * 2, 1, 100),
		CFrame.new(0, -0.55, BORD_BASES - 50),
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
	for _ = 1, 70 do
		arbre(nature, pointLibre(), hasard)
	end
	for _ = 1, 40 do
		rocher(nature, pointLibre(), hasard)
	end
	for _ = 1, 14 do
		champignon(nature, pointLibre(), hasard)
	end
	local fleurs = dossier(nature, "Fleurs")
	for _ = 1, 45 do
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
	for _ = 1, 30 do
		local x = hasard:NextNumber(-DEMI_LARGEUR + 10, DEMI_LARGEUR - 10)
		arbre(nature, Vector3.new(x, 0, hasard:NextNumber(-95, -40)), hasard)
	end

	-- Collines tout autour (fond, côtés, arrière).
	local bord = dossier(racine, "Bordure")
	local x = -DEMI_LARGEUR
	while x <= DEMI_LARGEUR do
		local t = hasard:NextNumber(50, 80)
		colline(bord, Vector3.new(x, 0, FOND_SAUVAGE + 15), t, COULEURS.Colline)
		colline(bord, Vector3.new(x, 0, -110), t * 0.8, COULEURS.CollineClaire)
		x += 45
	end
	local z = -100
	while z <= FOND_SAUVAGE do
		local t = hasard:NextNumber(50, 80)
		colline(bord, Vector3.new(-DEMI_LARGEUR - 15, 0, z), t, COULEURS.Colline)
		colline(bord, Vector3.new(DEMI_LARGEUR + 15, 0, z), t, COULEURS.Colline)
		z += 45
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
	local d = DEMI_SOL_BASE
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

---------------------------------------------------------------------------
-- Détails mignons d'une créature (reflets dans les yeux, joues, petits pieds).
-- `corps` est la boule principale, regard vers son LookVector.

function Decor.mignonner(modele: Model, corps: BasePart, taille: number)
	local t = taille
	local pieds = corps.Color:Lerp(Color3.new(0, 0, 0), 0.18)
	for _, cote in { -1, 1 } do
		local reflet = piece(
			modele,
			"Reflet",
			Enum.PartType.Ball,
			Vector3.one * t * 0.08,
			corps.CFrame * CFrame.new(cote * t * 0.2 + t * 0.04, t * 0.17, -t * 0.56),
			Color3.new(1, 1, 1)
		)
		reflet.CastShadow = false
		local joue = piece(
			modele,
			"Joue",
			Enum.PartType.Ball,
			Vector3.new(t * 0.2, t * 0.12, t * 0.08),
			corps.CFrame * CFrame.new(cote * t * 0.32, -t * 0.03, -t * 0.43),
			Color3.fromRGB(255, 140, 170)
		)
		joue.CastShadow = false
		piece(
			modele,
			"Pied",
			Enum.PartType.Ball,
			Vector3.new(t * 0.3, t * 0.18, t * 0.4),
			corps.CFrame * CFrame.new(cote * t * 0.22, -t * 0.45, -t * 0.05),
			pieds
		)
	end
end

---------------------------------------------------------------------------
-- Détails selon la rareté : plus la créature est rare, plus elle est ornée.
-- Commune : une pousse sur la tête (on lance des graines !).
-- Rare : + petites oreilles. Épique : + petites ailes et étincelles.
-- Légendaire : ailes, couronne dorée. Mythique : + auréole d'étoiles.

local VERT_POUSSE = Color3.fromRGB(90, 210, 70)
local OR = Color3.fromRGB(255, 205, 50)

local function rangDe(rarete: string): number
	local ordre: { string } = (Config :: any).Raretes.Ordre
	return table.find(ordre, rarete) or 1
end

local function pousse(modele: Model, corps: BasePart, t: number)
	local tige = piece(
		modele,
		"Tige",
		Enum.PartType.Cylinder,
		Vector3.new(t * 0.22, t * 0.06, t * 0.06),
		corps.CFrame * CFrame.new(0, t * 0.55, 0) * CFrame.Angles(0, 0, math.rad(90)),
		VERT_POUSSE
	)
	tige.CastShadow = false
	for _, cote in { -1, 1 } do
		local feuille = piece(
			modele,
			"Feuille",
			Enum.PartType.Ball,
			Vector3.new(t * 0.26, t * 0.06, t * 0.14),
			corps.CFrame
				* CFrame.new(cote * t * 0.12, t * 0.67, 0)
				* CFrame.Angles(0, 0, math.rad(cote * 25)),
			VERT_POUSSE
		)
		feuille.CastShadow = false
	end
end

local function oreilles(modele: Model, corps: BasePart, t: number)
	local fonce = corps.Color:Lerp(Color3.new(0, 0, 0), 0.15)
	for _, cote in { -1, 1 } do
		local cadre = corps.CFrame
			* CFrame.new(cote * t * 0.3, t * 0.42, 0)
			* CFrame.Angles(0, 0, math.rad(-cote * 22))
		piece(
			modele,
			"Oreille",
			Enum.PartType.Ball,
			Vector3.new(t * 0.22, t * 0.32, t * 0.12),
			cadre,
			fonce
		)
		piece(
			modele,
			"OreilleInterieur",
			Enum.PartType.Ball,
			Vector3.new(t * 0.12, t * 0.2, t * 0.06),
			cadre * CFrame.new(0, 0, -t * 0.04),
			Color3.fromRGB(255, 170, 200)
		)
	end
end

local function ailes(modele: Model, corps: BasePart, t: number)
	for _, cote in { -1, 1 } do
		local aile = piece(
			modele,
			"Aile",
			Enum.PartType.Ball,
			Vector3.new(t * 0.08, t * 0.36, t * 0.6),
			corps.CFrame
				* CFrame.new(cote * t * 0.5, t * 0.12, t * 0.15)
				* CFrame.Angles(math.rad(-20), 0, math.rad(cote * 30)),
			Color3.new(1, 1, 1)
		)
		aile.Transparency = 0.25
		aile.CastShadow = false
	end
end

local function couronne(modele: Model, corps: BasePart, t: number)
	local base = piece(
		modele,
		"Couronne",
		Enum.PartType.Cylinder,
		Vector3.new(t * 0.14, t * 0.4, t * 0.4),
		corps.CFrame * CFrame.new(0, t * 0.52, 0) * CFrame.Angles(0, 0, math.rad(90)),
		OR
	)
	base.Material = Enum.Material.Foil
	for i = 1, 5 do
		local angle = (i / 5) * math.pi * 2
		local pointe = piece(
			modele,
			"Couronne",
			Enum.PartType.Ball,
			Vector3.one * t * 0.1,
			corps.CFrame
				* CFrame.new(math.cos(angle) * t * 0.17, t * 0.64, math.sin(angle) * t * 0.17),
			OR
		)
		pointe.Material = Enum.Material.Foil
	end
end

local function aureole(modele: Model, corps: BasePart, t: number)
	for i = 1, 10 do
		local angle = (i / 10) * math.pi * 2
		local etoile = piece(
			modele,
			"Aureole",
			Enum.PartType.Ball,
			Vector3.one * t * 0.08,
			corps.CFrame
				* CFrame.new(math.cos(angle) * t * 0.32, t * 0.88, math.sin(angle) * t * 0.32),
			Color3.fromRGB(255, 250, 200)
		)
		etoile.Material = Enum.Material.Neon
		etoile.CastShadow = false
	end
end

local function etincelles(corps: BasePart, couleur: Color3, rang: number)
	local e = Instance.new("ParticleEmitter")
	e.Name = "Etincelles"
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(couleur, Color3.new(1, 1, 1))
	e.LightEmission = 1
	e.Size = NumberSequence.new(0.25, 0)
	e.Lifetime = NumberRange.new(0.6, 1.2)
	e.Speed = NumberRange.new(0.5, 1.5)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Rate = 3 * (rang - 2)
	e.Parent = corps
end

function Decor.detaillerCreature(modele: Model, corps: BasePart, taille: number, rarete: string)
	local rang = rangDe(rarete)
	if rang >= 4 then
		couronne(modele, corps, taille)
	else
		pousse(modele, corps, taille)
	end
	if rang >= 2 then
		oreilles(modele, corps, taille)
	end
	if rang >= 3 then
		ailes(modele, corps, taille)
		etincelles(corps, corps.Color, rang)
	end
	if rang >= 5 then
		aureole(modele, corps, taille)
	end
end

---------------------------------------------------------------------------
-- Détails des monstres selon leur zone (tous ont des pieds et des reflets).
-- Proche (gluant) : antenne et gouttes. Moyenne (grognon) : sourcils froncés,
-- petites cornes, piquants. Lointaine (costaud) : grandes cornes, dents,
-- petits bras, taches.

function Decor.detaillerMonstre(modele: Model, corps: BasePart, zone: string)
	local t = corps.Size.X
	local c = corps.CFrame
	local fonce = corps.Color:Lerp(Color3.new(0, 0, 0), 0.25)
	local clair = corps.Color:Lerp(Color3.new(1, 1, 1), 0.45)
	local creme = Color3.fromRGB(255, 240, 210)
	for _, cote in { -1, 1 } do
		piece(
			modele,
			"Pied",
			Enum.PartType.Ball,
			Vector3.new(t * 0.3, t * 0.16, t * 0.4),
			c * CFrame.new(cote * t * 0.22, -t * 0.46, -t * 0.08),
			fonce
		)
		local reflet = piece(
			modele,
			"Reflet",
			Enum.PartType.Ball,
			Vector3.one * t * 0.07,
			c * CFrame.new(cote * t * 0.2 + t * 0.04, t * 0.24, -t * 0.6),
			Color3.new(1, 1, 1)
		)
		reflet.CastShadow = false
	end

	if zone == "Proche" then
		piece(
			modele,
			"Antenne",
			Enum.PartType.Cylinder,
			Vector3.new(t * 0.3, t * 0.05, t * 0.05),
			c * CFrame.new(0, t * 0.6, 0) * CFrame.Angles(0, 0, math.rad(90)),
			fonce
		)
		local bout = piece(
			modele,
			"Antenne",
			Enum.PartType.Ball,
			Vector3.one * t * 0.14,
			c * CFrame.new(0, t * 0.78, 0),
			clair
		)
		bout.Material = Enum.Material.Neon
		for i, x in { -0.32, 0.1, 0.36 } do
			piece(
				modele,
				"Goutte",
				Enum.PartType.Ball,
				Vector3.new(t * 0.12, t * 0.18, t * 0.12),
				c * CFrame.new(x * t, -t * 0.3 - i * t * 0.02, (i - 2) * t * 0.15 - t * 0.2),
				clair
			)
		end
	elseif zone == "Moyenne" then
		for _, cote in { -1, 1 } do
			piece(
				modele,
				"Sourcil",
				Enum.PartType.Block,
				Vector3.new(t * 0.3, t * 0.06, t * 0.06),
				c
					* CFrame.new(cote * t * 0.2, t * 0.4, -t * 0.42)
					* CFrame.Angles(0, 0, math.rad(cote * 18)),
				Color3.fromRGB(60, 30, 20)
			)
			piece(
				modele,
				"Corne",
				Enum.PartType.Ball,
				Vector3.new(t * 0.12, t * 0.26, t * 0.12),
				c
					* CFrame.new(cote * t * 0.22, t * 0.5, 0)
					* CFrame.Angles(0, 0, math.rad(-cote * 20)),
				creme
			)
		end
		for i = 1, 3 do
			piece(
				modele,
				"Piquant",
				Enum.PartType.Ball,
				Vector3.new(t * 0.1, t * 0.22, t * 0.14),
				c
					* CFrame.new(0, t * (0.42 - i * 0.12), t * (0.28 + i * 0.06))
					* CFrame.Angles(math.rad(40 + i * 15), 0, 0),
				fonce
			)
		end
	else
		for _, cote in { -1, 1 } do
			piece(
				modele,
				"Corne",
				Enum.PartType.Ball,
				Vector3.new(t * 0.14, t * 0.4, t * 0.14),
				c
					* CFrame.new(cote * t * 0.3, t * 0.5, 0)
					* CFrame.Angles(0, 0, math.rad(-cote * 30)),
				creme
			)
			piece(
				modele,
				"Dent",
				Enum.PartType.Block,
				Vector3.new(t * 0.08, t * 0.1, t * 0.04),
				c * CFrame.new(cote * t * 0.08, -t * 0.08, -t * 0.52),
				Color3.new(1, 1, 1)
			)
			piece(
				modele,
				"Bras",
				Enum.PartType.Ball,
				Vector3.new(t * 0.18, t * 0.32, t * 0.18),
				c
					* CFrame.new(cote * t * 0.52, -t * 0.1, -t * 0.05)
					* CFrame.Angles(0, 0, math.rad(cote * 25)),
				fonce
			)
		end
		for _, p in { { -0.25, 0.1, 0.35 }, { 0.3, -0.05, 0.38 }, { 0, 0.3, 0.38 } } do
			piece(
				modele,
				"Tache",
				Enum.PartType.Ball,
				Vector3.one * t * 0.14,
				c * CFrame.new(p[1] * t, p[2] * t, p[3] * t),
				clair
			)
		end
	end
end

return Decor
