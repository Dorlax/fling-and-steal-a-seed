--!strict
-- Bestiaire du biome 17 : Coffre à Jouets (cubes, peluches, ressorts, papier).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux = o.definir, o.ajouter, o.yeux
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local ROUGE = { 230, 60, 60 }
	local BLEU = { 60, 130, 230 }
	local JAUNE = { 255, 210, 50 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : cube de bois à lettre, sur deux petits pieds.
	definir("Cubinou", 0.55, function(l)
		ajouter(l, { n = "Cube", t = { 0.46, 0.46, 0.46 }, p = { 0, -0.24, 0 }, c = BLEU })
		ajouter(
			l,
			{ n = "Lettre", t = { 0.06, 0.24, 0.02 }, p = { -0.08, -0.24, -0.235 }, c = JAUNE }
		)
		ajouter(l, { n = "Lettre2", t = { 0.16, 0.06, 0.02 }, p = { 0, -0.14, -0.235 }, c = JAUNE })
		ajouter(
			l,
			{ n = "Lettre3", t = { 0.06, 0.24, 0.02 }, p = { 0.08, -0.24, -0.235 }, c = JAUNE }
		)
		ajouter(
			l,
			{ n = "Cote", t = { 0.02, 0.3, 0.3 }, p = { 0.235, -0.24, 0 }, c = "Rarete" },
			true
		)
		yeux(l, 0.1, -0.06, -0.24, 0.07)
		ajouter(l, {
			n = "Pied",
			t = { 0.1, 0.04, 0.12 },
			p = { 0.12, -0.48, -0.02 },
			c = ROUGE,
			a = "Patte",
			j = { 0.12, -0.46, 0 },
			ph = 0,
		}, true)
	end)

	-- Commune : toupie qui tourne sur elle-même.
	definir("Toupinette", 0.65, function(l)
		local axe = { 0, -0.1, 0 }
		ajouter(
			l,
			{ n = "Pointe", t = { 0.08, 0.12, 0.08 }, p = { 0, -0.44, 0 }, c = { 120, 120, 130 } }
		)
		ajouter(l, {
			n = "Bas",
			t = { 0.3, 0.12, 0.3 },
			p = { 0, -0.34, 0 },
			r = { 0, 45, 0 },
			c = ROUGE,
			a = "Antenne",
			j = axe,
		})
		ajouter(l, {
			n = "Ventre",
			t = { 0.5, 0.16, 0.5 },
			p = { 0, -0.2, 0 },
			c = JAUNE,
			a = "Antenne",
			j = axe,
		})
		ajouter(l, {
			n = "Bande",
			t = { 0.52, 0.04, 0.52 },
			p = { 0, -0.2, 0 },
			c = "Rarete",
			a = "Antenne",
			j = axe,
		})
		ajouter(l, {
			n = "Haut",
			t = { 0.34, 0.12, 0.34 },
			p = { 0, -0.06, 0 },
			r = { 0, 45, 0 },
			c = ROUGE,
			a = "Antenne",
			j = axe,
		})
		ajouter(l, {
			n = "Manche",
			t = { 0.06, 0.16, 0.06 },
			p = { 0, 0.08, 0 },
			c = BLEU,
			a = "Antenne",
			j = axe,
		})
		yeux(l, 0.08, -0.18, -0.255, 0.07)
	end)

	-- Rare : petit soldat de plomb au tambour.
	definir("Soldaplomb", 0.9, function(l)
		local tete = { 0, 0.14, 0 }
		ajouter(l, { n = "Veste", t = { 0.3, 0.3, 0.22 }, p = { 0, -0.06, 0 }, c = ROUGE })
		ajouter(l, {
			n = "Baudrier",
			t = { 0.04, 0.32, 0.23 },
			p = { 0, -0.06, 0 },
			r = { 0, 0, 30 },
			c = BLANC,
		})
		ajouter(l, { n = "Pantalon", t = { 0.28, 0.24, 0.2 }, p = { 0, -0.33, 0 }, c = BLEU })
		ajouter(l, {
			n = "Botte",
			t = { 0.12, 0.06, 0.16 },
			p = { 0.07, -0.47, -0.02 },
			c = NOIR,
			a = "Patte",
			j = { 0.07, -0.4, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.2, 0.2 },
			p = { 0, 0.18, 0 },
			c = { 255, 220, 190 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Joue",
			t = { 0.04, 0.03, 0.02 },
			p = { 0.07, 0.14, -0.105 },
			c = ROSE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.05, 0.2, -0.105 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Shako",
			t = { 0.2, 0.26, 0.2 },
			p = { 0, 0.4, 0 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Plumet",
			t = { 0.04, 0.1, 0.04 },
			p = { 0, 0.57, -0.06 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tambour",
			f = "Cylinder",
			t = { 0.12, 0.2, 0.2 },
			p = { 0, -0.12, -0.18 },
			r = { 0, 0, 90 },
			c = JAUNE,
		})
		ajouter(l, {
			n = "Baguette",
			t = { 0.02, 0.02, 0.16 },
			p = { 0.12, -0.04, -0.18 },
			r = { 30, 0, 0 },
			c = CREME,
			a = "Bras",
			j = { 0.14, 0.0, -0.06 },
			ph = 0,
		}, true)
	end)

	-- Rare : canard de bain jaune.
	definir("Canardbain", 0.6, function(l)
		local tete = { 0, -0.04, -0.12 }
		ajouter(l, { n = "Corps", t = { 0.44, 0.3, 0.52 }, p = { 0, -0.34, 0.04 }, c = JAUNE })
		ajouter(l, {
			n = "Queue",
			t = { 0.2, 0.12, 0.1 },
			p = { 0, -0.18, 0.32 },
			r = { -30, 0, 0 },
			c = JAUNE,
			a = "Queue",
			j = { 0, -0.22, 0.28 },
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.16, 0.26 },
			p = { 0.23, -0.3, 0.06 },
			c = { 255, 190, 40 },
			a = "Aile",
			j = { 0.22, -0.24, 0.04 },
		}, true)
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.28, 0.28 },
			p = { 0, -0.02, -0.14 },
			c = JAUNE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.2, 0.06, 0.12 },
			p = { 0, -0.08, -0.32 },
			c = { 255, 130, 40 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.04, -0.285, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Bulle",
			f = "Ball",
			t = { 0.1, 0.1, 0.1 },
			p = { 0.16, 0.18, -0.2 },
			c = "Rarete",
			tr = 0.4,
			a = "Antenne",
			j = { 0.1, 0.1, -0.14 },
		})
	end, "Gelee")

	-- Épique : ourson en peluche recousu.
	definir("Ourspeluche", 0.8, function(l)
		local peluche = { 200, 150, 100 }
		local tete = { 0, 0.1, -0.02 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.38, 0.32 }, p = { 0, -0.24, 0.02 }, c = peluche })
		ajouter(l, { n = "Ventre", t = { 0.24, 0.24, 0.03 }, p = { 0, -0.24, -0.145 }, c = CREME })
		ajouter(
			l,
			{ n = "Couture", t = { 0.02, 0.2, 0.02 }, p = { 0, -0.24, -0.16 }, c = { 120, 80, 60 } }
		)
		ajouter(l, {
			n = "Tete",
			t = { 0.38, 0.32, 0.3 },
			p = { 0, 0.14, -0.02 },
			c = peluche,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.14, 0.1, 0.04 },
			p = { 0, 0.08, -0.18 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.06, 0.04, 0.02 },
			p = { 0, 0.11, -0.205 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilG",
			f = "Ball",
			t = { 0.06, 0.06, 0.03 },
			p = { -0.08, 0.2, -0.175 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilD",
			t = { 0.07, 0.07, 0.02 },
			p = { 0.08, 0.2, -0.175 },
			r = { 0, 0, 45 },
			c = BLEU,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.1, 0.06 },
			p = { 0.15, 0.32, -0.02 },
			c = peluche,
			a = "Oreille",
			j = { 0.13, 0.28, -0.02 },
		}, true)
		ajouter(l, { n = "Noeud", t = { 0.2, 0.08, 0.04 }, p = { 0, -0.04, -0.16 }, c = "Rarete" })
		ajouter(l, {
			n = "Bras",
			t = { 0.1, 0.22, 0.1 },
			p = { 0.25, -0.2, 0 },
			r = { 0, 0, -25 },
			c = peluche,
			a = "Bras",
			j = { 0.2, -0.1, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.14, 0.1, 0.16 },
			p = { 0.12, -0.45, -0.04 },
			c = peluche,
			a = "Patte",
			j = { 0.12, -0.4, 0 },
			ph = math.pi,
		}, true)
	end, "Pelage")

	-- Épique : diable à ressort qui sort de sa boîte.
	definir("Diablotboite", 0.95, function(l)
		local ressort = { 0, -0.1, 0 }
		ajouter(l, { n = "Boite", t = { 0.44, 0.34, 0.44 }, p = { 0, -0.33, 0 }, c = ROUGE })
		ajouter(l, { n = "Face", t = { 0.3, 0.2, 0.02 }, p = { 0, -0.33, -0.225 }, c = JAUNE })
		ajouter(l, {
			n = "Couvercle",
			t = { 0.44, 0.04, 0.44 },
			p = { 0, -0.12, 0.26 },
			r = { 70, 0, 0 },
			c = BLEU,
		})
		ajouter(l, {
			n = "Manivelle",
			t = { 0.1, 0.04, 0.04 },
			p = { 0.27, -0.3, 0 },
			c = { 140, 140, 150 },
			a = "Bras",
			j = { 0.23, -0.3, 0 },
			ph = 0,
		})
		for k = 0, 2 do
			ajouter(l, {
				n = "Spire" .. k,
				t = { 0.14, 0.03, 0.14 },
				p = { 0, -0.12 + k * 0.06, 0 },
				c = { 170, 170, 180 },
				a = "Antenne",
				j = ressort,
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.26, 0.26 },
			p = { 0, 0.16, 0 },
			c = { 255, 225, 200 },
			a = "Antenne",
			j = ressort,
		})
		yeux(l, 0.07, 0.18, -0.135, 0.07, "Antenne", ressort)
		ajouter(l, {
			n = "Nez",
			f = "Ball",
			t = { 0.08, 0.08, 0.08 },
			p = { 0, 0.12, -0.15 },
			c = ROUGE,
			a = "Antenne",
			j = ressort,
		})
		ajouter(l, {
			n = "Chapeau",
			t = { 0.1, 0.14, 0.1 },
			p = { 0.08, 0.36, 0 },
			r = { 0, 0, -30 },
			c = "Rarete",
			a = "Antenne",
			j = ressort,
		}, true)
		ajouter(l, {
			n = "Grelot",
			f = "Ball",
			t = { 0.05, 0.05, 0.05 },
			p = { 0.16, 0.42, 0 },
			c = JAUNE,
			a = "Antenne",
			j = ressort,
		}, true)
	end)

	-- Légendaire : robot jouet à clé remontoir.
	definir("Robotin", 0.9, function(l)
		local metal = { 170, 180, 200 }
		local tete = { 0, 0.18, 0 }
		ajouter(l, { n = "Torse", t = { 0.38, 0.36, 0.28 }, p = { 0, -0.06, 0 }, c = metal })
		ajouter(
			l,
			{ n = "Ecran", t = { 0.2, 0.14, 0.02 }, p = { 0, -0.04, -0.145 }, c = { 40, 50, 60 } }
		)
		ajouter(l, {
			n = "Coeur",
			t = { 0.06, 0.06, 0.02 },
			p = { 0, -0.04, -0.155 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Cle",
			t = { 0.04, 0.04, 0.16 },
			p = { 0, -0.04, 0.22 },
			c = JAUNE,
			a = "Queue",
			j = { 0, -0.04, 0.14 },
		})
		ajouter(l, {
			n = "Anneau",
			t = { 0.04, 0.16, 0.16 },
			p = { 0, -0.04, 0.32 },
			c = JAUNE,
			a = "Queue",
			j = { 0, -0.04, 0.14 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.24, 0.26 },
			p = { 0, 0.26, 0 },
			c = metal,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.06, 0.02 },
			p = { 0.07, 0.28, -0.135 },
			c = { 120, 230, 255 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.14, 0.03, 0.02 },
			p = { 0, 0.2, -0.135 },
			c = { 60, 60, 70 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Antenne",
			t = { 0.02, 0.12, 0.02 },
			p = { 0, 0.44, 0 },
			c = { 90, 90, 100 },
			a = "Antenne",
			j = { 0, 0.38, 0 },
		})
		ajouter(l, {
			n = "Boule",
			f = "Ball",
			t = { 0.06, 0.06, 0.06 },
			p = { 0, 0.51, 0 },
			c = ROUGE,
			m = "Neon",
			a = "Antenne",
			j = { 0, 0.38, 0 },
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.1, 0.26, 0.1 },
			p = { 0.25, -0.06, 0 },
			c = metal,
			a = "Bras",
			j = { 0.22, 0.06, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pince",
			t = { 0.1, 0.06, 0.08 },
			p = { 0.25, -0.22, -0.02 },
			c = ROUGE,
			a = "Bras",
			j = { 0.22, 0.06, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.12, 0.2, 0.14 },
			p = { 0.1, -0.4, 0 },
			c = BLEU,
			a = "Patte",
			j = { 0.1, -0.3, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Légendaire : cheval à bascule à la crinière en laine.
	definir("Chevalbascule", 0.9, function(l)
		local bois = { 240, 220, 190 }
		local bascule = { 0, -0.4, 0 }
		ajouter(l, {
			n = "Bascule",
			t = { 0.06, 0.06, 0.8 },
			p = { 0.14, -0.47, 0 },
			c = ROUGE,
			a = "Patte",
			j = bascule,
		}, true)
		ajouter(l, {
			n = "Montant",
			t = { 0.04, 0.16, 0.04 },
			p = { 0.1, -0.36, -0.18 },
			c = ROUGE,
			a = "Patte",
			j = bascule,
		}, true)
		ajouter(l, {
			n = "Montant2",
			t = { 0.04, 0.16, 0.04 },
			p = { 0.1, -0.36, 0.18 },
			c = ROUGE,
			a = "Patte",
			j = bascule,
		}, true)
		ajouter(l, {
			n = "Corps",
			t = { 0.26, 0.24, 0.5 },
			p = { 0, -0.16, 0 },
			c = bois,
			a = "Patte",
			j = bascule,
		})
		ajouter(l, {
			n = "Selle",
			t = { 0.28, 0.04, 0.2 },
			p = { 0, -0.03, 0.04 },
			c = BLEU,
			a = "Patte",
			j = bascule,
		})
		ajouter(l, {
			n = "Cou",
			t = { 0.14, 0.26, 0.14 },
			p = { 0, 0.04, -0.2 },
			r = { -20, 0, 0 },
			c = bois,
			a = "Patte",
			j = bascule,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.18, 0.18, 0.28 },
			p = { 0, 0.2, -0.3 },
			c = bois,
			a = "Patte",
			j = bascule,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.03, 0.04, 0.02 },
			p = { 0.095, 0.24, -0.34 },
			c = NOIR,
			a = "Patte",
			j = bascule,
		}, true)
		ajouter(l, {
			n = "Criniere",
			t = { 0.06, 0.12, 0.3 },
			p = { 0, 0.26, -0.16 },
			c = "Rarete",
			a = "Patte",
			j = bascule,
		})
		ajouter(l, {
			n = "Rene",
			t = { 0.2, 0.03, 0.03 },
			p = { 0, 0.16, -0.4 },
			c = JAUNE,
			a = "Patte",
			j = bascule,
		})
		ajouter(l, {
			n = "Queue",
			t = { 0.06, 0.18, 0.06 },
			p = { 0, -0.1, 0.28 },
			r = { 30, 0, 0 },
			c = "Rarete",
			a = "Queue",
			j = { 0, -0.04, 0.26 },
		})
	end)

	-- Mythique : poupée gigogne qui en cache une autre.
	definir("Matriochou", 0.85, function(l)
		local corps = { 0, -0.2, 0 }
		ajouter(l, {
			n = "Bas",
			f = "Ball",
			t = { 0.5, 0.5, 0.46 },
			p = { 0, -0.24, 0 },
			c = ROUGE,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Tablier",
			t = { 0.3, 0.3, 0.04 },
			p = { 0, -0.24, -0.22 },
			c = CREME,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Fleur",
			t = { 0.1, 0.1, 0.02 },
			p = { 0, -0.24, -0.245 },
			r = { 0, 0, 45 },
			c = "Rarete",
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Haut",
			f = "Ball",
			t = { 0.38, 0.36, 0.36 },
			p = { 0, 0.1, 0 },
			c = ROUGE,
			a = "Tete",
			j = { 0, 0.0, 0 },
		})
		ajouter(l, {
			n = "Visage",
			t = { 0.22, 0.2, 0.03 },
			p = { 0, 0.1, -0.17 },
			c = { 255, 230, 210 },
			a = "Tete",
			j = { 0, 0.0, 0 },
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.03, 0.04, 0.02 },
			p = { 0.05, 0.13, -0.19 },
			c = NOIR,
			a = "Tete",
			j = { 0, 0.0, 0 },
		}, true)
		ajouter(l, {
			n = "Joue",
			t = { 0.04, 0.04, 0.02 },
			p = { 0.08, 0.07, -0.19 },
			c = ROSE,
			a = "Tete",
			j = { 0, 0.0, 0 },
		}, true)
		ajouter(l, {
			n = "Petite",
			f = "Ball",
			t = { 0.14, 0.16, 0.14 },
			p = { 0.3, -0.38, -0.16 },
			c = BLEU,
			m = "Neon",
			tr = 0.2,
			a = "Bras",
			j = { 0.24, -0.3, -0.1 },
			ph = 0,
		})
	end)

	-- Mythique : avion en papier plié qui plane.
	definir("Papivol", 0.55, function(l)
		local papier = { 250, 250, 245 }
		local corps = { 0, -0.1, 0 }
		ajouter(l, {
			n = "Nez",
			t = { 0.08, 0.1, 0.5 },
			p = { 0, -0.14, -0.04 },
			c = papier,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.36, 0.02, 0.5 },
			p = { 0.2, -0.08, 0.04 },
			r = { 0, -12, -8 },
			c = papier,
			a = "Aile",
			j = { 0.04, -0.08, 0.04 },
		}, true)
		ajouter(l, {
			n = "Pli",
			t = { 0.3, 0.025, 0.02 },
			p = { 0.18, -0.07, 0.2 },
			r = { 0, -12, -8 },
			c = { 200, 220, 255 },
			a = "Aile",
			j = { 0.04, -0.08, 0.04 },
		}, true)
		ajouter(l, {
			n = "Dessin",
			t = { 0.1, 0.03, 0.1 },
			p = { 0.3, -0.06, 0.1 },
			r = { 0, 45, 0 },
			c = "Rarete",
			a = "Aile",
			j = { 0.04, -0.08, 0.04 },
		}, true)
		ajouter(l, {
			n = "Quille",
			t = { 0.04, 0.14, 0.4 },
			p = { 0, -0.24, 0.04 },
			c = papier,
			a = "Antenne",
			j = corps,
		})
		yeux(l, 0.03, -0.12, -0.3, 0.04, "Antenne", corps)
		ajouter(l, {
			n = "Traine",
			t = { 0.02, 0.02, 0.3 },
			p = { 0, -0.12, 0.4 },
			c = { 120, 200, 255 },
			m = "Neon",
			tr = 0.3,
			a = "Queue",
			j = { 0, -0.12, 0.26 },
		})
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : bille enragée qui roule.
	definir("Billerage", 0.6, function(l)
		local corps = { 0, -0.2, 0 }
		ajouter(l, {
			n = "Bille",
			f = "Ball",
			t = { 0.6, 0.6, 0.6 },
			p = { 0, -0.2, 0 },
			c = { 120, 200, 255 },
			m = "Glass",
			tr = 0.2,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Spirale",
			t = { 0.5, 0.08, 0.08 },
			p = { 0, -0.2, 0 },
			r = { 0, 0, 30 },
			c = ROUGE,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Spirale2",
			t = { 0.08, 0.5, 0.08 },
			p = { 0, -0.2, 0 },
			r = { 0, 0, 30 },
			c = JAUNE,
			a = "Antenne",
			j = corps,
		})
		yeux(l, 0.11, -0.14, -0.3, 0.1)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.03, 0.02 },
			p = { 0.11, -0.03, -0.31 },
			r = { 0, 0, 25 },
			c = NOIR,
		}, true)
		ajouter(l, { n = "Bouche", t = { 0.14, 0.03, 0.02 }, p = { 0, -0.3, -0.3 }, c = NOIR })
	end)

	-- Moyenne : tambour qui cogne en marchant.
	definir("Tamboum", 0.8, function(l)
		local tete = { 0, 0.0, 0 }
		ajouter(l, {
			n = "Fut",
			f = "Cylinder",
			t = { 0.5, 0.56, 0.56 },
			p = { 0, -0.1, 0 },
			r = { 0, 0, 90 },
			c = ROUGE,
		})
		ajouter(l, {
			n = "Peau",
			f = "Cylinder",
			t = { 0.04, 0.58, 0.58 },
			p = { 0, 0.16, 0 },
			r = { 0, 0, 90 },
			c = CREME,
		})
		for k = 0, 5 do
			local a = math.rad(k * 60)
			ajouter(l, {
				n = "Corde" .. k,
				t = { 0.03, 0.5, 0.03 },
				p = { math.cos(a) * 0.285, -0.1, math.sin(a) * 0.285 },
				r = { 0, -k * 60, 15 },
				c = JAUNE,
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.06, 0.02 },
			p = { 0.1, -0.02, -0.285 },
			c = { 255, 240, 80 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.03, 0.02 },
			p = { 0.1, 0.04, -0.29 },
			r = { 0, 0, 25 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.18, 0.04, 0.02 },
			p = { 0, -0.18, -0.285 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Baguette",
			t = { 0.04, 0.3, 0.04 },
			p = { 0.34, 0.12, 0 },
			r = { 0, 0, 30 },
			c = CREME,
			a = "Bras",
			j = { 0.28, -0.02, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.12, 0.08, 0.16 },
			p = { 0.14, -0.46, 0 },
			c = BLEU,
			a = "Patte",
			j = { 0.14, -0.4, 0 },
			ph = 0,
		}, true)
	end)

	-- Lointaine : piano à queue qui claque ses touches.
	definir("Pianogre", 0.85, function(l)
		local noir = { 30, 30, 35 }
		ajouter(l, { n = "Caisse", t = { 0.8, 0.36, 0.56 }, p = { 0, -0.02, 0.08 }, c = noir })
		ajouter(l, {
			n = "Couvercle",
			t = { 0.8, 0.04, 0.56 },
			p = { 0, 0.28, 0.2 },
			r = { -35, 0, 0 },
			c = noir,
			a = "Tete",
			j = { 0, 0.16, -0.2 },
		})
		ajouter(l, {
			n = "Clavier",
			t = { 0.76, 0.06, 0.16 },
			p = { 0, -0.04, -0.26 },
			c = BLANC,
			a = "Machoire",
			j = { 0, -0.02, -0.18 },
		})
		for i = 0, 5 do
			ajouter(l, {
				n = "Touche" .. i,
				t = { 0.06, 0.05, 0.1 },
				p = { -0.3 + i * 0.12, 0.0, -0.24 },
				c = noir,
				a = "Machoire",
				j = { 0, -0.02, -0.18 },
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.06, 0.02 },
			p = { 0.2, 0.1, -0.205 },
			c = { 255, 60, 80 },
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.14, 0.04, 0.02 },
			p = { 0.2, 0.16, -0.21 },
			r = { 0, 0, 25 },
			c = { 90, 90, 100 },
		}, true)
		ajouter(l, {
			n = "Note",
			t = { 0.04, 0.16, 0.02 },
			p = { 0.36, 0.42, -0.1 },
			r = { 0, 0, -10 },
			c = JAUNE,
			m = "Neon",
			a = "Antenne",
			j = { 0.3, 0.3, -0.1 },
		})
		ajouter(l, {
			n = "Note2",
			t = { 0.08, 0.06, 0.02 },
			p = { 0.33, 0.34, -0.1 },
			c = JAUNE,
			m = "Neon",
			a = "Antenne",
			j = { 0.3, 0.3, -0.1 },
		})
		ajouter(l, {
			n = "Pied",
			t = { 0.08, 0.3, 0.08 },
			p = { 0.32, -0.35, 0.0 },
			c = noir,
			a = "Patte",
			j = { 0.32, -0.2, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "PiedArriere",
			t = { 0.08, 0.3, 0.08 },
			p = { 0, -0.35, 0.3 },
			c = noir,
			a = "Patte",
			j = { 0, -0.2, 0.3 },
			ph = math.pi,
		})
	end)
end
