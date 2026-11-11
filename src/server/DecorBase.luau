--!strict
-- Habillage des bases en « enclos de ranch » (visuel seulement, rien n'entre
-- en collision) : pelouse tondue en bandes, muret de pierre surmonté d'une
-- barrière en bois, piliers d'angle à lanterne, petite cabane au fond,
-- mare avec nénuphars et roseaux, bottes de foin, abreuvoir, massifs fleuris,
-- arbres d'angle, chemin de pierres de la porte à la Forge et cercle au point
-- d'apparition. Tout s'adapte à la taille de la base (agrandissements).
local DecorBase = {}

local HERBE_CLAIRE = Color3.fromRGB(132, 214, 96)
local HERBE_FONCEE = Color3.fromRGB(108, 192, 78)
local TERRE = Color3.fromRGB(176, 132, 92)
local PIERRE = Color3.fromRGB(196, 190, 178)
local PIERRE_FONCEE = Color3.fromRGB(150, 144, 134)
local BOIS = Color3.fromRGB(184, 124, 72)
local BOIS_FONCE = Color3.fromRGB(122, 78, 44)
local TOIT = Color3.fromRGB(214, 84, 70)
local EAU = Color3.fromRGB(90, 180, 235)
local FOIN = Color3.fromRGB(236, 200, 96)
local FEUILLAGE = Color3.fromRGB(78, 176, 84)
local LUMIERE = Color3.fromRGB(255, 214, 140)
local FLEURS = {
	Color3.fromRGB(255, 120, 170),
	Color3.fromRGB(255, 220, 70),
	Color3.fromRGB(160, 130, 255),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 150, 80),
}

local HAUTEUR_MURET = 1.4
local EPAISSEUR_MURET = 1.6
local HAUTEUR_BARRIERE = 2.2

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

-- Disque posé à plat (cylindre couché) de diamètre `d` et d'épaisseur `e`.
local function disque(
	parent: Instance,
	nom: string,
	p: Vector3,
	d: number,
	e: number,
	couleur: Color3,
	matiere: Enum.Material?
): Part
	return piece(
		parent,
		nom,
		Vector3.new(e, d, d),
		CFrame.new(p) * CFrame.Angles(0, 0, math.rad(90)),
		couleur,
		matiere,
		Enum.PartType.Cylinder
	)
end

-- Pelouse tondue : bandes claires alternées le long de Z.
local function pelouse(dossier: Instance, centre: Vector3, taille: number)
	local bandes = math.max(6, math.floor(taille / 6))
	local largeur = taille / bandes
	for i = 0, bandes - 1, 2 do
		piece(
			dossier,
			"Bande",
			Vector3.new(largeur, 0.05, taille - 2 * EPAISSEUR_MURET),
			CFrame.new(centre.X - taille / 2 + (i + 0.5) * largeur, centre.Y + 0.025, centre.Z),
			HERBE_CLAIRE,
			Enum.Material.Grass
		)
	end
end

-- Un côté de l'enclos de `a` à `b` : muret de pierre et barrière en bois
-- dessus, avec ou sans ouverture centrale (la porte).
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
			local regard = CFrame.lookAt(milieu, milieu + unite)
			piece(
				dossier,
				"Muret",
				Vector3.new(EPAISSEUR_MURET, HAUTEUR_MURET, l),
				regard + Vector3.new(0, HAUTEUR_MURET / 2, 0),
				PIERRE,
				Enum.Material.Cobblestone
			)
			piece(
				dossier,
				"Couronne",
				Vector3.new(EPAISSEUR_MURET + 0.3, 0.3, l),
				regard + Vector3.new(0, HAUTEUR_MURET + 0.15, 0),
				PIERRE_FONCEE,
				Enum.Material.Slate
			)
			-- Barrière : deux lisses et des poteaux tous les ~4 studs.
			local base = HAUTEUR_MURET + 0.3
			for _, h in { 0.8, 1.7 } do
				piece(
					dossier,
					"Lisse",
					Vector3.new(0.3, 0.35, l),
					regard + Vector3.new(0, base + h, 0),
					BOIS,
					Enum.Material.Wood
				)
			end
			local nombre = math.max(1, math.floor(l / 4))
			for k = 0, nombre do
				local p = a + unite * (t[1] + l * k / nombre)
				piece(
					dossier,
					"Poteau",
					Vector3.new(0.5, HAUTEUR_BARRIERE, 0.5),
					CFrame.new(p + Vector3.new(0, base + HAUTEUR_BARRIERE / 2, 0)),
					BOIS_FONCE,
					Enum.Material.Wood
				)
			end
		end
	end
