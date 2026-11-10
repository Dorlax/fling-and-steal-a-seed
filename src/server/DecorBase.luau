--!strict
-- Habillage des bases (visuel seulement, rien n'entre en collision) :
-- pelouse en damier, clôture en bois tout autour (ouverte à la porte),
-- poteaux à lanterne aux coins, buissons fleuris, chemin de pierres de la
-- porte à la Forge, cercle lumineux au point d'apparition.
local DecorBase = {}

local VERT_CLAIR = Color3.fromRGB(128, 222, 92)
local VERT_FONCE = Color3.fromRGB(104, 198, 74)
local BOIS = Color3.fromRGB(176, 116, 64)
local BOIS_FONCE = Color3.fromRGB(128, 80, 44)
local PIERRE = Color3.fromRGB(226, 214, 188)
local BUISSON = Color3.fromRGB(70, 170, 70)
local FLEURS = {
	Color3.fromRGB(255, 120, 170),
	Color3.fromRGB(255, 220, 70),
	Color3.fromRGB(150, 120, 255),
	Color3.fromRGB(255, 255, 255),
}
local LUMIERE = Color3.fromRGB(255, 220, 140)

local HAUTEUR_CLOTURE = 3

local function piece(
	parent: Instance,
	nom: string,
	taille: Vector3,
	cf: CFrame,
	couleur: Color3,
	matiere: Enum.Material?,
	forme: Enum.PartType?
): Part
	local p = Instance.new("Part")
	p.Name = nom
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = taille
	p.CFrame = cf
	p.Color = couleur
	p.Material = matiere or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if forme then
		p.Shape = forme
	end
	p.CastShadow = math.max(taille.X, taille.Y, taille.Z) >= 4
	p.Parent = parent
	return p
end

-- Pelouse en damier : 8 x 8 cases posées sur le sol.
local function damier(dossier: Instance, centre: Vector3, taille: number)
	local cases = 8
	local cote = taille / cases
	for i = 0, cases - 1 do
		for j = 0, cases - 1 do
			if (i + j) % 2 == 0 then
				piece(
					dossier,
					"Case",
					Vector3.new(cote, 0.06, cote),
					CFrame.new(
						centre.X - taille / 2 + (i + 0.5) * cote,
						centre.Y + 0.03,
						centre.Z - taille / 2 + (j + 0.5) * cote
					),
					VERT_CLAIR,
					Enum.Material.Grass
				)
			end
		end
	end
end

-- Un côté de clôture de `a` à `b` (au sol), avec ou sans ouverture centrale.
local function cote(dossier: Instance, a: Vector3, b: Vector3, ouverture: number)
	local direction = b - a
	local longueur = direction.Magnitude
	local unite = direction.Unit
	local troncons: { { number } } = if ouverture > 0
		then { { 0, (longueur - ouverture) / 2 }, { (longueur + ouverture) / 2, longueur } }
		else { { 0, longueur } }
	for _, t in troncons do
		local l = t[2] - t[1]
		if l > 0.5 then
			local milieu = a + unite * ((t[1] + t[2]) / 2)
			for _, h in { 1.1, 2.3 } do
				piece(
					dossier,
					"Traverse",
					Vector3.new(0.35, 0.4, l),
					CFrame.lookAt(
						milieu + Vector3.new(0, h, 0),
						milieu + Vector3.new(0, h, 0) + unite
					),
					BOIS
				)
			end
			-- Poteaux tous les ~4 studs, bout arrondi.
			local nombre = math.max(1, math.floor(l / 4))
			for k = 0, nombre do
				local p = a + unite * (t[1] + l * k / nombre)
				piece(
					dossier,
					"Piquet",
					Vector3.new(0.6, HAUTEUR_CLOTURE, 0.6),
					CFrame.new(p + Vector3.new(0, HAUTEUR_CLOTURE / 2, 0)),
					BOIS_FONCE
				)
				piece(
					dossier,
					"Pointe",
					Vector3.new(0.7, 0.7, 0.7),
					CFrame.new(p + Vector3.new(0, HAUTEUR_CLOTURE + 0.1, 0)),
					BOIS,
					nil,
					Enum.PartType.Ball
				)
			end
		end
	end
end

local function lanterne(dossier: Instance, p: Vector3)
	piece(
		dossier,
		"Mat",
		Vector3.new(0.5, 5, 0.5),
		CFrame.new(p + Vector3.new(0, 2.5, 0)),
		BOIS_FONCE
	)
	local lampe = piece(
		dossier,
		"Lampe",
		Vector3.new(1.1, 1.1, 1.1),
		CFrame.new(p + Vector3.new(0, 5.4, 0)),
		LUMIERE,
		Enum.Material.Neon,
		Enum.PartType.Ball
	)
	local l = Instance.new("PointLight")
	l.Color = LUMIERE
	l.Range = 14
	l.Brightness = 1.2
	l.Parent = lampe
	piece(
		dossier,
		"Chapeau",
		Vector3.new(1.5, 0.3, 1.5),
		CFrame.new(p + Vector3.new(0, 6.1, 0)),
		BOIS_FONCE
	)
end

local function buisson(dossier: Instance, p: Vector3, hasard: Random)
	for k = 1, 3 do
		local d = 1.6 + hasard:NextNumber() * 0.8
		piece(
			dossier,
			"Buisson",
			Vector3.new(d, d, d),
			CFrame.new(
				p
					+ Vector3.new(
						hasard:NextNumber(-0.8, 0.8),
						d / 2 - 0.2,
						hasard:NextNumber(-0.8, 0.8)
					)
			),
			BUISSON:Lerp(VERT_FONCE, k / 4),
			Enum.Material.Grass,
			Enum.PartType.Ball
		)
	end
	for _ = 1, 5 do
		piece(
			dossier,
			"Fleur",
			Vector3.new(0.45, 0.45, 0.45),
			CFrame.new(
				p
					+ Vector3.new(
						hasard:NextNumber(-1.2, 1.2),
						hasard:NextNumber(1.4, 2.2),
						hasard:NextNumber(-1.2, 1.2)
					)
			),
			FLEURS[hasard:NextInteger(1, #FLEURS)],
			Enum.Material.SmoothPlastic,
			Enum.PartType.Ball
		)
	end
end

-- Habille la base dont le sol est centré sur `centre` (dessus du sol en Y).
-- `ouverture` : largeur de la porte au bord +Z ; `forgeZ`, `apparition` :
-- positions de la Forge et du point d'apparition.
function DecorBase.habiller(
	modele: Model,
	centre: Vector3,
	taille: number,
	ouverture: number,
	forge: Vector3,
	apparition: Vector3
)
	local dossier = Instance.new("Folder")
	dossier.Name = "Habillage"
	dossier.Parent = modele
	local hasard = Random.new(math.floor(centre.X * 7 + centre.Z))
	local sol = modele:FindFirstChild("Sol")
	if sol and sol:IsA("BasePart") then
		sol.Color = VERT_FONCE -- cases foncées du damier
	end

	damier(dossier, centre, taille)

	local d = taille / 2 - 0.5
	local y = centre.Y
	local c1 = Vector3.new(centre.X - d, y, centre.Z - d)
	local c2 = Vector3.new(centre.X + d, y, centre.Z - d)
	local c3 = Vector3.new(centre.X + d, y, centre.Z + d)
	local c4 = Vector3.new(centre.X - d, y, centre.Z + d)
	cote(dossier, c1, c2, 0)
	cote(dossier, c2, c3, 0)
	cote(dossier, c3, c4, ouverture + 2) -- côté de la porte
	cote(dossier, c4, c1, 0)
	for _, coin in { c1, c2, c3, c4 } do
		local dedans = (Vector3.new(centre.X, y, centre.Z) - coin).Unit * 1.5
		lanterne(dossier, coin + dedans)
	end
	-- Buissons fleuris de part et d'autre de la porte et au fond.
	for _, p in
		{
			Vector3.new(centre.X - ouverture / 2 - 3, y, centre.Z + d - 2),
			Vector3.new(centre.X + ouverture / 2 + 3, y, centre.Z + d - 2),
			Vector3.new(centre.X - d + 3, y, centre.Z - d + 3),
			Vector3.new(centre.X + d - 3, y, centre.Z - d + 3),
		}
	do
		buisson(dossier, p, hasard)
	end

	-- Chemin de pierres de la porte jusqu'à la Forge.
	local depart = Vector3.new(centre.X, y, centre.Z + d)
	local arrivee = Vector3.new(forge.X, y, forge.Z + 4.5)
	local longueur = (arrivee - depart).Magnitude
	local pas = 2.6
	for k = 0, math.floor(longueur / pas) do
		local p = depart + (arrivee - depart).Unit * (k * pas + 1)
		local decale = (if k % 2 == 0 then 0.5 else -0.5)
		piece(
			dossier,
			"Pierre",
			Vector3.new(0.2, 1.8 + hasard:NextNumber() * 0.4, 1.8 + hasard:NextNumber() * 0.4),
			CFrame.new(p + Vector3.new(decale, 0.08, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			PIERRE,
			Enum.Material.Slate,
			Enum.PartType.Cylinder
		)
	end

	-- Cercle lumineux au point d'apparition.
	local anneau = piece(
		dossier,
		"Apparition",
		Vector3.new(0.1, 5, 5),
		CFrame.new(apparition.X, y + 0.08, apparition.Z) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(120, 230, 255),
		Enum.Material.Neon,
		Enum.PartType.Cylinder
	)
	anneau.Transparency = 0.35
	piece(
		dossier,
		"ApparitionCoeur",
		Vector3.new(0.11, 3.8, 3.8),
		CFrame.new(apparition.X, y + 0.09, apparition.Z) * CFrame.Angles(0, 0, math.rad(90)),
		VERT_FONCE,
		Enum.Material.Grass,
		Enum.PartType.Cylinder
	)
	return dossier
end

return DecorBase
