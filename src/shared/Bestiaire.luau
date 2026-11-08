--!strict
-- Bestiaire (données pures, testables avec Lune) : la forme en blocs de chaque
-- créature et de chaque monstre, dans le style « jouet en blocs » du jeu.
--
-- Chaque espèce tient dans une boîte de 1 × 1 × 1 (unités), centrée sur
-- l'origine : les pieds sont à Y = -0.5, l'avant regarde vers -Z, la droite
-- est +X. Le serveur multiplie tout par la taille réelle (en studs).
--
-- Un bloc :
--   n  nom de la pièce (les yeux commencent par « Oeil » : ils brillent la nuit)
--   f  forme : "Block" (défaut), "Ball", "Cylinder" ou "Wedge"
--   t  taille {x, y, z}            p  centre {x, y, z}
--   c  couleur {r, g, b} (0-255) ou "Rarete" (couleur de la rareté)
--   r  rotation {x, y, z} en degrés (facultatif)
--   m  matériau : "Neon", "Glass" ou "Foil" (facultatif)
--   tr transparence (facultatif)
--   a  rôle d'animation : Patte, Bras, Aile, Queue, Oreille, Tete, Antenne,
--      Machoire (facultatif) ; j = articulation {x, y, z} ; ph = phase ;
--      cote = -1 (gauche) ou 1 (droite)
local Bestiaire = {}

export type Couleur = { number } | string
export type Bloc = {
	n: string,
	f: string?,
	t: { number },
	p: { number },
	c: Couleur,
	r: { number }?,
	m: string?,
	tr: number?,
	a: string?,
	j: { number }?,
	ph: number?,
	cote: number?,
}
export type Espece = {
	Nom: string,
	Hauteur: number, -- haut du modèle (unités), pour placer le panneau
	Blocs: { Bloc },
}

local PI = math.pi

-- Couleurs communes
local BLANC = { 255, 255, 255 }
local NOIR = { 25, 20, 30 }
local ROSE = { 255, 140, 175 }
local CREME = { 255, 236, 200 }

-- Ajoute un bloc, et son symétrique (X opposé, rotation Y/Z opposées) si
-- `paire` est vrai. Le bloc de gauche reçoit cote = -1, celui de droite 1.
local function ajouter(liste: { Bloc }, b: Bloc, paire: boolean?)
	if not paire then
		table.insert(liste, b)
		return
	end
	for _, cote in { -1, 1 } do
		local copie: Bloc = table.clone(b)
		copie.n = b.n .. (if cote < 0 then "G" else "D")
		copie.p = { b.p[1] * cote, b.p[2], b.p[3] }
		if b.j then
			local j = b.j :: { number }
			copie.j = { j[1] * cote, j[2], j[3] }
		end
		if b.r then
			local r = b.r :: { number }
			copie.r = { r[1], r[2] * cote, r[3] * cote }
		end
		copie.cote = cote
		if b.ph ~= nil and cote < 0 then
			copie.ph = (b.ph :: number) + PI
		end
		table.insert(liste, copie)
	end
end

-- Deux yeux (blanc + pupille + reflet) sur un plan avant à `z`.
local function yeux(
	liste: { Bloc },
	x: number,
	y: number,
	z: number,
	taille: number,
	role: string?,
	j: { number }?
)
	ajouter(liste, {
		n = "Oeil",
		t = { taille, taille * 1.15, 0.04 },
		p = { x, y, z },
		c = BLANC,
		a = role,
		j = j,
	}, true)
	ajouter(liste, {
		n = "Pupille",
		t = { taille * 0.5, taille * 0.65, 0.03 },
		p = { x - taille * 0.08, y - taille * 0.08, z - 0.025 },
		c = NOIR,
		a = role,
		j = j,
	}, true)
	ajouter(liste, {
		n = "Reflet",
		t = { taille * 0.2, taille * 0.2, 0.02 },
		p = { x + taille * 0.15, y + taille * 0.25, z - 0.035 },
		c = BLANC,
		a = role,
		j = j,
	}, true)
end

-- Quatre pattes : avant (z1) et arrière (z2), pas alternés.
local function pattes4(
	liste: { Bloc },
	x: number,
	z1: number,
	z2: number,
	t: { number },
	c: Couleur
)
	local y = -0.5 + t[2] / 2
	local jy = y + t[2] / 2 - 0.02
	ajouter(
		liste,
		{ n = "PatteAv", t = t, p = { x, y, z1 }, c = c, a = "Patte", j = { x, jy, z1 }, ph = 0 },
		true
	)
	ajouter(
		liste,
		{ n = "PatteAr", t = t, p = { x, y, z2 }, c = c, a = "Patte", j = { x, jy, z2 }, ph = PI },
		true
	)
