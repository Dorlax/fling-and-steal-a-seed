--!strict
-- Bestiaire du biome 5 : Volcan Ardent (roche noire, lave, braises).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR = o.BLANC, o.NOIR

	local ROCHE = { 60, 50, 55 }
	local ROCHE_CLAIRE = { 95, 80, 85 }
	local LAVE = { 255, 120, 30 }
	local BRAISE = { 255, 210, 70 }
	local ROUGE = { 220, 50, 40 }

	-- Fissures de lave sur une face avant (z) d'un bloc.
	local function fissures(
		l: any,
		positions: { { number } },
		z: number,
		role: string?,
		j: { number }?
	)
		for i, p in positions do
			ajouter(l, {
				n = "Fissure" .. i,
				t = { p[3], 0.03, 0.02 },
				p = { p[1], p[2], z },
				r = { 0, 0, p[4] },
				c = LAVE,
				m = "Neon",
				a = role,
				j = j,
			})
		end
	end

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : petit esprit de braise en forme de flamme.
	definir("Braisillon", 0.75, function(l)
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.42, 0.4 }, p = { 0, -0.24, 0 }, c = LAVE })
		ajouter(l, {
			n = "Coeur",
			t = { 0.28, 0.28, 0.03 },
			p = { 0, -0.26, -0.205 },
			c = BRAISE,
			m = "Neon",
		})
		ajouter(l, {
			n = "Flamme1",
			t = { 0.3, 0.2, 0.3 },
			p = { 0, 0.04, 0 },
			c = { 255, 150, 40 },
			m = "Neon",
			a = "Antenne",
			j = tete,
		})
		ajouter(l, {
			n = "Flamme2",
			t = { 0.18, 0.18, 0.18 },
			p = { 0.04, 0.22, 0.02 },
			r = { 0, 0, -12 },
			c = BRAISE,
			m = "Neon",
			a = "Antenne",
			j = tete,
		})
		ajouter(l, {
			n = "Flamme3",
			t = { 0.08, 0.12, 0.08 },
			p = { 0.08, 0.36, 0.02 },
			r = { 0, 0, -20 },
			c = { 255, 250, 200 },
			m = "Neon",
			a = "Antenne",
			j = tete,
		})
		yeux(l, 0.08, -0.16, -0.225, 0.1)
		ajouter(l, {
			n = "Bouche",
			t = { 0.08, 0.03, 0.02 },
			p = { 0, -0.28, -0.225 },
			c = { 120, 30, 10 },
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.06, 0.12, 0.06 },
			p = { 0.24, -0.24, 0 },
			c = LAVE,
			a = "Bras",
			j = { 0.22, -0.19, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.12, 0.06, 0.14 },
			p = { 0.11, -0.47, -0.04 },
			c = ROUGE,
			a = "Patte",
			j = { 0.11, -0.42, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Commune : caillou volcanique aux fissures de lave.
	definir("Caillouflam", 0.58, function(l)
		ajouter(l, { n = "Roche", t = { 0.6, 0.46, 0.54 }, p = { 0, -0.26, 0 }, c = ROCHE })
		ajouter(
			l,
			{ n = "Dessus", t = { 0.4, 0.12, 0.36 }, p = { 0, 0.02, 0.02 }, c = ROCHE_CLAIRE }
		)
		fissures(
			l,
			{ { -0.18, -0.36, 0.14, 30 }, { 0.2, -0.16, 0.12, -20 }, { 0.14, -0.4, 0.1, 10 } },
			-0.275
		)
		yeux(l, 0.1, -0.16, -0.28, 0.11)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.1, 0.03, 0.02 }, p = { 0, -0.29, -0.28 }, c = LAVE, m = "Neon" }
		)
		ajouter(l, {
			n = "Braise",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.1, 0.11, 0.0 },
			c = BRAISE,
			m = "Neon",
			a = "Antenne",
			j = { 0.1, 0.08, 0 },
		})
		ajouter(l, {
			n = "Pied",
			t = { 0.14, 0.05, 0.16 },
			p = { 0.16, -0.48, -0.06 },
			c = ROCHE_CLAIRE,
			a = "Patte",
			j = { 0.16, -0.46, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Rare : crabe à carapace de roche et pinces de lave.
	definir("Crabraise", 0.52, function(l)
		local tete = { 0, -0.24, -0.1 }
		ajouter(l, { n = "Carapace", t = { 0.6, 0.22, 0.46 }, p = { 0, -0.24, 0.04 }, c = ROUGE })
		ajouter(l, { n = "Dos", t = { 0.42, 0.08, 0.32 }, p = { 0, -0.09, 0.04 }, c = ROCHE })
		fissures(l, { { -0.1, -0.05, 0.12, 15 }, { 0.12, -0.05, 0.1, -25 } }, 0.04)
		ajouter(l, {
			n = "Pedoncule",
			t = { 0.03, 0.12, 0.03 },
			p = { 0.1, -0.08, -0.16 },
			c = ROUGE,
			a = "Antenne",
			j = { 0.1, -0.14, -0.16 },
		}, true)
		ajouter(l, {
			n = "OeilBoule",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.1, 0.0, -0.17 },
			c = BLANC,
			a = "Antenne",
			j = { 0.1, -0.14, -0.16 },
		}, true)
		ajouter(l, {
			n = "Pupille",
			t = { 0.04, 0.04, 0.02 },
			p = { 0.1, 0.0, -0.215 },
			c = NOIR,
			a = "Antenne",
			j = { 0.1, -0.14, -0.16 },
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.12, 0.025, 0.02 },
			p = { 0, -0.26, -0.195 },
			c = { 90, 20, 15 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.16, 0.06, 0.06 },
			p = { 0.34, -0.26, -0.18 },
			r = { 0, 30, 0 },
			c = ROUGE,
			a = "Bras",
			j = { 0.28, -0.26, -0.12 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pince",
			t = { 0.14, 0.12, 0.16 },
			p = { 0.4, -0.24, -0.3 },
			c = LAVE,
			m = "Neon",
			a = "Bras",
			j = { 0.28, -0.26, -0.12 },
			ph = 0,
		}, true)
		for i, z in { -0.04, 0.1, 0.24 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.18, 0.04, 0.04 },
				p = { 0.34, -0.42, z },
				r = { 0, 0, -30 },
				c = ROUGE,
				a = "Patte",
				j = { 0.28, -0.38, z },
				ph = i * 2,
			}, true)
		end
	end, "Ecailles")

	-- Rare : chauve-souris des cendres aux ailes rougeoyantes.
	definir("Chauvesouffre", 0.7, function(l)
		local suie = { 70, 55, 70 }
		local tete = { 0, 0.04, -0.06 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.36, 0.3 }, p = { 0, -0.04, 0.02 }, c = suie })
		ajouter(l, {
			n = "Ventre",
			t = { 0.2, 0.24, 0.03 },
			p = { 0, -0.06, -0.135 },
			c = { 120, 90, 100 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.24, 0.26 },
			p = { 0, 0.24, -0.04 },
			c = suie,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.26, -0.175, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Croc",
			t = { 0.03, 0.04, 0.02 },
			p = { 0.04, 0.16, -0.175 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.16, 0.05 },
			p = { 0.11, 0.42, -0.04 },
			r = { 0, 0, -15 },
			c = suie,
			a = "Oreille",
			j = { 0.1, 0.35, -0.04 },
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.42, 0.3, 0.03 },
			p = { 0.34, 0.04, 0.04 },
			r = { 0, 0, 10 },
			c = { 150, 50, 50 },
			a = "Aile",
			j = { 0.14, 0.08, 0.04 },
		}, true)
		ajouter(l, {
			n = "Nervure",
			t = { 0.4, 0.03, 0.035 },
			p = { 0.34, 0.08, 0.04 },
			r = { 0, 0, 10 },
			c = LAVE,
			m = "Neon",
			a = "Aile",
			j = { 0.14, 0.08, 0.04 },
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.05, 0.28, 0.05 },
			p = { 0.07, -0.36, 0.02 },
			c = suie,
			a = "Patte",
			j = { 0.07, -0.22, 0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Joyau",
			t = { 0.06, 0.06, 0.03 },
			p = { 0, 0.04, -0.16 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
		})
	end)

	-- Épique : rhinocéros de cendre à la corne d'obsidienne.
	definir("Rhinocendre", 0.7, function(l)
		local cendre = { 120, 110, 115 }
		local tete = { 0, 0.02, -0.28 }
		ajouter(l, { n = "Corps", t = { 0.56, 0.44, 0.72 }, p = { 0, -0.06, 0.08 }, c = cendre })
		ajouter(l, { n = "Plaque", t = { 0.5, 0.06, 0.4 }, p = { 0, 0.18, 0.08 }, c = ROCHE })
		fissures(l, { { 0.29, -0.04, 0.16, 20 }, { -0.29, -0.08, 0.14, -15 } }, 0.0)
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.32, 0.34 },
			p = { 0, 0.04, -0.42 },
			c = cendre,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.08, 0.24, 0.08 },
			p = { 0, 0.24, -0.56 },
			r = { -25, 0, 0 },
			c = { 30, 20, 40 },
			m = "Glass",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "PetiteCorne",
			t = { 0.06, 0.1, 0.06 },
			p = { 0, 0.22, -0.44 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.12, 0.1, -0.595, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.12, 0.05 },
			p = { 0.15, 0.25, -0.32 },
			c = cendre,
			a = "Oreille",
			j = { 0.15, 0.2, -0.32 },
		}, true)
		pattes4(l, 0.2, -0.16, 0.32, { 0.15, 0.22, 0.15 }, ROCHE)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.14, 0.04 },
			p = { 0, 0.02, 0.46 },
			c = cendre,
			a = "Queue",
			j = { 0, 0.08, 0.45 },
		})
	end, "Ecailles")

	-- Épique : serpent de lave enroulé.
	definir("Serpenlave", 0.68, function(l)
		local noir = { 45, 35, 40 }
		local tete = { 0, 0.1, -0.12 }
		local queue = { 0, -0.36, 0.2 }
		ajouter(l, { n = "Spire1", t = { 0.6, 0.16, 0.6 }, p = { 0, -0.42, 0.04 }, c = noir })
		ajouter(
			l,
			{ n = "Spire2", t = { 0.46, 0.14, 0.46 }, p = { 0, -0.28, 0.04 }, c = { 60, 45, 50 } }
		)
		ajouter(l, {
			n = "Anneau1",
			t = { 0.61, 0.03, 0.61 },
			p = { 0, -0.38, 0.04 },
			c = LAVE,
			m = "Neon",
		})
		ajouter(l, {
			n = "Anneau2",
			t = { 0.47, 0.03, 0.47 },
			p = { 0, -0.24, 0.04 },
			c = LAVE,
			m = "Neon",
		})
		ajouter(l, {
			n = "Cou",
			t = { 0.14, 0.3, 0.14 },
			p = { 0, -0.06, -0.06 },
			c = noir,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.16, 0.3 },
			p = { 0, 0.14, -0.14 },
			c = noir,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.17, -0.295, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Langue",
			t = { 0.04, 0.02, 0.1 },
			p = { 0, 0.08, -0.33 },
			c = { 255, 80, 120 },
			a = "Machoire",
			j = { 0, 0.1, -0.28 },
		})
		ajouter(l, {
			n = "Crete",
			t = { 0.03, 0.1, 0.2 },
			p = { 0, 0.26, -0.1 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Queue",
			t = { 0.1, 0.08, 0.26 },
			p = { 0.2, -0.46, 0.38 },
			r = { 0, 30, 0 },
			c = noir,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Hochet",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.28, -0.46, 0.5 },
			c = BRAISE,
			m = "Neon",
			a = "Queue",
			j = queue,
		})
	end, "Ecailles")

	-- Légendaire : taureau de feu à la crinière de flammes.
	definir("Taurobraise", 0.78, function(l)
		local tete = { 0, 0.06, -0.28 }
		ajouter(l, { n = "Corps", t = { 0.56, 0.46, 0.7 }, p = { 0, -0.04, 0.08 }, c = ROUGE })
		ajouter(
			l,
			{ n = "Bosse", t = { 0.44, 0.14, 0.3 }, p = { 0, 0.24, -0.08 }, c = { 190, 40, 30 } }
		)
		ajouter(l, {
			n = "Criniere",
			t = { 0.3, 0.2, 0.4 },
			p = { 0, 0.34, 0.0 },
			c = BRAISE,
			m = "Neon",
			a = "Antenne",
			j = { 0, 0.28, 0 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.38, 0.34, 0.32 },
			p = { 0, 0.06, -0.44 },
			c = ROUGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Mufle",
			t = { 0.26, 0.14, 0.08 },
			p = { 0, -0.04, -0.62 },
			c = { 240, 140, 120 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Anneau",
			t = { 0.08, 0.06, 0.02 },
			p = { 0, -0.1, -0.665 },
			c = { 255, 205, 50 },
			m = "Foil",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.2, 0.06, 0.06 },
			p = { 0.24, 0.2, -0.44 },
			r = { 0, 0, 25 },
			c = { 255, 205, 50 },
			m = "Foil",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.05, 0.02 },
			p = { 0.1, 0.14, -0.605 },
			c = BRAISE,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Joyau",
			t = { 0.06, 0.06, 0.02 },
			p = { 0, 0.18, -0.605 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		pattes4(l, 0.2, -0.16, 0.32, { 0.14, 0.24, 0.14 }, ROCHE)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.2, 0.04 },
			p = { 0, 0.0, 0.45 },
			c = ROUGE,
			a = "Queue",
			j = { 0, 0.08, 0.44 },
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.08, 0.08, 0.08 },
			p = { 0, -0.12, 0.45 },
			c = BRAISE,
			m = "Neon",
			a = "Queue",
			j = { 0, 0.08, 0.44 },
		})
	end)

	-- Légendaire : reine salamandre couronnée de lave.
	definir("Salamandreine", 0.6, function(l)
		local orange = { 255, 140, 50 }
		local tete = { 0, -0.24, -0.26 }
		local queue = { 0, -0.34, 0.32 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.2, 0.62 }, p = { 0, -0.34, 0.04 }, c = orange })
		for i, z in { -0.16, 0.0, 0.16 } do
			ajouter(l, { n = "Tache" .. i, t = { 0.1, 0.02, 0.1 }, p = { 0, -0.235, z }, c = NOIR })
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.18, 0.26 },
			p = { 0, -0.24, -0.38 },
			c = orange,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.09, -0.2, -0.515, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.14, 0.02, 0.02 },
			p = { 0, -0.29, -0.515 },
			c = { 140, 50, 20 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Couronne",
			t = { 0.2, 0.06, 0.16 },
			p = { 0, -0.12, -0.36 },
			c = { 255, 205, 50 },
			m = "Foil",
			a = "Tete",
			j = tete,
		})
		for i, x in { -0.07, 0, 0.07 } do
			ajouter(l, {
				n = "Pointe" .. i,
				t = { 0.03, 0.06, 0.03 },
				p = { x, -0.07, -0.42 },
				c = if i == 2 then "Rarete" else LAVE,
				m = "Neon",
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "PatteAv",
			t = { 0.16, 0.08, 0.1 },
			p = { 0.22, -0.44, -0.16 },
			c = orange,
			a = "Patte",
			j = { 0.16, -0.42, -0.16 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "PatteAr",
			t = { 0.16, 0.08, 0.1 },
			p = { 0.22, -0.44, 0.22 },
			c = orange,
			a = "Patte",
			j = { 0.16, -0.42, 0.22 },
			ph = math.pi,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.14, 0.1, 0.34 },
			p = { 0, -0.36, 0.5 },
			c = orange,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.1, 0.1, 0.14 },
			p = { 0, -0.34, 0.72 },
			c = BRAISE,
			m = "Neon",
			a = "Queue",
			j = queue,
		})
	end, "Ecailles")

	-- Mythique : petit génie de feu aux bracelets d'or.
	definir("Ifritou", 0.9, function(l)
		local tete = { 0, 0.2, 0 }
		local flamme = { 0, -0.14, 0 }
		ajouter(l, { n = "Torse", t = { 0.36, 0.3, 0.3 }, p = { 0, 0.02, 0 }, c = ROUGE })
		ajouter(l, {
			n = "Ceinture",
			t = { 0.37, 0.05, 0.31 },
			p = { 0, -0.1, 0 },
			c = { 255, 205, 50 },
			m = "Foil",
		})
		ajouter(l, {
			n = "Flamme1",
			t = { 0.28, 0.18, 0.28 },
			p = { 0, -0.22, 0.02 },
			c = LAVE,
			m = "Neon",
			a = "Queue",
			j = flamme,
		})
		ajouter(l, {
			n = "Flamme2",
			t = { 0.18, 0.14, 0.18 },
			p = { 0, -0.36, 0.06 },
			c = BRAISE,
			m = "Neon",
			a = "Queue",
			j = flamme,
		})
		ajouter(l, {
			n = "Flamme3",
			t = { 0.08, 0.1, 0.08 },
			p = { 0, -0.46, 0.1 },
			c = { 255, 250, 200 },
			m = "Neon",
			a = "Queue",
			j = flamme,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.28, 0.28 },
			p = { 0, 0.32, -0.02 },
			c = ROUGE,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.34, -0.165, 0.1, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.12, 0.03, 0.02 },
			p = { 0, 0.25, -0.165 },
			c = { 90, 20, 10 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.05, 0.16, 0.05 },
			p = { 0.12, 0.52, -0.02 },
			r = { 0, 0, -20 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Cheveux",
			t = { 0.2, 0.16, 0.2 },
			p = { 0, 0.52, 0.04 },
			c = BRAISE,
			m = "Neon",
			a = "Antenne",
			j = { 0, 0.46, 0.02 },
		})
		ajouter(l, {
			n = "Joyau",
			t = { 0.07, 0.07, 0.03 },
			p = { 0, 0.04, -0.165 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.1, 0.24, 0.1 },
			p = { 0.24, 0.02, -0.02 },
			c = ROUGE,
			a = "Bras",
			j = { 0.22, 0.12, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Bracelet",
			t = { 0.11, 0.04, 0.11 },
			p = { 0.24, -0.06, -0.02 },
			c = { 255, 205, 50 },
			m = "Foil",
			a = "Bras",
			j = { 0.22, 0.12, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Mythique : chiot à trois têtes, gardien des braises.
	definir("Cerberou", 0.7, function(l)
		local pelage = { 70, 55, 60 }
		ajouter(l, { n = "Corps", t = { 0.5, 0.34, 0.6 }, p = { 0, -0.18, 0.08 }, c = pelage })
		ajouter(l, {
			n = "Collier",
			t = { 0.52, 0.08, 0.2 },
			p = { 0, -0.04, -0.16 },
			c = "Rarete",
			m = "Neon",
		})
		for i, x in { -0.2, 0, 0.2 } do
			local j = { x, 0.0, -0.18 }
			local z = if i == 2 then -0.34 else -0.3
			local y = if i == 2 then 0.12 else 0.06
			ajouter(l, {
				n = "Tete" .. i,
				t = { 0.2, 0.18, 0.2 },
				p = { x, y, z },
				c = pelage,
				a = "Tete",
				j = j,
			})
			ajouter(l, {
				n = "Museau" .. i,
				t = { 0.1, 0.07, 0.08 },
				p = { x, y - 0.04, z - 0.13 },
				c = { 100, 85, 90 },
				a = "Tete",
				j = j,
			})
			ajouter(l, {
				n = "Truffe" .. i,
				t = { 0.04, 0.03, 0.02 },
				p = { x, y - 0.01, z - 0.175 },
				c = NOIR,
				a = "Tete",
				j = j,
			})
			ajouter(l, {
				n = "OeilG" .. i,
				t = { 0.04, 0.04, 0.02 },
				p = { x - 0.05, y + 0.04, z - 0.105 },
				c = BRAISE,
				m = "Neon",
				a = "Tete",
				j = j,
			})
			ajouter(l, {
				n = "OeilD" .. i,
				t = { 0.04, 0.04, 0.02 },
				p = { x + 0.05, y + 0.04, z - 0.105 },
				c = BRAISE,
				m = "Neon",
				a = "Tete",
				j = j,
			})
			ajouter(l, {
				n = "Oreille" .. i,
				t = { 0.06, 0.08, 0.04 },
				p = { x + 0.06, y + 0.13, z },
				c = pelage,
				a = "Oreille",
				j = { x + 0.06, y + 0.09, z },
				cote = 1,
			})
		end
		pattes4(l, 0.16, -0.1, 0.28, { 0.12, 0.16, 0.12 }, pelage)
		ajouter(l, {
			n = "Queue",
			t = { 0.06, 0.06, 0.24 },
			p = { 0, -0.08, 0.46 },
			r = { -30, 0, 0 },
			c = pelage,
			a = "Queue",
			j = { 0, -0.12, 0.38 },
		})
		ajouter(l, {
			n = "Flamme",
			t = { 0.1, 0.12, 0.1 },
			p = { 0, 0.04, 0.56 },
			c = LAVE,
			m = "Neon",
			a = "Queue",
			j = { 0, -0.12, 0.38 },
		})
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : flaque de lave vivante et ronchonne.
	definir("Magmouille", 0.5, function(l)
		ajouter(
			l,
			{ n = "Lave", t = { 0.92, 0.6, 0.92 }, p = { 0, -0.2, 0 }, c = LAVE, m = "Neon" }
		)
		ajouter(l, { n = "Croute", t = { 0.7, 0.12, 0.7 }, p = { 0, 0.14, 0.04 }, c = ROCHE })
		ajouter(
			l,
			{ n = "Croute2", t = { 0.3, 0.08, 0.3 }, p = { 0.2, 0.22, 0.18 }, c = ROCHE_CLAIRE }
		)
		yeux(l, 0.2, -0.06, -0.47, 0.2)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.22, 0.05, 0.03 },
			p = { 0.2, 0.1, -0.47 },
			r = { 0, 0, 20 },
			c = ROCHE,
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.34, 0.08, 0.02 }, p = { 0, -0.3, -0.465 }, c = { 120, 30, 10 } }
		)
		for i, pos in { { -0.36, -0.46, -0.32 }, { 0.38, -0.46, 0.1 } } do
			ajouter(
				l,
				{ n = "Goutte" .. i, t = { 0.1, 0.1, 0.1 }, p = pos, c = BRAISE, m = "Neon" }
			)
		end
		ajouter(l, {
			n = "Bulle",
			t = { 0.12, 0.12, 0.12 },
			p = { -0.2, 0.26, -0.1 },
			c = BRAISE,
			m = "Neon",
			a = "Antenne",
			j = { -0.2, 0.2, -0.1 },
		})
	end)

	-- Moyenne : chien de lave aux crocs incandescents.
	definir("Cendrecroc", 0.7, function(l)
		local tete = { 0, 0.1, -0.4 }
		local queue = { 0, 0.06, 0.46 }
		ajouter(l, { n = "Corps", t = { 0.54, 0.42, 0.88 }, p = { 0, -0.06, 0.06 }, c = ROCHE })
		fissures(
			l,
			{ { 0.28, -0.04, 0.2, 25 }, { -0.28, -0.1, 0.16, -20 }, { 0.28, -0.14, 0.12, -10 } },
			0.1
		)
		ajouter(
			l,
			{ n = "Criniere", t = { 0.5, 0.16, 0.3 }, p = { 0, 0.2, -0.22 }, c = LAVE, m = "Neon" }
		)
		ajouter(l, {
			n = "Tete",
			t = { 0.4, 0.34, 0.36 },
			p = { 0, 0.14, -0.52 },
			c = ROCHE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.3, 0.08, 0.26 },
			p = { 0, -0.05, -0.62 },
			c = ROCHE_CLAIRE,
			a = "Machoire",
			j = { 0, -0.02, -0.48 },
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.04, 0.08, 0.03 },
			p = { 0.1, 0.0, -0.715 },
			c = BRAISE,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.05, 0.03 },
			p = { 0.11, 0.21, -0.71 },
			r = { 0, 0, -12 },
			c = BRAISE,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.16, 0.06 },
			p = { 0.13, 0.38, -0.5 },
			c = ROCHE,
			a = "Oreille",
			j = { 0.13, 0.31, -0.5 },
		}, true)
		pattes4(l, 0.18, -0.28, 0.34, { 0.13, 0.26, 0.13 }, ROCHE_CLAIRE)
		ajouter(l, {
			n = "Queue",
			t = { 0.1, 0.1, 0.36 },
			p = { 0, 0.12, 0.62 },
			r = { -30, 0, 0 },
			c = ROCHE,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Flamme",
			t = { 0.14, 0.14, 0.14 },
			p = { 0, 0.24, 0.78 },
			c = LAVE,
			m = "Neon",
			a = "Queue",
			j = queue,
		})
	end, "Ecailles")

	-- Lointaine : titan de lave aux poings de magma.
	definir("Titanflamme", 0.88, function(l)
		local tete = { 0, 0.3, 0 }
		ajouter(l, { n = "Torse", t = { 0.8, 0.64, 0.56 }, p = { 0, 0.0, 0 }, c = ROCHE })
		fissures(
			l,
			{ { -0.2, 0.06, 0.24, 30 }, { 0.22, -0.12, 0.2, -25 }, { 0.0, 0.2, 0.18, 5 } },
			-0.29
		)
		ajouter(l, {
			n = "Coeur",
			t = { 0.16, 0.16, 0.03 },
			p = { 0, -0.04, -0.29 },
			r = { 0, 0, 45 },
			c = BRAISE,
			m = "Neon",
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.4, 0.3, 0.36 },
			p = { 0, 0.46, -0.04 },
			c = ROCHE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.06, 0.03 },
			p = { 0.09, 0.48, -0.235 },
			c = BRAISE,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Gueule",
			t = { 0.22, 0.06, 0.02 },
			p = { 0, 0.38, -0.235 },
			c = LAVE,
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Flammes",
			t = { 0.3, 0.2, 0.26 },
			p = { 0, 0.68, 0.0 },
			c = LAVE,
			m = "Neon",
			a = "Antenne",
			j = { 0, 0.6, 0 },
		})
		ajouter(
			l,
			{ n = "Epaule", t = { 0.3, 0.16, 0.32 }, p = { 0.48, 0.3, -0.02 }, c = ROCHE_CLAIRE },
			true
		)
		ajouter(l, {
			n = "Bras",
			t = { 0.22, 0.5, 0.24 },
			p = { 0.52, 0.0, -0.02 },
			c = ROCHE,
			a = "Bras",
			j = { 0.52, 0.22, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Poing",
			t = { 0.3, 0.26, 0.3 },
			p = { 0.52, -0.32, -0.04 },
			c = LAVE,
			m = "Neon",
			a = "Bras",
			j = { 0.52, 0.22, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.26, 0.22, 0.28 },
			p = { 0.2, -0.38, 0 },
			c = ROCHE_CLAIRE,
			a = "Patte",
			j = { 0.2, -0.27, 0 },
			ph = math.pi,
		}, true)
	end)
end
