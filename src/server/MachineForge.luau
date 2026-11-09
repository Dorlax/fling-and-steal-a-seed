--!strict
-- La Forge : une seule machine (Plan), qui change d'agrès selon le mode du
-- propriétaire. Vitesse : tapis de course ; Force : barre de musculation sur
-- son support ; Double : tapis rond et corde à sauter. Les trois agrès sont
-- construits ici ; le client (AnimationsForge) n'affiche que celui du mode
-- et anime le personnage (course, soulevé, corde). Rien n'entre en collision
-- sauf la plateforme : la zone d'entraînement reste la Part « Forge ».
local CollectionService = game:GetService("CollectionService")

local MachineForge = {}

MachineForge.Tag = "MachineForge"

local BLANC = Color3.fromRGB(236, 240, 248)
local GRIS = Color3.fromRGB(150, 156, 172)
local NOIR = Color3.fromRGB(38, 40, 52)
local ACIER = Color3.fromRGB(196, 202, 214)
local BLEU = Color3.fromRGB(70, 165, 255)
local BLEU_FONCE = Color3.fromRGB(30, 60, 120)
local ROUGE = Color3.fromRGB(235, 70, 60)
local JAUNE = Color3.fromRGB(255, 205, 50)
local VIOLET = Color3.fromRGB(175, 95, 255)
local ROSE = Color3.fromRGB(255, 140, 210)
local SOL = Color3.fromRGB(58, 62, 84)

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
	p.CastShadow = math.max(taille.X, taille.Y, taille.Z) >= 3
	p.Parent = parent
	return p
end

-- Cylindre dont l'axe suit `axe` ("X", "Y" ou "Z").
local function cylindre(
	parent: Instance,
	nom: string,
	longueur: number,
	diametre: number,
	position: Vector3,
	axe: string,
	couleur: Color3,
	matiere: Enum.Material?
): Part
	local rotation = if axe == "Y"
		then CFrame.Angles(0, 0, math.rad(90))
		elseif axe == "Z" then CFrame.Angles(0, math.rad(90), 0)
		else CFrame.new()
	return piece(
		parent,
		nom,
		Vector3.new(longueur, diametre, diametre),
		CFrame.new(position) * rotation,
		couleur,
		matiere,
		Enum.PartType.Cylinder
	)
end

local function boule(
	parent: Instance,
	nom: string,
	d: number,
	position: Vector3,
	couleur: Color3
): Part
	return piece(
		parent,
		nom,
		Vector3.new(d, d, d),
		CFrame.new(position),
		couleur,
		nil,
		Enum.PartType.Ball
	)
end

local function poste(modele: Model, mode: string): Model
	local m = Instance.new("Model")
	m.Name = "Poste" .. mode
	m:SetAttribute("Mode", mode)
	m.Parent = modele
	return m
end