end

local especes: { [string]: Espece } = {}

local function definir(nom: string, hauteur: number, remplir: (liste: { Bloc }) -> ())
	local liste: { Bloc } = {}
	remplir(liste)
	especes[nom] = { Nom = nom, Hauteur = hauteur, Blocs = liste }
end

---------------------------------------------------------------------------
-- Créatures (une espèce par rareté)

-- Commune : poussin jaune avec une pousse sur la tête.
definir("Poussigraine", 0.7, function(l)
	local jaune = { 255, 214, 70 }
	local orange = { 255, 150, 40 }
	local vert = { 90, 210, 70 }
	local tete = { 0, 0.12, -0.04 }
	ajouter(l, { n = "Ventre", t = { 0.62, 0.52, 0.6 }, p = { 0, -0.14, 0.02 }, c = jaune })
	ajouter(l, {
		n = "Tete",
		t = { 0.5, 0.42, 0.48 },
		p = { 0, 0.3, -0.06 },
		c = jaune,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Bec",
		t = { 0.16, 0.1, 0.14 },
		p = { 0, 0.26, -0.36 },
		c = orange,
		a = "Tete",
		j = tete,
	})
	yeux(l, 0.12, 0.36, -0.31, 0.12, "Tete", tete)
	ajouter(l, {
		n = "Joue",
		t = { 0.08, 0.05, 0.03 },
		p = { 0.19, 0.25, -0.31 },
		c = ROSE,
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Aile",
		t = { 0.08, 0.3, 0.36 },
		p = { 0.35, -0.1, 0.02 },
		c = { 240, 180, 50 },
		a = "Aile",
		j = { 0.31, 0.04, 0.02 },
	}, true)
	ajouter(l, {
		n = "Patte",
		t = { 0.07, 0.12, 0.07 },
		p = { 0.13, -0.42, 0 },
		c = orange,
		a = "Patte",
		j = { 0.13, -0.38, 0 },
		ph = 0,
	}, true)
	ajouter(l, {
		n = "Pied",
		t = { 0.18, 0.04, 0.2 },
		p = { 0.13, -0.48, -0.04 },
		c = orange,
		a = "Patte",
		j = { 0.13, -0.38, 0 },
		ph = 0,
	}, true)
	local pousse = { 0, 0.5, -0.04 }
	ajouter(l, {
		n = "Tige",
		t = { 0.04, 0.14, 0.04 },
		p = { 0, 0.57, -0.04 },
		c = vert,
		a = "Antenne",
		j = pousse,
	})
	ajouter(l, {
		n = "Feuille",
		t = { 0.16, 0.04, 0.1 },
		p = { 0.08, 0.64, -0.04 },
		r = { 0, 0, 20 },
		c = vert,
		a = "Antenne",
		j = pousse,
	})
	ajouter(l, {
		n = "Feuille2",
		t = { 0.14, 0.04, 0.09 },
		p = { -0.07, 0.61, -0.04 },
		r = { 0, 0, -25 },
		c = vert,
		a = "Antenne",
		j = pousse,
	})
end)

