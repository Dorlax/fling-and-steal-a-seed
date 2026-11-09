--!strict
-- Bestiaire du biome 10 : Jungle Émeraude (lianes, fleurs géantes, ruines).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local FEUILLE = { 70, 160, 80 }
	local PIERRE = { 150, 150, 130 }
	local MOUSSE = { 100, 170, 90 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : petit singe à la longue queue enroulée.
	definir("Singinou", 0.75, function(l)
		local brun = { 150, 100, 60 }
		local tete = { 0, 0.04, -0.02 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.32, 0.28 }, p = { 0, -0.24, 0.04 }, c = brun })
		ajouter(l, { n = "Ventre", t = { 0.22, 0.22, 0.03 }, p = { 0, -0.24, -0.115 }, c = CREME })
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.32, 0.3 },
			p = { 0, 0.14, -0.02 },
			c = brun,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Visage",
			t = { 0.28, 0.22, 0.03 },
			p = { 0, 0.12, -0.18 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.17, -0.2, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.1, 0.02, 0.02 },
			p = { 0, 0.06, -0.2 },
			c = { 90, 50, 30 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.12, 0.04 },
			p = { 0.22, 0.16, -0.02 },
			c = CREME,
			a = "Oreille",
			j = { 0.18, 0.16, -0.02 },
		}, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.08, 0.26, 0.08 },
			p = { 0.22, -0.18, -0.02 },
			r = { 0, 0, -15 },
			c = brun,
			a = "Bras",
			j = { 0.2, -0.06, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.1, 0.1, 0.14 },
			p = { 0.1, -0.45, -0.02 },
			c = brun,
			a = "Patte",
			j = { 0.1, -0.4, 0 },
			ph = math.pi,
		}, true)
		local queue = { 0, -0.3, 0.18 }
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.05, 0.3 },
			p = { 0, -0.3, 0.32 },
			c = brun,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Queue2",
			t = { 0.05, 0.24, 0.05 },
			p = { 0, -0.18, 0.46 },
			c = brun,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Boucle",
			t = { 0.05, 0.05, 0.12 },
			p = { 0, -0.06, 0.42 },
			c = "Rarete",
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Banane",
			t = { 0.06, 0.16, 0.06 },
			p = { 0.3, -0.34, -0.06 },
			r = { 0, 0, 30 },
			c = { 255, 220, 70 },
			a = "Bras",
			j = { 0.2, -0.06, -0.02 },
			ph = 0,
		})
	end)

	-- Commune : petite perruche verte et jaune.
	definir("Perruchette", 0.7, function(l)
		local vert = { 110, 210, 90 }
		local tete = { 0, 0.06, -0.04 }
		ajouter(l, { n = "Corps", t = { 0.32, 0.36, 0.34 }, p = { 0, -0.2, 0.02 }, c = vert })
		ajouter(l, {
			n = "Ventre",
			t = { 0.22, 0.24, 0.03 },
			p = { 0, -0.24, -0.155 },
			c = { 255, 230, 90 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.28 },
			p = { 0, 0.12, -0.04 },
			c = { 255, 220, 70 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.08, 0.08 },
			p = { 0, 0.07, -0.22 },
			r = { 20, 0, 0 },
			c = { 255, 140, 60 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.15, -0.185, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Joue",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.12, 0.06, -0.185 },
			c = { 90, 160, 255 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Huppe",
			t = { 0.04, 0.12, 0.08 },
			p = { 0, 0.3, -0.02 },
			r = { -20, 0, 0 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.26, 0.26 },
			p = { 0.18, -0.18, 0.04 },
			c = { 70, 170, 70 },
			a = "Aile",
			j = { 0.16, -0.06, 0.02 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.12, 0.04, 0.26 },
			p = { 0, -0.3, 0.3 },
			r = { -20, 0, 0 },
			c = { 60, 140, 230 },
			a = "Queue",
			j = { 0, -0.26, 0.18 },
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.1, 0.06 },
			p = { 0.07, -0.45, -0.02 },
			c = { 255, 140, 60 },
			a = "Patte",
			j = { 0.07, -0.4, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Rare : toucan au gros bec arc-en-ciel.
	definir("Toucanou", 0.8, function(l)
		local tete = { 0, 0.1, -0.04 }
		ajouter(
			l,
			{ n = "Corps", t = { 0.32, 0.4, 0.34 }, p = { 0, -0.18, 0.06 }, c = { 35, 35, 45 } }
		)
		ajouter(l, {
			n = "Plastron",
			t = { 0.22, 0.2, 0.03 },
			p = { 0, -0.04, -0.125 },
			c = { 255, 230, 120 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.24, 0.26 },
			p = { 0, 0.16, -0.04 },
			c = { 35, 35, 45 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.14, 0.14, 0.3 },
			p = { 0, 0.14, -0.3 },
			c = { 255, 150, 40 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.1, 0.1, 0.08 },
			p = { 0, 0.12, -0.48 },
			c = { 230, 50, 50 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bande",
			t = { 0.145, 0.04, 0.3 },
			p = { 0, 0.2, -0.3 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tour",
			t = { 0.06, 0.08, 0.02 },
			p = { 0.1, 0.19, -0.175 },
			c = { 120, 220, 255 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.04, 0.02 },
			p = { 0.1, 0.19, -0.185 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.3, 0.28 },
			p = { 0.18, -0.16, 0.08 },
			c = { 50, 50, 60 },
			a = "Aile",
			j = { 0.16, -0.04, 0.06 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.14, 0.04, 0.2 },
			p = { 0, -0.34, 0.3 },
			c = { 35, 35, 45 },
			a = "Queue",
			j = { 0, -0.32, 0.22 },
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.05, 0.1, 0.06 },
			p = { 0.07, -0.45, 0.04 },
			c = { 90, 170, 255 },
			a = "Patte",
			j = { 0.07, -0.4, 0.04 },
			ph = 0,
		}, true)
	end)

	-- Rare : caméléon à l'œil qui roule et à la queue en spirale.
	definir("Cameleou", 0.55, function(l)
		local vert = { 120, 200, 90 }
		local tete = { 0, -0.2, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.3, 0.46 }, p = { 0, -0.26, 0.04 }, c = vert })
		ajouter(l, { n = "Crete", t = { 0.04, 0.06, 0.4 }, p = { 0, -0.08, 0.04 }, c = "Rarete" })
		for i, z in { -0.08, 0.06, 0.2 } do
			ajouter(l, {
				n = "Rayure" .. i,
				t = { 0.31, 0.24, 0.04 },
				p = { 0, -0.26, z },
				c = { 255, 180, 70 },
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.22 },
			p = { 0, -0.2, -0.28 },
			c = vert,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Casque",
			t = { 0.16, 0.12, 0.14 },
			p = { 0, -0.04, -0.22 },
			r = { -20, 0, 0 },
			c = vert,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.1, 0.1 },
			p = { 0.13, -0.16, -0.32 },
			c = { 255, 210, 70 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Pupille",
			t = { 0.04, 0.04, 0.02 },
			p = { 0.14, -0.16, -0.375 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Langue",
			t = { 0.03, 0.02, 0.14 },
			p = { 0, -0.27, -0.44 },
			c = ROSE,
			a = "Machoire",
			j = { 0, -0.27, -0.38 },
		})
		pattes4(l, 0.14, -0.1, 0.16, { 0.06, 0.12, 0.08 }, vert)
		local queue = { 0, -0.28, 0.26 }
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.08, 0.2 },
			p = { 0, -0.3, 0.36 },
			c = vert,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Spirale",
			t = { 0.08, 0.16, 0.08 },
			p = { 0, -0.34, 0.48 },
			c = vert,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Spirale2",
			t = { 0.08, 0.08, 0.1 },
			p = { 0, -0.4, 0.42 },
			c = vert,
			a = "Queue",
			j = queue,
		})
	end, "Ecailles")

	-- Épique : panthère noire au croissant de lune sur le front.
	definir("Panthelune", 0.7, function(l)
		local noir = { 45, 40, 60 }
		local tete = { 0, -0.04, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.3, 0.56 }, p = { 0, -0.16, 0.06 }, c = noir })
		pattes4(l, 0.11, -0.14, 0.24, { 0.1, 0.2, 0.1 }, noir)
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.28, 0.26 },
			p = { 0, 0.0, -0.32 },
			c = noir,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.16, 0.1, 0.06 },
			p = { 0, -0.07, -0.47 },
			c = { 70, 65, 90 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.03, 0.02 },
			p = { 0, -0.04, -0.505 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.05, 0.02 },
			p = { 0.08, 0.04, -0.455 },
			c = { 255, 230, 80 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Pupille",
			t = { 0.015, 0.05, 0.02 },
			p = { 0.08, 0.04, -0.47 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.08, 0.04 },
			p = { 0.12, 0.17, -0.3 },
			r = { 0, 0, -15 },
			c = noir,
			a = "Oreille",
			j = { 0.12, 0.13, -0.3 },
		}, true)
		ajouter(l, {
			n = "Lune",
			t = { 0.1, 0.03, 0.02 },
			p = { 0, 0.1, -0.455 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Lune2",
			t = { 0.03, 0.06, 0.02 },
			p = { 0.04, 0.12, -0.455 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Queue",
			t = { 0.06, 0.06, 0.4 },
			p = { 0, -0.04, 0.5 },
			r = { 25, 0, 0 },
			c = noir,
			a = "Queue",
			j = { 0, -0.1, 0.32 },
		})
	end)

	-- Épique : paresseux suspendu à une branche fleurie.
	definir("Paressou", 0.85, function(l)
		local gris = { 170, 150, 120 }
		local branche = { 0, 0.38, 0 }
		ajouter(
			l,
			{ n = "Branche", t = { 0.8, 0.08, 0.08 }, p = { 0, 0.42, 0 }, c = { 110, 80, 50 } }
		)
		ajouter(l, {
			n = "Fleur",
			t = { 0.1, 0.06, 0.1 },
			p = { 0.3, 0.48, 0 },
			r = { 0, 45, 0 },
			c = { 255, 120, 170 },
		})
		ajouter(
			l,
			{ n = "Feuille", t = { 0.14, 0.03, 0.08 }, p = { -0.28, 0.47, 0.02 }, c = FEUILLE }
		)
		ajouter(l, {
			n = "Corps",
			t = { 0.36, 0.36, 0.3 },
			p = { 0, 0.0, 0.0 },
			c = gris,
			a = "Antenne",
			j = branche,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.24 },
			p = { 0, -0.24, -0.04 },
			c = gris,
			a = "Antenne",
			j = branche,
		})
		ajouter(l, {
			n = "Masque",
			t = { 0.24, 0.16, 0.03 },
			p = { 0, -0.25, -0.165 },
			c = CREME,
			a = "Antenne",
			j = branche,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.04, 0.02 },
			p = { 0.07, -0.22, -0.185 },
			r = { 0, 0, 15 },
			c = { 80, 55, 40 },
			a = "Antenne",
			j = branche,
		}, true)
		ajouter(l, {
			n = "Sourire",
			t = { 0.08, 0.02, 0.02 },
			p = { 0, -0.3, -0.185 },
			c = { 80, 55, 40 },
			a = "Antenne",
			j = branche,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.07, 0.24, 0.07 },
			p = { 0.14, 0.28, 0 },
			c = gris,
			a = "Antenne",
			j = branche,
		}, true)
		ajouter(l, {
			n = "Griffe",
			t = { 0.07, 0.04, 0.1 },
			p = { 0.14, 0.42, -0.02 },
			c = "Rarete",
			a = "Antenne",
			j = branche,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.08, 0.2, 0.08 },
			p = { 0.12, -0.1, 0.12 },
			r = { 30, 0, 0 },
			c = gris,
			a = "Patte",
			j = { 0.12, -0.02, 0.08 },
			ph = 0,
		}, true)
	end)

	-- Légendaire : jeune gorille à la couronne de feuilles.
	definir("Gorillon", 0.9, function(l)
		local poil = { 70, 65, 75 }
		local peau = { 120, 110, 120 }
		local tete = { 0, 0.18, -0.06 }
		ajouter(l, { n = "Torse", t = { 0.5, 0.42, 0.38 }, p = { 0, -0.04, 0.04 }, c = poil })
		ajouter(l, { n = "Pectoraux", t = { 0.34, 0.2, 0.03 }, p = { 0, 0.0, -0.16 }, c = peau })
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.28, 0.28 },
			p = { 0, 0.3, -0.08 },
			c = poil,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Visage",
			t = { 0.24, 0.18, 0.03 },
			p = { 0, 0.27, -0.225 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, 0.31, -0.24, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Narines",
			t = { 0.08, 0.03, 0.02 },
			p = { 0, 0.24, -0.245 },
			c = { 50, 45, 55 },
			a = "Tete",
			j = tete,
		})
		for i, x in { -0.1, 0, 0.1 } do
			ajouter(l, {
				n = "Feuille" .. i,
				t = { 0.08, 0.1, 0.04 },
				p = { x, 0.47, -0.08 },
				r = { 0, 0, x * -150 },
				c = if i == 2 then "Rarete" else FEUILLE,
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Bras",
			t = { 0.14, 0.44, 0.14 },
			p = { 0.33, -0.12, -0.04 },
			c = poil,
			a = "Bras",
			j = { 0.3, 0.12, -0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Poing",
			t = { 0.16, 0.12, 0.16 },
			p = { 0.33, -0.42, -0.06 },
			c = peau,
			a = "Bras",
			j = { 0.3, 0.12, -0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.14, 0.18, 0.16 },
			p = { 0.13, -0.41, 0.06 },
			c = poil,
			a = "Patte",
			j = { 0.13, -0.32, 0.06 },
			ph = math.pi,
		}, true)
	end)

	-- Légendaire : tigre au pelage rayé de lianes.
	definir("Tigrebois", 0.75, function(l)
		local orange = { 240, 140, 50 }
		local tete = { 0, 0.0, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.32, 0.6 }, p = { 0, -0.14, 0.06 }, c = orange })
		for i, z in { -0.12, 0.04, 0.2 } do
			ajouter(l, {
				n = "Liane" .. i,
				t = { 0.37, 0.06, 0.05 },
				p = { 0, -0.02, z },
				c = { 60, 120, 60 },
			})
			ajouter(l, {
				n = "Rayure" .. i,
				t = { 0.37, 0.2, 0.04 },
				p = { 0, -0.14, z + 0.06 },
				c = { 50, 40, 40 },
			})
		end
		pattes4(l, 0.12, -0.14, 0.26, { 0.11, 0.2, 0.11 }, orange)
		ajouter(l, {
			n = "Tete",
			t = { 0.34, 0.3, 0.26 },
			p = { 0, 0.04, -0.34 },
			c = orange,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.18, 0.12, 0.06 },
			p = { 0, -0.04, -0.49 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.06, 0.04, 0.02 },
			p = { 0, 0.0, -0.525 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.08, -0.475, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.08, 0.04 },
			p = { 0.13, 0.22, -0.32 },
			c = orange,
			a = "Oreille",
			j = { 0.13, 0.18, -0.32 },
		}, true)
		ajouter(l, {
			n = "Fleur",
			t = { 0.08, 0.08, 0.06 },
			p = { 0.16, 0.22, -0.36 },
			r = { 0, 0, 45 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Queue",
			t = { 0.07, 0.07, 0.36 },
			p = { 0, -0.02, 0.5 },
			r = { 30, 0, 0 },
			c = orange,
			a = "Queue",
			j = { 0, -0.08, 0.34 },
		})
	end, "Pelage")

	-- Mythique : serpent à plumes enflammées.
	definir("Quetzaflamme", 0.8, function(l)
		local vert = { 40, 180, 140 }
		local tete = { 0, 0.18, -0.2 }
		for i = 0, 3 do
			ajouter(l, {
				n = "Anneau" .. i,
				t = { 0.18, 0.16, 0.16 },
				p = { math.sin(i * 1.4) * 0.12, -0.4 + i * 0.04, 0.36 - i * 0.14 },
				c = vert,
				a = "Queue",
				j = { 0, -0.36, 0.1 },
				ph = i,
			})
		end
		ajouter(l, { n = "Cou", t = { 0.16, 0.36, 0.16 }, p = { 0, -0.06, -0.18 }, c = vert })
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.2, 0.3 },
			p = { 0, 0.2, -0.28 },
			c = vert,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.2, 0.05, 0.22 },
			p = { 0, 0.08, -0.32 },
			c = { 255, 220, 120 },
			a = "Machoire",
			j = { 0, 0.1, -0.2 },
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.03 },
			p = { 0.1, 0.25, -0.39 },
			c = { 255, 220, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		for i, c in { { 255, 80, 40 }, { 255, 170, 40 }, { 255, 230, 80 } } do
			ajouter(l, {
				n = "Plume" .. i,
				t = { 0.06, 0.24, 0.06 },
				p = { (i - 2) * 0.09, 0.4, -0.18 },
				r = { -25, 0, (i - 2) * -25 },
				c = c,
				m = "Neon",
				a = "Antenne",
				j = { 0, 0.3, -0.2 },
			})
		end
		ajouter(l, {
			n = "Aile",
			t = { 0.3, 0.04, 0.18 },
			p = { 0.2, 0.0, -0.12 },
			r = { 0, 0, -20 },
			c = "Rarete",
			m = "Neon",
			a = "Aile",
			j = { 0.08, 0.0, -0.12 },
		}, true)
	end, "Ecailles")

	-- Mythique : idole de pierre éveillée, couverte de mousse.
	definir("Idolou", 0.9, function(l)
		local tete = { 0, 0.0, 0 }
		ajouter(
			l,
			{ n = "Socle", t = { 0.56, 0.14, 0.5 }, p = { 0, -0.43, 0 }, c = { 120, 120, 105 } }
		)
		ajouter(l, {
			n = "Corps",
			t = { 0.44, 0.7, 0.4 },
			p = { 0, -0.01, 0 },
			c = PIERRE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Front",
			t = { 0.48, 0.08, 0.44 },
			p = { 0, 0.3, 0 },
			c = { 130, 130, 115 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Mousse",
			t = { 0.3, 0.06, 0.3 },
			p = { -0.06, 0.37, 0.04 },
			c = MOUSSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.06, 0.03 },
			p = { 0.1, 0.16, -0.21 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Nez",
			t = { 0.08, 0.14, 0.06 },
			p = { 0, 0.06, -0.22 },
			c = { 135, 135, 120 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bouche",
			t = { 0.24, 0.06, 0.03 },
			p = { 0, -0.08, -0.21 },
			c = { 60, 60, 55 },
			a = "Machoire",
			j = { 0, -0.06, -0.2 },
		})
		ajouter(l, {
			n = "Glyphe",
			t = { 0.16, 0.03, 0.02 },
			p = { 0, -0.24, -0.21 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.24, 0.12 },
			p = { 0.25, 0.04, 0 },
			c = PIERRE,
			a = "Oreille",
			j = { 0.22, 0.12, 0 },
		}, true)
		ajouter(
			l,
			{ n = "Liane", t = { 0.03, 0.4, 0.03 }, p = { -0.2, -0.04, -0.205 }, c = FEUILLE }
		)
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : fourmi géante aux mandibules qui claquent.
	definir("Fourmigeant", 0.55, function(l)
		local rouge = { 180, 50, 40 }
		local tete = { 0, -0.2, -0.24 }
		ajouter(l, { n = "Abdomen", t = { 0.34, 0.3, 0.36 }, p = { 0, -0.22, 0.26 }, c = rouge })
		ajouter(l, { n = "Thorax", t = { 0.2, 0.18, 0.22 }, p = { 0, -0.26, -0.02 }, c = rouge })
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.24 },
			p = { 0, -0.2, -0.26 },
			c = rouge,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Mandibule",
			t = { 0.05, 0.05, 0.14 },
			p = { 0.07, -0.28, -0.42 },
			r = { 0, 20, 0 },
			c = { 60, 30, 25 },
			a = "Machoire",
			j = { 0.06, -0.28, -0.36 },
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.07, 0.03 },
			p = { 0.1, -0.15, -0.385 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.09, 0.025, 0.02 },
			p = { 0.1, -0.1, -0.39 },
			r = { 0, 0, 20 },
			c = { 60, 20, 20 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Antenne",
			t = { 0.025, 0.2, 0.025 },
			p = { 0.08, -0.02, -0.3 },
			r = { -25, 0, -20 },
			c = { 60, 30, 25 },
			a = "Antenne",
			j = { 0.06, -0.1, -0.28 },
		}, true)
		for i, z in { -0.1, 0.0, 0.1 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.22, 0.03, 0.03 },
				p = { 0.18, -0.36, z },
				r = { 0, 0, -30 },
				c = { 60, 30, 25 },
				a = "Patte",
				j = { 0.08, -0.3, z },
				ph = i * 2,
			}, true)
		end
	end)

	-- Moyenne : serpent aux anneaux colorés qui siffle.
	definir("Serpentacle", 0.7, function(l)
		local vert = { 90, 180, 60 }
		local tete = { 0, 0.18, -0.16 }
		for i = 0, 4 do
			ajouter(l, {
				n = "Anneau" .. i,
				t = { 0.18, 0.16, 0.18 },
				p = { math.sin(i * 1.3) * 0.16, -0.42, 0.34 - i * 0.12 },
				c = if i % 2 == 0 then vert else { 255, 210, 60 },
				a = "Queue",
				j = { 0, -0.42, 0.1 },
				ph = i,
			})
		end
		ajouter(l, { n = "Cou", t = { 0.16, 0.5, 0.16 }, p = { 0, -0.12, -0.16 }, c = vert })
		ajouter(l, {
			n = "Capuchon",
			t = { 0.34, 0.26, 0.06 },
			p = { 0, 0.14, -0.1 },
			c = { 255, 210, 60 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.16, 0.26 },
			p = { 0, 0.2, -0.24 },
			c = vert,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.03 },
			p = { 0.08, 0.24, -0.37 },
			c = { 255, 60, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Langue",
			t = { 0.02, 0.02, 0.14 },
			p = { 0, 0.14, -0.43 },
			c = { 230, 40, 70 },
			a = "Machoire",
			j = { 0, 0.14, -0.36 },
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.02, 0.05, 0.02 },
			p = { 0.05, 0.1, -0.36 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
	end, "Ecailles")

	-- Lointaine : plante carnivore géante.
	definir("Plantegloutonne", 0.95, function(l)
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Pot", t = { 0.56, 0.18, 0.56 }, p = { 0, -0.41, 0 }, c = { 90, 70, 50 } })
		for i, r in { 0, 90, 180, 270 } do
			ajouter(l, {
				n = "Feuille" .. i,
				t = { 0.16, 0.04, 0.34 },
				p = { math.sin(math.rad(r)) * 0.3, -0.3, -math.cos(math.rad(r)) * 0.3 },
				r = { 15, r, 0 },
				c = FEUILLE,
				a = "Patte",
				j = { 0, -0.3, 0 },
				ph = i,
			})
		end
		ajouter(
			l,
			{ n = "Tige", t = { 0.14, 0.4, 0.14 }, p = { 0, -0.12, 0 }, c = { 80, 150, 70 } }
		)
		ajouter(l, {
			n = "Machoire",
			t = { 0.7, 0.18, 0.6 },
			p = { 0, 0.12, -0.04 },
			c = { 200, 50, 70 },
			a = "Machoire",
			j = { 0, 0.14, 0.24 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.7, 0.24, 0.6 },
			p = { 0, 0.34, -0.04 },
			r = { -15, 0, 0 },
			c = { 200, 50, 70 },
			a = "Tete",
			j = tete,
		})
		for i, x in { -0.24, -0.08, 0.08, 0.24 } do
			ajouter(l, {
				n = "Croc" .. i,
				t = { 0.05, 0.1, 0.03 },
				p = { x, 0.2, -0.34 },
				c = BLANC,
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Pois",
			t = { 0.1, 0.03, 0.1 },
			p = { 0.2, 0.47, -0.02 },
			r = { -15, 0, 0 },
			c = { 255, 230, 120 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.06, 0.03 },
			p = { 0.16, 0.4, -0.33 },
			c = { 255, 240, 80 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
	end)
end
