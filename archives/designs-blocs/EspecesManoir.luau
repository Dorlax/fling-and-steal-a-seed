--!strict
-- Bestiaire du biome 12 : Manoir Hanté (fantômes mignons, citrouilles, bougies).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE = o.BLANC, o.NOIR, o.ROSE

	local SPECTRE = { 225, 235, 255 }
	local CITROUILLE = { 255, 140, 40 }
	local VIOLET = { 120, 70, 170 }
	local OS = { 240, 235, 220 }
	local FLAMME = { 255, 210, 90 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : petit fantôme en drap qui flotte.
	definir("Fantomou", 0.75, function(l)
		local drap = { 0, -0.1, 0 }
		ajouter(l, {
			n = "Drap",
			t = { 0.44, 0.5, 0.4 },
			p = { 0, -0.02, 0 },
			c = SPECTRE,
			tr = 0.1,
			a = "Antenne",
			j = drap,
		})
		ajouter(l, {
			n = "Sommet",
			t = { 0.32, 0.12, 0.3 },
			p = { 0, 0.29, 0 },
			c = SPECTRE,
			tr = 0.1,
			a = "Antenne",
			j = drap,
		})
		for i, x in { -0.15, 0, 0.15 } do
			ajouter(l, {
				n = "Frange" .. i,
				t = { 0.12, 0.14, 0.38 },
				p = { x, -0.32 - (i % 2) * 0.04, 0 },
				c = SPECTRE,
				tr = 0.1,
				a = "Patte",
				j = { x, -0.26, 0 },
				ph = i,
			})
		end
		ajouter(l, {
			n = "OeilG",
			t = { 0.08, 0.12, 0.02 },
			p = { -0.09, 0.08, -0.205 },
			c = NOIR,
			a = "Antenne",
			j = drap,
		})
		ajouter(l, {
			n = "OeilD",
			t = { 0.08, 0.12, 0.02 },
			p = { 0.09, 0.08, -0.205 },
			c = NOIR,
			a = "Antenne",
			j = drap,
		})
		ajouter(l, {
			n = "Bouche",
			t = { 0.08, 0.08, 0.02 },
			p = { 0, -0.06, -0.205 },
			c = NOIR,
			a = "Antenne",
			j = drap,
		})
		ajouter(l, {
			n = "Joue",
			t = { 0.05, 0.03, 0.02 },
			p = { 0.15, -0.02, -0.205 },
			c = ROSE,
			a = "Antenne",
			j = drap,
		}, true)
		ajouter(l, {
			n = "Noeud",
			t = { 0.12, 0.06, 0.04 },
			p = { 0.12, 0.3, -0.1 },
			r = { 0, 0, -20 },
			c = "Rarete",
			a = "Antenne",
			j = drap,
		})
	end)

	-- Commune : citrouille au sourire découpé.
	definir("Citrouillou", 0.6, function(l)
		local corps = { 0, -0.3, 0 }
		ajouter(l, {
			n = "Citrouille",
			t = { 0.56, 0.42, 0.5 },
			p = { 0, -0.28, 0 },
			c = CITROUILLE,
			a = "Antenne",
			j = corps,
		})
		for i, x in { -0.18, 0, 0.18 } do
			ajouter(l, {
				n = "Cote" .. i,
				t = { 0.04, 0.43, 0.51 },
				p = { x, -0.28, 0 },
				c = { 220, 110, 30 },
				a = "Antenne",
				j = corps,
			})
		end
		ajouter(l, {
			n = "OeilG",
			t = { 0.08, 0.08, 0.02 },
			p = { -0.11, -0.2, -0.255 },
			r = { 0, 0, 45 },
			c = FLAMME,
			m = "Neon",
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "OeilD",
			t = { 0.08, 0.08, 0.02 },
			p = { 0.11, -0.2, -0.255 },
			r = { 0, 0, 45 },
			c = FLAMME,
			m = "Neon",
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Sourire",
			t = { 0.26, 0.05, 0.02 },
			p = { 0, -0.34, -0.255 },
			c = FLAMME,
			m = "Neon",
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Dent",
			t = { 0.05, 0.04, 0.02 },
			p = { 0.06, -0.31, -0.26 },
			c = CITROUILLE,
			a = "Antenne",
			j = corps,
		}, true)
		ajouter(l, {
			n = "Tige",
			t = { 0.07, 0.12, 0.07 },
			p = { 0, -0.02, 0 },
			r = { 0, 0, 15 },
			c = { 90, 130, 60 },
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Feuille",
			t = { 0.14, 0.03, 0.08 },
			p = { 0.08, -0.05, 0 },
			r = { 0, 0, -20 },
			c = "Rarete",
			a = "Antenne",
			j = corps,
		})
	end)

	-- Rare : chauve-souris aux grandes oreilles.
	definir("Chauvinette", 0.65, function(l)
		local peau = { 90, 70, 110 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.32, 0.26 }, p = { 0, -0.12, 0 }, c = peau })
		ajouter(l, {
			n = "Ventre",
			t = { 0.2, 0.2, 0.03 },
			p = { 0, -0.14, -0.135 },
			c = { 150, 120, 170 },
		})
		yeux(l, 0.07, -0.02, -0.135, 0.08)
		ajouter(
			l,
			{ n = "Croc", t = { 0.025, 0.04, 0.02 }, p = { 0.04, -0.12, -0.14 }, c = BLANC },
			true
		)
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.18, 0.04 },
			p = { 0.11, 0.14, 0 },
			r = { 0, 0, -15 },
			c = peau,
			a = "Oreille",
			j = { 0.1, 0.06, 0 },
		}, true)
		ajouter(l, {
			n = "InterOreille",
			t = { 0.05, 0.1, 0.02 },
			p = { 0.11, 0.13, -0.02 },
			r = { 0, 0, -15 },
			c = ROSE,
			a = "Oreille",
			j = { 0.1, 0.06, 0 },
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.34, 0.24, 0.03 },
			p = { 0.32, -0.08, 0.04 },
			r = { 0, 20, 0 },
			c = { 60, 45, 80 },
			a = "Aile",
			j = { 0.15, -0.06, 0.02 },
		}, true)
		ajouter(l, {
			n = "Pointe",
			t = { 0.08, 0.12, 0.03 },
			p = { 0.45, -0.22, 0.08 },
			r = { 0, 20, 30 },
			c = "Rarete",
			a = "Aile",
			j = { 0.15, -0.06, 0.02 },
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.12, 0.04 },
			p = { 0.06, -0.38, 0 },
			c = peau,
			a = "Patte",
			j = { 0.06, -0.3, 0 },
			ph = 0,
		}, true)
	end, "Pelage")

	-- Rare : bougie vivante à la flamme dansante.
	definir("Chandelou", 0.85, function(l)
		local cire = { 250, 240, 220 }
		ajouter(
			l,
			{ n = "Bougeoir", t = { 0.44, 0.06, 0.44 }, p = { 0, -0.47, 0 }, c = { 200, 160, 60 } }
		)
		ajouter(
			l,
			{ n = "Pied", t = { 0.14, 0.08, 0.14 }, p = { 0, -0.4, 0 }, c = { 200, 160, 60 } }
		)
		ajouter(l, { n = "Cire", t = { 0.3, 0.5, 0.3 }, p = { 0, -0.11, 0 }, c = cire })
		ajouter(
			l,
			{ n = "Coulure", t = { 0.06, 0.16, 0.03 }, p = { 0.08, 0.04, -0.155 }, c = cire }
		)
		ajouter(
			l,
			{ n = "Coulure2", t = { 0.05, 0.1, 0.03 }, p = { -0.1, 0.08, -0.155 }, c = cire }
		)
		yeux(l, 0.06, -0.06, -0.155, 0.07)
		ajouter(l, {
			n = "Sourire",
			t = { 0.08, 0.02, 0.02 },
			p = { 0, -0.16, -0.155 },
			c = { 120, 80, 60 },
		})
		ajouter(l, { n = "Meche", t = { 0.02, 0.06, 0.02 }, p = { 0, 0.17, 0 }, c = NOIR })
		local flamme = { 0, 0.2, 0 }
		ajouter(l, {
			n = "Flamme",
			t = { 0.12, 0.18, 0.12 },
			p = { 0, 0.29, 0 },
			c = FLAMME,
			m = "Neon",
			a = "Antenne",
			j = flamme,
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.06, 0.1, 0.06 },
			p = { 0, 0.42, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = flamme,
		})
		ajouter(l, {
			n = "Anse",
			t = { 0.04, 0.12, 0.04 },
			p = { 0.24, -0.38, 0 },
			c = { 200, 160, 60 },
			a = "Bras",
			j = { 0.2, -0.42, 0 },
			ph = 0,
		})
	end)

	-- Épique : petit chien squelette qui remue la queue.
	definir("Squelettou", 0.6, function(l)
		local tete = { 0, -0.1, -0.2 }
		ajouter(l, { n = "Colonne", t = { 0.08, 0.08, 0.44 }, p = { 0, -0.14, 0.08 }, c = OS })
		for i, z in { -0.04, 0.06, 0.16 } do
			ajouter(l, { n = "Cote" .. i, t = { 0.3, 0.16, 0.04 }, p = { 0, -0.22, z }, c = OS })
		end
		pattes4(l, 0.1, -0.08, 0.26, { 0.05, 0.28, 0.05 }, OS)
		ajouter(l, {
			n = "Crane",
			t = { 0.3, 0.26, 0.26 },
			p = { 0, -0.02, -0.26 },
			c = OS,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.16, 0.1, 0.12 },
			p = { 0, -0.1, -0.44 },
			c = OS,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.03, 0.02 },
			p = { 0, -0.06, -0.505 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilG",
			t = { 0.07, 0.07, 0.02 },
			p = { -0.07, 0.02, -0.395 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilD",
			t = { 0.07, 0.07, 0.02 },
			p = { 0.07, 0.02, -0.395 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Lueur",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.07, 0.02, -0.405 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.12, 0.04 },
			p = { 0.13, 0.04, -0.22 },
			r = { 0, 0, -30 },
			c = OS,
			a = "Oreille",
			j = { 0.12, 0.08, -0.22 },
		}, true)
		ajouter(
			l,
			{ n = "Collier", t = { 0.2, 0.04, 0.12 }, p = { 0, -0.15, -0.16 }, c = { 200, 50, 60 } }
		)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.04, 0.2 },
			p = { 0, -0.06, 0.38 },
			r = { 35, 0, 0 },
			c = OS,
			a = "Queue",
			j = { 0, -0.12, 0.3 },
		})
	end)

	-- Épique : grimoire qui claque des pages.
	definir("Grimoirou", 0.55, function(l)
		local couverture = { 120, 50, 70 }
		local haut = { 0, -0.24, 0.18 }
		ajouter(l, { n = "Dos", t = { 0.5, 0.08, 0.4 }, p = { 0, -0.44, 0 }, c = couverture })
		ajouter(l, {
			n = "Pages",
			t = { 0.46, 0.12, 0.36 },
			p = { 0, -0.34, -0.01 },
			c = { 245, 235, 205 },
		})
		ajouter(l, {
			n = "Couvercle",
			t = { 0.5, 0.08, 0.4 },
			p = { 0, -0.12, 0.04 },
			r = { -30, 0, 0 },
			c = couverture,
			a = "Machoire",
			j = haut,
		})
		ajouter(l, {
			n = "Symbole",
			t = { 0.12, 0.02, 0.12 },
			p = { 0, -0.07, 0.06 },
			r = { -30, 45, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Machoire",
			j = haut,
		})
		ajouter(l, {
			n = "Coin",
			t = { 0.08, 0.09, 0.08 },
			p = { 0.22, -0.44, -0.17 },
			c = { 220, 180, 70 },
		}, true)
		ajouter(
			l,
			{ n = "Oeil", t = { 0.08, 0.08, 0.03 }, p = { 0.1, -0.31, -0.2 }, c = BLANC },
			true
		)
		ajouter(
			l,
			{ n = "Pupille", t = { 0.04, 0.05, 0.02 }, p = { 0.1, -0.31, -0.215 }, c = NOIR },
			true
		)
		ajouter(l, {
			n = "Langue",
			t = { 0.12, 0.02, 0.18 },
			p = { 0, -0.26, -0.22 },
			r = { -20, 0, 0 },
			c = { 200, 60, 80 },
			a = "Machoire",
			j = haut,
		})
		ajouter(l, {
			n = "Ruban",
			t = { 0.04, 0.24, 0.02 },
			p = { 0.12, -0.42, -0.21 },
			c = { 255, 210, 80 },
			a = "Queue",
			j = { 0.12, -0.32, -0.2 },
		})
	end)

	-- Légendaire : chat vampire à la cape.
	definir("Vampichat", 0.8, function(l)
		local pelage = { 60, 55, 75 }
		local tete = { 0, 0.1, -0.06 }
		ajouter(l, { n = "Corps", t = { 0.32, 0.34, 0.3 }, p = { 0, -0.22, 0.02 }, c = pelage })
		ajouter(l, {
			n = "Cape",
			t = { 0.42, 0.42, 0.06 },
			p = { 0, -0.14, 0.2 },
			c = { 30, 20, 40 },
			a = "Queue",
			j = { 0, 0.04, 0.18 },
		})
		ajouter(l, {
			n = "Doublure",
			t = { 0.36, 0.36, 0.02 },
			p = { 0, -0.15, 0.165 },
			c = { 200, 30, 50 },
			a = "Queue",
			j = { 0, 0.04, 0.18 },
		})
		ajouter(l, {
			n = "Col",
			t = { 0.1, 0.16, 0.04 },
			p = { 0.17, 0.1, 0.12 },
			r = { 0, 0, -20 },
			c = { 200, 30, 50 },
		}, true)
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.26, 0.26 },
			p = { 0, 0.12, -0.06 },
			c = pelage,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.1, 0.04 },
			p = { 0.11, 0.3, -0.06 },
			r = { 0, 0, -15 },
			c = pelage,
			a = "Oreille",
			j = { 0.11, 0.25, -0.06 },
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.06, 0.02 },
			p = { 0.08, 0.15, -0.195 },
			c = { 255, 60, 80 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Pupille",
			t = { 0.02, 0.06, 0.02 },
			p = { 0.08, 0.15, -0.205 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Croc",
			t = { 0.025, 0.05, 0.02 },
			p = { 0.04, 0.03, -0.195 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Medaillon",
			t = { 0.07, 0.07, 0.02 },
			p = { 0, -0.08, -0.135 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.1, 0.08, 0.14 },
			p = { 0.1, -0.46, -0.04 },
			c = pelage,
			a = "Patte",
			j = { 0.1, -0.4, 0 },
			ph = 0,
		}, true)
	end)

	-- Légendaire : petite armure animée avec un plumet.
	definir("Armurinou", 0.95, function(l)
		local acier = { 170, 180, 195 }
		local tete = { 0, 0.18, 0 }
		ajouter(l, { n = "Plastron", t = { 0.38, 0.34, 0.28 }, p = { 0, -0.04, 0 }, c = acier })
		ajouter(
			l,
			{ n = "Ceinture", t = { 0.4, 0.06, 0.3 }, p = { 0, -0.2, 0 }, c = { 120, 80, 50 } }
		)
		ajouter(
			l,
			{ n = "Blason", t = { 0.12, 0.14, 0.02 }, p = { 0, -0.02, -0.15 }, c = "Rarete" }
		)
		ajouter(l, {
			n = "Heaume",
			t = { 0.3, 0.3, 0.3 },
			p = { 0, 0.3, 0 },
			c = acier,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Visiere",
			t = { 0.22, 0.04, 0.02 },
			p = { 0, 0.3, -0.155 },
			c = { 30, 30, 40 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.03, 0.02 },
			p = { 0.06, 0.3, -0.165 },
			c = { 120, 220, 255 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Plumet",
			t = { 0.06, 0.2, 0.16 },
			p = { 0, 0.52, 0.04 },
			r = { 20, 0, 0 },
			c = { 220, 50, 60 },
			a = "Antenne",
			j = { 0, 0.44, 0 },
		})
		ajouter(l, { n = "Epaule", t = { 0.14, 0.1, 0.18 }, p = { 0.24, 0.1, 0 }, c = acier }, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.1, 0.24, 0.1 },
			p = { 0.25, -0.08, 0 },
			c = acier,
			a = "Bras",
			j = { 0.24, 0.06, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Epee",
			t = { 0.03, 0.04, 0.34 },
			p = { 0.25, -0.2, -0.2 },
			c = { 220, 225, 235 },
			a = "Bras",
			j = { 0.24, 0.06, 0 },
			ph = 0,
		})
		ajouter(l, {
			n = "Jambe",
			t = { 0.12, 0.24, 0.14 },
			p = { 0.1, -0.38, 0 },
			c = acier,
			a = "Patte",
			j = { 0.1, -0.26, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Mythique : spectre à la lanterne bleue.
	definir("Spectrelle", 0.95, function(l)
		local voile = { 170, 190, 255 }
		local corps = { 0, 0.0, 0 }
		ajouter(l, {
			n = "Capuche",
			t = { 0.34, 0.32, 0.32 },
			p = { 0, 0.28, 0 },
			c = { 60, 50, 100 },
			a = "Tete",
			j = { 0, 0.16, 0 },
		})
		ajouter(l, {
			n = "Visage",
			t = { 0.24, 0.2, 0.03 },
			p = { 0, 0.26, -0.155 },
			c = { 20, 20, 40 },
			a = "Tete",
			j = { 0, 0.16, 0 },
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.06, 0.28, -0.17 },
			c = voile,
			m = "Neon",
			a = "Tete",
			j = { 0, 0.16, 0 },
		}, true)
		ajouter(l, {
			n = "Robe",
			t = { 0.4, 0.5, 0.34 },
			p = { 0, -0.12, 0 },
			c = { 70, 60, 120 },
			tr = 0.15,
			a = "Antenne",
			j = corps,
		})
		for i, x in { -0.13, 0, 0.13 } do
			ajouter(l, {
				n = "Lambeau" .. i,
				t = { 0.1, 0.16, 0.3 },
				p = { x, -0.42, 0 },
				c = voile,
				tr = 0.4,
				a = "Patte",
				j = { x, -0.34, 0 },
				ph = i,
			})
		end
		ajouter(l, {
			n = "Bras",
			t = { 0.08, 0.08, 0.24 },
			p = { 0.24, 0.0, -0.12 },
			c = { 70, 60, 120 },
			a = "Bras",
			j = { 0.2, 0.0, 0 },
			ph = 0,
		})
		ajouter(l, {
			n = "Lanterne",
			t = { 0.14, 0.18, 0.14 },
			p = { 0.26, -0.16, -0.26 },
			c = "Rarete",
			m = "Neon",
			a = "Bras",
			j = { 0.2, 0.0, 0 },
			ph = 0,
		})
		ajouter(l, {
			n = "Cadre",
			t = { 0.16, 0.03, 0.16 },
			p = { 0.26, -0.055, -0.26 },
			c = { 50, 50, 60 },
			a = "Bras",
			j = { 0.2, 0.0, 0 },
			ph = 0,
		})
	end)

	-- Mythique : haut-de-forme magique aux yeux pétillants.
	definir("Chapodou", 0.85, function(l)
		local noir = { 35, 30, 45 }
		local chapeau = { 0, -0.2, 0 }
		ajouter(l, {
			n = "Bord",
			t = { 0.6, 0.06, 0.56 },
			p = { 0, -0.44, 0 },
			c = noir,
			a = "Antenne",
			j = chapeau,
		})
		ajouter(l, {
			n = "Cylindre",
			t = { 0.4, 0.5, 0.38 },
			p = { 0, -0.16, 0 },
			c = noir,
			a = "Antenne",
			j = chapeau,
		})
		ajouter(l, {
			n = "Ruban",
			t = { 0.41, 0.08, 0.39 },
			p = { 0, -0.34, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = chapeau,
		})
		yeux(l, 0.09, -0.08, -0.195, 0.09, "Antenne", chapeau)
		ajouter(l, {
			n = "Sourire",
			t = { 0.12, 0.02, 0.02 },
			p = { 0, -0.22, -0.195 },
			c = { 200, 160, 230 },
			a = "Antenne",
			j = chapeau,
		})
		ajouter(l, {
			n = "Lapin",
			t = { 0.06, 0.16, 0.04 },
			p = { 0.08, 0.16, 0.04 },
			r = { 0, 0, -10 },
			c = BLANC,
			a = "Oreille",
			j = { 0.06, 0.08, 0.04 },
		}, true)
		for i, pos in { { 0.3, 0.1, -0.1 }, { -0.32, 0.0, 0.06 }, { 0.12, 0.3, -0.12 } } do
			ajouter(l, {
				n = "Etincelle" .. i,
				t = { 0.05, 0.05, 0.02 },
				p = pos,
				r = { 0, 0, 45 },
				c = { 255, 230, 120 },
				m = "Neon",
				a = "Antenne",
				j = chapeau,
			})
		end
		ajouter(l, {
			n = "Baguette",
			t = { 0.03, 0.03, 0.3 },
			p = { -0.26, -0.3, -0.16 },
			r = { 0, 30, 0 },
			c = noir,
		})
		ajouter(l, {
			n = "Bout",
			t = { 0.04, 0.04, 0.06 },
			p = { -0.33, -0.3, -0.28 },
			r = { 0, 30, 0 },
			c = BLANC,
		})
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : araignée poilue qui tisse sa toile.
	definir("Toilou", 0.5, function(l)
		local poil = { 60, 45, 70 }
		local tete = { 0, -0.24, -0.2 }
		ajouter(l, { n = "Abdomen", t = { 0.4, 0.34, 0.4 }, p = { 0, -0.2, 0.14 }, c = poil })
		ajouter(l, {
			n = "Motif",
			t = { 0.14, 0.02, 0.14 },
			p = { 0, -0.02, 0.14 },
			r = { 0, 45, 0 },
			c = { 200, 60, 60 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.2, 0.2 },
			p = { 0, -0.28, -0.14 },
			c = poil,
			a = "Tete",
			j = tete,
		})
		for i, pos in { { -0.08, -0.22 }, { 0.08, -0.22 }, { -0.04, -0.3 }, { 0.04, -0.3 } } do
			ajouter(l, {
				n = "Oeil" .. i,
				t = { 0.05, 0.05, 0.02 },
				p = { pos[1], pos[2], -0.245 },
				c = { 255, 60, 60 },
				m = "Neon",
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Croc",
			t = { 0.03, 0.06, 0.03 },
			p = { 0.05, -0.38, -0.22 },
			c = BLANC,
			a = "Machoire",
			j = { 0.04, -0.34, -0.2 },
		}, true)
		for i, z in { -0.16, -0.06, 0.04, 0.14 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.3, 0.04, 0.04 },
				p = { 0.26, -0.3, z },
				r = { 0, z * 80, -35 },
				c = poil,
				a = "Patte",
				j = { 0.12, -0.26, z },
				ph = i * 1.5,
			}, true)
		end
	end)

	-- Moyenne : momie qui se déroule en marchant.
	definir("Momiflet", 0.9, function(l)
		local bande = { 225, 215, 185 }
		local tete = { 0, 0.18, 0 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.42, 0.26 }, p = { 0, -0.04, 0 }, c = bande })
		for i, y in { -0.18, -0.04, 0.1 } do
			ajouter(l, {
				n = "Bande" .. i,
				t = { 0.37, 0.04, 0.27 },
				p = { 0, y, 0 },
				r = { 0, 0, i * 6 - 12 },
				c = { 195, 185, 155 },
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.26 },
			p = { 0, 0.3, 0 },
			c = bande,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Fente",
			t = { 0.24, 0.06, 0.02 },
			p = { 0, 0.32, -0.135 },
			c = { 30, 25, 25 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.04, 0.02 },
			p = { 0.06, 0.32, -0.145 },
			c = { 120, 255, 120 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.1, 0.1, 0.32 },
			p = { 0.24, 0.08, -0.18 },
			c = bande,
			a = "Bras",
			j = { 0.22, 0.08, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pendouille",
			t = { 0.06, 0.2, 0.02 },
			p = { 0.28, -0.04, -0.32 },
			r = { 0, 0, 15 },
			c = bande,
			a = "Bras",
			j = { 0.22, 0.08, 0 },
			ph = 0,
		})
		ajouter(l, {
			n = "Jambe",
			t = { 0.12, 0.24, 0.14 },
			p = { 0.1, -0.38, 0 },
			c = bande,
			a = "Patte",
			j = { 0.1, -0.26, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Lointaine : gargouille de pierre aux ailes déployées.
	definir("Gargouillard", 0.95, function(l)
		local pierre = { 110, 110, 125 }
		local tete = { 0, 0.22, -0.1 }
		ajouter(l, { n = "Torse", t = { 0.5, 0.46, 0.42 }, p = { 0, -0.02, 0.04 }, c = pierre })
		ajouter(l, {
			n = "Tete",
			t = { 0.38, 0.32, 0.34 },
			p = { 0, 0.34, -0.12 },
			c = pierre,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.06, 0.18, 0.06 },
			p = { 0.14, 0.54, -0.08 },
			r = { -20, 0, -25 },
			c = { 80, 80, 95 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.06, 0.03 },
			p = { 0.1, 0.38, -0.295 },
			c = { 255, 120, 40 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.04, 0.04 },
			p = { 0.1, 0.44, -0.29 },
			r = { 0, 0, 25 },
			c = { 80, 80, 95 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Gueule",
			t = { 0.24, 0.08, 0.03 },
			p = { 0, 0.24, -0.295 },
			c = { 40, 35, 45 },
			a = "Machoire",
			j = { 0, 0.26, -0.2 },
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.04, 0.06, 0.02 },
			p = { 0.07, 0.25, -0.3 },
			c = OS,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.5, 0.36, 0.04 },
			p = { 0.46, 0.14, 0.2 },
			r = { 0, 25, -15 },
			c = { 90, 90, 105 },
			a = "Aile",
			j = { 0.22, 0.1, 0.16 },
		}, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.14, 0.34, 0.16 },
			p = { 0.32, -0.16, -0.04 },
			c = pierre,
			a = "Bras",
			j = { 0.3, 0.06, -0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Griffe",
			t = { 0.16, 0.08, 0.18 },
			p = { 0.32, -0.36, -0.06 },
			c = VIOLET,
			a = "Bras",
			j = { 0.3, 0.06, -0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.16, 0.2, 0.2 },
			p = { 0.14, -0.4, 0.04 },
			c = pierre,
			a = "Patte",
			j = { 0.14, -0.3, 0.04 },
			ph = math.pi,
		}, true)
	end)
end