-- Rare : lapin aux grandes oreilles, collier de la couleur de rareté.
definir("Lapinou", 0.65, function(l)
	local poil = { 205, 220, 245 }
	local tete = { 0, -0.06, -0.16 }
	ajouter(l, { n = "Ventre", t = { 0.5, 0.38, 0.6 }, p = { 0, -0.22, 0.06 }, c = poil })
	ajouter(l, {
		n = "Tete",
		t = { 0.42, 0.36, 0.36 },
		p = { 0, 0.06, -0.26 },
		c = poil,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Museau",
		t = { 0.2, 0.1, 0.05 },
		p = { 0, -0.02, -0.45 },
		c = BLANC,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Nez",
		t = { 0.08, 0.05, 0.03 },
		p = { 0, 0.03, -0.47 },
		c = ROSE,
		a = "Tete",
		j = tete,
	})
	yeux(l, 0.11, 0.11, -0.45, 0.1, "Tete", tete)
	ajouter(l, {
		n = "Joue",
		t = { 0.07, 0.04, 0.03 },
		p = { 0.16, 0.0, -0.45 },
		c = ROSE,
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Oreille",
		t = { 0.1, 0.34, 0.07 },
		p = { 0.11, 0.4, -0.24 },
		c = poil,
		a = "Oreille",
		j = { 0.11, 0.24, -0.24 },
	}, true)
	ajouter(l, {
		n = "OreilleInterieur",
		t = { 0.05, 0.24, 0.02 },
		p = { 0.11, 0.4, -0.28 },
		c = ROSE,
		a = "Oreille",
		j = { 0.11, 0.24, -0.24 },
	}, true)
	ajouter(l, { n = "Collier", t = { 0.44, 0.06, 0.38 }, p = { 0, -0.13, -0.24 }, c = "Rarete" })
	pattes4(l, 0.15, -0.16, 0.24, { 0.12, 0.13, 0.16 }, poil)
	ajouter(l, {
		n = "Queue",
		f = "Ball",
		t = { 0.17, 0.17, 0.17 },
		p = { 0, -0.14, 0.38 },
		c = BLANC,
		a = "Queue",
		j = { 0, -0.14, 0.34 },
	})
end)

-- Épique : renard à la grande queue, écharpe de la couleur de rareté.
definir("Renardelle", 0.7, function(l)
	local roux = { 245, 130, 40 }
	local sombre = { 70, 45, 35 }
	local tete = { 0, 0, -0.2 }
	local queue = { 0, -0.08, 0.32 }
	ajouter(l, { n = "Ventre", t = { 0.44, 0.32, 0.62 }, p = { 0, -0.2, 0 }, c = roux })
	ajouter(l, { n = "Poitrail", t = { 0.3, 0.22, 0.05 }, p = { 0, -0.16, -0.32 }, c = BLANC })
	ajouter(l, {
		n = "Tete",
		t = { 0.4, 0.32, 0.34 },
		p = { 0, 0.1, -0.32 },
		c = roux,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Museau",
		t = { 0.18, 0.12, 0.16 },
		p = { 0, 0.03, -0.55 },
		c = BLANC,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Nez",
		t = { 0.07, 0.05, 0.04 },
		p = { 0, 0.08, -0.63 },
		c = NOIR,
		a = "Tete",
		j = tete,
	})
	yeux(l, 0.1, 0.16, -0.5, 0.09, "Tete", tete)
	ajouter(l, {
		n = "Oreille",
		t = { 0.11, 0.16, 0.06 },
		p = { 0.12, 0.33, -0.3 },
		c = roux,
		a = "Oreille",
		j = { 0.12, 0.26, -0.3 },
	}, true)
	ajouter(l, {
		n = "BoutOreille",
		t = { 0.11, 0.05, 0.065 },
		p = { 0.12, 0.41, -0.3 },
		c = sombre,
		a = "Oreille",
		j = { 0.12, 0.26, -0.3 },
	}, true)
	ajouter(l, { n = "Echarpe", t = { 0.42, 0.08, 0.36 }, p = { 0, -0.06, -0.22 }, c = "Rarete" })
	pattes4(l, 0.14, -0.2, 0.2, { 0.1, 0.16, 0.1 }, sombre)
	ajouter(l, {
		n = "Queue",
		t = { 0.2, 0.2, 0.36 },
		p = { 0, -0.04, 0.48 },
		r = { -15, 0, 0 },
		c = roux,
		a = "Queue",
		j = queue,
	})
	ajouter(l, {
		n = "BoutQueue",
		t = { 0.18, 0.18, 0.14 },
		p = { 0, 0.02, 0.7 },
		r = { -15, 0, 0 },
		c = BLANC,
		a = "Queue",
		j = queue,
	})
end)

