--!strict
-- Bestiaire du biome 19 : Ferme Joyeuse (granges rouges, foin, moulins).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, CREME = o.BLANC, o.NOIR, o.CREME

	local ROUGE = { 210, 60, 50 }
	local FOIN = { 240, 205, 100 }
	local ORANGE = { 255, 150, 50 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : poussin dodu de la basse-cour.
	definir("Poulichou", 0.55, function(l)
		local tete = { 0, -0.1, -0.06 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.36, 0.42 }, p = { 0, -0.3, 0.04 }, c = BLANC })
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.24 },
			p = { 0, -0.02, -0.1 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Crete",
			t = { 0.04, 0.1, 0.14 },
			p = { 0, 0.14, -0.1 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.06, 0.08 },
			p = { 0, -0.04, -0.26 },
			c = ORANGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Barbillon",
			t = { 0.04, 0.06, 0.02 },
			p = { 0, -0.1, -0.23 },
			c = ROUGE,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.02, -0.225, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.2, 0.26 },
			p = { 0.22, -0.28, 0.04 },
			c = CREME,
			a = "Aile",
			j = { 0.2, -0.2, 0.02 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.16, 0.14, 0.06 },
			p = { 0, -0.14, 0.26 },
			r = { -30, 0, 0 },
			c = BLANC,
			a = "Queue",
			j = { 0, -0.2, 0.24 },
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.08, 0.08 },
			p = { 0.08, -0.46, -0.02 },
			c = ORANGE,
			a = "Patte",
			j = { 0.08, -0.42, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Commune : petit cochon rose qui adore la boue.
	definir("Groinou", 0.55, function(l)
		local rose = { 255, 180, 190 }
		local tete = { 0, -0.2, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.44, 0.34, 0.5 }, p = { 0, -0.26, 0.06 }, c = rose })
		ajouter(
			l,
			{ n = "Boue", t = { 0.2, 0.04, 0.16 }, p = { 0.1, -0.08, 0.12 }, c = { 130, 90, 60 } }
		)
		pattes4(l, 0.14, -0.08, 0.22, { 0.1, 0.1, 0.1 }, rose)
		ajouter(l, {
			n = "Tete",
			t = { 0.34, 0.28, 0.24 },
			p = { 0, -0.18, -0.28 },
			c = rose,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Groin",
			t = { 0.14, 0.1, 0.06 },
			p = { 0, -0.22, -0.42 },
			c = { 255, 140, 160 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Narine",
			t = { 0.03, 0.04, 0.02 },
			p = { 0.03, -0.22, -0.455 },
			c = { 150, 70, 90 },
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.08, -0.1, -0.405, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.08, 0.04 },
			p = { 0.13, -0.02, -0.26 },
			r = { 30, 0, -20 },
			c = rose,
			a = "Oreille",
			j = { 0.12, -0.06, -0.26 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.04, 0.1 },
			p = { 0, -0.18, 0.34 },
			r = { 0, 0, 45 },
			c = "Rarete",
			a = "Queue",
			j = { 0, -0.18, 0.3 },
		})
	end)

	-- Rare : petite vache tachetée à la cloche.
	definir("Vachou", 0.75, function(l)
		local tete = { 0, 0.0, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.34, 0.56 }, p = { 0, -0.12, 0.06 }, c = BLANC })
		for i, pos in { { 0.201, -0.08, -0.04 }, { 0.201, -0.16, 0.18 }, { 0.0, 0.051, 0.1 } } do
			ajouter(l, {
				n = "Tache" .. i,
				t = if i == 3 then { 0.14, 0.02, 0.14 } else { 0.02, 0.12, 0.14 },
				p = pos,
				c = NOIR,
			}, i < 3)
		end
		pattes4(l, 0.13, -0.12, 0.26, { 0.1, 0.2, 0.1 }, BLANC)
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.24 },
			p = { 0, 0.0, -0.32 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Mufle",
			t = { 0.24, 0.12, 0.08 },
			p = { 0, -0.08, -0.47 },
			c = { 255, 190, 200 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Narine",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.05, -0.07, -0.515 },
			c = { 150, 80, 90 },
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.08, 0.06, -0.445, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Corne",
			t = { 0.04, 0.08, 0.04 },
			p = { 0.1, 0.16, -0.3 },
			r = { 0, 0, -20 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Cloche",
			t = { 0.1, 0.1, 0.08 },
			p = { 0, -0.18, -0.3 },
			c = "Rarete",
			m = "Foil",
			a = "Antenne",
			j = { 0, -0.12, -0.3 },
		})
		ajouter(l, {
			n = "Queue",
			t = { 0.03, 0.22, 0.03 },
			p = { 0, -0.06, 0.35 },
			r = { 15, 0, 0 },
			c = NOIR,
			a = "Queue",
			j = { 0, 0.04, 0.34 },
		})
	end)

	-- Rare : chevreau qui grimpe partout.
	definir("Chevrinou", 0.75, function(l)
		local robe = { 220, 210, 190 }
		local tete = { 0, 0.08, -0.18 }
		ajouter(l, { n = "Corps", t = { 0.28, 0.26, 0.44 }, p = { 0, -0.12, 0.06 }, c = robe })
		pattes4(l, 0.09, -0.08, 0.22, { 0.06, 0.24, 0.06 }, robe)
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.2, 0.24 },
			p = { 0, 0.12, -0.26 },
			c = robe,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Barbiche",
			t = { 0.06, 0.1, 0.04 },
			p = { 0, -0.02, -0.36 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.03, 0.02 },
			p = { 0.08, 0.16, -0.385 },
			c = { 220, 170, 60 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Corne",
			t = { 0.04, 0.14, 0.04 },
			p = { 0.06, 0.28, -0.2 },
			r = { 30, 0, -10 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.12, 0.04, 0.04 },
			p = { 0.15, 0.16, -0.22 },
			r = { 0, 0, -20 },
			c = robe,
			a = "Oreille",
			j = { 0.11, 0.16, -0.22 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.08, 0.04 },
			p = { 0, 0.02, 0.29 },
			r = { -30, 0, 0 },
			c = robe,
			a = "Queue",
			j = { 0, 0.0, 0.28 },
		})
	end)

	-- Épique : oie ronde au nœud papillon.
	definir("Oieronde", 0.85, function(l)
		local tete = { 0, 0.28, -0.1 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.38, 0.5 }, p = { 0, -0.24, 0.06 }, c = BLANC })
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.24, 0.36 },
			p = { 0.23, -0.2, 0.08 },
			c = { 230, 230, 240 },
			a = "Aile",
			j = { 0.21, -0.1, 0.06 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.2, 0.1, 0.1 },
			p = { 0, -0.1, 0.34 },
			r = { -30, 0, 0 },
			c = BLANC,
			a = "Queue",
			j = { 0, -0.14, 0.3 },
		})
		ajouter(l, {
			n = "Cou",
			t = { 0.1, 0.34, 0.1 },
			p = { 0, 0.08, -0.12 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, { n = "Noeud", t = { 0.2, 0.08, 0.04 }, p = { 0, 0.0, -0.18 }, c = "Rarete" })
		ajouter(l, {
			n = "Tete",
			t = { 0.16, 0.14, 0.18 },
			p = { 0, 0.3, -0.14 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.05, 0.12 },
			p = { 0, 0.28, -0.28 },
			c = ORANGE,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.05, 0.33, -0.235, 0.05, "Tete", tete)
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.1, 0.12 },
			p = { 0.1, -0.45, -0.02 },
			c = ORANGE,
			a = "Patte",
			j = { 0.1, -0.4, 0 },
			ph = 0,
		}, true)
	end)

	-- Épique : ponette à la crinière tressée.
	definir("Ponette", 0.85, function(l)
		local robe = { 180, 120, 80 }
		local tete = { 0, 0.12, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.32, 0.28, 0.5 }, p = { 0, -0.1, 0.06 }, c = robe })
		pattes4(l, 0.1, -0.1, 0.24, { 0.08, 0.24, 0.08 }, robe)
		ajouter(l, {
			n = "Cou",
			t = { 0.14, 0.24, 0.14 },
			p = { 0, 0.08, -0.2 },
			r = { -15, 0, 0 },
			c = robe,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.2, 0.2, 0.3 },
			p = { 0, 0.26, -0.3 },
			c = robe,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.16, 0.12, 0.08 },
			p = { 0, 0.2, -0.47 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.06, 0.02 },
			p = { 0.105, 0.3, -0.36 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		for k = 0, 2 do
			ajouter(l, {
				n = "Tresse" .. k,
				t = { 0.07, 0.08, 0.08 },
				p = { 0, 0.36 - k * 0.08, -0.16 + k * 0.06 },
				c = if k == 1 then "Rarete" else FOIN,
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Oreille",
			t = { 0.05, 0.08, 0.04 },
			p = { 0.07, 0.4, -0.24 },
			c = robe,
			a = "Oreille",
			j = { 0.07, 0.36, -0.24 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.24, 0.08 },
			p = { 0, -0.04, 0.36 },
			r = { 25, 0, 0 },
			c = FOIN,
			a = "Queue",
			j = { 0, 0.04, 0.32 },
		})
	end, "Pelage")

	-- Légendaire : jeune taureau à l'anneau d'or.
	definir("Taureaudor", 0.8, function(l)
		local poil = { 90, 60, 50 }
		local tete = { 0, 0.02, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.46, 0.4, 0.58 }, p = { 0, -0.1, 0.08 }, c = poil })
		ajouter(l, { n = "Bosse", t = { 0.36, 0.12, 0.24 }, p = { 0, 0.14, -0.04 }, c = poil })
		pattes4(l, 0.15, -0.1, 0.28, { 0.12, 0.2, 0.12 }, poil)
		ajouter(l, {
			n = "Tete",
			t = { 0.34, 0.3, 0.26 },
			p = { 0, 0.02, -0.34 },
			c = poil,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Mufle",
			t = { 0.24, 0.12, 0.06 },
			p = { 0, -0.08, -0.49 },
			c = { 200, 150, 140 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Anneau",
			t = { 0.1, 0.1, 0.02 },
			p = { 0, -0.14, -0.53 },
			c = "Rarete",
			m = "Foil",
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.09, 0.08, -0.475, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Corne",
			t = { 0.2, 0.06, 0.06 },
			p = { 0.22, 0.14, -0.32 },
			r = { 0, 0, 25 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.24, 0.04 },
			p = { 0, -0.02, 0.4 },
			r = { 15, 0, 0 },
			c = poil,
			a = "Queue",
			j = { 0, 0.08, 0.38 },
		})
	end, "Pelage")

	-- Légendaire : coq royal à la queue en éventail.
	definir("Coqroyal", 0.9, function(l)
		local tete = { 0, 0.18, -0.1 }
		ajouter(
			l,
			{ n = "Corps", t = { 0.34, 0.36, 0.38 }, p = { 0, -0.16, 0.02 }, c = { 200, 90, 40 } }
		)
		ajouter(l, {
			n = "Plastron",
			t = { 0.24, 0.24, 0.03 },
			p = { 0, -0.12, -0.175 },
			c = { 60, 140, 90 },
		})
		for i, c in { { 40, 120, 80 }, { 30, 60, 140 }, { 40, 120, 80 } } do
			ajouter(l, {
				n = "Plume" .. i,
				t = { 0.06, 0.34, 0.08 },
				p = { (i - 2) * 0.1, 0.06, 0.28 },
				r = { -20, 0, (i - 2) * 25 },
				c = c,
				a = "Queue",
				j = { 0, -0.1, 0.22 },
				ph = i,
			})
		end
		ajouter(l, {
			n = "Cou",
			t = { 0.16, 0.16, 0.16 },
			p = { 0, 0.08, -0.08 },
			c = ORANGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.2, 0.18, 0.2 },
			p = { 0, 0.22, -0.12 },
			c = { 200, 90, 40 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Crete",
			t = { 0.04, 0.12, 0.18 },
			p = { 0, 0.36, -0.12 },
			c = ROUGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Couronne",
			t = { 0.12, 0.06, 0.12 },
			p = { 0, 0.44, -0.12 },
			r = { 0, 45, 0 },
			c = "Rarete",
			m = "Foil",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.06, 0.05, 0.08 },
			p = { 0, 0.2, -0.26 },
			c = FOIN,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.04, 0.02 },
			p = { 0.105, 0.24, -0.14 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.16, 0.04 },
			p = { 0.08, -0.42, 0.0 },
			c = FOIN,
			a = "Patte",
			j = { 0.08, -0.34, 0 },
			ph = 0,
		}, true)
	end)

	-- Mythique : petit tracteur vivant qui klaxonne.
	definir("Tracteurou", 0.8, function(l)
		ajouter(l, { n = "Capot", t = { 0.36, 0.26, 0.36 }, p = { 0, -0.18, -0.16 }, c = ROUGE })
		ajouter(l, {
			n = "Calandre",
			t = { 0.28, 0.2, 0.02 },
			p = { 0, -0.18, -0.345 },
			c = { 60, 60, 70 },
		})
		yeux(l, 0.09, -0.06, -0.36, 0.08)
		ajouter(l, { n = "Sourire", t = { 0.12, 0.02, 0.02 }, p = { 0, -0.24, -0.36 }, c = BLANC })
		ajouter(l, { n = "Cabine", t = { 0.36, 0.34, 0.26 }, p = { 0, 0.0, 0.16 }, c = ROUGE })
		ajouter(l, {
			n = "Vitre",
			t = { 0.3, 0.18, 0.02 },
			p = { 0, 0.04, 0.02 },
			c = { 160, 220, 255 },
			tr = 0.3,
		})
		ajouter(l, { n = "Toit", t = { 0.42, 0.05, 0.32 }, p = { 0, 0.19, 0.16 }, c = BLANC })
		ajouter(
			l,
			{ n = "Pot", t = { 0.06, 0.18, 0.06 }, p = { 0.1, 0.0, -0.22 }, c = { 60, 60, 70 } }
		)
		ajouter(l, {
			n = "Fumee",
			f = "Ball",
			t = { 0.1, 0.1, 0.1 },
			p = { 0.1, 0.14, -0.22 },
			c = "Rarete",
			tr = 0.2,
			a = "Antenne",
			j = { 0.1, 0.08, -0.22 },
		})
		ajouter(l, {
			n = "GrandeRoue",
			f = "Cylinder",
			t = { 0.1, 0.4, 0.4 },
			p = { 0.22, -0.3, 0.16 },
			c = { 50, 50, 55 },
			a = "Patte",
			j = { 0.22, -0.3, 0.16 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "PetiteRoue",
			f = "Cylinder",
			t = { 0.08, 0.22, 0.22 },
			p = { 0.2, -0.39, -0.22 },
			c = { 50, 50, 55 },
			a = "Patte",
			j = { 0.2, -0.39, -0.22 },
			ph = 0,
		}, true)
	end)

	-- Mythique : esprit du moulin aux ailes qui tournent.
	definir("Mouliventou", 0.95, function(l)
		local ailes = { 0, 0.18, -0.18 }
		ajouter(l, { n = "Tour", t = { 0.36, 0.56, 0.34 }, p = { 0, -0.2, 0 }, c = CREME })
		ajouter(l, { n = "Toit", t = { 0.42, 0.14, 0.4 }, p = { 0, 0.14, 0 }, c = ROUGE })
		ajouter(l, { n = "Pointe", t = { 0.2, 0.1, 0.2 }, p = { 0, 0.25, 0 }, c = ROUGE })
		ajouter(
			l,
			{ n = "Porte", t = { 0.12, 0.16, 0.02 }, p = { 0, -0.4, -0.175 }, c = { 120, 80, 55 } }
		)
		yeux(l, 0.08, -0.12, -0.18, 0.07)
		ajouter(l, {
			n = "Moyeu",
			t = { 0.08, 0.08, 0.06 },
			p = { 0, 0.18, -0.2 },
			c = { 120, 80, 55 },
			a = "Antenne",
			j = ailes,
		})
		for k = 0, 3 do
			local a = math.rad(k * 90 + 45)
			ajouter(l, {
				n = "Aile" .. k,
				t = { 0.08, 0.34, 0.02 },
				p = { math.sin(a) * 0.2, 0.18 + math.cos(a) * 0.2, -0.22 },
				r = { 0, 0, -k * 90 - 45 },
				c = if k == 0 then "Rarete" else BLANC,
				a = "Antenne",
				j = ailes,
			})
		end
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : corbeau chapardeur.
	definir("Corbinard", 0.6, function(l)
		local plume = { 40, 40, 55 }
		local tete = { 0, -0.04, -0.12 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.32, 0.44 }, p = { 0, -0.24, 0.06 }, c = plume })
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.24 },
			p = { 0, 0.0, -0.16 },
			c = plume,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.06, 0.16 },
			p = { 0, -0.04, -0.34 },
			c = FOIN,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.08, 0.04, -0.285 },
			c = { 255, 220, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.07, 0.025, 0.02 },
			p = { 0.08, 0.09, -0.29 },
			r = { 0, 0, 25 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Graine",
			t = { 0.05, 0.03, 0.05 },
			p = { 0, -0.08, -0.42 },
			c = FOIN,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.36, 0.04, 0.26 },
			p = { 0.32, -0.16, 0.04 },
			r = { 0, 0, 20 },
			c = plume,
			a = "Aile",
			j = { 0.16, -0.2, 0.04 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.18, 0.04, 0.2 },
			p = { 0, -0.24, 0.36 },
			c = plume,
			a = "Queue",
			j = { 0, -0.24, 0.28 },
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.1, 0.04 },
			p = { 0.07, -0.45, 0.04 },
			c = FOIN,
			a = "Patte",
			j = { 0.07, -0.4, 0.04 },
			ph = 0,
		}, true)
	end)

	-- Moyenne : chèvre folle qui fonce cornes en avant.
	definir("Biqueboum", 0.8, function(l)
		local robe = { 150, 140, 130 }
		local tete = { 0, -0.04, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.34, 0.56 }, p = { 0, -0.1, 0.08 }, c = robe })
		pattes4(l, 0.13, -0.1, 0.28, { 0.09, 0.22, 0.09 }, robe)
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.26, 0.28 },
			p = { 0, -0.02, -0.36 },
			r = { 20, 0, 0 },
			c = robe,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.06, 0.06, 0.24 },
			p = { 0.1, 0.1, -0.38 },
			r = { 20, 15, 0 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.05, 0.02 },
			p = { 0.08, 0.02, -0.505 },
			c = { 255, 80, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Barbiche",
			t = { 0.08, 0.14, 0.04 },
			p = { 0, -0.2, -0.48 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Fumee",
			f = "Ball",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.06, -0.1, -0.56 },
			c = BLANC,
			tr = 0.4,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.1, 0.05 },
			p = { 0, 0.1, 0.38 },
			r = { -30, 0, 0 },
			c = robe,
			a = "Queue",
			j = { 0, 0.06, 0.36 },
		})
	end)

	-- Lointaine : moissonneuse géante aux pales dentelées.
	definir("Moissogre", 0.85, function(l)
		local corps = { 60, 150, 60 }
		local rabatteur = { 0, -0.24, -0.38 }
		ajouter(l, { n = "Corps", t = { 0.7, 0.44, 0.56 }, p = { 0, -0.04, 0.12 }, c = corps })
		ajouter(l, { n = "Cabine", t = { 0.36, 0.3, 0.3 }, p = { 0, 0.32, 0.12 }, c = corps })
		ajouter(l, {
			n = "Vitre",
			t = { 0.3, 0.16, 0.02 },
			p = { 0, 0.34, -0.035 },
			c = { 255, 80, 60 },
			m = "Neon",
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.06, 0.02 },
			p = { 0.08, 0.34, -0.045 },
			c = { 255, 240, 80 },
			m = "Neon",
		}, true)
		ajouter(
			l,
			{ n = "Barre", t = { 0.84, 0.06, 0.06 }, p = { 0, -0.24, -0.32 }, c = { 220, 200, 60 } }
		)
		for k = 0, 3 do
			local a = math.rad(k * 90)
			ajouter(l, {
				n = "Pale" .. k,
				t = { 0.8, 0.04, 0.16 },
				p = { 0, -0.24 + math.sin(a) * 0.14, -0.38 - math.cos(a) * 0.1 },
				r = { -k * 90, 0, 0 },
				c = { 230, 220, 120 },
				a = "Machoire",
				j = rabatteur,
			})
		end
		ajouter(l, {
			n = "Roue",
			f = "Cylinder",
			t = { 0.12, 0.34, 0.34 },
			p = { 0.36, -0.33, 0.2 },
			c = { 40, 40, 45 },
			a = "Patte",
			j = { 0.36, -0.33, 0.2 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Paille",
			f = "Ball",
			t = { 0.16, 0.12, 0.16 },
			p = { 0.2, 0.2, 0.42 },
			c = FOIN,
			a = "Antenne",
			j = { 0.2, 0.16, 0.4 },
		})
	end)
end