-- Tapis de course, console vers -Z (le joueur regarde -Z).
local function tapisDeCourse(modele: Model, o: Vector3)
	local m = poste(modele, "Vitesse")
	local function p(x: number, y: number, z: number): Vector3
		return o + Vector3.new(x, y, z)
	end
	piece(m, "Cadre", Vector3.new(3.8, 0.4, 7), CFrame.new(p(0, 0.2, 0.3)), BLANC)
	piece(m, "Jupe", Vector3.new(3.9, 0.15, 7.1), CFrame.new(p(0, 0.08, 0.3)), BLEU)
	for _, z in { -3.2, 3.8 } do
		cylindre(m, "Rouleau", 3.9, 0.55, p(0, 0.3, z), "X", GRIS, Enum.Material.Metal)
	end
	piece(m, "Tapis", Vector3.new(3.1, 0.06, 6.8), CFrame.new(p(0, 0.43, 0.3)), NOIR)
	-- Bandes du tapis : le client les fait défiler.
	for i = 1, 8 do
		local bande = piece(
			m,
			"Bande",
			Vector3.new(3.1, 0.07, 0.22),
			CFrame.new(p(0, 0.44, -3 + i * 0.85)),
			Color3.fromRGB(70, 75, 98)
		)
		bande:SetAttribute("Indice", i)
	end
	for _, x in { -1.75, 1.75 } do
		-- Montant penché vers l'avant, poignée latérale, embout arrondi.
		piece(
			m,
			"Montant",
			Vector3.new(0.35, 3.8, 0.35),
			CFrame.new(p(x, 2.2, -3.25)) * CFrame.Angles(math.rad(-12), 0, 0),
			BLEU
		)
		cylindre(m, "Poignee", 2.4, 0.3, p(x, 3.3, -2.2), "Z", BLANC)
		boule(m, "Embout", 0.42, p(x, 3.3, -1), BLEU)
	end
	cylindre(m, "Traverse", 3.5, 0.32, p(0, 3.85, -3.55), "X", BLANC)
	-- Console inclinée et écran tourné vers le joueur.
	local console = piece(
		m,
		"Console",
		Vector3.new(3.2, 1.3, 0.5),
		CFrame.new(p(0, 4.45, -3.55)) * CFrame.Angles(math.rad(25), 0, 0),
		BLANC
	)
	local ecran = piece(
		m,
		"Ecran",
		Vector3.new(2.4, 0.8, 0.06),
		console.CFrame * CFrame.new(0, 0.05, 0.28),
		BLEU_FONCE,
		Enum.Material.Neon
	)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "Affichage"
	surface.Face = Enum.NormalId.Back
	surface.PixelsPerStud = 60
	surface.LightInfluence = 0
	surface.Parent = ecran
	local texte = Instance.new("TextLabel")
	texte.Name = "Texte"
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = Color3.fromRGB(140, 255, 200)
	texte.Text = "VITESSE"
	texte.Parent = surface
	for i, couleur in { ROUGE, JAUNE, Color3.fromRGB(90, 230, 120) } do
		boule(
			m,
			"Voyant",
			0.22,
			console.CFrame * CFrame.new(-1.2 + i * 0.6, -0.5, 0.26).Position,
			couleur
		).Material =
			Enum.Material.Neon
	end
end

-- Support de musculation et barre chargée, derrière le joueur.
local function supportDeBarre(modele: Model, o: Vector3)
	local m = poste(modele, "Force")
	local function p(x: number, y: number, z: number): Vector3
		return o + Vector3.new(x, y, z)
	end
	piece(
		m,
		"TapisSol",
		Vector3.new(6.4, 0.1, 4.6),
		CFrame.new(p(0, 0.05, 0.4)),
		NOIR,
		Enum.Material.Fabric
	)
	piece(m, "Liseré", Vector3.new(6.6, 0.08, 4.8), CFrame.new(p(0, 0.03, 0.4)), ROUGE)
	for _, x in { -3, 3 } do
		piece(m, "Pied", Vector3.new(0.9, 0.3, 1.8), CFrame.new(p(x, 0.25, 1.3)), ROUGE)
		piece(m, "Montant", Vector3.new(0.45, 5.4, 0.45), CFrame.new(p(x, 2.9, 1.3)), ROUGE)
		boule(m, "Capuchon", 0.6, p(x, 5.65, 1.3), JAUNE)
		-- Crochet en J qui tient la barre.
		piece(
			m,
			"Crochet",
			Vector3.new(0.3, 0.2, 0.7),
			CFrame.new(p(x, 4.45, 0.85)),
			ACIER,
			Enum.Material.Metal
		)
		piece(
			m,
			"Bec",
			Vector3.new(0.3, 0.45, 0.15),
			CFrame.new(p(x, 4.62, 0.55)),
			ACIER,
			Enum.Material.Metal
		)
	end
	cylindre(m, "Entretoise", 6, 0.3, p(0, 0.6, 2.1), "X", ROUGE)
	-- Barre posée sur les crochets (cachée par le client pendant le soulevé).
	local barre = Instance.new("Model")
	barre.Name = "Barre"
	barre.Parent = m
	local y, z = 4.72, 0.75
	cylindre(barre, "Tige", 7.2, 0.24, p(0, y, z), "X", ACIER, Enum.Material.Metal)
	for _, cote in { -1, 1 } do
		cylindre(barre, "Disque", 0.35, 1.9, p(cote * 2.45, y, z), "X", ROUGE)
		cylindre(barre, "Disque", 0.3, 1.4, p(cote * 2.8, y, z), "X", JAUNE)
		cylindre(barre, "Bague", 0.25, 0.45, p(cote * 3.1, y, z), "X", ACIER, Enum.Material.Metal)
	end
	-- Petite gourde et serviette pour la vie.
	cylindre(m, "Gourde", 0.9, 0.5, p(2.4, 0.55, -1.6), "Y", BLEU)
	cylindre(m, "Bouchon", 0.2, 0.36, p(2.4, 1.1, -1.6), "Y", BLANC)
	piece(
		m,
		"Serviette",
		Vector3.new(1.2, 0.12, 0.8),
		CFrame.new(p(-2.4, 0.16, -1.6)) * CFrame.Angles(0, 0.4, 0),
		ROSE,
		Enum.Material.Fabric
	)