-- Légendaire : faon aux bois dorés et joyau au front.
definir("Cerfaurore", 0.95, function(l)
	local fauve = { 205, 150, 90 }
	local sombre = { 80, 55, 40 }
	local or_ = { 255, 205, 50 }
	local tete = { 0, 0.08, -0.22 }
	ajouter(l, { n = "Ventre", t = { 0.38, 0.3, 0.58 }, p = { 0, -0.06, 0.06 }, c = fauve })
	for i, pos in { { 0.1, 0.095, 0.0 }, { -0.08, 0.095, 0.18 }, { 0.06, 0.095, 0.26 } } do
		ajouter(l, { n = "Tache" .. i, t = { 0.08, 0.02, 0.08 }, p = pos, c = CREME })
	end
	pattes4(l, 0.12, -0.14, 0.26, { 0.08, 0.3, 0.08 }, fauve)
	ajouter(l, {
		n = "Cou",
		t = { 0.16, 0.26, 0.14 },
		p = { 0, 0.16, -0.2 },
		c = fauve,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Tete",
		t = { 0.26, 0.22, 0.3 },
		p = { 0, 0.32, -0.34 },
		c = fauve,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Museau",
		t = { 0.16, 0.12, 0.12 },
		p = { 0, 0.27, -0.53 },
		c = CREME,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Nez",
		t = { 0.07, 0.05, 0.03 },
		p = { 0, 0.31, -0.6 },
		c = sombre,
		a = "Tete",
		j = tete,
	})
	yeux(l, 0.09, 0.36, -0.495, 0.08, "Tete", tete)
	ajouter(l, {
		n = "Oreille",
		t = { 0.12, 0.06, 0.04 },
		p = { 0.18, 0.4, -0.3 },
		r = { 0, 0, 20 },
		c = fauve,
		a = "Oreille",
		j = { 0.12, 0.4, -0.3 },
	}, true)
	ajouter(l, {
		n = "BoisBas",
		t = { 0.04, 0.2, 0.04 },
		p = { 0.08, 0.52, -0.32 },
		c = or_,
		m = "Foil",
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "BoisBranche",
		t = { 0.14, 0.04, 0.04 },
		p = { 0.14, 0.58, -0.32 },
		c = or_,
		m = "Foil",
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "BoisPointe",
		t = { 0.04, 0.14, 0.04 },
		p = { 0.2, 0.67, -0.32 },
		c = or_,
		m = "Foil",
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "BoisPointe2",
		t = { 0.04, 0.1, 0.04 },
		p = { 0.08, 0.66, -0.32 },
		c = or_,
		m = "Foil",
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Joyau",
		t = { 0.07, 0.07, 0.03 },
		p = { 0, 0.4, -0.5 },
		r = { 0, 0, 45 },
		c = "Rarete",
		m = "Neon",
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Queue",
		t = { 0.08, 0.12, 0.06 },
		p = { 0, 0.04, 0.37 },
		c = CREME,
		a = "Queue",
		j = { 0, 0.08, 0.35 },
	})
end)

-- Mythique : bébé dragon ailé, crête et bout de queue lumineux.
definir("Dragonnet", 0.75, function(l)
	local rose = { 255, 80, 150 }
	local tete = { 0, 0.02, -0.14 }
	local queue = { 0, -0.22, 0.28 }
	ajouter(l, { n = "Ventre", t = { 0.42, 0.36, 0.5 }, p = { 0, -0.16, 0.04 }, c = rose })
	ajouter(l, { n = "Plastron", t = { 0.3, 0.26, 0.04 }, p = { 0, -0.18, -0.22 }, c = CREME })
	ajouter(l, {
		n = "Tete",
		t = { 0.38, 0.32, 0.34 },
		p = { 0, 0.16, -0.24 },
		c = rose,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Museau",
		t = { 0.24, 0.14, 0.14 },
		p = { 0, 0.09, -0.46 },
		c = rose,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Narine",
		t = { 0.04, 0.03, 0.02 },
		p = { 0.05, 0.12, -0.535 },
		c = NOIR,
		a = "Tete",
		j = tete,
	}, true)
	yeux(l, 0.11, 0.23, -0.415, 0.11, "Tete", tete)
	ajouter(l, {
		n = "Corne",
		t = { 0.06, 0.16, 0.06 },
		p = { 0.12, 0.38, -0.18 },
		r = { -20, 0, -15 },
		c = CREME,
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Crete1",
		t = { 0.06, 0.08, 0.08 },
		p = { 0, 0.04, -0.04 },
		r = { 45, 0, 0 },
		c = "Rarete",
		m = "Neon",
	})
	ajouter(l, {
		n = "Crete2",
		t = { 0.06, 0.08, 0.08 },
		p = { 0, 0.04, 0.12 },
		r = { 45, 0, 0 },
		c = "Rarete",
		m = "Neon",
	})
	pattes4(l, 0.14, -0.12, 0.2, { 0.12, 0.14, 0.14 }, rose)
	ajouter(l, {
		n = "Aile",
		t = { 0.04, 0.32, 0.36 },
		p = { 0.3, 0.08, 0.08 },
		r = { 0, 0, -20 },
		c = { 190, 120, 255 },
		tr = 0.15,
		a = "Aile",
		j = { 0.22, 0, 0.06 },
	}, true)
	ajouter(l, {
		n = "Queue",
		t = { 0.12, 0.12, 0.3 },
		p = { 0, -0.22, 0.42 },
		c = rose,
		a = "Queue",
		j = queue,
	})
	ajouter(l, {
		n = "BoutQueue",
		t = { 0.16, 0.06, 0.12 },
		p = { 0, -0.2, 0.6 },
		r = { 0, 45, 0 },
		c = "Rarete",
		m = "Neon",
		a = "Queue",
		j = queue,
	})
end)

