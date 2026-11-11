--!strict
-- Bestiaire du biome 14 : Cité Mécanique (laiton, engrenages, vapeur).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR = o.BLANC, o.NOIR

	local LAITON = { 215, 170, 80 }
	local CUIVRE = { 200, 120, 70 }
	local ACIER = { 160, 165, 175 }
	local SOMBRE = { 70, 70, 80 }
	local VAPEUR = { 235, 235, 240 }
	local LUEUR = { 120, 230, 255 }

	-- Engrenage plat (un disque + 6 dents) centré en `p`, face vers -Z.
	local function engrenage(
		l: any,
		nom: string,
		p: { number },
		rayon: number,
		c: any,
		role: string?,
		j: { number }?
	)
		ajouter(l, {
			n = nom,
			f = "Cylinder",
			t = { 0.04, rayon * 2, rayon * 2 },
			p = p,
			r = { 0, 90, 0 },
			c = c,
			m = "Metal",
			a = role,
			j = j,
		})
		for k = 0, 5 do
			local a = math.rad(k * 60)
			ajouter(l, {
				n = nom .. "Dent" .. k,
				t = { rayon * 0.5, rayon * 0.5, 0.04 },
				p = { p[1] + math.cos(a) * rayon, p[2] + math.sin(a) * rayon, p[3] },
				r = { 0, 0, k * 60 },
				c = c,
				m = "Metal",
				a = role,
				j = j,
			})
		end
	end

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : petit scarabée-boulon.
	definir("Boulonou", 0.45, function(l)
		ajouter(l, { n = "Carapace", t = { 0.44, 0.24, 0.5 }, p = { 0, -0.3, 0.02 }, c = ACIER })
		ajouter(l, {
			n = "Tete",
			f = "Cylinder",
			t = { 0.1, 0.3, 0.3 },
			p = { 0, -0.3, -0.27 },
			r = { 0, 90, 0 },
			c = LAITON,
			m = "Metal",
		})
		ajouter(l, { n = "Fente", t = { 0.04, 0.24, 0.42 }, p = { 0, -0.17, 0.02 }, c = SOMBRE })
		yeux(l, 0.07, -0.28, -0.33, 0.07)
		for i, z in { -0.12, 0.02, 0.16 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.14, 0.03, 0.03 },
				p = { 0.26, -0.44, z },
				r = { 0, 0, -20 },
				c = SOMBRE,
				a = "Patte",
				j = { 0.2, -0.42, z },
				ph = i * 2,
			}, true)
		end
		ajouter(l, {
			n = "Antenne",
			t = { 0.02, 0.14, 0.02 },
			p = { 0.06, -0.12, -0.3 },
			r = { -20, 0, -15 },
			c = SOMBRE,
			a = "Antenne",
			j = { 0.06, -0.18, -0.28 },
		}, true)
		ajouter(l, {
			n = "Voyant",
			t = { 0.04, 0.04, 0.04 },
			p = { 0.08, -0.05, -0.33 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = { 0.06, -0.18, -0.28 },
		}, true)
	end)

	-- Commune : ressort sauteur à grands yeux.
	definir("Ressortin", 0.7, function(l)
		local corps = { 0, -0.3, 0 }
		for k = 0, 4 do
			ajouter(l, {
				n = "Spire" .. k,
				f = "Cylinder",
				t = { 0.05, 0.3, 0.3 },
				p = { 0, -0.46 + k * 0.08, 0 },
				r = { 0, 0, 90 },
				c = ACIER,
				m = "Metal",
				a = "Patte",
				j = corps,
				ph = k,
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.3, 0.32 },
			p = { 0, 0.0, 0 },
			c = CUIVRE,
			a = "Tete",
			j = { 0, -0.12, 0 },
		})
		yeux(l, 0.08, 0.04, -0.165, 0.1, "Tete", { 0, -0.12, 0 })
		ajouter(l, {
			n = "Bouche",
			t = { 0.1, 0.03, 0.02 },
			p = { 0, -0.08, -0.165 },
			c = SOMBRE,
			a = "Tete",
			j = { 0, -0.12, 0 },
		})
		ajouter(l, {
			n = "Hublot",
			f = "Cylinder",
			t = { 0.04, 0.12, 0.12 },
			p = { 0, 0.17, 0 },
			r = { 0, 0, 90 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = { 0, -0.12, 0 },
		})
	end)

	-- Rare : chat-robot à la queue d'antenne.
	definir("Robichat", 0.7, function(l)
		local tete = { 0, 0.0, -0.18 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.26, 0.46 }, p = { 0, -0.2, 0.06 }, c = ACIER })
		ajouter(
			l,
			{ n = "Panneau", t = { 0.2, 0.14, 0.03 }, p = { 0.155, -0.18, 0.06 }, c = LAITON },
			true
		)
		pattes4(l, 0.1, -0.08, 0.22, { 0.07, 0.18, 0.07 }, SOMBRE)
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.24 },
			p = { 0, 0.02, -0.26 },
			c = ACIER,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Ecran",
			t = { 0.24, 0.16, 0.02 },
			p = { 0, 0.02, -0.385 },
			c = { 30, 40, 50 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.06, 0.04, -0.395 },
			c = LUEUR,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Moustache",
			t = { 0.1, 0.015, 0.015 },
			p = { 0.18, -0.02, -0.38 },
			c = LAITON,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.1, 0.04 },
			p = { 0.1, 0.18, -0.26 },
			c = LAITON,
			a = "Oreille",
			j = { 0.1, 0.14, -0.26 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.03, 0.3, 0.03 },
			p = { 0, 0.0, 0.3 },
			r = { 20, 0, 0 },
			c = SOMBRE,
			a = "Queue",
			j = { 0, -0.12, 0.28 },
		})
		ajouter(l, {
			n = "Bout",
			t = { 0.07, 0.07, 0.07 },
			p = { 0, 0.15, 0.36 },
			c = "Rarete",
			m = "Neon",
			a = "Queue",
			j = { 0, -0.12, 0.28 },
		})
	end)

	-- Rare : hibou mécanique aux yeux-objectifs.
	definir("Hiboulon", 0.75, function(l)
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Corps", t = { 0.38, 0.42, 0.34 }, p = { 0, -0.18, 0.02 }, c = CUIVRE })
		ajouter(l, { n = "Ventre", t = { 0.26, 0.28, 0.03 }, p = { 0, -0.2, -0.155 }, c = LAITON })
		for i, y in { -0.1, -0.2, -0.3 } do
			ajouter(
				l,
				{ n = "Rivet" .. i, t = { 0.03, 0.03, 0.02 }, p = { 0, y, -0.17 }, c = SOMBRE }
			)
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.42, 0.28, 0.34 },
			p = { 0, 0.18, 0 },
			c = CUIVRE,
			a = "Tete",
			j = tete,
		})
		for _, x in { -0.1, 0.1 } do
			ajouter(l, {
				n = "Objectif" .. (if x < 0 then "G" else "D"),
				f = "Cylinder",
				t = { 0.06, 0.16, 0.16 },
				p = { x, 0.2, -0.19 },
				r = { 0, 90, 0 },
				c = SOMBRE,
				m = "Metal",
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.07, 0.02 },
			p = { 0.1, 0.2, -0.225 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bec",
			t = { 0.06, 0.06, 0.06 },
			p = { 0, 0.1, -0.2 },
			r = { 0, 0, 45 },
			c = LAITON,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Aigrette",
			t = { 0.06, 0.12, 0.04 },
			p = { 0.16, 0.36, 0 },
			r = { 0, 0, -25 },
			c = LAITON,
			a = "Oreille",
			j = { 0.14, 0.3, 0 },
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.3, 0.26 },
			p = { 0.21, -0.16, 0.04 },
			c = LAITON,
			a = "Aile",
			j = { 0.19, -0.04, 0.02 },
		}, true)
		engrenage(l, "Cle", { 0, -0.16, 0.2 }, 0.08, ACIER, "Queue", { 0, -0.16, 0.18 })
		ajouter(l, {
			n = "Patte",
			t = { 0.06, 0.08, 0.08 },
			p = { 0.08, -0.45, -0.04 },
			c = SOMBRE,
			a = "Patte",
			j = { 0.08, -0.4, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Épique : petite locomotive à vapeur souriante.
	definir("Locomotou", 0.75, function(l)
		ajouter(l, {
			n = "Chaudiere",
			f = "Cylinder",
			t = { 0.5, 0.32, 0.32 },
			p = { 0, -0.14, -0.06 },
			r = { 0, 90, 0 },
			c = { 60, 120, 200 },
		})
		ajouter(
			l,
			{ n = "Cabine", t = { 0.36, 0.36, 0.22 }, p = { 0, -0.04, 0.26 }, c = { 220, 60, 60 } }
		)
		ajouter(l, { n = "Toit", t = { 0.42, 0.05, 0.28 }, p = { 0, 0.16, 0.26 }, c = SOMBRE })
		ajouter(
			l,
			{ n = "Fenetre", t = { 0.02, 0.12, 0.1 }, p = { 0.185, 0.02, 0.26 }, c = LUEUR },
			true
		)
		ajouter(l, {
			n = "Face",
			f = "Cylinder",
			t = { 0.04, 0.32, 0.32 },
			p = { 0, -0.14, -0.32 },
			r = { 0, 90, 0 },
			c = SOMBRE,
		})
		yeux(l, 0.07, -0.1, -0.345, 0.07)
		ajouter(l, { n = "Sourire", t = { 0.1, 0.02, 0.02 }, p = { 0, -0.22, -0.345 }, c = BLANC })
		local fumee = { 0, 0.1, -0.12 }
		ajouter(l, { n = "Cheminee", t = { 0.1, 0.18, 0.1 }, p = { 0, 0.1, -0.16 }, c = SOMBRE })
		ajouter(l, {
			n = "Fumee",
			f = "Ball",
			t = { 0.16, 0.14, 0.16 },
			p = { 0, 0.28, -0.16 },
			c = VAPEUR,
			tr = 0.2,
			a = "Antenne",
			j = fumee,
		})
		ajouter(l, {
			n = "Fumee2",
			f = "Ball",
			t = { 0.12, 0.1, 0.12 },
			p = { 0.04, 0.4, -0.12 },
			c = VAPEUR,
			tr = 0.35,
			a = "Antenne",
			j = fumee,
		})
		for i, z in { -0.2, 0.04, 0.26 } do
			ajouter(l, {
				n = "Roue" .. i,
				f = "Cylinder",
				t = { 0.04, 0.18, 0.18 },
				p = { 0.18, -0.4, z },
				c = if i == 2 then "Rarete" else SOMBRE,
				a = "Patte",
				j = { 0.18, -0.4, z },
				ph = i,
			}, true)
		end
	end)

	-- Épique : petit hélico-libellule à hélice.
	definir("Helicopou", 0.75, function(l)
		local rotor = { 0, 0.18, 0 }
		ajouter(l, {
			n = "Cabine",
			f = "Ball",
			t = { 0.4, 0.36, 0.42 },
			p = { 0, -0.14, -0.04 },
			c = { 255, 200, 70 },
		})
		ajouter(
			l,
			{ n = "Vitre", t = { 0.26, 0.16, 0.02 }, p = { 0, -0.06, -0.25 }, c = LUEUR, tr = 0.3 }
		)
		yeux(l, 0.07, -0.06, -0.26, 0.06)
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.08, 0.36 },
			p = { 0, -0.1, 0.32 },
			c = { 255, 200, 70 },
			a = "Queue",
			j = { 0, -0.1, 0.16 },
		})
		ajouter(l, {
			n = "Helicette",
			t = { 0.02, 0.16, 0.04 },
			p = { 0.05, -0.1, 0.5 },
			c = "Rarete",
			a = "Queue",
			j = { 0, -0.1, 0.16 },
		})
		ajouter(l, { n = "Mat", t = { 0.04, 0.12, 0.04 }, p = { 0, 0.1, -0.04 }, c = SOMBRE })
		ajouter(l, {
			n = "Pale",
			t = { 0.8, 0.02, 0.08 },
			p = { 0, 0.17, -0.04 },
			c = ACIER,
			a = "Aile",
			j = rotor,
		})
		ajouter(l, {
			n = "Pale2",
			t = { 0.08, 0.02, 0.8 },
			p = { 0, 0.17, -0.04 },
			c = ACIER,
			a = "Aile",
			j = rotor,
		})
		ajouter(l, {
			n = "Patin",
			t = { 0.04, 0.04, 0.4 },
			p = { 0.14, -0.44, -0.04 },
			c = SOMBRE,
			a = "Patte",
			j = { 0.12, -0.34, -0.04 },
		}, true)
	end)

	-- Légendaire : gardien d'engrenages, petit golem à rouage.
	definir("Gardengrenage", 0.95, function(l)
		local tete = { 0, 0.22, 0 }
		ajouter(l, { n = "Torse", t = { 0.5, 0.44, 0.34 }, p = { 0, -0.04, 0 }, c = LAITON })
		engrenage(l, "Rouage", { 0, -0.04, -0.2 }, 0.12, "Rarete", "Antenne", { 0, -0.04, -0.2 })
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.24, 0.26 },
			p = { 0, 0.32, 0 },
			c = CUIVRE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Visiere",
			t = { 0.24, 0.06, 0.02 },
			p = { 0, 0.34, -0.135 },
			c = { 30, 30, 40 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.04, 0.02 },
			p = { 0.06, 0.34, -0.145 },
			c = LUEUR,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(
			l,
			{ n = "Cheminee", t = { 0.06, 0.12, 0.06 }, p = { 0.18, 0.18, 0.14 }, c = SOMBRE },
			true
		)
		ajouter(l, {
			n = "Bras",
			t = { 0.12, 0.38, 0.14 },
			p = { 0.33, -0.08, 0 },
			c = ACIER,
			a = "Bras",
			j = { 0.3, 0.12, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pince",
			t = { 0.16, 0.1, 0.16 },
			p = { 0.33, -0.32, -0.02 },
			c = SOMBRE,
			a = "Bras",
			j = { 0.3, 0.12, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.14, 0.24, 0.16 },
			p = { 0.13, -0.38, 0 },
			c = ACIER,
			a = "Patte",
			j = { 0.13, -0.26, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Légendaire : théière-robot qui siffle de la vapeur.
	definir("Theierobot", 0.8, function(l)
		local corps = { 0, -0.2, 0 }
		ajouter(l, {
			n = "Panse",
			f = "Ball",
			t = { 0.5, 0.42, 0.5 },
			p = { 0, -0.2, 0 },
			c = { 120, 200, 180 },
		})
		ajouter(l, { n = "Motif", t = { 0.52, 0.06, 0.52 }, p = { 0, -0.2, 0 }, c = LAITON })
		ajouter(l, {
			n = "Couvercle",
			t = { 0.26, 0.08, 0.26 },
			p = { 0, 0.04, 0 },
			c = LAITON,
			a = "Tete",
			j = { 0, 0.0, 0 },
		})
		ajouter(l, {
			n = "Bouton",
			f = "Ball",
			t = { 0.08, 0.08, 0.08 },
			p = { 0, 0.12, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = { 0, 0.0, 0 },
		})
		yeux(l, 0.08, -0.14, -0.24, 0.08)
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.08, 0.26 },
			p = { 0, -0.18, -0.34 },
			r = { -30, 0, 0 },
			c = { 120, 200, 180 },
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Vapeur",
			f = "Ball",
			t = { 0.12, 0.12, 0.12 },
			p = { 0, -0.02, -0.48 },
			c = VAPEUR,
			tr = 0.3,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Anse",
			t = { 0.06, 0.26, 0.2 },
			p = { 0, -0.18, 0.3 },
			c = LAITON,
			a = "Queue",
			j = { 0, -0.18, 0.24 },
		})
		ajouter(l, {
			n = "Pied",
			t = { 0.08, 0.06, 0.1 },
			p = { 0.12, -0.47, 0 },
			c = SOMBRE,
			a = "Patte",
			j = { 0.12, -0.42, 0 },
			ph = 0,
		}, true)
	end)

	-- Mythique : horloge vivante aux aiguilles qui tournent.
	definir("Horlogeon", 0.9, function(l)
		local cadran = { 0, 0.08, -0.15 }
		ajouter(
			l,
			{ n = "Boitier", t = { 0.46, 0.7, 0.26 }, p = { 0, -0.12, 0 }, c = { 140, 90, 60 } }
		)
		ajouter(l, { n = "Fronton", t = { 0.5, 0.08, 0.3 }, p = { 0, 0.26, 0 }, c = LAITON })
		ajouter(l, {
			n = "Cadran",
			f = "Cylinder",
			t = { 0.03, 0.34, 0.34 },
			p = { 0, 0.06, -0.14 },
			r = { 0, 90, 0 },
			c = { 250, 245, 225 },
		})
		ajouter(l, {
			n = "Aiguille",
			t = { 0.03, 0.14, 0.02 },
			p = { 0, 0.13, -0.16 },
			c = NOIR,
			a = "Antenne",
			j = cadran,
		})
		ajouter(l, {
			n = "Aiguille2",
			t = { 0.1, 0.03, 0.02 },
			p = { 0.05, 0.06, -0.165 },
			c = NOIR,
			a = "Antenne",
			j = cadran,
		})
		ajouter(l, { n = "OeilG", t = { 0.05, 0.05, 0.02 }, p = { -0.08, 0.1, -0.165 }, c = NOIR })
		ajouter(l, { n = "OeilD", t = { 0.05, 0.05, 0.02 }, p = { 0.08, 0.1, -0.165 }, c = NOIR })
		ajouter(
			l,
			{ n = "Vitre", t = { 0.26, 0.26, 0.02 }, p = { 0, -0.3, -0.14 }, c = LUEUR, tr = 0.5 }
		)
		ajouter(l, {
			n = "Balancier",
			f = "Ball",
			t = { 0.12, 0.12, 0.04 },
			p = { 0, -0.36, -0.1 },
			c = "Rarete",
			m = "Neon",
			a = "Queue",
			j = { 0, -0.16, -0.1 },
		})
		ajouter(l, {
			n = "Tige",
			t = { 0.02, 0.18, 0.02 },
			p = { 0, -0.24, -0.1 },
			c = LAITON,
			a = "Queue",
			j = { 0, -0.16, -0.1 },
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.06, 0.2, 0.06 },
			p = { 0.26, -0.06, 0 },
			r = { 0, 0, -20 },
			c = LAITON,
			a = "Bras",
			j = { 0.23, 0.02, 0 },
			ph = 0,
		}, true)
	end)

	-- Mythique : petit dragon mécanique au cœur de chaudière.
	definir("Mecadragon", 0.8, function(l)
		local tete = { 0, 0.1, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.3, 0.46 }, p = { 0, -0.14, 0.06 }, c = CUIVRE })
		ajouter(l, {
			n = "Coeur",
			f = "Ball",
			t = { 0.14, 0.14, 0.06 },
			p = { 0, -0.12, -0.17 },
			c = "Rarete",
			m = "Neon",
		})
		for i, z in { -0.08, 0.06, 0.2 } do
			ajouter(l, {
				n = "Plaque" .. i,
				t = { 0.08, 0.08, 0.08 },
				p = { 0, 0.04, z },
				r = { 0, 0, 45 },
				c = LAITON,
			})
		end
		pattes4(l, 0.12, -0.08, 0.22, { 0.08, 0.16, 0.08 }, SOMBRE)
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.22, 0.28 },
			p = { 0, 0.14, -0.3 },
			c = CUIVRE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.2, 0.06, 0.2 },
			p = { 0, 0.02, -0.36 },
			c = ACIER,
			a = "Machoire",
			j = { 0, 0.04, -0.24 },
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.08, 0.18, -0.445 },
			c = { 255, 150, 40 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Corne",
			t = { 0.04, 0.12, 0.04 },
			p = { 0.08, 0.3, -0.26 },
			r = { 25, 0, 0 },
			c = ACIER,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.24, 0.3 },
			p = { 0.22, 0.06, 0.06 },
			r = { 15, 0, -30 },
			c = LAITON,
			a = "Aile",
			j = { 0.16, -0.04, 0.06 },
		}, true)
		ajouter(l, {
			n = "Membrane",
			t = { 0.02, 0.18, 0.24 },
			p = { 0.235, 0.04, 0.08 },
			r = { 15, 0, -30 },
			c = { 255, 150, 60 },
			tr = 0.3,
			a = "Aile",
			j = { 0.16, -0.04, 0.06 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.08, 0.34 },
			p = { 0, -0.12, 0.44 },
			c = CUIVRE,
			a = "Queue",
			j = { 0, -0.12, 0.28 },
		})
	end, "Ecailles")

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : tournevis sur pattes qui vrille tout.
	definir("Visseur", 0.65, function(l)
		local tete = { 0, -0.1, 0 }
		ajouter(
			l,
			{ n = "Manche", t = { 0.4, 0.36, 0.4 }, p = { 0, -0.12, 0.02 }, c = { 220, 60, 50 } }
		)
		for i, x in { -0.14, 0, 0.14 } do
			ajouter(l, {
				n = "Rainure" .. i,
				t = { 0.04, 0.37, 0.41 },
				p = { x, -0.12, 0.02 },
				c = { 170, 40, 40 },
			})
		end
		ajouter(l, {
			n = "Tige",
			t = { 0.08, 0.08, 0.3 },
			p = { 0, -0.12, -0.32 },
			c = ACIER,
			a = "Antenne",
			j = { 0, -0.12, -0.18 },
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.12, 0.03, 0.06 },
			p = { 0, -0.12, -0.48 },
			c = ACIER,
			a = "Antenne",
			j = { 0, -0.12, -0.18 },
		})
		yeux(l, 0.1, 0.0, -0.185, 0.1, "Tete", tete)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.03, 0.02 },
			p = { 0.1, 0.1, -0.19 },
			r = { 0, 0, 25 },
			c = SOMBRE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.06, 0.2, 0.06 },
			p = { 0.12, -0.4, 0.02 },
			c = SOMBRE,
			a = "Patte",
			j = { 0.12, -0.3, 0.02 },
			ph = 0,
		}, true)
	end)

	-- Moyenne : piston rageur qui écrase en sautant.
	definir("Pistonard", 0.8, function(l)
		local piston = { 0, 0.0, 0 }
		ajouter(l, {
			n = "Cylindre",
			f = "Cylinder",
			t = { 0.5, 0.46, 0.46 },
			p = { 0, -0.1, 0 },
			r = { 0, 0, 90 },
			c = ACIER,
			m = "Metal",
		})
		ajouter(l, {
			n = "Bague",
			f = "Cylinder",
			t = { 0.06, 0.5, 0.5 },
			p = { 0, 0.14, 0 },
			r = { 0, 0, 90 },
			c = LAITON,
			m = "Metal",
		})
		ajouter(l, {
			n = "Tige",
			t = { 0.1, 0.2, 0.1 },
			p = { 0, 0.26, 0 },
			c = SOMBRE,
			a = "Antenne",
			j = piston,
		})
		ajouter(l, {
			n = "Marteau",
			t = { 0.36, 0.1, 0.36 },
			p = { 0, 0.38, 0 },
			c = SOMBRE,
			a = "Antenne",
			j = piston,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.06, 0.02 },
			p = { 0.1, 0.0, -0.235 },
			c = { 255, 80, 40 },
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.03, 0.02 },
			p = { 0.1, 0.06, -0.24 },
			r = { 0, 0, 25 },
			c = SOMBRE,
		}, true)
		ajouter(l, { n = "Bouche", t = { 0.16, 0.03, 0.02 }, p = { 0, -0.14, -0.235 }, c = SOMBRE })
		ajouter(l, {
			n = "Vapeur",
			f = "Ball",
			t = { 0.12, 0.12, 0.12 },
			p = { 0.3, 0.1, 0 },
			c = VAPEUR,
			tr = 0.3,
			a = "Antenne",
			j = piston,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.14, 0.08, 0.2 },
			p = { 0.14, -0.46, 0 },
			c = SOMBRE,
			a = "Patte",
			j = { 0.14, -0.4, 0 },
			ph = 0,
		}, true)
	end)

	-- Lointaine : broyeuse géante aux mâchoires d'engrenages.
	definir("Broyeurex", 0.95, function(l)
		local tete = { 0, 0.16, 0 }
		ajouter(
			l,
			{ n = "Coque", t = { 0.8, 0.5, 0.66 }, p = { 0, -0.1, 0.04 }, c = { 90, 85, 95 } }
		)
		ajouter(
			l,
			{ n = "Bande", t = { 0.82, 0.08, 0.68 }, p = { 0, 0.06, 0.04 }, c = { 255, 200, 40 } }
		)
		engrenage(
			l,
			"MachoireHaut",
			{ -0.2, 0.0, -0.3 },
			0.14,
			ACIER,
			"Machoire",
			{ -0.2, 0.0, -0.3 }
		)
		engrenage(l, "MachoireBas", { 0.2, 0.0, -0.3 }, 0.14, ACIER, "Machoire", { 0.2, 0.0, -0.3 })
		ajouter(l, {
			n = "Tete",
			t = { 0.5, 0.2, 0.4 },
			p = { 0, 0.26, 0.0 },
			c = { 90, 85, 95 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.06, 0.03 },
			p = { 0.14, 0.28, -0.215 },
			c = { 255, 60, 40 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(
			l,
			{ n = "Cheminee", t = { 0.1, 0.24, 0.1 }, p = { 0.22, 0.46, 0.14 }, c = SOMBRE },
			true
		)
		ajouter(l, {
			n = "Fumee",
			f = "Ball",
			t = { 0.16, 0.16, 0.16 },
			p = { 0.22, 0.64, 0.14 },
			c = { 120, 120, 130 },
			tr = 0.3,
			a = "Antenne",
			j = { 0.22, 0.58, 0.14 },
		}, true)
		ajouter(l, {
			n = "Chenille",
			t = { 0.16, 0.16, 0.7 },
			p = { 0.36, -0.42, 0.04 },
			c = { 40, 40, 45 },
			a = "Patte",
			j = { 0.36, -0.34, 0.04 },
			ph = 0,
		}, true)
	end)
end