end

-- Pilier d'angle en pierre coiffé d'une lanterne.
local function pilier(dossier: Instance, p: Vector3)
	local hauteur = HAUTEUR_MURET + HAUTEUR_BARRIERE + 1
	piece(
		dossier,
		"Pilier",
		Vector3.new(2.6, hauteur, 2.6),
		CFrame.new(p + Vector3.new(0, hauteur / 2, 0)),
		PIERRE,
		Enum.Material.Cobblestone
	)
	piece(
		dossier,
		"Chapiteau",
		Vector3.new(3.2, 0.5, 3.2),
		CFrame.new(p + Vector3.new(0, hauteur + 0.25, 0)),
		PIERRE_FONCEE,
		Enum.Material.Slate
	)
	local lampe = piece(
		dossier,
		"Lampe",
		Vector3.new(1.2, 1.4, 1.2),
		CFrame.new(p + Vector3.new(0, hauteur + 1.2, 0)),
		LUMIERE,
		Enum.Material.Neon
	)
	local lumiere = Instance.new("PointLight")
	lumiere.Color = LUMIERE
	lumiere.Range = 16
	lumiere.Brightness = 1
	lumiere.Parent = lampe
	piece(
		dossier,
		"Toiture",
		Vector3.new(1.8, 0.4, 1.8),
		CFrame.new(p + Vector3.new(0, hauteur + 2.1, 0)),
		BOIS_FONCE,
		Enum.Material.Wood
	)
end

-- Arbre rond (tronc et trois boules de feuillage).
local function arbre(dossier: Instance, p: Vector3, echelle: number, hasard: Random)
	piece(
		dossier,
		"Tronc",
		Vector3.new(1.2, 5, 1.2) * echelle,
		CFrame.new(p + Vector3.new(0, 2.5 * echelle, 0)),
		BOIS_FONCE,
		Enum.Material.Wood
	)
	for k = 1, 3 do
		local d = (3.6 + hasard:NextNumber() * 1.2) * echelle
		piece(
			dossier,
			"Feuillage",
			Vector3.one * d,
			CFrame.new(
				p
					+ Vector3.new(
						hasard:NextNumber(-1, 1) * echelle,
						(5 + k * 0.9) * echelle,
						hasard:NextNumber(-1, 1) * echelle
					)
			),
			FEUILLAGE:Lerp(HERBE_CLAIRE, k / 5),
			Enum.Material.Grass,
			Enum.PartType.Ball
		)
	end
end