---------------------------------------------------------------------------
-- Monstres (deux espèces par zone, toutes originales)

-- Proche : slime cube translucide, cœur sombre, gouttes qui pendent.
definir("Gloupinou", 0.55, function(l)
	local gelee = { 120, 230, 255 }
	ajouter(
		l,
		{ n = "Gelee", t = { 0.9, 0.8, 0.9 }, p = { 0, -0.1, 0 }, c = gelee, tr = 0.3, m = "Glass" }
	)
	ajouter(
		l,
		{ n = "Coeur", t = { 0.4, 0.35, 0.4 }, p = { 0, -0.15, 0.08 }, c = { 40, 140, 200 } }
	)
	ajouter(l, {
		n = "Bulle",
		f = "Ball",
		t = { 0.1, 0.1, 0.1 },
		p = { 0.25, 0.1, 0.2 },
		c = BLANC,
		tr = 0.4,
	})
	ajouter(l, {
		n = "Bulle2",
		f = "Ball",
		t = { 0.07, 0.07, 0.07 },
		p = { -0.28, -0.05, 0.1 },
		c = BLANC,
		tr = 0.4,
	})
	yeux(l, 0.2, 0.08, -0.46, 0.24)
	ajouter(
		l,
		{ n = "Bouche", t = { 0.36, 0.1, 0.03 }, p = { 0, -0.18, -0.46 }, c = { 30, 60, 110 } }
	)
	ajouter(l, { n = "Langue", t = { 0.12, 0.08, 0.04 }, p = { 0.08, -0.25, -0.465 }, c = ROSE })
	ajouter(l, {
		n = "Sommet",
		t = { 0.42, 0.12, 0.42 },
		p = { 0, 0.36, 0 },
		c = gelee,
		tr = 0.3,
		m = "Glass",
		a = "Antenne",
		j = { 0, 0.3, 0 },
	})
	for i, pos in { { -0.3, -0.48, -0.3 }, { 0.32, -0.47, -0.1 }, { 0.05, -0.48, 0.32 } } do
		ajouter(
			l,
			{ n = "Goutte" .. i, t = { 0.1, 0.14, 0.1 }, p = pos, c = gelee, tr = 0.3, m = "Glass" }
		)
	end
end)

-- Proche : hérisson grognon couvert de piquants.
definir("Piquerelle", 0.62, function(l)
	local brun = { 140, 90, 55 }
	local fonce = { 85, 50, 30 }
	local tete = { 0, -0.15, -0.3 }
	ajouter(l, { n = "Dos", t = { 0.7, 0.5, 0.78 }, p = { 0, -0.12, 0.06 }, c = brun })
	ajouter(l, {
		n = "Visage",
		t = { 0.5, 0.4, 0.2 },
		p = { 0, -0.12, -0.38 },
		c = CREME,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Museau",
		t = { 0.16, 0.12, 0.18 },
		p = { 0, -0.16, -0.54 },
		c = CREME,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Nez",
		t = { 0.08, 0.07, 0.04 },
		p = { 0, -0.13, -0.64 },
		c = NOIR,
		a = "Tete",
		j = tete,
	})
	yeux(l, 0.12, -0.02, -0.49, 0.1, "Tete", tete)
	ajouter(l, {
		n = "Sourcil",
		t = { 0.14, 0.04, 0.03 },
		p = { 0.12, 0.07, -0.49 },
		r = { 0, 0, 15 },
		c = fonce,
		a = "Tete",
		j = tete,
	}, true)
	for ix, x in { -0.24, 0, 0.24 } do
		for iz, z in { -0.18, 0.06, 0.3 } do
			ajouter(l, {
				n = `Piquant{ix}{iz}`,
				t = { 0.12, 0.24, 0.12 },
				p = { x, 0.2, z },
				r = { -35, 0, x * 60 },
				c = if (ix + iz) % 2 == 0 then fonce else { 110, 70, 40 },
			})
		end
	end
	pattes4(l, 0.2, -0.18, 0.3, { 0.14, 0.14, 0.14 }, fonce)
end)

