--!strict
-- La Forge : une seule machine (Plan) dont l'agrès dépend du mode du
-- propriétaire et se modernise avec le niveau de Forge (Config.Forge.Paliers) :
--   Vitesse : roue en bois -> tapis de course -> tapis pro -> piste néon -> piste cosmique
--   Force   : gros rocher -> haltères -> barre olympique -> barre plasma -> météorite
--   Double  : tapis rond et corde (lumineuse, laser, anneau cosmique)
-- Les trois agrès du palier sont construits ici ; le client (AnimationsForge)
-- n'affiche que celui du mode et anime le personnage. Rien n'entre en
-- collision sauf la plateforme (la Part « Forge », zone d'entraînement).
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Forge = require(ReplicatedStorage.Shared.Forge)

local MachineForge = {}

MachineForge.Tag = "MachineForge"

local function rgb(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local BLANC = rgb(236, 240, 248)
local GRIS = rgb(150, 156, 172)
local NOIR = rgb(38, 40, 52)
local ACIER = rgb(196, 202, 214)
local BOIS = rgb(168, 112, 62)
local BOIS_CLAIR = rgb(214, 160, 98)
local BOIS_FONCE = rgb(116, 74, 40)
local PIERRE = rgb(128, 124, 136)
local BLEU = rgb(70, 165, 255)
local BLEU_FONCE = rgb(30, 60, 120)
local CYAN = rgb(60, 240, 255)
local ROUGE = rgb(235, 70, 60)
local JAUNE = rgb(255, 205, 50)
local VERT = rgb(110, 210, 90)
local VIOLET = rgb(175, 95, 255)
local ROSE = rgb(255, 120, 210)
local NUIT = rgb(30, 18, 60)
local LAVE = rgb(255, 120, 40)

-- Sol de la plateforme selon le palier.
local SOLS: { { couleur: Color3, matiere: Enum.Material } } = {
	{ couleur = BOIS, matiere = Enum.Material.WoodPlanks },
	{ couleur = rgb(70, 74, 90), matiere = Enum.Material.Fabric },
	{ couleur = rgb(40, 56, 96), matiere = Enum.Material.SmoothPlastic },
	{ couleur = rgb(22, 24, 34), matiere = Enum.Material.SmoothPlastic },
	{ couleur = NUIT, matiere = Enum.Material.SmoothPlastic },
}

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

local function neon(p: Part): Part
	p.Material = Enum.Material.Neon
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

local function lumiere(parent: Instance, couleur: Color3, portee: number)
	local l = Instance.new("PointLight")
	l.Color = couleur
	l.Range = portee
	l.Brightness = 1.5
	l.Parent = parent
end

local function etincelles(parent: Instance, couleur: Color3, debit: number)
	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(couleur, Color3.new(1, 1, 1))
	e.LightEmission = 1
	e.Size = NumberSequence.new(0.35, 0)
	e.Lifetime = NumberRange.new(0.8, 1.6)
	e.Speed = NumberRange.new(0.5, 1.5)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Rate = debit
	e.Parent = parent
end

local function poste(modele: Model, mode: string): Model
	local m = Instance.new("Model")
	m.Name = "Poste" .. mode
	m:SetAttribute("Mode", mode)
	m.Parent = modele
	return m
end

-- ===== Vitesse =====

-- Roue de hamster géante en bois : le joueur court dedans, la roue tourne
-- (le client fait tourner le modèle « Roue » autour de l'attribut Axe).
local function roueEnBois(m: Model, o: Vector3)
	local rayon, largeur = 3.7, 3.4
	local axe = CFrame.new(o + Vector3.new(0, rayon + 0.25, 0))
	m:SetAttribute("Hauteur", 0.4)
	local roue = Instance.new("Model")
	roue.Name = "Roue"
	roue:SetAttribute("Axe", axe)
	roue:SetAttribute("Rayon", rayon)
	roue.Parent = m
	local n = 18
	local corde = 2 * rayon * math.sin(math.pi / n) + 0.12
	for k = 0, n - 1 do
		local a = k * 2 * math.pi / n
		local autour = axe * CFrame.Angles(a, 0, 0)
		-- Lattes où l'on court, cerclage de chaque côté.
		piece(
			roue,
			"Latte",
			Vector3.new(largeur - 0.3, 0.16, corde * 0.78),
			autour * CFrame.new(0, -rayon + 0.12, 0),
			if k % 2 == 0 then BOIS_CLAIR else BOIS,
			Enum.Material.Wood
		)
		for _, x in { -largeur / 2, largeur / 2 } do
			piece(
				roue,
				"Cerclage",
				Vector3.new(0.3, 0.42, corde),
				autour * CFrame.new(x, -rayon, 0),
				BOIS_FONCE,
				Enum.Material.Wood
			)
		end
	end
	for k = 0, 3 do
		for _, x in { -largeur / 2, largeur / 2 } do
			piece(
				roue,
				"Rayon",
				Vector3.new(0.2, 0.22, 2 * rayon),
				axe * CFrame.Angles(k * math.pi / 4, 0, 0) * CFrame.new(x, 0, 0),
				BOIS_FONCE,
				Enum.Material.Wood
			)
		end
	end
	for _, x in { -largeur / 2, largeur / 2 } do
		cylindre(roue, "Moyeu", 0.4, 0.9, (axe * CFrame.new(x, 0, 0)).Position, "X", JAUNE)
	end
	for _, p in roue:GetChildren() do
		if p:IsA("BasePart") then
			p:SetAttribute("Decalage", axe:ToObjectSpace(p.CFrame))
		end
	end
	-- Chevalets fixes de chaque côté et essieu.
	for _, x in { -largeur / 2 - 0.5, largeur / 2 + 0.5 } do
		local sommet = Vector3.new(o.X + x, axe.Position.Y, axe.Position.Z)
		for _, z in { -1.9, 1.9 } do
			local pied = o + Vector3.new(x, 0, z)
			piece(
				m,
				"Chevalet",
				Vector3.new(0.35, 0.35, (sommet - pied).Magnitude),
				CFrame.lookAt((pied + sommet) / 2, sommet),
				BOIS_FONCE,
				Enum.Material.Wood
			)
		end
	end
	cylindre(m, "Essieu", largeur + 1.4, 0.3, axe.Position, "X", PIERRE, Enum.Material.Metal)
	-- Touffes d'herbe et panneau en bois.
	for i, position in
		{ Vector3.new(-3.3, 0, -3.2), Vector3.new(3.3, 0, 3.1), Vector3.new(3.4, 0, -2.8) }
	do
		boule(m, "Touffe", 0.7 + i * 0.1, o + position + Vector3.new(0, 0.2, 0), VERT).Material =
			Enum.Material.Grass
	end
end

type StyleTapis = {
	cadre: Color3,
	jupe: Color3,
	tapis: Color3,
	bande: Color3,
	montant: Color3,
	poignee: Color3,
	console: Color3,
	ecran: boolean,
	neon: boolean,
	flotte: number,
	etoiles: boolean,
}

-- Tapis de course (console vers -Z, le joueur regarde -Z).
local function tapis(m: Model, o: Vector3, style: StyleTapis)
	local f = style.flotte
	local function p(x: number, y: number, z: number): Vector3
		return o + Vector3.new(x, y + f, z)
	end
	m:SetAttribute("Hauteur", 0.45 + f)
	piece(m, "Cadre", Vector3.new(3.8, 0.4, 7), CFrame.new(p(0, 0.2, 0.3)), style.cadre)
	local jupe =
		piece(m, "Jupe", Vector3.new(3.9, 0.15, 7.1), CFrame.new(p(0, 0.08, 0.3)), style.jupe)
	if style.neon then
		neon(jupe)
		lumiere(jupe, style.jupe, 10)
	end
	if f > 0 then
		-- Socle lumineux : le tapis flotte au-dessus.
		neon(
			piece(
				m,
				"Lueur",
				Vector3.new(3, 0.08, 6),
				CFrame.new(o + Vector3.new(0, 0.05, 0.3)),
				style.jupe
			)
		).Transparency =
			0.3
	end
	for _, z in { -3.2, 3.8 } do
		cylindre(m, "Rouleau", 3.9, 0.55, p(0, 0.3, z), "X", GRIS, Enum.Material.Metal)
	end
	piece(m, "Tapis", Vector3.new(3.1, 0.06, 6.8), CFrame.new(p(0, 0.43, 0.3)), style.tapis)
	for i = 1, 8 do
		local bande = piece(
			m,
			"Bande",
			Vector3.new(3.1, 0.07, 0.22),
			CFrame.new(p(0, 0.44, -3 + i * 0.85)),
			style.bande
		)
		if style.neon then
			neon(bande)
		end
		bande:SetAttribute("Indice", i)
	end
	for _, x in { -1.75, 1.75 } do
		local montant = piece(
			m,
			"Montant",
			Vector3.new(0.35, 3.8, 0.35),
			CFrame.new(p(x, 2.2, -3.25)) * CFrame.Angles(math.rad(-12), 0, 0),
			style.montant
		)
		if style.neon then
			neon(montant)
		end
		cylindre(m, "Poignee", 2.4, 0.3, p(x, 3.3, -2.2), "Z", style.poignee)
		boule(m, "Embout", 0.42, p(x, 3.3, -1), style.montant)
	end
	cylindre(m, "Traverse", 3.5, 0.32, p(0, 3.85, -3.55), "X", style.poignee)
	local console = piece(
		m,
		"Console",
		Vector3.new(3.2, 1.3, 0.5),
		CFrame.new(p(0, 4.45, -3.55)) * CFrame.Angles(math.rad(25), 0, 0),
		style.console
	)
	if style.ecran then
		local ecran = piece(
			m,
			"Ecran",
			Vector3.new(2.4, 0.8, 0.06),
			console.CFrame * CFrame.new(0, 0.05, 0.28),
			BLEU_FONCE,
			Enum.Material.Neon
		)
		if style.neon then
			ecran.Transparency = 0.25
		end
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
		texte.TextColor3 = rgb(140, 255, 200)
		texte.Text = "GO !"
		texte.Parent = surface
		for i, couleur in { ROUGE, JAUNE, rgb(90, 230, 120) } do
			neon(
				boule(
					m,
					"Voyant",
					0.22,
					(console.CFrame * CFrame.new(-1.2 + i * 0.6, -0.5, 0.26)).Position,
					couleur
				)
			)
		end
	end
	if style.etoiles then
		-- Anneaux en orbite et poussière d'étoiles.
		for i, couleur in { ROSE, CYAN } do
			local centre = o + Vector3.new(0, 3.2, 0.3)
			for k = 0, 23 do
				local a = k * 2 * math.pi / 24
				local incline = CFrame.Angles(math.rad(70), math.rad(i * 60), 0)
				local point = CFrame.new(centre)
					* incline
					* CFrame.new(math.cos(a) * (4 + i * 0.4), 0, math.sin(a) * (4 + i * 0.4))
				neon(boule(m, "Orbite", 0.22, point.Position, couleur))
			end
		end
		etincelles(console, ROSE, 8)
	end
end

local function agresVitesse(m: Model, o: Vector3, palier: number)
	if palier <= 1 then
		roueEnBois(m, o)
	elseif palier == 2 then
		tapis(m, o, {
			cadre = GRIS,
			jupe = rgb(110, 116, 132),
			tapis = NOIR,
			bande = rgb(70, 75, 98),
			montant = GRIS,
			poignee = rgb(60, 62, 74),
			console = rgb(60, 62, 74),
			ecran = false,
			neon = false,
			flotte = 0,
			etoiles = false,
		})
	elseif palier == 3 then
		tapis(m, o, {
			cadre = BLANC,
			jupe = BLEU,
			tapis = NOIR,
			bande = rgb(70, 75, 98),
			montant = BLEU,
			poignee = BLANC,
			console = BLANC,
			ecran = true,
			neon = false,
			flotte = 0,
			etoiles = false,
		})
	elseif palier == 4 then
		tapis(m, o, {
			cadre = rgb(28, 30, 42),
			jupe = CYAN,
			tapis = rgb(14, 16, 24),
			bande = CYAN,
			montant = CYAN,
			poignee = rgb(28, 30, 42),
			console = rgb(28, 30, 42),
			ecran = true,
			neon = true,
			flotte = 0.6,
			etoiles = false,
		})
	else
		tapis(m, o, {
			cadre = NUIT,
			jupe = VIOLET,
			tapis = rgb(16, 8, 34),
			bande = ROSE,
			montant = VIOLET,
			poignee = NUIT,
			console = NUIT,
			ecran = true,
			neon = true,
			flotte = 0.9,
			etoiles = true,
		})
	end
end

-- ===== Force =====

-- Gros rocher bosselé (plusieurs boules) posé devant le joueur.
local function rocher(parent: Instance, centre: Vector3, taille: number)
	for _, b in
		{
			{ 0, 0, 0, 1 },
			{ 0.35, 0.15, 0.1, 0.75 },
			{ -0.3, 0.1, -0.15, 0.7 },
			{ 0.05, 0.35, -0.1, 0.6 },
		}
	do
		boule(parent, "Roc", taille * b[4], centre + Vector3.new(b[1], b[2], b[3]) * taille, PIERRE).Material =
			Enum.Material.Slate
	end
	boule(parent, "Mousse", taille * 0.35, centre + Vector3.new(-0.2, 0.42, 0.2) * taille, VERT).Material =
		Enum.Material.Grass
end

local function haltere(parent: Instance, centre: Vector3, couleur: Color3)
	cylindre(parent, "Poignee", 1.1, 0.2, centre, "X", ACIER, Enum.Material.Metal)
	for _, cote in { -1, 1 } do
		cylindre(parent, "Poids", 0.32, 0.75, centre + Vector3.new(cote * 0.6, 0, 0), "X", couleur)
	end
end

-- Support de barre (palier 3 : rouge ; palier 4 : noir et néon).
local function supportBarre(m: Model, o: Vector3, futur: boolean)
	local function p(x: number, y: number, z: number): Vector3
		return o + Vector3.new(x, y, z)
	end
	local teinte = if futur then rgb(28, 30, 42) else ROUGE
	local accent = if futur then CYAN else JAUNE
	for _, x in { -3, 3 } do
		piece(m, "Pied", Vector3.new(0.9, 0.3, 1.8), CFrame.new(p(x, 0.25, 1.3)), teinte)
		local montant =
			piece(m, "Montant", Vector3.new(0.45, 5.4, 0.45), CFrame.new(p(x, 2.9, 1.3)), teinte)
		if futur then
			neon(
				piece(
					m,
					"Filet",
					Vector3.new(0.12, 5, 0.47),
					montant.CFrame * CFrame.new(-0.2, 0, 0),
					CYAN
				)
			)
		end
		boule(m, "Capuchon", 0.6, p(x, 5.65, 1.3), accent)
		piece(
			m,
			"Crochet",
			Vector3.new(0.3, 0.2, 0.7),
			CFrame.new(p(x, 4.45, 0.85)),
			ACIER,
			Enum.Material.Metal
		)
	end
	cylindre(m, "Entretoise", 6, 0.3, p(0, 0.6, 2.1), "X", teinte)
	local objet = Instance.new("Model")
	objet.Name = "Objet"
	objet.Parent = m
	local y, z = 4.72, 0.75
	cylindre(objet, "Tige", 7.2, 0.24, p(0, y, z), "X", ACIER, Enum.Material.Metal)
	for _, cote in { -1, 1 } do
		if futur then
			local disque = neon(cylindre(objet, "Disque", 0.4, 1.9, p(cote * 2.5, y, z), "X", CYAN))
			disque.Transparency = 0.3
			lumiere(disque, CYAN, 8)
		else
			cylindre(objet, "Disque", 0.35, 1.9, p(cote * 2.45, y, z), "X", ROUGE)
			cylindre(objet, "Disque", 0.3, 1.4, p(cote * 2.8, y, z), "X", JAUNE)
		end
	end
end

local function agresForce(m: Model, o: Vector3, palier: number)
	local function p(x: number, y: number, z: number): Vector3
		return o + Vector3.new(x, y, z)
	end
	local objets = { "Rocher", "Halteres", "Barre", "Plasma", "Meteorite" }
	m:SetAttribute("Objet", objets[palier] or "Rocher")
	if palier <= 1 then
		local objet = Instance.new("Model")
		objet.Name = "Objet"
		objet.Parent = m
		rocher(objet, p(0, 0.9, -1.6), 1.8)
		for i, position in { Vector3.new(-3.2, 0, 2.8), Vector3.new(3.1, 0, 2.6) } do
			boule(m, "Touffe", 0.7 + i * 0.1, o + position + Vector3.new(0, 0.2, 0), VERT).Material =
				Enum.Material.Grass
		end
		cylindre(m, "Souche", 0.9, 1.3, p(2.9, 0.45, -2.6), "Y", BOIS_FONCE, Enum.Material.Wood)
	elseif palier == 2 then
		-- Petit râtelier d'haltères.
		piece(
			m,
			"Ratelier",
			Vector3.new(4.4, 0.25, 1.2),
			CFrame.new(p(0, 1.4, 2.6)),
			rgb(60, 62, 74)
		)
		for _, x in { -2, 2 } do
			piece(
				m,
				"PiedRatelier",
				Vector3.new(0.3, 1.4, 1),
				CFrame.new(p(x, 0.7, 2.6)),
				rgb(60, 62, 74)
			)
		end
		local objet = Instance.new("Model")
		objet.Name = "Objet"
		objet.Parent = m
		for i, x in { -1.2, 1.2 } do
			haltere(objet, p(x, 1.85, 2.6), if i == 1 then BLEU else ROUGE)
		end
		haltere(m, p(0, 1.85, 2.6), JAUNE)
		piece(
			m,
			"TapisSol",
			Vector3.new(4, 0.08, 3),
			CFrame.new(p(0, 0.04, -0.6)),
			rgb(60, 62, 74),
			Enum.Material.Fabric
		)
	elseif palier <= 4 then
		piece(
			m,
			"TapisSol",
			Vector3.new(6.4, 0.1, 4.6),
			CFrame.new(p(0, 0.05, 0.4)),
			NOIR,
			Enum.Material.Fabric
		)
		supportBarre(m, o, palier == 4)
	else
		-- Météorite flottant au-dessus d'un socle.
		cylindre(m, "Socle", 0.8, 3, p(0, 0.4, 2.4), "Y", NUIT)
		neon(cylindre(m, "Anneau", 0.15, 3.2, p(0, 0.85, 2.4), "Y", VIOLET))
		local objet = Instance.new("Model")
		objet.Name = "Objet"
		objet.Parent = m
		local roc = boule(objet, "Meteore", 2.4, p(0, 3, 2.4), rgb(90, 50, 40))
		roc.Material = Enum.Material.CrackedLava
		lumiere(roc, LAVE, 12)
		local feu = Instance.new("ParticleEmitter")
		feu.Texture = "rbxasset://textures/particles/fire_main.dds"
		feu.Color = ColorSequence.new(LAVE, ROSE)
		feu.LightEmission = 1
		feu.Size = NumberSequence.new(1, 0)
		feu.Lifetime = NumberRange.new(0.4, 0.8)
		feu.Speed = NumberRange.new(0.5, 1.5)
		feu.Rate = 12
		feu.Parent = roc
		etincelles(roc, VIOLET, 6)
	end
end

-- ===== Double =====

local function agresDouble(m: Model, o: Vector3, palier: number)
	local function p(x: number, y: number, z: number): Vector3
		return o + Vector3.new(x, y, z)
	end
	local couleurs: { Color3 } = if palier >= 5
		then { NUIT, VIOLET, ROSE }
		elseif palier == 4 then { rgb(22, 24, 34), CYAN, BLEU }
		else { VIOLET, ROSE, JAUNE }
	m:SetAttribute(
		"Corde",
		if palier >= 5 then "Arcenciel" elseif palier == 4 then "Laser" else "Lumineuse"
	)
	cylindre(m, "Tapis", 0.12, 6.6, p(0, 0.06, 0), "Y", couleurs[1], Enum.Material.Fabric)
	local cercle =
		cylindre(m, "Cercle", 0.13, 4.8, p(0, 0.07, 0), "Y", couleurs[2], Enum.Material.Fabric)
	cylindre(m, "Coeur", 0.14, 3.6, p(0, 0.08, 0), "Y", couleurs[1], Enum.Material.Fabric)
	if palier >= 4 then
		neon(cercle)
	end
	for i = 0, 4 do
		local a = i * 2 * math.pi / 5
		neon(boule(m, "Etoile", 0.35, p(math.cos(a) * 2.9, 0.1, math.sin(a) * 2.9), couleurs[3]))
	end
end

-- Plateforme et agrès du palier ; renvoie le modèle.
local function remplir(modele: Model, plateforme: BasePart, palier: number)
	local sol = SOLS[palier] or SOLS[1]
	local centre = plateforme.Position
	local haut = centre.Y + plateforme.Size.Y / 2
	local diametre = plateforme.Size.X
	-- Dalle ronde à ras du sol (matière selon le palier) bordée de pavés.
	cylindre(
		modele,
		"Dalle",
		0.12,
		diametre - 1.2,
		Vector3.new(centre.X, haut - 0.05, centre.Z),
		"Y",
		sol.couleur,
		sol.matiere
	)
	local n = 16
	for i = 1, n do
		local a = (i - 0.5) / n * 2 * math.pi
		local r = diametre / 2 - 0.3
		piece(
			modele,
			"Pave",
			Vector3.new(1.1, 0.2, 0.7),
			CFrame.new(centre.X + math.cos(a) * r, haut, centre.Z + math.sin(a) * r)
				* CFrame.Angles(0, -a + math.pi / 2, 0),
			if i % 2 == 0 then rgb(150, 146, 140) else rgb(126, 122, 118),
			Enum.Material.Cobblestone
		)
	end
	local origine = Vector3.new(centre.X, haut, centre.Z)
	agresVitesse(poste(modele, "Vitesse"), origine, palier)
	agresForce(poste(modele, "Force"), origine, palier)
	agresDouble(poste(modele, "Double"), origine, palier)
end

-- Construit la Forge autour de `plateforme` (la Part « Forge ») pour le
-- niveau de Forge `niveau`. `sol` : hauteur du dessus du sol de la base.
function MachineForge.construire(
	plateforme: BasePart,
	sol: number,
	proprietaire: any,
	niveau: any?
): Model
	local _ = sol
	local palier = Forge.palier(niveau)
	local modele = Instance.new("Model")
	modele.Name = "MachineForge"
	modele:SetAttribute("Proprietaire", proprietaire)
	modele:SetAttribute("Palier", palier)
	-- Streaming : la machine arrive chez le client en une fois.
	modele.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	remplir(modele, plateforme, palier)

	if plateforme:FindFirstChild("Poste") == nil then
		-- Point où se tient le joueur (au centre, dos à l'enclos : regard vers +Z).
		local point = Instance.new("Attachment")
		point.Name = "Poste"
		point.Parent = plateforme
		point.WorldCFrame =
			CFrame.new(plateforme.Position + Vector3.new(0, plateforme.Size.Y / 2, 0))
	end

	modele.Parent = plateforme.Parent
	CollectionService:AddTag(modele, MachineForge.Tag)
	return modele
end

-- Reconstruit la machine si le palier du niveau a changé.
function MachineForge.mettreAJour(plateforme: BasePart, proprietaire: any, niveau: any)
	local parent = plateforme.Parent
	local ancien = parent and parent:FindFirstChild("MachineForge")
	if ancien and ancien:GetAttribute("Palier") == Forge.palier(niveau) then
		return
	end
	if ancien then
		ancien:Destroy()
	end
	MachineForge.construire(plateforme, 0, proprietaire, niveau)
end

return MachineForge
