--!strict
-- Bestiaire du biome 15 : Jardin Zen (cerisiers, bambous, bassins de carpes).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local SAKURA = { 255, 190, 210 }
	local BAMBOU = { 140, 200, 90 }
	local JADE = { 90, 190, 140 }
	local LAQUE = { 200, 40, 50 }
	local PIERRE = { 150, 150, 145 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : carpe koï tachetée qui sautille.
	definir("Koinou", 0.55, function(l)
		ajouter(l, { n = "Corps", t = { 0.3, 0.3, 0.54 }, p = { 0, -0.22, 0.02 }, c = BLANC })
		ajouter(
			l,
			{ n = "Tache", t = { 0.31, 0.16, 0.18 }, p = { 0, -0.14, -0.08 }, c = { 255, 110, 50 } }
		)
		ajouter(l, { n = "Tache2", t = { 0.31, 0.12, 0.12 }, p = { 0, -0.24, 0.16 }, c = NOIR })
		yeux(l, 0.08, -0.16, -0.255, 0.07)
		ajouter(l, { n = "Bouche", t = { 0.08, 0.06, 0.02 }, p = { 0, -0.27, -0.26 }, c = ROSE })
		ajouter(l, {
			n = "Barbillon",
			t = { 0.02, 0.02, 0.1 },
			p = { 0.06, -0.3, -0.3 },
			r = { 20, 30, 0 },
			c = { 255, 180, 120 },
		}, true)
		ajouter(l, {
			n = "Nageoire",
			t = { 0.12, 0.03, 0.1 },
			p = { 0.18, -0.32, -0.04 },
			r = { 0, 0, -25 },
			c = { 255, 160, 110 },
			tr = 0.2,
			a = "Aile",
			j = { 0.15, -0.3, -0.04 },
		}, true)
		ajouter(l, {
			n = "Caudale",
			t = { 0.03, 0.26, 0.18 },
			p = { 0, -0.22, 0.36 },
			c = "Rarete",
			tr = 0.15,
			a = "Queue",
			j = { 0, -0.22, 0.28 },
		})
	end, "Ecailles")

	-- Commune : petit tanuki avec une feuille sur la tête.
	definir("Tanukou", 0.75, function(l)
		local brun = { 150, 110, 80 }
		local tete = { 0, 0.08, -0.04 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.38, 0.34 }, p = { 0, -0.27, 0.04 }, c = brun })
		ajouter(l, { n = "Ventre", t = { 0.28, 0.26, 0.03 }, p = { 0, -0.28, -0.135 }, c = CREME })
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.3, 0.3 },
			p = { 0, 0.12, -0.04 },
			c = brun,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Masque",
			t = { 0.3, 0.1, 0.03 },
			p = { 0, 0.14, -0.195 },
			c = { 70, 50, 40 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.14, -0.215, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Museau",
			t = { 0.12, 0.08, 0.04 },
			p = { 0, 0.04, -0.21 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.03, 0.02 },
			p = { 0, 0.07, -0.235 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.08, 0.04 },
			p = { 0.13, 0.3, -0.04 },
			c = { 70, 50, 40 },
			a = "Oreille",
			j = { 0.12, 0.26, -0.04 },
		}, true)
		ajouter(l, {
			n = "Feuille",
			t = { 0.16, 0.03, 0.1 },
			p = { 0, 0.29, -0.02 },
			r = { 0, 30, 10 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Queue",
			t = { 0.16, 0.16, 0.26 },
			p = { 0, -0.34, 0.3 },
			c = brun,
			a = "Queue",
			j = { 0, -0.34, 0.2 },
		})
		ajouter(l, {
			n = "Anneau",
			t = { 0.17, 0.05, 0.05 },
			p = { 0, -0.27, 0.32 },
			c = { 70, 50, 40 },
			a = "Queue",
			j = { 0, -0.34, 0.2 },
		})
		ajouter(l, {
			n = "Pied",
			t = { 0.1, 0.06, 0.12 },
			p = { 0.12, -0.47, -0.06 },
			c = { 70, 50, 40 },
			a = "Patte",
			j = { 0.12, -0.44, -0.04 },
			ph = 0,
		}, true)
	end)

	-- Rare : grue élégante à la calotte rouge.
	definir("Grulune", 0.98, function(l)
		local tete = { 0, 0.3, -0.06 }
		ajouter(l, { n = "Corps", t = { 0.26, 0.24, 0.4 }, p = { 0, -0.04, 0.06 }, c = BLANC })
		ajouter(l, {
			n = "Plumes",
			t = { 0.24, 0.12, 0.16 },
			p = { 0, -0.04, 0.3 },
			r = { -20, 0, 0 },
			c = NOIR,
			a = "Queue",
			j = { 0, -0.04, 0.24 },
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.2, 0.34 },
			p = { 0.15, -0.02, 0.08 },
			c = BLANC,
			a = "Aile",
			j = { 0.13, 0.06, 0.06 },
		}, true)
		ajouter(l, {
			n = "Cou",
			t = { 0.06, 0.34, 0.06 },
			p = { 0, 0.24, -0.08 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.12, 0.1, 0.14 },
			p = { 0, 0.44, -0.1 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Calotte",
			t = { 0.1, 0.03, 0.08 },
			p = { 0, 0.5, -0.1 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.03, 0.03, 0.16 },
			p = { 0, 0.43, -0.25 },
			c = { 220, 200, 120 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.025, 0.025, 0.02 },
			p = { 0.06, 0.45, -0.14 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.025, 0.36, 0.025 },
			p = { 0.05, -0.32, 0.06 },
			c = { 60, 60, 60 },
			a = "Patte",
			j = { 0.05, -0.14, 0.06 },
			ph = 0,
		}, true)
	end)

	-- Rare : panda roux à la queue annelée.
	definir("Pandaroux", 0.7, function(l)
		local roux = { 200, 90, 50 }
		local tete = { 0, -0.04, -0.18 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.26, 0.44 }, p = { 0, -0.24, 0.06 }, c = roux })
		pattes4(l, 0.1, -0.08, 0.2, { 0.08, 0.12, 0.08 }, { 60, 40, 35 })
		ajouter(l, {
			n = "Tete",
			t = { 0.34, 0.26, 0.24 },
			p = { 0, -0.02, -0.24 },
			c = roux,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Masque",
			t = { 0.26, 0.12, 0.03 },
			p = { 0, -0.06, -0.365 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.0, -0.375, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.03, 0.02 },
			p = { 0, -0.08, -0.385 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.08, 0.04 },
			p = { 0.13, 0.14, -0.22 },
			c = BLANC,
			a = "Oreille",
			j = { 0.12, 0.1, -0.22 },
		}, true)
		local queue = { 0, -0.22, 0.28 }
		for k = 0, 3 do
			ajouter(l, {
				n = "Queue" .. k,
				t = { 0.12, 0.12, 0.1 },
				p = { 0, -0.2 + k * 0.02, 0.32 + k * 0.1 },
				c = if k % 2 == 0 then roux else { 120, 60, 40 },
				a = "Queue",
				j = queue,
			})
		end
		ajouter(l, {
			n = "Bambou",
			t = { 0.03, 0.2, 0.03 },
			p = { 0.14, -0.14, -0.36 },
			r = { 0, 0, 20 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
	end, "Pelage")

	-- Épique : renarde à trois queues et flammes bleues.
	definir("Kitsunou", 0.8, function(l)
		local tete = { 0, 0.04, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.28, 0.26, 0.44 }, p = { 0, -0.18, 0.04 }, c = BLANC })
		pattes4(l, 0.09, -0.1, 0.2, { 0.07, 0.18, 0.07 }, BLANC)
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.24, 0.22 },
			p = { 0, 0.04, -0.28 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.12, 0.08, 0.1 },
			p = { 0, -0.02, -0.42 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.04, 0.03, 0.02 },
			p = { 0, 0.0, -0.475 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Trait",
			t = { 0.04, 0.08, 0.02 },
			p = { 0.08, 0.1, -0.395 },
			r = { 0, 0, 30 },
			c = LAQUE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.02, 0.02 },
			p = { 0.07, 0.06, -0.395 },
			r = { 0, 0, -10 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.14, 0.04 },
			p = { 0.1, 0.22, -0.26 },
			r = { 0, 0, -15 },
			c = BLANC,
			a = "Oreille",
			j = { 0.1, 0.16, -0.26 },
		}, true)
		ajouter(l, {
			n = "InterOreille",
			t = { 0.04, 0.08, 0.02 },
			p = { 0.1, 0.22, -0.28 },
			r = { 0, 0, -15 },
			c = LAQUE,
			a = "Oreille",
			j = { 0.1, 0.16, -0.26 },
		}, true)
		for i, x in { -0.14, 0, 0.14 } do
			ajouter(l, {
				n = "Queue" .. i,
				t = { 0.1, 0.32, 0.1 },
				p = { x, 0.0, 0.34 },
				r = { 30, 0, -x * 120 },
				c = BLANC,
				a = "Queue",
				j = { 0, -0.12, 0.26 },
				ph = i,
			})
			ajouter(l, {
				n = "Flamme" .. i,
				t = { 0.08, 0.1, 0.08 },
				p = { x * 1.6, 0.18, 0.42 },
				c = "Rarete",
				m = "Neon",
				a = "Queue",
				j = { 0, -0.12, 0.26 },
				ph = i,
			})
		end
	end)

	-- Épique : lanterne de papier qui flotte et sourit.
	definir("Lanternou", 0.85, function(l)
		local corps = { 0, -0.04, 0 }
		ajouter(l, {
			n = "Chapeau",
			t = { 0.28, 0.06, 0.28 },
			p = { 0, 0.26, 0 },
			c = NOIR,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Papier",
			f = "Ball",
			t = { 0.46, 0.5, 0.46 },
			p = { 0, 0.0, 0 },
			c = { 255, 120, 90 },
			a = "Antenne",
			j = corps,
		})
		for i, y in { -0.12, 0.0, 0.12 } do
			ajouter(l, {
				n = "Arete" .. i,
				t = { 0.47, 0.02, 0.47 },
				p = { 0, y, 0 },
				c = { 200, 70, 50 },
				a = "Antenne",
				j = corps,
			})
		end
		ajouter(l, {
			n = "Lueur",
			f = "Ball",
			t = { 0.3, 0.3, 0.3 },
			p = { 0, 0.0, 0 },
			c = "Rarete",
			m = "Neon",
			tr = 0.3,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "OeilG",
			t = { 0.05, 0.02, 0.02 },
			p = { -0.08, 0.04, -0.235 },
			c = NOIR,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "OeilD",
			t = { 0.05, 0.02, 0.02 },
			p = { 0.08, 0.04, -0.235 },
			c = NOIR,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Langue",
			t = { 0.08, 0.12, 0.02 },
			p = { 0, -0.1, -0.235 },
			c = ROSE,
			a = "Machoire",
			j = { 0, -0.06, -0.23 },
		})
		ajouter(l, {
			n = "Base",
			t = { 0.22, 0.05, 0.22 },
			p = { 0, -0.26, 0 },
			c = NOIR,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Pompon",
			t = { 0.04, 0.16, 0.04 },
			p = { 0, -0.37, 0 },
			c = { 255, 210, 80 },
			a = "Queue",
			j = { 0, -0.29, 0 },
		})
	end)

	-- Légendaire : dragon de bambou aux feuilles moustaches.
	definir("Dragonbambou", 0.85, function(l)
		local tete = { 0, 0.18, -0.2 }
		for k = 0, 3 do
			ajouter(l, {
				n = "Segment" .. k,
				t = { 0.18, 0.16, 0.16 },
				p = { math.sin(k * 1.4) * 0.1, -0.4 + k * 0.03, 0.36 - k * 0.14 },
				c = BAMBOU,
				a = "Queue",
				j = { 0, -0.36, 0.1 },
				ph = k,
			})
			ajouter(l, {
				n = "Noeud" .. k,
				t = { 0.19, 0.04, 0.17 },
				p = { math.sin(k * 1.4) * 0.1, -0.34 + k * 0.03, 0.36 - k * 0.14 },
				c = { 100, 160, 60 },
				a = "Queue",
				j = { 0, -0.36, 0.1 },
				ph = k,
			})
		end
		ajouter(l, { n = "Cou", t = { 0.14, 0.36, 0.14 }, p = { 0, -0.04, -0.16 }, c = BAMBOU })
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.2, 0.3 },
			p = { 0, 0.2, -0.26 },
			c = BAMBOU,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.18, 0.1, 0.1 },
			p = { 0, 0.16, -0.44 },
			c = { 170, 220, 120 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.09, 0.25, -0.415 },
			c = { 255, 220, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Moustache",
			t = { 0.24, 0.02, 0.06 },
			p = { 0.18, 0.14, -0.44 },
			r = { 0, 20, -10 },
			c = "Rarete",
			a = "Antenne",
			j = { 0.06, 0.14, -0.44 },
		}, true)
		ajouter(l, {
			n = "Bois",
			t = { 0.04, 0.14, 0.04 },
			p = { 0.08, 0.36, -0.2 },
			r = { 20, 0, -20 },
			c = { 100, 160, 60 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Feuille",
			t = { 0.1, 0.02, 0.05 },
			p = { 0.13, 0.42, -0.2 },
			r = { 0, 0, -30 },
			c = { 60, 160, 80 },
			a = "Tete",
			j = tete,
		}, true)
	end)

	-- Légendaire : tortue de jade portant un petit temple.
	definir("Tortujade", 0.85, function(l)
		local peau = { 140, 180, 120 }
		local tete = { 0, -0.26, -0.28 }
		ajouter(l, {
			n = "Carapace",
			t = { 0.52, 0.22, 0.56 },
			p = { 0, -0.28, 0.02 },
			c = JADE,
			m = "Glass",
		})
		ajouter(
			l,
			{ n = "Bord", t = { 0.56, 0.06, 0.6 }, p = { 0, -0.38, 0.02 }, c = { 60, 140, 100 } }
		)
		ajouter(l, { n = "Temple", t = { 0.2, 0.14, 0.2 }, p = { 0, -0.1, 0.02 }, c = LAQUE })
		ajouter(l, { n = "Toit", t = { 0.32, 0.04, 0.32 }, p = { 0, -0.01, 0.02 }, c = NOIR })
		ajouter(l, { n = "Toit2", t = { 0.2, 0.04, 0.2 }, p = { 0, 0.04, 0.02 }, c = NOIR })
		ajouter(l, {
			n = "Perle",
			f = "Ball",
			t = { 0.06, 0.06, 0.06 },
			p = { 0, 0.09, 0.02 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.18, 0.16, 0.18 },
			p = { 0, -0.28, -0.36 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.05, -0.25, -0.455, 0.05, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.06, 0.02, 0.02 },
			p = { 0, -0.32, -0.455 },
			c = { 60, 90, 60 },
			a = "Tete",
			j = tete,
		})
		pattes4(l, 0.2, -0.16, 0.2, { 0.1, 0.1, 0.12 }, peau)
	end)

	-- Mythique : esprit de cerisier aux pétales qui volent.
	definir("Sakurelle", 0.95, function(l)
		local tete = { 0, 0.12, 0 }
		ajouter(l, { n = "Robe", t = { 0.38, 0.42, 0.32 }, p = { 0, -0.28, 0 }, c = SAKURA })
		ajouter(l, { n = "Ceinture", t = { 0.4, 0.06, 0.34 }, p = { 0, -0.12, 0 }, c = LAQUE })
		ajouter(l, {
			n = "Noeud",
			t = { 0.16, 0.1, 0.06 },
			p = { 0, -0.12, 0.2 },
			c = LAQUE,
			a = "Queue",
			j = { 0, -0.12, 0.17 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.26, 0.26 },
			p = { 0, 0.04, 0 },
			c = { 255, 235, 235 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.04, -0.135, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Joue",
			t = { 0.05, 0.03, 0.02 },
			p = { 0.1, -0.02, -0.135 },
			c = ROSE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Cheveux",
			t = { 0.32, 0.14, 0.3 },
			p = { 0, 0.2, 0.02 },
			c = { 120, 60, 80 },
			a = "Tete",
			j = tete,
		})
		for i, x in { -0.12, 0.0, 0.12 } do
			ajouter(l, {
				n = "Fleur" .. i,
				t = { 0.08, 0.08, 0.04 },
				p = { x, 0.29, -0.06 },
				r = { 0, 0, 45 },
				c = if i == 2 then "Rarete" else SAKURA,
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Manche",
			t = { 0.14, 0.2, 0.14 },
			p = { 0.24, -0.2, 0 },
			r = { 0, 0, -20 },
			c = SAKURA,
			a = "Bras",
			j = { 0.18, -0.12, 0 },
			ph = 0,
		}, true)
		for i, pos in { { 0.34, 0.1, -0.1 }, { -0.36, 0.0, 0.06 }, { 0.26, 0.3, 0.1 } } do
			ajouter(l, {
				n = "Petale" .. i,
				t = { 0.06, 0.02, 0.04 },
				p = pos,
				r = { 0, i * 40, 30 },
				c = SAKURA,
				m = "Neon",
				a = "Antenne",
				j = { 0, 0, 0 },
				ph = i,
			})
		end
	end)

	-- Mythique : carpe dorée devenue dragon.
	definir("Carpedor", 0.85, function(l)
		local or_ = { 255, 200, 60 }
		local tete = { 0, 0.18, -0.2 }
		for k = 0, 3 do
			ajouter(l, {
				n = "Anneau" .. k,
				t = { 0.2 - k * 0.02, 0.18 - k * 0.02, 0.16 },
				p = { math.sin(k * 1.5) * 0.12, -0.36 + k * 0.05, 0.3 - k * 0.12 },
				c = or_,
				a = "Queue",
				j = { 0, -0.3, 0.06 },
				ph = k,
			})
		end
		ajouter(l, { n = "Cou", t = { 0.18, 0.34, 0.18 }, p = { 0, -0.04, -0.16 }, c = or_ })
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.24, 0.3 },
			p = { 0, 0.22, -0.26 },
			c = or_,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.22, 0.06, 0.22 },
			p = { 0, 0.08, -0.3 },
			c = { 255, 150, 60 },
			a = "Machoire",
			j = { 0, 0.1, -0.18 },
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.03 },
			p = { 0.1, 0.28, -0.41 },
			c = BLANC,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Barbillon",
			t = { 0.02, 0.02, 0.24 },
			p = { 0.1, 0.12, -0.46 },
			r = { 30, 20, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = { 0.08, 0.14, -0.38 },
		}, true)
		ajouter(l, {
			n = "Corne",
			t = { 0.04, 0.14, 0.04 },
			p = { 0.08, 0.4, -0.2 },
			r = { 30, 0, -15 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Nageoire",
			t = { 0.24, 0.03, 0.14 },
			p = { 0.2, 0.02, -0.12 },
			r = { 0, 0, -20 },
			c = { 255, 150, 60 },
			tr = 0.2,
			a = "Aile",
			j = { 0.1, 0.02, -0.12 },
		}, true)
	end, "Ecailles")

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : pousse de bambou grincheuse.
	definir("Bambougre", 0.85, function(l)
		local tete = { 0, 0.1, 0 }
		for k = 0, 2 do
			ajouter(l, {
				n = "Tronc" .. k,
				t = { 0.34, 0.26, 0.34 },
				p = { 0, -0.36 + k * 0.28, 0 },
				c = BAMBOU,
				a = if k == 2 then "Tete" else nil,
				j = if k == 2 then tete else nil,
			})
			ajouter(l, {
				n = "Noeud" .. k,
				t = { 0.38, 0.04, 0.38 },
				p = { 0, -0.23 + k * 0.28, 0 },
				c = { 100, 160, 60 },
			})
		end
		yeux(l, 0.08, 0.0, -0.175, 0.08)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.1, 0.03, 0.02 },
			p = { 0.08, 0.08, -0.18 },
			r = { 0, 0, 25 },
			c = { 50, 90, 40 },
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.14, 0.03, 0.02 }, p = { 0, -0.1, -0.175 }, c = { 50, 90, 40 } }
		)
		ajouter(l, {
			n = "Feuille",
			t = { 0.26, 0.03, 0.08 },
			p = { 0.24, 0.3, 0 },
			r = { 0, 0, 25 },
			c = { 60, 160, 80 },
			a = "Bras",
			j = { 0.16, 0.26, 0 },
			ph = 0,
		}, true)
	end)

	-- Moyenne : boule d'ogre rouge à cornes, toute ronde.
	definir("Oniboule", 0.75, function(l)
		local rouge = { 220, 70, 60 }
		local corps = { 0, -0.14, 0 }
		ajouter(l, {
			n = "Boule",
			f = "Ball",
			t = { 0.66, 0.6, 0.6 },
			p = { 0, -0.18, 0 },
			c = rouge,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.06, 0.16, 0.06 },
			p = { 0.14, 0.2, -0.04 },
			r = { 0, 0, -15 },
			c = CREME,
			a = "Antenne",
			j = corps,
		}, true)
		ajouter(l, {
			n = "Cheveux",
			t = { 0.3, 0.08, 0.3 },
			p = { 0, 0.12, 0.04 },
			c = NOIR,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.08, 0.03 },
			p = { 0.11, -0.1, -0.29 },
			c = { 255, 240, 80 },
			m = "Neon",
			a = "Antenne",
			j = corps,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.14, 0.04, 0.03 },
			p = { 0.11, -0.02, -0.29 },
			r = { 0, 0, 25 },
			c = NOIR,
			a = "Antenne",
			j = corps,
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.24, 0.06, 0.03 },
			p = { 0, -0.26, -0.29 },
			c = { 60, 20, 20 },
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.04, 0.06, 0.02 },
			p = { 0.08, -0.22, -0.3 },
			c = BLANC,
			a = "Antenne",
			j = corps,
		}, true)
		ajouter(l, {
			n = "Massue",
			t = { 0.1, 0.4, 0.1 },
			p = { 0.38, -0.1, -0.04 },
			r = { 0, 0, -20 },
			c = { 120, 90, 60 },
			a = "Bras",
			j = { 0.3, -0.2, 0 },
			ph = 0,
		})
		ajouter(l, {
			n = "Pied",
			t = { 0.12, 0.06, 0.14 },
			p = { 0.14, -0.47, 0 },
			c = rouge,
			a = "Patte",
			j = { 0.14, -0.42, 0 },
			ph = 0,
		}, true)
	end)

	-- Lointaine : lion-gardien de pierre qui se réveille.
	definir("Komapierre", 0.95, function(l)
		local tete = { 0, 0.18, -0.12 }
		ajouter(
			l,
			{ n = "Socle", t = { 0.7, 0.14, 0.7 }, p = { 0, -0.43, 0 }, c = { 120, 120, 115 } }
		)
		ajouter(l, { n = "Corps", t = { 0.5, 0.46, 0.5 }, p = { 0, -0.13, 0.06 }, c = PIERRE })
		ajouter(l, {
			n = "Criniere",
			t = { 0.6, 0.5, 0.2 },
			p = { 0, 0.22, -0.06 },
			c = { 130, 130, 125 },
			a = "Tete",
			j = tete,
		})
		for i, y in { 0.06, 0.22, 0.38 } do
			ajouter(l, {
				n = "Boucle" .. i,
				t = { 0.1, 0.1, 0.1 },
				p = { 0.28, y, -0.06 },
				r = { 0, 0, 45 },
				c = { 115, 115, 110 },
				a = "Tete",
				j = tete,
			}, true)
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.4, 0.34, 0.26 },
			p = { 0, 0.22, -0.24 },
			c = PIERRE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.06, 0.03 },
			p = { 0.1, 0.28, -0.385 },
			c = { 90, 255, 180 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.04, 0.04 },
			p = { 0.1, 0.34, -0.38 },
			r = { 0, 0, 25 },
			c = { 100, 100, 95 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Gueule",
			t = { 0.24, 0.08, 0.03 },
			p = { 0, 0.12, -0.385 },
			c = { 50, 50, 50 },
			a = "Machoire",
			j = { 0, 0.14, -0.3 },
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.04, 0.06, 0.02 },
			p = { 0.08, 0.14, -0.39 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Boule",
			f = "Ball",
			t = { 0.2, 0.2, 0.2 },
			p = { 0.2, -0.28, -0.3 },
			c = JADE,
			a = "Bras",
			j = { 0.2, -0.2, -0.2 },
			ph = 0,
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.14, 0.24, 0.14 },
			p = { 0.2, -0.24, -0.2 },
			c = PIERRE,
			a = "Bras",
			j = { 0.2, -0.12, -0.2 },
			ph = 0,
		}, true)
	end)
end