-- Moyenne : sanglier ronchon, défenses et crinière.
definir("Ronchonbulle", 0.62, function(l)
	local roux = { 210, 120, 60 }
	local fonce = { 110, 55, 30 }
	local tete = { 0, 0, -0.32 }
	ajouter(l, { n = "Ventre", t = { 0.7, 0.55, 0.85 }, p = { 0, -0.1, 0.06 }, c = roux })
	ajouter(l, {
		n = "Tete",
		t = { 0.55, 0.48, 0.38 },
		p = { 0, 0.04, -0.5 },
		c = roux,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Groin",
		t = { 0.3, 0.2, 0.12 },
		p = { 0, -0.04, -0.74 },
		c = ROSE,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Narine",
		t = { 0.06, 0.08, 0.02 },
		p = { 0.07, -0.04, -0.805 },
		c = { 120, 40, 60 },
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Defense",
		t = { 0.06, 0.2, 0.06 },
		p = { 0.17, 0.02, -0.73 },
		r = { 0, 0, -18 },
		c = CREME,
		a = "Tete",
		j = tete,
	}, true)
	yeux(l, 0.15, 0.15, -0.695, 0.11, "Tete", tete)
	ajouter(l, {
		n = "Sourcil",
		t = { 0.18, 0.05, 0.03 },
		p = { 0.15, 0.24, -0.7 },
		r = { 0, 0, 22 },
		c = fonce,
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Oreille",
		t = { 0.12, 0.16, 0.08 },
		p = { 0.24, 0.32, -0.44 },
		r = { 0, 0, -20 },
		c = roux,
		a = "Oreille",
		j = { 0.22, 0.26, -0.44 },
	}, true)
	for i, z in { -0.24, -0.02, 0.2, 0.42 } do
		ajouter(l, {
			n = "Criniere" .. i,
			t = { 0.1, 0.2, 0.16 },
			p = { 0, 0.24, z },
			r = { -25, 0, 0 },
			c = fonce,
		})
	end
	pattes4(l, 0.22, -0.22, 0.32, { 0.15, 0.22, 0.15 }, fonce)
	ajouter(l, {
		n = "Queue",
		t = { 0.06, 0.06, 0.16 },
		p = { 0, 0.06, 0.55 },
		r = { -30, 0, 0 },
		c = roux,
		a = "Queue",
		j = { 0, 0.04, 0.48 },
	})
end)

-- Moyenne : loup de lune aux yeux lumineux.
definir("Croquelune", 0.7, function(l)
	local gris = { 110, 120, 170 }
	local clair = { 200, 210, 240 }
	local tete = { 0, 0.1, -0.4 }
	local queue = { 0, 0.05, 0.48 }
	ajouter(l, { n = "Ventre", t = { 0.55, 0.44, 0.9 }, p = { 0, -0.06, 0.06 }, c = gris })
	ajouter(l, { n = "Criniere", t = { 0.62, 0.32, 0.22 }, p = { 0, 0.08, -0.3 }, c = clair })
	ajouter(l, {
		n = "Tete",
		t = { 0.42, 0.38, 0.38 },
		p = { 0, 0.16, -0.52 },
		c = gris,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Museau",
		t = { 0.22, 0.16, 0.24 },
		p = { 0, 0.07, -0.78 },
		c = clair,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Truffe",
		t = { 0.08, 0.06, 0.04 },
		p = { 0, 0.14, -0.9 },
		c = NOIR,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Croc",
		t = { 0.04, 0.07, 0.03 },
		p = { 0.06, -0.04, -0.89 },
		c = BLANC,
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Oeil",
		t = { 0.1, 0.07, 0.03 },
		p = { 0.12, 0.23, -0.715 },
		r = { 0, 0, -12 },
		c = { 255, 230, 60 },
		m = "Neon",
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Sourcil",
		t = { 0.13, 0.04, 0.03 },
		p = { 0.12, 0.29, -0.715 },
		r = { 0, 0, 20 },
		c = { 50, 50, 80 },
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Oreille",
		t = { 0.12, 0.18, 0.06 },
		p = { 0.13, 0.43, -0.5 },
		c = gris,
		a = "Oreille",
		j = { 0.13, 0.35, -0.5 },
	}, true)
	pattes4(l, 0.18, -0.28, 0.34, { 0.12, 0.28, 0.12 }, gris)
	ajouter(l, {
		n = "Queue",
		t = { 0.13, 0.13, 0.36 },
		p = { 0, 0.12, 0.66 },
		r = { 30, 0, 0 },
		c = gris,
		a = "Queue",
		j = queue,
	})
	ajouter(l, {
		n = "BoutQueue",
		t = { 0.12, 0.12, 0.12 },
		p = { 0, 0.22, 0.83 },
		r = { 30, 0, 0 },
		c = clair,
		a = "Queue",
		j = queue,
	})
end)

