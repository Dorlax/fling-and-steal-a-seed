--!strict
-- Ciel propre à chaque biome (côté client, affichage seulement) : soleil,
-- planètes, lunes, aurore, étoiles, bulles, nuages, montgolfières ou orage.
-- Les éléments sont des pièces locales placées loin du joueur, qui suivent la
-- caméra : ils restent toujours au même endroit du ciel, comme le soleil.
-- Aucun plafond : rien n'est posé au-dessus de la carte.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local CielBiome = {}

local DISTANCE = 650 -- studs entre la caméra et les éléments du ciel

type Element = {
	part: BasePart,
	direction: Vector3, -- direction depuis la caméra (unitaire)
	distance: number,
	mouvement: string?, -- "monte", "flotte", "derive", "ondule", "clignote"
	phase: number,
}

local elements: { Element } = {}
local modele: Model? = nil
local connexion: RBXScriptConnection? = nil
local debut = os.clock()

-- Direction depuis l'azimut (degrés, 0 = devant les bases, vers +Z) et
-- l'élévation (degrés au-dessus de l'horizon).
local function direction(azimut: number, elevation: number): Vector3
	local a, e = math.rad(azimut), math.rad(elevation)
	return Vector3.new(math.sin(a) * math.cos(e), math.sin(e), math.cos(a) * math.cos(e))
end

local function piece(
	taille: Vector3,
	couleur: Color3,
	matiere: Enum.Material,
	forme: Enum.PartType?
): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = taille
	p.Color = couleur
	p.Material = matiere
	if forme then
		p.Shape = forme
	end
	p.Parent = modele
	return p
end

local function ajouter(
	p: BasePart,
	azimut: number,
	elevation: number,
	mouvement: string?,
	distance: number?
)
	table.insert(elements, {
		part = p,
		direction = direction(azimut, elevation),
		distance = distance or DISTANCE,
		mouvement = mouvement,
		phase = #elements * 1.7,
	})
end

local function boule(diametre: number, couleur: Color3, matiere: Enum.Material?): Part
	return piece(
		Vector3.one * diametre,
		couleur,
		matiere or Enum.Material.SmoothPlastic,
		Enum.PartType.Ball
	)
end

-- Variante plus claire ou plus sombre d'une couleur.
local function nuance(c: Color3, vers: Color3, part: number): Color3
	return c:Lerp(vers, part)
end

local BLANC = Color3.new(1, 1, 1)
local NOIR = Color3.new(0, 0, 0)

local CONSTRUCTEURS: { [string]: (couleur: Color3, hasard: Random) -> () } = {}

function CONSTRUCTEURS.Soleil(couleur: Color3, _hasard: Random)
	ajouter(boule(90, couleur, Enum.Material.Neon), 35, 32)
	local halo = boule(150, nuance(couleur, BLANC, 0.4), Enum.Material.Neon)
	halo.Transparency = 0.85
	ajouter(halo, 35, 32, nil, DISTANCE + 5)
	CONSTRUCTEURS.Nuages(BLANC, Random.new(7))
end

function CONSTRUCTEURS.Planetes(couleur: Color3, hasard: Random)
	local grande = boule(220, couleur)
	ajouter(grande, -40, 30)
	local teinteAnneau = nuance(couleur, BLANC, 0.5)
	local anneau =
		piece(Vector3.new(2, 380, 380), teinteAnneau, Enum.Material.Neon, Enum.PartType.Cylinder)
	anneau.Transparency = 0.55
	ajouter(anneau, -40, 30, "anneau")
	ajouter(boule(90, nuance(couleur, Color3.fromRGB(120, 200, 255), 0.6)), 50, 45)
	ajouter(boule(50, nuance(couleur, Color3.fromRGB(255, 220, 120), 0.6)), 15, 60)
	CONSTRUCTEURS.Etoiles(BLANC, hasard)
end

function CONSTRUCTEURS.Lunes(couleur: Color3, hasard: Random)
	ajouter(boule(130, couleur, Enum.Material.Neon), -25, 38)
	local creux = boule(40, nuance(couleur, NOIR, 0.25))
	ajouter(creux, -21, 41, nil, DISTANCE - 60)
	ajouter(boule(45, nuance(couleur, BLANC, 0.4), Enum.Material.Neon), 30, 55)
	CONSTRUCTEURS.Etoiles(BLANC, hasard)
end

function CONSTRUCTEURS.Aurore(couleur: Color3, hasard: Random)
	for i = 0, 6 do
		local voile = piece(
			Vector3.new(160, 90, 1),
			nuance(couleur, Color3.fromRGB(150, 120, 255), i / 7),
			Enum.Material.Neon
		)
		voile.Transparency = 0.6
		ajouter(voile, -60 + i * 20, 40 + math.sin(i) * 6, "ondule")
	end
	CONSTRUCTEURS.Etoiles(BLANC, hasard)
end

function CONSTRUCTEURS.Etoiles(couleur: Color3, hasard: Random)
	for _ = 1, 90 do
		local etoile = boule(hasard:NextNumber(2, 5), couleur, Enum.Material.Neon)
		ajouter(
			etoile,
			hasard:NextNumber(0, 360),
			hasard:NextNumber(18, 85),
			"clignote",
			DISTANCE + hasard:NextNumber(-40, 40)
		)
	end
end