-- Massif fleuri le long d'un bord : terre et fleurs en boules.
local function massif(dossier: Instance, p: Vector3, longueur: number, hasard: Random)
	piece(
		dossier,
		"Massif",
		Vector3.new(longueur, 0.4, 2.2),
		CFrame.new(p + Vector3.new(0, 0.2, 0)),
		TERRE,
		Enum.Material.Ground
	)
	for _ = 1, math.floor(longueur * 1.2) do
		local x = hasard:NextNumber(-longueur / 2 + 0.4, longueur / 2 - 0.4)
		local h = 0.7 + hasard:NextNumber() * 0.4
		local f = p + Vector3.new(x, h, hasard:NextNumber(-0.8, 0.8))
		piece(
			dossier,
			"Tige",
			Vector3.new(0.15, 0.7, 0.15),
			CFrame.new(f - Vector3.new(0, 0.3, 0)),
			FEUILLAGE
		)
		piece(
			dossier,
			"Fleur",
			Vector3.one * 0.55,
			CFrame.new(f + Vector3.new(0, 0.1, 0)),
			FLEURS[hasard:NextInteger(1, #FLEURS)],
			Enum.Material.SmoothPlastic,
			Enum.PartType.Ball
		)
	end
end

-- Petite cabane au fond de l'enclos (façade vers la porte).
local function cabane(dossier: Instance, p: Vector3)
	local l, h, pr = 8, 5, 5
	piece(
		dossier,
		"Cabane",
		Vector3.new(l, h, pr),
		CFrame.new(p + Vector3.new(0, h / 2, 0)),
		BOIS,
		Enum.Material.WoodPlanks
	)
	-- Toit à deux pans (deux coins).
	for _, sens in { -1, 1 } do
		piece(
			dossier,
			"Toit",
			Vector3.new(pr + 1, 2.6, l / 2 + 0.6),
			CFrame.new(p + Vector3.new(sens * (l / 4 + 0.15), h + 1.3, 0))
				* CFrame.Angles(0, math.rad(-90 * sens), 0),
			TOIT,
			Enum.Material.SmoothPlastic,
			Enum.PartType.Wedge
		)
	end
	-- Porte en arc et fenêtres rondes.
	piece(
		dossier,
		"PorteCabane",
		Vector3.new(2.4, 3.2, 0.2),
		CFrame.new(p + Vector3.new(0, 1.6, pr / 2 + 0.05)),
		BOIS_FONCE,
		Enum.Material.Wood
	)
	for _, x in { -2.7, 2.7 } do
		-- Cylindre couché le long de Z : rond vu de face.
		local centreFenetre = p + Vector3.new(x, 3.2, pr / 2 + 0.05)
		piece(
			dossier,
			"Fenetre",
			Vector3.new(0.2, 1.4, 1.4),
			CFrame.new(centreFenetre) * CFrame.Angles(0, math.rad(90), 0),
			LUMIERE,
			Enum.Material.Neon,
			Enum.PartType.Cylinder
		)
	end
end

-- Mare ronde avec nénuphars et roseaux.
local function mare(dossier: Instance, p: Vector3, d: number, hasard: Random)
	local rive = p + Vector3.new(0, 0.06, 0)
	disque(dossier, "Rive", rive, d + 1.2, 0.12, PIERRE, Enum.Material.Pebble)
	local surface = p + Vector3.new(0, 0.1, 0)
	local eau = disque(dossier, "Eau", surface, d, 0.12, EAU, Enum.Material.Glass)
	eau.Transparency = 0.15
	for _ = 1, 3 do
		local a = hasard:NextNumber(0, 2 * math.pi)
		local r = hasard:NextNumber(0.2, 0.35) * d
		local q = p + Vector3.new(math.cos(a) * r, 0.18, math.sin(a) * r)
		disque(dossier, "Nenuphar", q, 1.2, 0.05, FEUILLAGE)
		piece(
			dossier,
			"FleurNenuphar",
			Vector3.one * 0.45,
			CFrame.new(q + Vector3.new(0.2, 0.2, 0)),
			FLEURS[1],
			Enum.Material.SmoothPlastic,
			Enum.PartType.Ball
		)
	end
	for k = 1, 6 do
		local a = k / 6 * math.pi + math.pi
		local q = p + Vector3.new(math.cos(a) * d * 0.55, 0, math.sin(a) * d * 0.55)
		local h = 1.6 + hasard:NextNumber()
		piece(
			dossier,
			"Roseau",
			Vector3.new(0.2, h, 0.2),
			CFrame.new(q + Vector3.new(0, h / 2, 0)),
			Color3.fromRGB(96, 150, 70)
		)
		piece(
			dossier,
			"Massette",
			Vector3.new(0.35, 0.6, 0.35),
			CFrame.new(q + Vector3.new(0, h, 0)),
			BOIS_FONCE
		)
	end
end

-- Bottes de foin (cylindres couchés) empilées.
local function foin(dossier: Instance, p: Vector3)
	local pile = { Vector3.new(-1.1, 0.9, 0), Vector3.new(1.1, 0.9, 0), Vector3.new(0, 2.5, 0) }
	for i, decalage in pile do
		piece(
			dossier,
			"Foin",
			Vector3.new(2.4, 1.8, 1.8),
			CFrame.new(p + decalage) * CFrame.Angles(0, if i == 3 then math.rad(20) else 0, 0),
			FOIN,
			Enum.Material.Fabric,
			Enum.PartType.Cylinder
		)
	end
end

-- Abreuvoir en bois rempli d'eau.
local function abreuvoir(dossier: Instance, p: Vector3)
	local bac = CFrame.new(p + Vector3.new(0, 0.6, 0))
	piece(dossier, "Abreuvoir", Vector3.new(4, 1.2, 1.6), bac, BOIS, Enum.Material.Wood)
	piece(
		dossier,
		"EauAbreuvoir",
		Vector3.new(3.6, 0.1, 1.2),
		CFrame.new(p + Vector3.new(0, 1.15, 0)),
		EAU,
		Enum.Material.Glass
	)
end

-- Habille la base dont le sol est centré sur `centre` (dessus du sol en Y).
-- `ouverture` : largeur de la porte au bord +Z ; `forge`, `apparition` :
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
		sol.Color = HERBE_FONCEE
	end

	pelouse(dossier, centre, taille)

	local d = taille / 2 - EPAISSEUR_MURET / 2
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
		pilier(dossier, coin)
	end

	-- Fond : cabane au centre, massifs de chaque côté.
	local fond = centre.Z - d + 4
	cabane(dossier, Vector3.new(centre.X, y, fond))
	local largeurMassif = math.max(4, d - 9)
	for _, sens in { -1, 1 } do
		massif(
			dossier,
			Vector3.new(centre.X + sens * (5 + largeurMassif / 2), y, centre.Z - d + 2),
			largeurMassif,
			hasard
		)
	end

	-- Coins du fond : arbre à gauche, mare (base agrandie) ou foin à droite.
	local echelle = math.clamp(taille / 48, 0.8, 1.4)
	arbre(dossier, Vector3.new(centre.X - d + 3.5, y, centre.Z - d + 3.5), echelle, hasard)
	arbre(dossier, Vector3.new(centre.X + d - 3.5, y, centre.Z - d + 3.5), echelle, hasard)
	if taille >= 56 then
		mare(dossier, Vector3.new(centre.X - d + 9, y, centre.Z), 6 * echelle, hasard)
		foin(dossier, Vector3.new(centre.X + d - 6, y, centre.Z + 2))
	else
		foin(dossier, Vector3.new(centre.X + d - 5, y, centre.Z - 2))
	end
	abreuvoir(dossier, Vector3.new(centre.X - d + 3, y, centre.Z + d - 6))

	-- Massifs de part et d'autre de la porte.
	for _, sens in { -1, 1 } do
		massif(
			dossier,
			Vector3.new(centre.X + sens * (ouverture / 2 + 3.5), y, centre.Z + d - 1.8),
			4,
			hasard
		)
	end

	-- Chemin de pierres de la porte jusqu'à la Forge.
	local depart = Vector3.new(centre.X, y, centre.Z + d)
	local arrivee = Vector3.new(forge.X, y, forge.Z + 4.5)
	local longueur = (arrivee - depart).Magnitude
	local pas = 2.6
	for k = 0, math.floor(longueur / pas) do
		local p = depart + (arrivee - depart).Unit * (k * pas + 1)
		local decale = (if k % 2 == 0 then 0.5 else -0.5)
		disque(
			dossier,
			"Pierre",
			p + Vector3.new(decale, 0.08, 0),
			1.8 + hasard:NextNumber() * 0.4,
			0.2,
			PIERRE,
			Enum.Material.Slate
		)
	end

	-- Cercle lumineux au point d'apparition.
	local anneau = disque(
		dossier,
		"Apparition",
		Vector3.new(apparition.X, y + 0.08, apparition.Z),
		5,
		0.1,
		Color3.fromRGB(120, 230, 255),
		Enum.Material.Neon
	)
	anneau.Transparency = 0.35
	disque(
		dossier,
		"ApparitionCoeur",
		Vector3.new(apparition.X, y + 0.09, apparition.Z),
		3.8,
		0.11,
		HERBE_FONCEE,
		Enum.Material.Grass
	)
	return dossier
end

return DecorBase