-- Lointaine : ogre-ours violet debout, cornes et gros poings.
definir("Grobidou", 0.82, function(l)
	local violet = { 125, 65, 210 }
	local fonce = { 75, 30, 140 }
	local lilas = { 210, 180, 255 }
	local tete = { 0, 0.28, 0 }
	ajouter(l, { n = "Torse", t = { 0.8, 0.66, 0.6 }, p = { 0, -0.02, 0 }, c = violet })
	ajouter(l, { n = "Ventre", t = { 0.54, 0.46, 0.04 }, p = { 0, -0.08, -0.31 }, c = lilas })
	ajouter(l, {
		n = "Tete",
		t = { 0.6, 0.34, 0.5 },
		p = { 0, 0.46, -0.02 },
		c = violet,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Corne",
		t = { 0.1, 0.28, 0.1 },
		p = { 0.25, 0.72, 0 },
		r = { 0, 0, -25 },
		c = CREME,
		a = "Tete",
		j = tete,
	}, true)
	yeux(l, 0.13, 0.5, -0.275, 0.14, "Tete", tete)
	ajouter(l, {
		n = "Sourcil",
		t = { 0.18, 0.05, 0.03 },
		p = { 0.13, 0.62, -0.28 },
		r = { 0, 0, 20 },
		c = fonce,
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Bouche",
		t = { 0.36, 0.08, 0.03 },
		p = { 0, 0.36, -0.275 },
		c = { 60, 15, 40 },
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Dent",
		t = { 0.06, 0.09, 0.03 },
		p = { 0.1, 0.3, -0.28 },
		c = BLANC,
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Bras",
		t = { 0.2, 0.48, 0.22 },
		p = { 0.5, 0.0, -0.02 },
		c = violet,
		a = "Bras",
		j = { 0.5, 0.22, -0.02 },
		ph = 0,
	}, true)
	ajouter(l, {
		n = "Poing",
		t = { 0.26, 0.22, 0.28 },
		p = { 0.5, -0.3, -0.04 },
		c = fonce,
		a = "Bras",
		j = { 0.5, 0.22, -0.02 },
		ph = 0,
	}, true)
	ajouter(l, {
		n = "Jambe",
		t = { 0.24, 0.2, 0.26 },
		p = { 0.2, -0.36, 0 },
		c = fonce,
		a = "Patte",
		j = { 0.2, -0.26, 0 },
		ph = PI,
	}, true)
	ajouter(l, {
		n = "Pied",
		t = { 0.28, 0.08, 0.34 },
		p = { 0.2, -0.46, -0.05 },
		c = fonce,
		a = "Patte",
		j = { 0.2, -0.26, 0 },
		ph = PI,
	}, true)
	for i, pos in { { -0.2, 0.15, 0.305 }, { 0.18, -0.12, 0.305 }, { 0.05, 0.2, 0.305 } } do
		ajouter(l, { n = "Tache" .. i, t = { 0.14, 0.14, 0.02 }, p = pos, c = lilas })
	end
end)