function CONSTRUCTEURS.Bulles(couleur: Color3, hasard: Random)
	for _ = 1, 28 do
		local teinte = nuance(couleur, BLANC, 0.3)
		local bulle = boule(hasard:NextNumber(12, 34), teinte, Enum.Material.Glass)
		bulle.Transparency = 0.45
		ajouter(bulle, hasard:NextNumber(0, 360), hasard:NextNumber(10, 60), "monte")
	end
end

function CONSTRUCTEURS.Nuages(couleur: Color3, hasard: Random)
	for i = 1, 10 do
		local azimut = i * 36 + hasard:NextNumber(-10, 10)
		local elevation = hasard:NextNumber(12, 30)
		for k = 1, 3 do
			local nuage = boule(hasard:NextNumber(40, 70), nuance(couleur, BLANC, 0.6))
			nuage.Transparency = 0.1
			ajouter(nuage, azimut + (k - 2) * 4, elevation + (k % 2) * 2, "derive")
		end
	end
end

function CONSTRUCTEURS.Montgolfieres(couleur: Color3, hasard: Random)
	local teintes = {
		couleur,
		nuance(couleur, Color3.fromRGB(80, 170, 255), 0.6),
		nuance(couleur, Color3.fromRGB(255, 220, 80), 0.6),
		nuance(couleur, Color3.fromRGB(120, 230, 120), 0.6),
	}
	for i = 1, 7 do
		local azimut = i * 51 + hasard:NextNumber(-8, 8)
		local elevation = hasard:NextNumber(14, 34)
		ajouter(boule(36, teintes[(i - 1) % #teintes + 1]), azimut, elevation, "flotte")
		local osier = Color3.fromRGB(150, 100, 60)
		local nacelle = piece(Vector3.new(8, 7, 8), osier, Enum.Material.Wood)
		ajouter(nacelle, azimut, elevation - 3.6, "flotte")
	end
	CONSTRUCTEURS.Nuages(BLANC, hasard)
end

function CONSTRUCTEURS.Eclairs(couleur: Color3, hasard: Random)
	CONSTRUCTEURS.Nuages(Color3.fromRGB(70, 70, 90), hasard)
	for i = 1, 4 do
		local azimut = i * 90 + hasard:NextNumber(-20, 20)
		for k = 0, 2 do
			local eclair = piece(Vector3.new(3, 40, 3), couleur, Enum.Material.Neon)
			eclair.Transparency = 1
			eclair:SetAttribute("Eclair", i)
			ajouter(eclair, azimut + (if k % 2 == 0 then 0 else 1.5), 22 - k * 3.2, "eclair")
		end
	end
end

-- Place tous les éléments autour de la caméra (une fois par image).
local parts: { BasePart } = {}
local cadres: { CFrame } = {}

local function suivre()
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return
	end
	local oeil = camera.CFrame.Position
	local t = os.clock() - debut
	table.clear(parts)
	table.clear(cadres)
	local flash = math.floor(t / 3.2) % 4 + 1 -- quel orage gronde
	local allume = (t % 3.2) < 0.18
	for _, e in elements do
		local d = e.direction
		local position = oeil + d * e.distance
		local orientation = CFrame.identity
		if e.mouvement == "monte" then
			position += Vector3.new(0, ((t * 6 + e.phase * 20) % 120) - 60, 0)
		elseif e.mouvement == "flotte" then
			position += Vector3.new(0, math.sin(t * 0.5 + e.phase) * 6, 0)
		elseif e.mouvement == "derive" then
			position += Vector3.new(math.sin(t * 0.05 + e.phase) * 25, 0, 0)
		elseif e.mouvement == "ondule" then
			position += Vector3.new(0, math.sin(t * 0.7 + e.phase) * 8, 0)
			orientation = CFrame.Angles(0, math.sin(t * 0.3 + e.phase) * 0.3, 0)
		elseif e.mouvement == "clignote" then
			e.part.Transparency = 0.2 + 0.5 * (0.5 + 0.5 * math.sin(t * 2 + e.phase * 3))
		elseif e.mouvement == "anneau" then
			orientation = CFrame.Angles(0, 0, math.rad(70)) * CFrame.Angles(math.rad(20), 0, 0)
		elseif e.mouvement == "eclair" then
			e.part.Transparency = if allume and e.part:GetAttribute("Eclair") == flash then 0 else 1
			orientation = CFrame.Angles(0, 0, math.rad(if e.phase % 2 < 1 then 15 else -15))
		end
		-- Les aurores et les nuages font face à la caméra.
		local face = CFrame.lookAt(position, oeil)
		table.insert(parts, e.part)
		table.insert(cadres, face * orientation)
	end
	if #parts > 0 then
		Workspace:BulkMoveTo(parts, cadres, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

-- Remplace le ciel par celui d'un biome (`elements` : nom d'un constructeur).
function CielBiome.afficher(nom: string, couleur: Color3, graine: number)
	if modele then
		modele:Destroy()
	end
	table.clear(elements)
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return
	end
	local m = Instance.new("Model")
	m.Name = "CielBiome"
	modele = m
	local constructeur = CONSTRUCTEURS[nom] or CONSTRUCTEURS.Nuages
	constructeur(couleur, Random.new(graine))
	m.Parent = camera
	if connexion == nil then
		connexion = RunService.RenderStepped:Connect(suivre)
	end
end

return CielBiome