end

-- Tapis rond et corde enroulée (la corde qui tourne est celle du client).
local function aireDeCorde(modele: Model, o: Vector3)
	local m = poste(modele, "Double")
	local function p(x: number, y: number, z: number): Vector3
		return o + Vector3.new(x, y, z)
	end
	cylindre(m, "Tapis", 0.12, 6.6, p(0, 0.06, 0), "Y", VIOLET, Enum.Material.Fabric)
	cylindre(m, "Cercle", 0.13, 4.6, p(0, 0.07, 0), "Y", ROSE, Enum.Material.Fabric)
	cylindre(m, "Coeur", 0.14, 2.2, p(0, 0.08, 0), "Y", VIOLET, Enum.Material.Fabric)
	-- Étoiles du tapis.
	for i = 0, 4 do
		local a = i * 2 * math.pi / 5
		boule(m, "Etoile", 0.35, p(math.cos(a) * 2.8, 0.1, math.sin(a) * 2.8), JAUNE).Material =
			Enum.Material.Neon
	end
	-- Corde enroulée posée au sol.
	local corde = Instance.new("Model")
	corde.Name = "CordeRangee"
	corde.Parent = m
	for i = 0, 13 do
		local a = i * 2 * math.pi / 14
		piece(
			corde,
			"Brin",
			Vector3.new(0.36, 0.14, 0.14),
			CFrame.new(p(2.9 + math.cos(a) * 0.6, 0.2, -2.6 + math.sin(a) * 0.6))
				* CFrame.Angles(0, -a, 0),
			JAUNE
		)
	end
	for _, x in { 2.1, 3.7 } do
		cylindre(corde, "Manche", 0.7, 0.26, p(x, 0.25, -1.7), "Z", ROUGE)
	end
end

-- Construit la Forge autour de `plateforme` (la Part « Forge »). `sol` :
-- hauteur du dessus du sol de la base. Renvoie le modèle.
function MachineForge.construire(plateforme: BasePart, sol: number, proprietaire: any): Model
	local _ = sol
	local modele = Instance.new("Model")
	modele.Name = "MachineForge"
	modele:SetAttribute("Proprietaire", proprietaire)
	-- Streaming : la machine arrive chez le client en une fois.
	modele.ModelStreamingMode = Enum.ModelStreamingMode.Atomic

	-- Plateforme : sol de salle de sport, bord lumineux à la couleur du mode.
	plateforme.Material = Enum.Material.SmoothPlastic
	plateforme.Color = SOL
	local centre = plateforme.Position
	local haut = centre.Y + plateforme.Size.Y / 2
	local demi = plateforme.Size.X / 2
	for _, cote in { -1, 1 } do
		piece(
			modele,
			"Anneau",
			Vector3.new(plateforme.Size.X, 0.1, 0.35),
			CFrame.new(centre.X, haut + 0.05, centre.Z + cote * (demi - 0.2)),
			BLEU,
			Enum.Material.Neon
		)
		piece(
			modele,
			"Anneau",
			Vector3.new(0.35, 0.1, plateforme.Size.Z - 0.7),
			CFrame.new(centre.X + cote * (demi - 0.2), haut + 0.05, centre.Z),
			BLEU,
			Enum.Material.Neon
		)
	end
	local origine = Vector3.new(centre.X, haut, centre.Z)
	tapisDeCourse(modele, origine)
	supportDeBarre(modele, origine)
	aireDeCorde(modele, origine)

	-- Point où se tient le joueur (au centre, regard vers -Z).
	local point = Instance.new("Attachment")
	point.Name = "Poste"
	point.Parent = plateforme
	point.WorldCFrame = CFrame.new(origine)

	modele.Parent = plateforme.Parent
	CollectionService:AddTag(modele, MachineForge.Tag)
	return modele
end

return MachineForge