-- Lointaine : mini-dinosaure cracheur, plaques dorsales et petites ailes.
definir("Brasaurus", 0.8, function(l)
	local vert = { 90, 190, 90 }
	local orange = { 255, 160, 60 }
	local rouge = { 230, 60, 50 }
	local tete = { 0, 0.15, -0.2 }
	local queue = { 0, -0.08, 0.42 }
	ajouter(l, { n = "Ventre", t = { 0.55, 0.5, 0.66 }, p = { 0, -0.05, 0.1 }, c = vert })
	ajouter(l, { n = "Plastron", t = { 0.4, 0.36, 0.04 }, p = { 0, -0.08, -0.24 }, c = orange })
	ajouter(l, {
		n = "Tete",
		t = { 0.45, 0.32, 0.5 },
		p = { 0, 0.32, -0.36 },
		c = vert,
		a = "Tete",
		j = tete,
	})
	ajouter(l, {
		n = "Machoire",
		t = { 0.42, 0.1, 0.44 },
		p = { 0, 0.11, -0.4 },
		c = orange,
		a = "Machoire",
		j = { 0, 0.14, -0.2 },
	})
	ajouter(l, {
		n = "Dent",
		t = { 0.05, 0.06, 0.04 },
		p = { 0.12, 0.19, -0.6 },
		c = BLANC,
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Dent2",
		t = { 0.05, 0.06, 0.04 },
		p = { 0.04, 0.19, -0.6 },
		c = BLANC,
		a = "Tete",
		j = tete,
	}, true)
	yeux(l, 0.14, 0.42, -0.615, 0.11, "Tete", tete)
	ajouter(l, {
		n = "Sourcil",
		t = { 0.14, 0.04, 0.03 },
		p = { 0.14, 0.51, -0.62 },
		r = { 0, 0, 18 },
		c = { 40, 90, 40 },
		a = "Tete",
		j = tete,
	}, true)
	ajouter(l, {
		n = "Bras",
		t = { 0.08, 0.18, 0.08 },
		p = { 0.3, 0.0, -0.22 },
		c = vert,
		a = "Bras",
		j = { 0.3, 0.08, -0.22 },
		ph = 0,
	}, true)
	ajouter(l, {
		n = "Jambe",
		t = { 0.2, 0.26, 0.24 },
		p = { 0.2, -0.37, 0.15 },
		c = vert,
		a = "Patte",
		j = { 0.2, -0.26, 0.15 },
		ph = 0,
	}, true)
	ajouter(l, {
		n = "Pied",
		t = { 0.22, 0.06, 0.3 },
		p = { 0.2, -0.47, 0.1 },
		c = { 60, 140, 60 },
		a = "Patte",
		j = { 0.2, -0.26, 0.15 },
		ph = 0,
	}, true)
	ajouter(l, {
		n = "Queue",
		t = { 0.24, 0.2, 0.44 },
		p = { 0, -0.1, 0.62 },
		c = vert,
		a = "Queue",
		j = queue,
	})
	ajouter(l, {
		n = "BoutQueue",
		t = { 0.14, 0.12, 0.26 },
		p = { 0, -0.12, 0.94 },
		c = vert,
		a = "Queue",
		j = queue,
	})
	for i, z in { -0.05, 0.15, 0.35 } do
		ajouter(l, {
			n = "Plaque" .. i,
			t = { 0.06, 0.16, 0.14 },
			p = { 0, 0.24, z },
			r = { 0, 0, 0 },
			c = rouge,
		})
	end
	ajouter(l, {
		n = "PlaqueQueue",
		t = { 0.05, 0.12, 0.12 },
		p = { 0, 0.04, 0.62 },
		c = rouge,
		a = "Queue",
		j = queue,
	})
	ajouter(l, {
		n = "Aile",
		t = { 0.04, 0.22, 0.3 },
		p = { 0.3, 0.24, 0.15 },
		r = { 0, 0, -25 },
		c = rouge,
		tr = 0.1,
		a = "Aile",
		j = { 0.27, 0.18, 0.12 },
	}, true)
end)

Bestiaire.Especes = especes

-- Espèce de créature pour chaque rareté.
Bestiaire.Creatures = {
	Commune = "Poussigraine",
	Rare = "Lapinou",
	Epique = "Renardelle",
	Legendaire = "Cerfaurore",
	Mythique = "Dragonnet",
}

-- Espèces de monstres par zone (la première porte le nom de Config).
Bestiaire.Monstres = {
	Proche = { "Gloupinou", "Piquerelle" },
	Moyenne = { "Ronchonbulle", "Croquelune" },
	Lointaine = { "Grobidou", "Brasaurus" },
}

function Bestiaire.especeCreature(rarete: string): Espece
	return especes[Bestiaire.Creatures[rarete] or "Poussigraine"]
end

-- Espèce de monstre d'une zone ; `tirage` dans [0, 1[ choisit la variante.
function Bestiaire.especeMonstre(zone: string, tirage: number): Espece
	local liste = (Bestiaire.Monstres :: any)[zone] or Bestiaire.Monstres.Proche
	local i = math.clamp(math.floor(tirage * #liste) + 1, 1, #liste)
	return especes[liste[i]]
end

return Bestiaire
