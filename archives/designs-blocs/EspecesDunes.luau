--!strict
-- Bestiaire du biome 3 : Dunes Dorées (sable, cactus, turquoise, or).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
-- Ce fichier reçoit les outils de Bestiaire (definir, ajouter, yeux, pattes4).
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE = o.BLANC, o.NOIR, o.ROSE

	local TERRE = { 210, 110, 70 }
	local TURQUOISE = { 60, 200, 190 }
	local OR = { 255, 205, 50 }
	local CACTUS = { 90, 180, 90 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : scarabée turquoise à corne.
	definir("Scarabille", 0.55, function(l)
		local tete = { 0, -0.22, -0.2 }
		ajouter(
			l,
			{ n = "Carapace", t = { 0.5, 0.26, 0.56 }, p = { 0, -0.18, 0.06 }, c = TURQUOISE }
		)
		ajouter(
			l,
			{ n = "Fente", t = { 0.02, 0.265, 0.5 }, p = { 0, -0.18, 0.08 }, c = { 30, 110, 110 } }
		)
		ajouter(l, {
			n = "Reflet",
			t = { 0.1, 0.02, 0.24 },
			p = { 0.13, -0.045, 0.02 },
			c = { 170, 250, 240 },
		}, true)
		ajouter(
			l,
			{ n = "Dessous", t = { 0.44, 0.08, 0.5 }, p = { 0, -0.34, 0.06 }, c = { 40, 60, 70 } }
		)
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.2, 0.2 },
			p = { 0, -0.22, -0.3 },
			c = { 40, 60, 70 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.06, 0.2, 0.06 },
			p = { 0, -0.06, -0.38 },
			r = { 30, 0, 0 },
			c = OR,
			m = "Foil",
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, -0.2, -0.405, 0.09, "Tete", tete)
		for i, z in { -0.12, 0.06, 0.24 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.04, 0.16, 0.04 },
				p = { 0.27, -0.42, z },
				r = { 0, 0, 30 },
				c = { 40, 60, 70 },
				a = "Patte",
				j = { 0.24, -0.36, z },
				ph = i * 2,
			}, true)
		end
	end, "Ecailles")

	-- Commune : petit cactus en pot, fleur rose sur la tête.
	definir("Cactounet", 0.7, function(l)
		local fleur = { 0, 0.1, 0 }
		ajouter(l, { n = "Pot", t = { 0.42, 0.14, 0.42 }, p = { 0, -0.43, 0 }, c = TERRE })
		ajouter(
			l,
			{ n = "Rebord", t = { 0.46, 0.05, 0.46 }, p = { 0, -0.36, 0 }, c = { 230, 140, 90 } }
		)
		ajouter(l, { n = "Corps", t = { 0.34, 0.5, 0.34 }, p = { 0, -0.1, 0 }, c = CACTUS })
		ajouter(l, {
			n = "Cote",
			t = { 0.04, 0.46, 0.02 },
			p = { 0.08, -0.1, -0.175 },
			c = { 70, 150, 70 },
		}, true)
		ajouter(l, {
			n = "BrasCourt",
			t = { 0.1, 0.08, 0.1 },
			p = { 0.21, -0.14, 0 },
			c = CACTUS,
			a = "Bras",
			j = { 0.17, -0.14, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "BrasHaut",
			t = { 0.1, 0.18, 0.1 },
			p = { 0.28, -0.03, 0 },
			c = CACTUS,
			a = "Bras",
			j = { 0.17, -0.14, 0 },
			ph = 0,
		}, true)
		yeux(l, 0.07, 0.0, -0.185, 0.09)
		ajouter(
			l,
			{ n = "Joue", t = { 0.05, 0.03, 0.02 }, p = { 0.12, -0.07, -0.18 }, c = ROSE },
			true
		)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.06, 0.025, 0.02 }, p = { 0, -0.08, -0.18 }, c = { 50, 90, 50 } }
		)
		for i, pos in { { 0.18, 0.08, -0.06 }, { -0.18, -0.2, 0.05 }, { 0.12, -0.28, 0.17 } } do
			ajouter(l, { n = "Epine" .. i, t = { 0.02, 0.04, 0.02 }, p = pos, c = BLANC })
		end
		ajouter(l, {
			n = "Petale",
			t = { 0.18, 0.06, 0.18 },
			p = { 0, 0.18, 0 },
			r = { 0, 45, 0 },
			c = { 255, 120, 180 },
			a = "Antenne",
			j = fleur,
		})
		ajouter(l, {
			n = "CoeurFleur",
			t = { 0.07, 0.04, 0.07 },
			p = { 0, 0.22, 0 },
			c = { 255, 230, 80 },
			a = "Antenne",
			j = fleur,
		})
	end)

	-- Rare : fennec aux immenses oreilles.
	definir("Fennecil", 0.78, function(l)
		local fauve = { 245, 205, 145 }
		local tete = { 0, 0, -0.2 }
		local queue = { 0, -0.1, 0.3 }
		ajouter(l, { n = "Corps", t = { 0.38, 0.3, 0.56 }, p = { 0, -0.22, 0.04 }, c = fauve })
		ajouter(l, { n = "Poitrail", t = { 0.24, 0.2, 0.03 }, p = { 0, -0.2, -0.245 }, c = BLANC })
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.28, 0.3 },
			p = { 0, 0.06, -0.3 },
			c = fauve,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.14, 0.1, 0.12 },
			p = { 0, 0.0, -0.5 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Nez",
			t = { 0.05, 0.04, 0.03 },
			p = { 0, 0.04, -0.565 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.09, 0.11, -0.455, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.14, 0.3, 0.05 },
			p = { 0.15, 0.36, -0.26 },
			r = { 0, 0, -15 },
			c = fauve,
			a = "Oreille",
			j = { 0.12, 0.2, -0.26 },
		}, true)
		ajouter(l, {
			n = "OreilleInterieur",
			t = { 0.08, 0.22, 0.02 },
			p = { 0.15, 0.35, -0.29 },
			r = { 0, 0, -15 },
			c = ROSE,
			a = "Oreille",
			j = { 0.12, 0.2, -0.26 },
		}, true)
		ajouter(
			l,
			{ n = "Foulard", t = { 0.38, 0.06, 0.32 }, p = { 0, -0.08, -0.22 }, c = "Rarete" }
		)
		pattes4(l, 0.12, -0.16, 0.22, { 0.08, 0.14, 0.08 }, fauve)
		ajouter(l, {
			n = "Queue",
			t = { 0.16, 0.16, 0.34 },
			p = { 0, -0.1, 0.44 },
			r = { -15, 0, 0 },
			c = fauve,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.14, 0.14, 0.1 },
			p = { 0, -0.04, 0.63 },
			r = { -15, 0, 0 },
			c = { 90, 60, 40 },
			a = "Queue",
			j = queue,
		})
	end)

	-- Rare : lézard à collerette.
	definir("Lezardo", 0.55, function(l)
		local rouge = { 230, 120, 60 }
		local tete = { 0, -0.24, -0.24 }
		local queue = { 0, -0.34, 0.32 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.2, 0.6 }, p = { 0, -0.32, 0.04 }, c = rouge })
		ajouter(
			l,
			{ n = "Ventre", t = { 0.24, 0.04, 0.5 }, p = { 0, -0.43, 0.04 }, c = { 250, 220, 140 } }
		)
		for i, z in { -0.12, 0.04, 0.2 } do
			ajouter(l, {
				n = "Tache" .. i,
				t = { 0.08, 0.02, 0.08 },
				p = { 0.07, -0.215, z },
				c = { 255, 220, 80 },
			}, true)
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.18, 0.24 },
			p = { 0, -0.22, -0.36 },
			c = rouge,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, -0.18, -0.485, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Bouche",
			t = { 0.14, 0.02, 0.02 },
			p = { 0, -0.27, -0.485 },
			c = { 120, 50, 30 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Collerette",
			t = { 0.22, 0.34, 0.03 },
			p = { 0.14, -0.14, -0.26 },
			r = { 0, 0, -20 },
			c = TURQUOISE,
			a = "Oreille",
			j = { 0.06, -0.2, -0.26 },
		}, true)
		ajouter(l, {
			n = "Rayon",
			t = { 0.03, 0.3, 0.035 },
			p = { 0.16, -0.14, -0.265 },
			r = { 0, 0, -20 },
			c = OR,
			a = "Oreille",
			j = { 0.06, -0.2, -0.26 },
		}, true)
		ajouter(l, {
			n = "PatteAv",
			t = { 0.16, 0.08, 0.1 },
			p = { 0.2, -0.44, -0.16 },
			c = rouge,
			a = "Patte",
			j = { 0.14, -0.42, -0.16 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "PatteAr",
			t = { 0.16, 0.08, 0.1 },
			p = { 0.2, -0.44, 0.22 },
			c = rouge,
			a = "Patte",
			j = { 0.14, -0.42, 0.22 },
			ph = math.pi,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.12, 0.1, 0.36 },
			p = { 0, -0.36, 0.5 },
			c = rouge,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.07, 0.07, 0.2 },
			p = { 0, -0.37, 0.76 },
			c = rouge,
			a = "Queue",
			j = queue,
		})
	end, "Ecailles")

	-- Épique : dromadaire endormi, tapis brodé sur la bosse.
	definir("Dromadune", 0.92, function(l)
		local chameau = { 215, 165, 105 }
		local tete = { 0, 0.06, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.32, 0.62 }, p = { 0, 0.0, 0.06 }, c = chameau })
		ajouter(l, { n = "Bosse", t = { 0.3, 0.18, 0.3 }, p = { 0, 0.24, 0.1 }, c = chameau })
		ajouter(l, { n = "Tapis", t = { 0.44, 0.04, 0.36 }, p = { 0, 0.17, 0.1 }, c = "Rarete" })
		ajouter(
			l,
			{ n = "Frange", t = { 0.45, 0.03, 0.04 }, p = { 0, 0.15, -0.09 }, c = OR, m = "Foil" }
		)
		ajouter(
			l,
			{ n = "Frange2", t = { 0.45, 0.03, 0.04 }, p = { 0, 0.15, 0.29 }, c = OR, m = "Foil" }
		)
		ajouter(l, {
			n = "Cou",
			t = { 0.14, 0.3, 0.14 },
			p = { 0, 0.18, -0.28 },
			r = { 20, 0, 0 },
			c = chameau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.2, 0.18, 0.3 },
			p = { 0, 0.36, -0.38 },
			c = chameau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Babine",
			t = { 0.16, 0.08, 0.06 },
			p = { 0, 0.31, -0.54 },
			c = { 190, 140, 90 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilPaupiere",
			t = { 0.07, 0.03, 0.03 },
			p = { 0.07, 0.4, -0.535 },
			c = { 120, 80, 50 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Cil",
			t = { 0.07, 0.015, 0.03 },
			p = { 0.07, 0.38, -0.54 },
			r = { 0, 0, -10 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.06, 0.04 },
			p = { 0.1, 0.47, -0.32 },
			c = chameau,
			a = "Oreille",
			j = { 0.08, 0.45, -0.32 },
		}, true)
		pattes4(l, 0.14, -0.14, 0.28, { 0.1, 0.34, 0.1 }, chameau)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.16, 0.04 },
			p = { 0, -0.04, 0.38 },
			c = { 150, 100, 60 },
			a = "Queue",
			j = { 0, 0.04, 0.37 },
		})
	end)

	-- Épique : scorpion tout mignon, dard lumineux.
	definir("Scorpiou", 0.62, function(l)
		local violet = { 125, 95, 205 }
		local tete = { 0, -0.36, -0.2 }
		local queue = { 0, -0.34, 0.2 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.16, 0.44 }, p = { 0, -0.36, 0.0 }, c = violet })
		ajouter(
			l,
			{ n = "Plaque", t = { 0.3, 0.03, 0.34 }, p = { 0, -0.27, 0.0 }, c = { 160, 130, 235 } }
		)
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.14, 0.2 },
			p = { 0, -0.34, -0.3 },
			c = violet,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, -0.3, -0.405, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Pince",
			t = { 0.08, 0.06, 0.2 },
			p = { 0.22, -0.36, -0.4 },
			c = violet,
			a = "Bras",
			j = { 0.18, -0.36, -0.3 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Doigt",
			t = { 0.14, 0.08, 0.14 },
			p = { 0.26, -0.36, -0.54 },
			c = { 160, 130, 235 },
			a = "Bras",
			j = { 0.18, -0.36, -0.3 },
			ph = 0,
		}, true)
		for i, z in { -0.12, 0.02, 0.16 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.16, 0.04, 0.04 },
				p = { 0.26, -0.44, z },
				r = { 0, 0, -25 },
				c = violet,
				a = "Patte",
				j = { 0.2, -0.4, z },
				ph = i * 2,
			}, true)
		end
		ajouter(l, {
			n = "Queue1",
			t = { 0.1, 0.1, 0.14 },
			p = { 0, -0.3, 0.28 },
			c = violet,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Queue2",
			t = { 0.09, 0.14, 0.09 },
			p = { 0, -0.18, 0.36 },
			c = violet,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Queue3",
			t = { 0.08, 0.14, 0.08 },
			p = { 0, -0.04, 0.38 },
			c = violet,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Queue4",
			t = { 0.08, 0.08, 0.12 },
			p = { 0, 0.08, 0.32 },
			c = violet,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Dard",
			t = { 0.07, 0.12, 0.07 },
			p = { 0, 0.12, 0.22 },
			r = { -40, 0, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Queue",
			j = queue,
		})
	end, "Ecailles")

	-- Légendaire : chat-sphinx coiffé du némès bleu et or.
	definir("Sphinxou", 0.82, function(l)
		local pelage = { 230, 190, 120 }
		local bleu = { 40, 80, 180 }
		local tete = { 0, 0.0, -0.18 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.34, 0.56 }, p = { 0, -0.23, 0.08 }, c = pelage })
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.28, 0.26 },
			p = { 0, 0.1, -0.26 },
			c = pelage,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Nemes",
			t = { 0.42, 0.24, 0.3 },
			p = { 0, 0.17, -0.2 },
			c = bleu,
			a = "Tete",
			j = tete,
		})
		for i, y in { 0.1, 0.18, 0.26 } do
			ajouter(l, {
				n = "Raie" .. i,
				t = { 0.43, 0.03, 0.31 },
				p = { 0, y, -0.2 },
				c = OR,
				m = "Foil",
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Pan",
			t = { 0.08, 0.28, 0.12 },
			p = { 0.2, -0.04, -0.28 },
			c = bleu,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Visage",
			t = { 0.24, 0.2, 0.04 },
			p = { 0, 0.07, -0.39 },
			c = pelage,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.05, 0.02 },
			p = { 0.06, 0.1, -0.415 },
			c = { 60, 200, 120 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Khol",
			t = { 0.1, 0.015, 0.02 },
			p = { 0.07, 0.125, -0.42 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Nez",
			t = { 0.05, 0.035, 0.02 },
			p = { 0, 0.05, -0.415 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Joyau",
			t = { 0.06, 0.08, 0.03 },
			p = { 0, 0.26, -0.37 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.12, 0.08, 0.26 },
			p = { 0.12, -0.46, -0.24 },
			c = pelage,
			a = "Patte",
			j = { 0.12, -0.42, -0.12 },
			ph = 0,
		}, true)
		ajouter(
			l,
			{ n = "Collier", t = { 0.32, 0.05, 0.08 }, p = { 0, -0.06, -0.2 }, c = OR, m = "Foil" }
		)
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.05, 0.3 },
			p = { 0.1, -0.42, 0.42 },
			r = { 0, -25, 0 },
			c = pelage,
			a = "Queue",
			j = { 0, -0.42, 0.34 },
		})
	end)

	-- Légendaire : tortue à carapace-pyramide et pointe d'or.
	definir("Tortusable", 0.72, function(l)
		local peau = { 170, 150, 100 }
		local pierre = { 205, 165, 95 }
		local tete = { 0, -0.2, -0.32 }
		ajouter(l, { n = "Base", t = { 0.62, 0.14, 0.66 }, p = { 0, -0.24, 0.04 }, c = pierre })
		ajouter(
			l,
			{ n = "Etage", t = { 0.46, 0.14, 0.5 }, p = { 0, -0.1, 0.04 }, c = { 220, 180, 110 } }
		)
		ajouter(l, { n = "Sommet", t = { 0.3, 0.14, 0.34 }, p = { 0, 0.04, 0.04 }, c = pierre })
		ajouter(
			l,
			{ n = "Pointe", t = { 0.14, 0.1, 0.16 }, p = { 0, 0.16, 0.04 }, c = OR, m = "Foil" }
		)
		ajouter(l, {
			n = "Joyau",
			t = { 0.06, 0.06, 0.06 },
			p = { 0, 0.23, 0.04 },
			r = { 0, 45, 0 },
			c = "Rarete",
			m = "Neon",
		})
		for i, x in { -0.14, 0.0, 0.14 } do
			ajouter(l, {
				n = "Signe" .. i,
				t = { 0.06, 0.06, 0.02 },
				p = { x, -0.1, -0.215 },
				c = { 150, 100, 50 },
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.2, 0.24 },
			p = { 0, -0.2, -0.42 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bandeau",
			t = { 0.23, 0.04, 0.25 },
			p = { 0, -0.13, -0.42 },
			c = TURQUOISE,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, -0.19, -0.545, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.08, 0.02, 0.02 },
			p = { 0, -0.26, -0.545 },
			c = { 90, 70, 40 },
			a = "Tete",
			j = tete,
		})
		pattes4(l, 0.24, -0.22, 0.3, { 0.14, 0.16, 0.14 }, peau)
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.06, 0.12 },
			p = { 0, -0.28, 0.44 },
			c = peau,
			a = "Queue",
			j = { 0, -0.28, 0.4 },
		})
	end)

	-- Mythique : ibis solaire à l'auréole lumineuse.
	definir("Ibisoleil", 0.95, function(l)
		local plume = { 250, 250, 245 }
		local tete = { 0, 0.16, -0.12 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.32, 0.44 }, p = { 0, -0.02, 0.06 }, c = plume })
		ajouter(l, {
			n = "Aile",
			t = { 0.05, 0.28, 0.42 },
			p = { 0.17, 0.0, 0.08 },
			c = plume,
			a = "Aile",
			j = { 0.15, 0.12, 0.06 },
		}, true)
		ajouter(l, {
			n = "BoutAile",
			t = { 0.055, 0.1, 0.16 },
			p = { 0.17, -0.08, 0.26 },
			c = NOIR,
			a = "Aile",
			j = { 0.15, 0.12, 0.06 },
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.32, 0.04 },
			p = { 0.07, -0.34, 0.04 },
			c = NOIR,
			a = "Patte",
			j = { 0.07, -0.18, 0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Cou",
			t = { 0.08, 0.24, 0.08 },
			p = { 0, 0.22, -0.14 },
			c = plume,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.16, 0.16, 0.18 },
			p = { 0, 0.36, -0.18 },
			c = plume,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.04, 0.04, 0.3 },
			p = { 0, 0.32, -0.4 },
			r = { 25, 0, 0 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.04, 0.02 },
			p = { 0.06, 0.38, -0.27 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		for i = 1, 8 do
			local angle = (i / 8) * 2 * math.pi
			ajouter(l, {
				n = "Rayon" .. i,
				t = { 0.06, 0.06, 0.03 },
				p = { math.cos(angle) * 0.18, 0.36 + math.sin(angle) * 0.18, -0.06 },
				r = { 0, 0, math.deg(angle) },
				c = OR,
				m = "Neon",
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Joyau",
			t = { 0.06, 0.06, 0.03 },
			p = { 0, 0.45, -0.18 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		for i, x in { -0.06, 0.0, 0.06 } do
			ajouter(l, {
				n = "Plume" .. i,
				t = { 0.05, 0.04, 0.24 },
				p = { x, 0.02, 0.36 },
				r = { -20, -x * 200, 0 },
				c = OR,
				m = "Neon",
				a = "Queue",
				j = { 0, 0.0, 0.26 },
			})
		end
	end)

	-- Mythique : petit génie bleu sorti de sa lampe.
	definir("Djinnoule", 0.9, function(l)
		local esprit = { 90, 170, 255 }
		local tete = { 0, 0.18, 0 }
		local fumee = { 0, -0.14, 0 }
		ajouter(
			l,
			{ n = "Torse", t = { 0.34, 0.3, 0.3 }, p = { 0, 0.02, 0 }, c = esprit, tr = 0.1 }
		)
		ajouter(
			l,
			{ n = "Ceinture", t = { 0.35, 0.05, 0.31 }, p = { 0, -0.1, 0 }, c = OR, m = "Foil" }
		)
		ajouter(l, {
			n = "Fumee1",
			t = { 0.26, 0.16, 0.26 },
			p = { 0, -0.2, 0.02 },
			c = esprit,
			tr = 0.2,
			a = "Queue",
			j = fumee,
		})
		ajouter(l, {
			n = "Fumee2",
			t = { 0.18, 0.14, 0.18 },
			p = { 0, -0.34, 0.06 },
			r = { 0, 20, 0 },
			c = esprit,
			tr = 0.3,
			a = "Queue",
			j = fumee,
		})
		ajouter(l, {
			n = "Fumee3",
			t = { 0.1, 0.1, 0.1 },
			p = { 0, -0.45, 0.1 },
			c = esprit,
			tr = 0.4,
			a = "Queue",
			j = fumee,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.28, 0.28 },
			p = { 0, 0.31, -0.02 },
			c = esprit,
			tr = 0.05,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.33, -0.165, 0.1, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.1, 0.025, 0.02 },
			p = { 0, 0.24, -0.165 },
			c = { 30, 60, 140 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Turban",
			t = { 0.34, 0.14, 0.32 },
			p = { 0, 0.49, -0.02 },
			c = { 150, 70, 200 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Joyau",
			t = { 0.07, 0.07, 0.03 },
			p = { 0, 0.49, -0.185 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Plume",
			t = { 0.04, 0.16, 0.04 },
			p = { 0.06, 0.62, 0.0 },
			r = { 0, 0, -20 },
			c = OR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.1, 0.24, 0.1 },
			p = { 0.22, 0.02, -0.02 },
			c = esprit,
			tr = 0.1,
			a = "Bras",
			j = { 0.2, 0.12, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Bracelet",
			t = { 0.11, 0.04, 0.11 },
			p = { 0.22, -0.06, -0.02 },
			c = OR,
			m = "Foil",
			a = "Bras",
			j = { 0.2, 0.12, -0.02 },
			ph = 0,
		}, true)
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : petite momie, un œil vert qui dépasse des bandelettes.
	definir("Momiotte", 0.8, function(l)
		local bande = { 235, 225, 200 }
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Corps", t = { 0.5, 0.52, 0.4 }, p = { 0, -0.18, 0 }, c = bande })
		for i, y in { -0.3, -0.16, -0.02 } do
			ajouter(l, {
				n = "Bande" .. i,
				t = { 0.51, 0.04, 0.41 },
				p = { 0, y, 0 },
				r = { 0, 0, (i - 2) * 6 },
				c = { 200, 190, 160 },
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.44, 0.36, 0.36 },
			p = { 0, 0.26, -0.02 },
			c = bande,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "BandeTete",
			t = { 0.45, 0.04, 0.37 },
			p = { 0, 0.34, -0.02 },
			r = { 0, 0, -8 },
			c = { 200, 190, 160 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.08, 0.03 },
			p = { 0.1, 0.24, -0.2 },
			c = { 120, 255, 120 },
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Fente",
			t = { 0.12, 0.02, 0.02 },
			p = { -0.1, 0.24, -0.205 },
			c = { 60, 50, 40 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.12, 0.12, 0.36 },
			p = { 0.18, 0.02, -0.3 },
			c = bande,
			a = "Bras",
			j = { 0.18, 0.02, -0.12 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Lambeau",
			t = { 0.04, 0.16, 0.02 },
			p = { 0.16, -0.08, -0.38 },
			c = { 200, 190, 160 },
			a = "Bras",
			j = { 0.18, 0.02, -0.12 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.14, 0.14, 0.14 },
			p = { 0.12, -0.43, 0 },
			c = bande,
			a = "Patte",
			j = { 0.12, -0.36, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Moyenne : vautour chauve et ronchon.
	definir("Vautourne", 0.78, function(l)
		local brun = { 90, 60, 50 }
		local tete = { 0, 0.22, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.5, 0.46, 0.56 }, p = { 0, -0.04, 0.04 }, c = brun })
		ajouter(l, {
			n = "Collerette",
			t = { 0.54, 0.14, 0.4 },
			p = { 0, 0.2, -0.12 },
			c = { 240, 235, 225 },
		})
		ajouter(l, {
			n = "Cou",
			t = { 0.12, 0.14, 0.12 },
			p = { 0, 0.28, -0.24 },
			c = { 230, 150, 150 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.22, 0.22 },
			p = { 0, 0.38, -0.32 },
			c = { 235, 160, 160 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.12, 0.12 },
			p = { 0, 0.34, -0.47 },
			c = { 255, 210, 80 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Crochet",
			t = { 0.06, 0.06, 0.04 },
			p = { 0, 0.27, -0.52 },
			c = { 220, 160, 50 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.04, 0.02 },
			p = { 0.07, 0.42, -0.435 },
			c = { 255, 80, 40 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.08, 0.025, 0.02 },
			p = { 0.07, 0.46, -0.435 },
			r = { 0, 0, 20 },
			c = brun,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.06, 0.4, 0.56 },
			p = { 0.3, 0.0, 0.08 },
			c = brun,
			a = "Aile",
			j = { 0.26, 0.18, 0.04 },
		}, true)
		ajouter(l, {
			n = "Remige",
			t = { 0.065, 0.12, 0.2 },
			p = { 0.3, -0.18, 0.28 },
			c = { 50, 35, 30 },
			a = "Aile",
			j = { 0.26, 0.18, 0.04 },
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.06, 0.18, 0.06 },
			p = { 0.12, -0.36, 0.04 },
			c = { 255, 210, 80 },
			a = "Patte",
			j = { 0.12, -0.28, 0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Serre",
			t = { 0.12, 0.04, 0.14 },
			p = { 0.12, -0.47, 0.0 },
			c = { 255, 210, 80 },
			a = "Patte",
			j = { 0.12, -0.28, 0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.3, 0.08, 0.24 },
			p = { 0, -0.12, 0.4 },
			c = { 60, 40, 35 },
			a = "Queue",
			j = { 0, -0.12, 0.3 },
		})
	end)

	-- Lointaine : golem de grès aux yeux et à la rune turquoise.
	definir("Golemsable", 0.82, function(l)
		local gres = { 215, 170, 110 }
		local gresFonce = { 175, 130, 80 }
		local tete = { 0, 0.3, 0 }
		ajouter(l, { n = "Torse", t = { 0.76, 0.6, 0.54 }, p = { 0, 0.02, 0 }, c = gres })
		ajouter(l, {
			n = "Rune",
			t = { 0.16, 0.16, 0.03 },
			p = { 0, 0.06, -0.28 },
			r = { 0, 0, 45 },
			c = TURQUOISE,
			m = "Neon",
		})
		ajouter(l, {
			n = "Fissure",
			t = { 0.03, 0.26, 0.02 },
			p = { -0.2, -0.08, -0.275 },
			r = { 0, 0, 15 },
			c = gresFonce,
		})
		ajouter(l, {
			n = "Fissure2",
			t = { 0.2, 0.03, 0.02 },
			p = { 0.2, 0.18, -0.275 },
			r = { 0, 0, -10 },
			c = gresFonce,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.34, 0.28, 0.32 },
			p = { 0, 0.46, -0.04 },
			c = gres,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.06, 0.03 },
			p = { 0.08, 0.48, -0.205 },
			c = TURQUOISE,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Front",
			t = { 0.36, 0.06, 0.06 },
			p = { 0, 0.55, -0.19 },
			c = gresFonce,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.24, 0.5, 0.26 },
			p = { 0.52, 0.0, -0.02 },
			c = gres,
			a = "Bras",
			j = { 0.52, 0.22, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Poing",
			t = { 0.3, 0.26, 0.3 },
			p = { 0.52, -0.32, -0.04 },
			c = gresFonce,
			a = "Bras",
			j = { 0.52, 0.22, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.26, 0.22, 0.28 },
			p = { 0.2, -0.38, 0 },
			c = gresFonce,
			a = "Patte",
			j = { 0.2, -0.27, 0 },
			ph = math.pi,
		}, true)
		ajouter(l, { n = "Cactus", t = { 0.08, 0.2, 0.08 }, p = { -0.3, 0.42, 0.1 }, c = CACTUS })
		ajouter(
			l,
			{ n = "CactusBras", t = { 0.12, 0.06, 0.06 }, p = { -0.26, 0.44, 0.1 }, c = CACTUS }
		)
		ajouter(l, {
			n = "Fleur",
			t = { 0.06, 0.04, 0.06 },
			p = { -0.3, 0.54, 0.1 },
			c = { 255, 120, 180 },
		})
	end)
end
