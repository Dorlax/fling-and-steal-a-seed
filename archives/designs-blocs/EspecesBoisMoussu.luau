--!strict
-- Bestiaire du biome 2 : Bois Moussu (mousse, lucioles, champignons, écorce).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
-- Ce fichier reçoit les outils de Bestiaire (definir, ajouter, yeux, pattes4).
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local MOUSSE = { 110, 185, 90 }
	local MOUSSE_FONCEE = { 60, 130, 70 }
	local ECORCE = { 120, 85, 55 }
	local ECORCE_FONCEE = { 80, 55, 35 }
	local LUEUR = { 150, 255, 210 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : gland tout rond, chapeau d'écorce et petite feuille.
	definir("Glandouille", 0.66, function(l)
		local noisette = { 195, 125, 60 }
		local tige = { 0, 0.22, 0 }
		ajouter(l, { n = "Noix", t = { 0.5, 0.48, 0.48 }, p = { 0, -0.2, 0 }, c = noisette })
		ajouter(
			l,
			{ n = "Pointe", t = { 0.2, 0.08, 0.2 }, p = { 0, -0.47, 0 }, c = { 170, 100, 50 } }
		)
		ajouter(l, { n = "Chapeau", t = { 0.58, 0.18, 0.56 }, p = { 0, 0.12, 0 }, c = ECORCE })
		for i, pos in { { -0.18, 0.12, -0.285 }, { 0, 0.12, -0.285 }, { 0.18, 0.12, -0.285 } } do
			ajouter(l, { n = "Ecaille" .. i, t = { 0.12, 0.06, 0.02 }, p = pos, c = ECORCE_FONCEE })
		end
		ajouter(l, {
			n = "Tige",
			t = { 0.06, 0.1, 0.06 },
			p = { 0, 0.26, 0 },
			c = ECORCE_FONCEE,
			a = "Antenne",
			j = tige,
		})
		ajouter(l, {
			n = "Feuille",
			t = { 0.16, 0.03, 0.08 },
			p = { 0.09, 0.27, 0.02 },
			r = { 0, 0, 20 },
			c = MOUSSE,
			a = "Antenne",
			j = tige,
		})
		yeux(l, 0.1, -0.12, -0.245, 0.11)
		ajouter(
			l,
			{ n = "Joue", t = { 0.07, 0.04, 0.02 }, p = { 0.17, -0.2, -0.245 }, c = ROSE },
			true
		)
		ajouter(l, {
			n = "Bouche",
			t = { 0.08, 0.03, 0.02 },
			p = { 0, -0.24, -0.245 },
			c = { 110, 50, 40 },
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.06, 0.12, 0.06 },
			p = { 0.28, -0.2, 0 },
			c = noisette,
			a = "Bras",
			j = { 0.26, -0.15, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.12, 0.06, 0.14 },
			p = { 0.12, -0.47, -0.06 },
			c = ECORCE_FONCEE,
			a = "Patte",
			j = { 0.12, -0.42, -0.04 },
			ph = 0,
		}, true)
	end)

	-- Commune : mouton dont la laine est un coussin de mousse fleurie.
	definir("Mousselin", 0.62, function(l)
		local tete = { 0, 0, -0.28 }
		local peau = { 70, 60, 55 }
		ajouter(l, { n = "Laine", t = { 0.62, 0.44, 0.66 }, p = { 0, -0.06, 0.04 }, c = MOUSSE })
		ajouter(l, {
			n = "LaineHaut",
			t = { 0.46, 0.08, 0.5 },
			p = { 0, 0.2, 0.04 },
			c = { 135, 205, 105 },
		})
		local fleurs = {
			{ x = 0.15, z = 0.1, c = ROSE },
			{ x = -0.12, z = 0.2, c = BLANC },
			{ x = 0.02, z = -0.12, c = { 255, 220, 80 } },
		}
		for i, f in fleurs do
			ajouter(
				l,
				{ n = "Fleur" .. i, t = { 0.07, 0.04, 0.07 }, p = { f.x, 0.25, f.z }, c = f.c }
			)
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.26, 0.24 },
			p = { 0, 0.04, -0.38 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Toupet",
			t = { 0.3, 0.1, 0.2 },
			p = { 0, 0.2, -0.34 },
			c = MOUSSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.12, 0.06, 0.06 },
			p = { 0.18, 0.08, -0.36 },
			r = { 0, 0, -20 },
			c = peau,
			a = "Oreille",
			j = { 0.14, 0.08, -0.36 },
		}, true)
		yeux(l, 0.07, 0.06, -0.505, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Nez",
			t = { 0.08, 0.04, 0.02 },
			p = { 0, -0.04, -0.505 },
			c = { 40, 30, 30 },
			a = "Tete",
			j = tete,
		})
		pattes4(l, 0.18, -0.18, 0.26, { 0.1, 0.2, 0.1 }, peau)
		ajouter(l, {
			n = "Queue",
			t = { 0.12, 0.12, 0.1 },
			p = { 0, 0.02, 0.41 },
			c = MOUSSE,
			a = "Queue",
			j = { 0, 0.02, 0.37 },
		})
	end)

	-- Rare : écureuil dont la queue porte une lanterne lumineuse.
	definir("Lanternil", 0.72, function(l)
		local roux = { 205, 110, 60 }
		local tete = { 0, -0.04, -0.1 }
		local queue = { 0, -0.22, 0.2 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.36, 0.4 }, p = { 0, -0.24, 0.02 }, c = roux })
		ajouter(l, { n = "Ventre", t = { 0.22, 0.26, 0.03 }, p = { 0, -0.26, -0.18 }, c = CREME })
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.28, 0.28 },
			p = { 0, 0.06, -0.16 },
			c = roux,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.14, 0.08, 0.04 },
			p = { 0, -0.01, -0.31 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Nez",
			t = { 0.05, 0.04, 0.02 },
			p = { 0, 0.02, -0.33 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.09, -0.305, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.14, 0.05 },
			p = { 0.1, 0.26, -0.14 },
			c = roux,
			a = "Oreille",
			j = { 0.1, 0.2, -0.14 },
		}, true)
		ajouter(l, {
			n = "Plumet",
			t = { 0.04, 0.06, 0.03 },
			p = { 0.1, 0.35, -0.14 },
			c = ECORCE_FONCEE,
			a = "Oreille",
			j = { 0.1, 0.2, -0.14 },
		}, true)
		pattes4(l, 0.11, -0.12, 0.14, { 0.09, 0.1, 0.12 }, { 150, 80, 45 })
		ajouter(l, {
			n = "Queue",
			t = { 0.22, 0.4, 0.16 },
			p = { 0, 0.0, 0.32 },
			r = { -10, 0, 0 },
			c = roux,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "QueueHaut",
			t = { 0.22, 0.16, 0.22 },
			p = { 0, 0.24, 0.38 },
			c = { 230, 140, 80 },
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Anse",
			t = { 0.02, 0.08, 0.02 },
			p = { 0, 0.2, 0.52 },
			c = ECORCE_FONCEE,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Lanterne",
			t = { 0.12, 0.14, 0.12 },
			p = { 0, 0.09, 0.52 },
			c = "Rarete",
			m = "Neon",
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Couvercle",
			t = { 0.15, 0.03, 0.15 },
			p = { 0, 0.17, 0.52 },
			c = ECORCE_FONCEE,
			a = "Queue",
			j = queue,
		})
	end)

	-- Rare : grenouille coiffée d'un champignon.
	definir("Crapousse", 0.58, function(l)
		local vert = { 95, 195, 110 }
		local tete = { 0, -0.12, 0.1 }
		ajouter(l, { n = "Corps", t = { 0.58, 0.32, 0.5 }, p = { 0, -0.3, 0.04 }, c = vert })
		ajouter(l, {
			n = "Ventre",
			t = { 0.4, 0.2, 0.03 },
			p = { 0, -0.32, -0.215 },
			c = { 230, 235, 150 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.56, 0.2, 0.4 },
			p = { 0, -0.06, -0.04 },
			c = vert,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bosse",
			t = { 0.16, 0.14, 0.14 },
			p = { 0.16, 0.08, -0.14 },
			c = vert,
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.16, 0.08, -0.215, 0.12, "Tete", tete)
		ajouter(l, {
			n = "Bouche",
			t = { 0.36, 0.025, 0.02 },
			p = { 0, -0.1, -0.245 },
			c = { 50, 90, 50 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Joue",
			t = { 0.06, 0.04, 0.02 },
			p = { 0.2, -0.07, -0.245 },
			c = ROSE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Chapeau",
			t = { 0.3, 0.1, 0.28 },
			p = { -0.1, 0.15, 0.08 },
			r = { 0, 0, 12 },
			c = { 200, 70, 150 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pois",
			t = { 0.06, 0.02, 0.06 },
			p = { -0.14, 0.205, 0.04 },
			r = { 0, 0, 12 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pois2",
			t = { 0.05, 0.02, 0.05 },
			p = { -0.04, 0.19, 0.14 },
			r = { 0, 0, 12 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "CuisseArr",
			t = { 0.16, 0.12, 0.3 },
			p = { 0.3, -0.44, 0.12 },
			c = vert,
			a = "Patte",
			j = { 0.3, -0.4, 0.12 },
			ph = math.pi,
		}, true)
		ajouter(l, {
			n = "PatteAv",
			t = { 0.08, 0.14, 0.08 },
			p = { 0.2, -0.43, -0.18 },
			c = vert,
			a = "Patte",
			j = { 0.2, -0.37, -0.18 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Tache",
			t = { 0.1, 0.02, 0.1 },
			p = { 0.12, 0.045, 0.1 },
			c = MOUSSE_FONCEE,
			a = "Tete",
			j = tete,
		}, true)
	end)

	-- Épique : ourson couvert de lierre, fleur lumineuse sur l'épaule.
	definir("Oursilierre", 0.78, function(l)
		local brun = { 150, 100, 70 }
		local tete = { 0, 0.06, -0.06 }
		ajouter(l, { n = "Corps", t = { 0.56, 0.48, 0.5 }, p = { 0, -0.22, 0.04 }, c = brun })
		ajouter(l, {
			n = "Tete",
			t = { 0.44, 0.36, 0.36 },
			p = { 0, 0.2, -0.1 },
			c = brun,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.12, 0.12, 0.06 },
			p = { 0.17, 0.42, -0.08 },
			c = brun,
			a = "Oreille",
			j = { 0.17, 0.37, -0.08 },
		}, true)
		ajouter(l, {
			n = "OreilleInterieur",
			t = { 0.06, 0.06, 0.02 },
			p = { 0.17, 0.42, -0.115 },
			c = { 220, 170, 140 },
			a = "Oreille",
			j = { 0.17, 0.37, -0.08 },
		}, true)
		ajouter(l, {
			n = "Museau",
			t = { 0.2, 0.12, 0.08 },
			p = { 0, 0.13, -0.31 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Nez",
			t = { 0.08, 0.05, 0.03 },
			p = { 0, 0.17, -0.355 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.1, 0.25, -0.285, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Lierre",
			t = { 0.06, 0.56, 0.03 },
			p = { 0, -0.18, -0.225 },
			r = { 0, 0, 35 },
			c = MOUSSE_FONCEE,
		})
		for i, pos in { { -0.14, 0.0 }, { -0.04, -0.14 }, { 0.08, -0.3 }, { 0.17, -0.42 } } do
			ajouter(l, {
				n = "FeuilleLierre" .. i,
				t = { 0.1, 0.07, 0.03 },
				p = { pos[1], pos[2], -0.235 },
				r = { 0, 0, 30 },
				c = MOUSSE,
			})
		end
		ajouter(l, {
			n = "Fleur",
			t = { 0.1, 0.1, 0.03 },
			p = { 0.17, -0.05, -0.235 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
		})
		pattes4(l, 0.17, -0.12, 0.2, { 0.14, 0.16, 0.16 }, { 120, 80, 55 })
		ajouter(l, {
			n = "Queue",
			t = { 0.1, 0.1, 0.06 },
			p = { 0, -0.12, 0.31 },
			c = brun,
			a = "Queue",
			j = { 0, -0.12, 0.29 },
		})
	end)

	-- Épique : grosse luciole au ventre lumineux.
	definir("Lucioline", 0.7, function(l)
		local nuit = { 55, 65, 110 }
		local tete = { 0, 0, -0.2 }
		ajouter(l, { n = "Thorax", t = { 0.3, 0.28, 0.34 }, p = { 0, -0.08, -0.04 }, c = nuit })
		ajouter(l, {
			n = "Abdomen",
			t = { 0.32, 0.28, 0.34 },
			p = { 0, -0.12, 0.28 },
			c = { 210, 255, 120 },
			m = "Neon",
		})
		ajouter(l, { n = "Rayure", t = { 0.33, 0.04, 0.35 }, p = { 0, 0.0, 0.28 }, c = nuit })
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.22 },
			p = { 0, 0.04, -0.3 },
			c = nuit,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.06, -0.415, 0.1, "Tete", tete)
		ajouter(l, {
			n = "Antenne",
			t = { 0.03, 0.2, 0.03 },
			p = { 0.07, 0.24, -0.33 },
			r = { -20, 0, -15 },
			c = nuit,
			a = "Antenne",
			j = { 0.07, 0.15, -0.31 },
		}, true)
		ajouter(l, {
			n = "BoutAntenne",
			f = "Ball",
			t = { 0.06, 0.06, 0.06 },
			p = { 0.1, 0.34, -0.37 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = { 0.07, 0.15, -0.31 },
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.3, 0.03, 0.42 },
			p = { 0.17, 0.1, 0.08 },
			r = { 0, 0, -15 },
			c = { 200, 240, 255 },
			tr = 0.35,
			a = "Aile",
			j = { 0.05, 0.08, 0.02 },
		}, true)
		for i, z in { -0.14, 0.0, 0.14 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.03, 0.26, 0.03 },
				p = { 0.13, -0.36, z },
				r = { 0, 0, -15 },
				c = nuit,
				a = "Patte",
				j = { 0.12, -0.22, z },
				ph = i,
			}, true)
		end
	end)

	-- Légendaire : petit roi-souche, couronne de feuilles et d'or.
	definir("Sylvoroi", 0.86, function(l)
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Tronc", t = { 0.56, 0.62, 0.5 }, p = { 0, -0.12, 0 }, c = ECORCE })
		for i, x in { -0.17, 0.08, 0.2 } do
			ajouter(l, {
				n = "Strie" .. i,
				t = { 0.035, 0.5, 0.03 },
				p = { x, -0.14, -0.255 },
				c = ECORCE_FONCEE,
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.06, 0.03 },
			p = { 0.12, 0.06, -0.26 },
			c = LUEUR,
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.13, 0.04, 0.03 },
			p = { 0.12, 0.12, -0.26 },
			r = { 0, 0, 12 },
			c = ECORCE_FONCEE,
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.16, 0.05, 0.03 }, p = { 0, -0.06, -0.26 }, c = { 50, 30, 20 } }
		)
		ajouter(l, { n = "Barbe", t = { 0.24, 0.16, 0.03 }, p = { 0, -0.18, -0.265 }, c = MOUSSE })
		ajouter(l, {
			n = "Mousse",
			t = { 0.62, 0.12, 0.56 },
			p = { 0, 0.24, 0 },
			c = MOUSSE,
			a = "Tete",
			j = tete,
		})
		for i = 1, 6 do
			local angle = (i / 6) * 2 * math.pi
			ajouter(l, {
				n = "FeuilleCouronne" .. i,
				t = { 0.12, 0.18, 0.05 },
				p = { math.cos(angle) * 0.26, 0.36, math.sin(angle) * 0.24 },
				r = { 0, -math.deg(angle) + 90, 0 },
				c = if i % 2 == 0 then MOUSSE else MOUSSE_FONCEE,
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Couronne",
			t = { 0.3, 0.08, 0.26 },
			p = { 0, 0.34, 0 },
			c = { 255, 205, 50 },
			m = "Foil",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Joyau",
			t = { 0.07, 0.07, 0.03 },
			p = { 0, 0.36, -0.14 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Branche",
			t = { 0.08, 0.32, 0.08 },
			p = { 0.34, -0.04, 0 },
			r = { 0, 0, -35 },
			c = ECORCE,
			a = "Bras",
			j = { 0.27, 0.06, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Feuillage",
			t = { 0.16, 0.14, 0.14 },
			p = { 0.45, 0.1, 0 },
			c = MOUSSE,
			a = "Bras",
			j = { 0.27, 0.06, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Racine",
			t = { 0.2, 0.1, 0.24 },
			p = { 0.16, -0.45, -0.04 },
			c = ECORCE_FONCEE,
			a = "Patte",
			j = { 0.16, -0.4, 0 },
			ph = 0,
		}, true)
	end)

	-- Légendaire : escargot géant à coquille de pierre moussue et de cristaux.
	definir("Escargolem", 0.8, function(l)
		local peau = { 150, 205, 185 }
		local pierre = { 135, 145, 155 }
		local tete = { 0, -0.34, -0.3 }
		ajouter(l, { n = "Pied", t = { 0.32, 0.14, 0.8 }, p = { 0, -0.43, 0 }, c = peau })
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.3, 0.2 },
			p = { 0, -0.22, -0.32 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Sourire",
			t = { 0.1, 0.025, 0.02 },
			p = { 0, -0.27, -0.425 },
			c = { 60, 100, 90 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Joue",
			t = { 0.05, 0.03, 0.02 },
			p = { 0.08, -0.24, -0.425 },
			c = ROSE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Tentacule",
			t = { 0.04, 0.16, 0.04 },
			p = { 0.07, -0.0, -0.34 },
			c = peau,
			a = "Antenne",
			j = { 0.07, -0.08, -0.34 },
		}, true)
		ajouter(l, {
			n = "OeilBoule",
			t = { 0.09, 0.09, 0.09 },
			p = { 0.07, 0.1, -0.34 },
			c = BLANC,
			a = "Antenne",
			j = { 0.07, -0.08, -0.34 },
		}, true)
		ajouter(l, {
			n = "Pupille",
			t = { 0.04, 0.05, 0.02 },
			p = { 0.07, 0.1, -0.39 },
			c = NOIR,
			a = "Antenne",
			j = { 0.07, -0.08, -0.34 },
		}, true)
		ajouter(l, { n = "Coquille", t = { 0.5, 0.5, 0.46 }, p = { 0, -0.06, 0.12 }, c = pierre })
		ajouter(l, {
			n = "Spirale",
			t = { 0.03, 0.3, 0.3 },
			p = { 0.255, -0.06, 0.12 },
			c = { 95, 105, 115 },
		}, true)
		ajouter(l, {
			n = "SpiraleCoeur",
			t = { 0.035, 0.12, 0.12 },
			p = { 0.26, -0.06, 0.12 },
			c = { 180, 190, 200 },
		}, true)
		ajouter(l, { n = "Mousse", t = { 0.4, 0.08, 0.4 }, p = { 0, 0.22, 0.12 }, c = MOUSSE })
		ajouter(l, {
			n = "Cristal1",
			t = { 0.08, 0.22, 0.08 },
			p = { 0.1, 0.32, 0.12 },
			r = { 10, 0, -15 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Cristal2",
			t = { 0.07, 0.16, 0.07 },
			p = { -0.1, 0.3, 0.2 },
			r = { -10, 0, 20 },
			c = LUEUR,
			m = "Neon",
		})
		ajouter(l, {
			n = "Cristal3",
			t = { 0.06, 0.12, 0.06 },
			p = { 0.0, 0.29, 0.02 },
			r = { 15, 0, 5 },
			c = LUEUR,
			m = "Neon",
		})
	end)

	-- Mythique : esprit-cerf translucide aux bois de lumière.
	definir("Sylphelune", 0.95, function(l)
		local esprit = { 130, 240, 220 }
		local tete = { 0, 0.08, -0.22 }
		ajouter(
			l,
			{ n = "Corps", t = { 0.36, 0.3, 0.56 }, p = { 0, -0.02, 0.06 }, c = esprit, tr = 0.15 }
		)
		pattes4(l, 0.12, -0.14, 0.26, { 0.07, 0.34, 0.07 }, esprit)
		ajouter(l, {
			n = "Cou",
			t = { 0.14, 0.26, 0.12 },
			p = { 0, 0.16, -0.2 },
			c = esprit,
			tr = 0.15,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.2, 0.28 },
			p = { 0, 0.32, -0.34 },
			c = esprit,
			tr = 0.1,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.14, 0.1, 0.1 },
			p = { 0, 0.27, -0.52 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.06, 0.03 },
			p = { 0.08, 0.35, -0.485 },
			c = { 60, 80, 160 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		for i, b in
			{
				{ 0.08, 0.5, 0.04, 0.2 },
				{ 0.14, 0.58, 0.14, 0.04 },
				{ 0.2, 0.66, 0.04, 0.14 },
				{ 0.08, 0.66, 0.04, 0.12 },
			}
		do
			ajouter(l, {
				n = "Bois" .. i,
				t = { b[3], b[4], 0.04 },
				p = { b[1], b[2], -0.32 },
				c = { 230, 255, 255 },
				m = "Neon",
				a = "Tete",
				j = tete,
			}, true)
		end
		for i, pos in { { 0.08, 0.135, 0.0 }, { -0.1, 0.135, 0.16 }, { 0.04, 0.135, 0.26 } } do
			ajouter(l, {
				n = "Etoile" .. i,
				t = { 0.06, 0.02, 0.06 },
				p = pos,
				r = { 0, 45, 0 },
				c = "Rarete",
				m = "Neon",
			})
		end
		ajouter(l, {
			n = "Queue",
			t = { 0.1, 0.16, 0.08 },
			p = { 0, 0.08, 0.37 },
			r = { -30, 0, 0 },
			c = { 230, 255, 255 },
			m = "Neon",
			a = "Queue",
			j = { 0, 0.06, 0.34 },
		})
	end)

	-- Mythique : grand papillon de nuit aux ailes ocellées.
	definir("Phalenor", 0.7, function(l)
		local duvet = { 240, 235, 220 }
		local aile = { 190, 255, 200 }
		local tete = { 0, 0, -0.18 }
		ajouter(l, { n = "Corps", t = { 0.26, 0.3, 0.4 }, p = { 0, -0.06, 0.04 }, c = duvet })
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.22, 0.2 },
			p = { 0, 0.04, -0.24 },
			c = duvet,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.06, -0.345, 0.1, "Tete", tete)
		ajouter(l, {
			n = "Antenne",
			t = { 0.12, 0.2, 0.03 },
			p = { 0.1, 0.24, -0.26 },
			r = { 0, 0, -20 },
			c = { 255, 215, 90 },
			a = "Antenne",
			j = { 0.06, 0.14, -0.26 },
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.5, 0.03, 0.4 },
			p = { 0.32, 0.1, -0.04 },
			r = { 0, 0, -10 },
			c = aile,
			a = "Aile",
			j = { 0.1, 0.08, 0 },
		}, true)
		ajouter(l, {
			n = "Ocelle",
			t = { 0.12, 0.035, 0.12 },
			p = { 0.38, 0.115, -0.06 },
			r = { 0, 0, -10 },
			c = "Rarete",
			m = "Neon",
			a = "Aile",
			j = { 0.1, 0.08, 0 },
		}, true)
		ajouter(l, {
			n = "Bordure",
			t = { 0.5, 0.032, 0.04 },
			p = { 0.32, 0.1, -0.23 },
			r = { 0, 0, -10 },
			c = { 140, 90, 160 },
			a = "Aile",
			j = { 0.1, 0.08, 0 },
		}, true)
		ajouter(l, {
			n = "Traine",
			t = { 0.16, 0.03, 0.42 },
			p = { 0.2, 0.02, 0.34 },
			r = { 0, -15, -10 },
			c = aile,
			a = "Aile",
			j = { 0.1, 0.08, 0 },
		}, true)
		for i, z in { -0.08, 0.06 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.03, 0.3, 0.03 },
				p = { 0.08, -0.35, z },
				c = { 200, 190, 170 },
				a = "Patte",
				j = { 0.08, -0.2, z },
				ph = i,
			}, true)
		end
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : champignon costaud et grognon, pois lumineux.
	definir("Champignard", 0.82, function(l)
		local pied = { 240, 225, 200 }
		local chapeau = { 150, 60, 170 }
		local tete = { 0, 0.03, 0 }
		ajouter(l, { n = "Pied", t = { 0.5, 0.5, 0.46 }, p = { 0, -0.2, 0 }, c = pied })
		ajouter(l, {
			n = "Chapeau",
			t = { 0.9, 0.28, 0.86 },
			p = { 0, 0.18, 0 },
			c = chapeau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "ChapeauHaut",
			t = { 0.6, 0.16, 0.56 },
			p = { 0, 0.38, 0 },
			c = chapeau,
			a = "Tete",
			j = tete,
		})
		for i, pos in
			{
				{ 0.2, 0.465, 0.1 },
				{ -0.18, 0.465, -0.1 },
				{ 0.32, 0.33, -0.2 },
				{ -0.3, 0.33, 0.2 },
			}
		do
			ajouter(l, {
				n = "Pois" .. i,
				t = { 0.12, 0.02, 0.12 },
				p = pos,
				c = { 230, 150, 255 },
				m = "Neon",
				a = "Tete",
				j = tete,
			})
		end
		yeux(l, 0.11, -0.08, -0.235, 0.12)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.15, 0.04, 0.03 },
			p = { 0.11, 0.0, -0.24 },
			r = { 0, 0, 20 },
			c = { 90, 40, 100 },
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.24, 0.06, 0.02 }, p = { 0, -0.26, -0.235 }, c = { 70, 20, 40 } }
		)
		ajouter(
			l,
			{ n = "Dent", t = { 0.05, 0.05, 0.02 }, p = { 0.07, -0.235, -0.24 }, c = BLANC },
			true
		)
		ajouter(l, {
			n = "Bras",
			t = { 0.14, 0.22, 0.14 },
			p = { 0.32, -0.2, 0 },
			c = pied,
			a = "Bras",
			j = { 0.3, -0.1, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.18, 0.08, 0.22 },
			p = { 0.14, -0.46, -0.04 },
			c = { 200, 180, 160 },
			a = "Patte",
			j = { 0.14, -0.4, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Moyenne : bête de ronces aux baies rouges lumineuses.
	definir("Roncebete", 0.66, function(l)
		local ronce = { 60, 110, 60 }
		local epine = { 150, 80, 50 }
		local baie = { 255, 60, 80 }
		local tete = { 0, 0.08, -0.4 }
		local queue = { 0, 0.06, 0.46 }
		ajouter(l, { n = "Corps", t = { 0.6, 0.42, 0.86 }, p = { 0, -0.06, 0.06 }, c = ronce })
		for i, z in { -0.26, -0.06, 0.14, 0.34 } do
			ajouter(l, {
				n = "Epine" .. i,
				t = { 0.06, 0.18, 0.06 },
				p = { 0.14, 0.2, z },
				r = { 20, 0, -25 },
				c = epine,
			}, true)
		end
		for i, pos in { { 0.3, 0.0, 0.0 }, { -0.3, -0.08, 0.24 }, { 0.3, -0.12, 0.3 } } do
			ajouter(l, {
				n = "Baie" .. i,
				t = { 0.08, 0.08, 0.08 },
				p = { pos[1] + (if pos[1] > 0 then 0.02 else -0.02), pos[2], pos[3] },
				c = baie,
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.4, 0.34, 0.36 },
			p = { 0, 0.12, -0.52 },
			c = ronce,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.32, 0.08, 0.26 },
			p = { 0, -0.07, -0.6 },
			c = { 45, 80, 45 },
			a = "Machoire",
			j = { 0, -0.04, -0.46 },
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.04, 0.07, 0.03 },
			p = { 0.1, -0.01, -0.715 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.06, 0.03 },
			p = { 0.11, 0.19, -0.71 },
			r = { 0, 0, -12 },
			c = baie,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Corne",
			t = { 0.05, 0.16, 0.05 },
			p = { 0.13, 0.35, -0.5 },
			r = { 25, 0, -20 },
			c = epine,
			a = "Tete",
			j = tete,
		}, true)
		pattes4(l, 0.2, -0.28, 0.34, { 0.14, 0.26, 0.14 }, { 45, 85, 45 })
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.08, 0.4 },
			p = { 0, 0.08, 0.62 },
			r = { -20, 0, 0 },
			c = ronce,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "EpineQueue",
			t = { 0.05, 0.1, 0.05 },
			p = { 0, 0.18, 0.7 },
			c = epine,
			a = "Queue",
			j = queue,
		})
	end)

	-- Lointaine : arbre colérique aux longs bras-branches.
	definir("Grumtronc", 0.9, function(l)
		local tete = { 0, 0.28, 0 }
		ajouter(l, { n = "Tronc", t = { 0.7, 0.7, 0.56 }, p = { 0, -0.05, 0 }, c = ECORCE })
		for i, x in { -0.22, 0.05, 0.25 } do
			ajouter(l, {
				n = "Strie" .. i,
				t = { 0.04, 0.6, 0.03 },
				p = { x, -0.06, -0.285 },
				c = ECORCE_FONCEE,
			})
		end
		ajouter(l, {
			n = "Feuillage",
			t = { 0.9, 0.4, 0.8 },
			p = { 0, 0.48, 0.02 },
			c = MOUSSE_FONCEE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "FeuillageHaut",
			t = { 0.6, 0.18, 0.56 },
			p = { 0, 0.74, 0.02 },
			c = MOUSSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Touffe",
			t = { 0.26, 0.2, 0.26 },
			p = { 0.44, 0.56, 0.1 },
			c = MOUSSE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.14, 0.08, 0.03 },
			p = { 0.15, 0.14, -0.29 },
			r = { 0, 0, -10 },
			c = { 255, 220, 60 },
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.2, 0.06, 0.04 },
			p = { 0.15, 0.24, -0.29 },
			r = { 0, 0, 20 },
			c = ECORCE_FONCEE,
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.36, 0.1, 0.03 }, p = { 0, -0.06, -0.29 }, c = { 40, 20, 15 } }
		)
		for i, x in { -0.12, 0, 0.12 } do
			ajouter(l, {
				n = "Dent" .. i,
				t = { 0.06, 0.07, 0.02 },
				p = { x, -0.03, -0.3 },
				c = { 220, 200, 160 },
			})
		end
		ajouter(l, {
			n = "Bras",
			t = { 0.18, 0.56, 0.2 },
			p = { 0.48, -0.02, -0.02 },
			c = ECORCE,
			a = "Bras",
			j = { 0.48, 0.24, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Main",
			t = { 0.24, 0.2, 0.26 },
			p = { 0.48, -0.32, -0.04 },
			c = MOUSSE,
			a = "Bras",
			j = { 0.48, 0.24, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Racine",
			t = { 0.24, 0.16, 0.3 },
			p = { 0.2, -0.42, 0 },
			c = ECORCE_FONCEE,
			a = "Patte",
			j = { 0.2, -0.34, 0 },
			ph = math.pi,
		}, true)
		ajouter(
			l,
			{ n = "Champi", t = { 0.1, 0.06, 0.1 }, p = { -0.37, 0.05, 0.1 }, c = { 230, 70, 60 } }
		)
		ajouter(l, {
			n = "Champi2",
			t = { 0.08, 0.05, 0.08 },
			p = { -0.37, -0.12, -0.05 },
			c = { 230, 70, 60 },
		})
	end)
end
