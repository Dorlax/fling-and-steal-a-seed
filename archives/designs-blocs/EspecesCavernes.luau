--!strict
-- Bestiaire du biome 16 : Cavernes Lumineuses (cristaux, champignons qui brillent).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE = o.BLANC, o.NOIR, o.ROSE

	local ROCHE = { 95, 90, 110 }
	local CRISTAL = { 120, 220, 255 }
	local AMETHYSTE = { 190, 110, 255 }
	local LUEUR = { 140, 255, 200 }

	-- Pointe de cristal (bloc incliné, brillant).
	local function cristal(
		l: any,
		nom: string,
		p: { number },
		h: number,
		r: { number },
		c: any,
		role: string?,
		j: { number }?
	)
		ajouter(l, {
			n = nom,
			t = { h * 0.35, h, h * 0.35 },
			p = p,
			r = r,
			c = c,
			m = "Neon",
			tr = 0.15,
			a = role,
			j = j,
		})
	end

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : taupe mineuse avec une lampe frontale.
	definir("Taupinou", 0.55, function(l)
		local peau = { 90, 80, 100 }
		local tete = { 0, -0.18, -0.16 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.32, 0.46 }, p = { 0, -0.3, 0.04 }, c = peau })
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.24, 0.22 },
			p = { 0, -0.18, -0.24 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Nez",
			t = { 0.1, 0.08, 0.08 },
			p = { 0, -0.22, -0.38 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilG",
			t = { 0.05, 0.02, 0.02 },
			p = { -0.07, -0.13, -0.355 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilD",
			t = { 0.05, 0.02, 0.02 },
			p = { 0.07, -0.13, -0.355 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Casque",
			t = { 0.32, 0.08, 0.24 },
			p = { 0, -0.04, -0.22 },
			c = { 255, 200, 50 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Lampe",
			t = { 0.08, 0.08, 0.04 },
			p = { 0, -0.04, -0.35 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Griffe",
			t = { 0.14, 0.06, 0.12 },
			p = { 0.22, -0.42, -0.14 },
			c = ROSE,
			a = "Bras",
			j = { 0.18, -0.38, -0.1 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.1, 0.06, 0.1 },
			p = { 0.14, -0.47, 0.18 },
			c = ROSE,
			a = "Patte",
			j = { 0.14, -0.44, 0.18 },
			ph = math.pi,
		}, true)
	end)

	-- Commune : petite luciole des grottes.
	definir("Luciolette", 0.6, function(l)
		local corps = { 60, 50, 80 }
		ajouter(l, { n = "Tete", t = { 0.26, 0.24, 0.24 }, p = { 0, -0.06, -0.14 }, c = corps })
		yeux(l, 0.07, -0.04, -0.265, 0.08)
		ajouter(l, { n = "Thorax", t = { 0.22, 0.2, 0.2 }, p = { 0, -0.1, 0.06 }, c = corps })
		ajouter(l, {
			n = "Lanterne",
			t = { 0.26, 0.24, 0.28 },
			p = { 0, -0.16, 0.28 },
			c = "Rarete",
			m = "Neon",
			a = "Queue",
			j = { 0, -0.12, 0.16 },
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.3, 0.02, 0.16 },
			p = { 0.18, 0.06, 0.06 },
			r = { 0, -15, 10 },
			c = { 200, 230, 255 },
			tr = 0.4,
			a = "Aile",
			j = { 0.06, 0.02, 0.06 },
		}, true)
		ajouter(l, {
			n = "Antenne",
			t = { 0.02, 0.16, 0.02 },
			p = { 0.06, 0.12, -0.18 },
			r = { -20, 0, -15 },
			c = corps,
			a = "Antenne",
			j = { 0.05, 0.05, -0.16 },
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.02, 0.2, 0.02 },
			p = { 0.08, -0.34, 0.04 },
			c = corps,
			a = "Patte",
			j = { 0.08, -0.22, 0.04 },
			ph = 0,
		}, true)
	end)

	-- Rare : tortue à carapace de géode.
	definir("Geodou", 0.6, function(l)
		local peau = { 140, 160, 140 }
		local tete = { 0, -0.26, -0.26 }
		ajouter(l, { n = "Carapace", t = { 0.5, 0.26, 0.54 }, p = { 0, -0.24, 0.02 }, c = ROCHE })
		ajouter(l, {
			n = "Geode",
			t = { 0.3, 0.06, 0.32 },
			p = { 0, -0.1, 0.02 },
			c = AMETHYSTE,
			m = "Neon",
		})
		cristal(l, "Pointe", { 0.08, 0.0, 0.02 }, 0.2, { 0, 0, -15 }, "Rarete")
		cristal(l, "Pointe2", { -0.08, -0.02, 0.06 }, 0.16, { 0, 0, 15 }, CRISTAL)
		ajouter(l, {
			n = "Tete",
			t = { 0.18, 0.16, 0.18 },
			p = { 0, -0.28, -0.34 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.05, -0.25, -0.435, 0.05, "Tete", tete)
		pattes4(l, 0.2, -0.16, 0.2, { 0.1, 0.12, 0.12 }, peau)
	end)

	-- Rare : champignon lumineux qui gigote.
	definir("Champilume", 0.75, function(l)
		local chapeau = { 0, 0.06, 0 }
		ajouter(
			l,
			{ n = "Pied", t = { 0.24, 0.42, 0.24 }, p = { 0, -0.29, 0 }, c = { 230, 225, 240 } }
		)
		yeux(l, 0.06, -0.2, -0.125, 0.07)
		ajouter(l, {
			n = "Sourire",
			t = { 0.06, 0.02, 0.02 },
			p = { 0, -0.3, -0.125 },
			c = { 90, 80, 110 },
		})
		ajouter(l, {
			n = "Chapeau",
			t = { 0.6, 0.18, 0.6 },
			p = { 0, 0.04, 0 },
			c = { 80, 200, 220 },
			m = "Neon",
			tr = 0.1,
			a = "Antenne",
			j = chapeau,
		})
		ajouter(l, {
			n = "Dome",
			t = { 0.4, 0.14, 0.4 },
			p = { 0, 0.18, 0 },
			c = { 80, 200, 220 },
			m = "Neon",
			tr = 0.1,
			a = "Antenne",
			j = chapeau,
		})
		for i, pos in { { 0.18, 0.14, -0.12 }, { -0.16, 0.16, 0.08 }, { 0.04, 0.26, 0.04 } } do
			ajouter(l, {
				n = "Pois" .. i,
				t = { 0.07, 0.04, 0.07 },
				p = pos,
				c = "Rarete",
				a = "Antenne",
				j = chapeau,
			})
		end
		ajouter(l, {
			n = "Bras",
			t = { 0.05, 0.14, 0.05 },
			p = { 0.15, -0.24, 0 },
			r = { 0, 0, -30 },
			c = { 230, 225, 240 },
			a = "Bras",
			j = { 0.12, -0.18, 0 },
			ph = 0,
		}, true)
	end)

	-- Épique : axolotl rose aux branchies lumineuses.
	definir("Axolumi", 0.5, function(l)
		local rose = { 255, 170, 200 }
		local tete = { 0, -0.26, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.2, 0.5 }, p = { 0, -0.38, 0.06 }, c = rose })
		ajouter(l, {
			n = "Tete",
			t = { 0.38, 0.24, 0.26 },
			p = { 0, -0.3, -0.28 },
			c = rose,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.1, -0.26, -0.415, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.16, 0.02, 0.02 },
			p = { 0, -0.36, -0.415 },
			c = { 150, 70, 100 },
			a = "Tete",
			j = tete,
		})
		for k = 0, 2 do
			ajouter(l, {
				n = "Branchie" .. k,
				t = { 0.18, 0.04, 0.04 },
				p = { 0.26, -0.2 - k * 0.06, -0.26 },
				r = { 0, 0, 30 - k * 30 },
				c = "Rarete",
				m = "Neon",
				a = "Oreille",
				j = { 0.18, -0.26, -0.26 },
				ph = k,
			}, true)
		end
		pattes4(l, 0.17, -0.08, 0.2, { 0.08, 0.08, 0.08 }, rose)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.16, 0.3 },
			p = { 0, -0.36, 0.44 },
			c = rose,
			tr = 0.1,
			a = "Queue",
			j = { 0, -0.36, 0.3 },
		})
	end, "Gelee")

	-- Épique : salamandre aux taches de braise.
	definir("Salamandrite", 0.45, function(l)
		local noir = { 40, 35, 50 }
		local tete = { 0, -0.34, -0.26 }
		ajouter(l, { n = "Corps", t = { 0.24, 0.16, 0.5 }, p = { 0, -0.42, 0.04 }, c = noir })
		for i, z in { -0.12, 0.04, 0.2 } do
			ajouter(l, {
				n = "Tache" .. i,
				t = { 0.1, 0.02, 0.08 },
				p = { (i % 2) * 0.08 - 0.04, -0.335, z },
				c = "Rarete",
				m = "Neon",
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.14, 0.2 },
			p = { 0, -0.38, -0.3 },
			c = noir,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.06, 0.04 },
			p = { 0.09, -0.3, -0.32 },
			c = { 255, 220, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		pattes4(l, 0.15, -0.12, 0.18, { 0.08, 0.06, 0.08 }, noir)
		ajouter(l, {
			n = "Queue",
			t = { 0.1, 0.1, 0.3 },
			p = { 0, -0.44, 0.42 },
			c = noir,
			a = "Queue",
			j = { 0, -0.44, 0.28 },
		})
	end, "Ecailles")

	-- Légendaire : loup aux cristaux dorsaux.
	definir("Cristaloup", 0.8, function(l)
		local pelage = { 120, 130, 170 }
		local tete = { 0, 0.02, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.32, 0.3, 0.56 }, p = { 0, -0.14, 0.06 }, c = pelage })
		for i, z in { -0.1, 0.06, 0.22 } do
			cristal(
				l,
				"Cristal" .. i,
				{ 0, 0.06, z },
				0.22 - i * 0.03,
				{ -15, 0, 0 },
				if i == 1 then "Rarete" else CRISTAL
			)
		end
		pattes4(l, 0.11, -0.12, 0.26, { 0.09, 0.2, 0.09 }, pelage)
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.24 },
			p = { 0, 0.04, -0.32 },
			c = pelage,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.14, 0.1, 0.12 },
			p = { 0, -0.02, -0.48 },
			c = { 200, 205, 225 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.04, 0.02 },
			p = { 0, 0.02, -0.545 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.04, 0.02 },
			p = { 0.08, 0.08, -0.445 },
			c = CRISTAL,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.07, 0.12, 0.04 },
			p = { 0.09, 0.2, -0.3 },
			c = pelage,
			a = "Oreille",
			j = { 0.09, 0.15, -0.3 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.1, 0.1, 0.3 },
			p = { 0, -0.02, 0.44 },
			r = { 30, 0, 0 },
			c = pelage,
			a = "Queue",
			j = { 0, -0.08, 0.32 },
		})
	end, "Pelage")

	-- Légendaire : golem de roche serti de gemmes.
	definir("Golemite", 0.9, function(l)
		local tete = { 0, 0.22, 0 }
		ajouter(l, { n = "Torse", t = { 0.5, 0.44, 0.36 }, p = { 0, -0.04, 0 }, c = ROCHE })
		ajouter(l, {
			n = "Gemme",
			t = { 0.14, 0.14, 0.04 },
			p = { 0, 0.0, -0.19 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.24, 0.26 },
			p = { 0, 0.3, 0 },
			c = ROCHE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.04, 0.02 },
			p = { 0.07, 0.32, -0.135 },
			c = LUEUR,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		cristal(l, "Couronne", { 0.08, 0.48, 0 }, 0.16, { 0, 0, -20 }, AMETHYSTE, "Tete", tete)
		cristal(l, "Couronne2", { -0.06, 0.46, 0.04 }, 0.12, { 0, 0, 20 }, CRISTAL, "Tete", tete)
		ajouter(l, {
			n = "Bras",
			t = { 0.14, 0.4, 0.16 },
			p = { 0.33, -0.1, 0 },
			c = ROCHE,
			a = "Bras",
			j = { 0.3, 0.12, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.14, 0.2, 0.16 },
			p = { 0.13, -0.4, 0 },
			c = ROCHE,
			a = "Patte",
			j = { 0.13, -0.3, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Mythique : petit dragon de quartz translucide.
	definir("Dracoquartz", 0.85, function(l)
		local quartz = { 230, 210, 255 }
		local tete = { 0, 0.12, -0.2 }
		ajouter(l, {
			n = "Corps",
			t = { 0.32, 0.3, 0.46 },
			p = { 0, -0.14, 0.06 },
			c = quartz,
			m = "Glass",
			tr = 0.2,
		})
		ajouter(l, {
			n = "Coeur",
			t = { 0.14, 0.14, 0.14 },
			p = { 0, -0.12, 0.04 },
			r = { 45, 45, 0 },
			c = "Rarete",
			m = "Neon",
		})
		pattes4(l, 0.12, -0.08, 0.22, { 0.08, 0.16, 0.08 }, quartz)
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.22, 0.28 },
			p = { 0, 0.14, -0.3 },
			c = quartz,
			m = "Glass",
			tr = 0.2,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.08, 0.18, -0.445 },
			c = AMETHYSTE,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		cristal(l, "Corne", { 0.08, 0.32, -0.24 }, 0.16, { 25, 0, -15 }, AMETHYSTE, "Tete", tete)
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.26, 0.3 },
			p = { 0.22, 0.08, 0.06 },
			r = { 15, 0, -30 },
			c = CRISTAL,
			m = "Neon",
			tr = 0.4,
			a = "Aile",
			j = { 0.16, -0.04, 0.06 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.08, 0.32 },
			p = { 0, -0.12, 0.42 },
			c = quartz,
			m = "Glass",
			tr = 0.2,
			a = "Queue",
			j = { 0, -0.12, 0.28 },
		})
	end)

	-- Mythique : fée des gemmes aux ailes de cristal.
	definir("Gemmelune", 0.9, function(l)
		local tete = { 0, 0.12, 0 }
		ajouter(l, { n = "Robe", t = { 0.3, 0.36, 0.26 }, p = { 0, -0.24, 0 }, c = AMETHYSTE })
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.24 },
			p = { 0, 0.06, 0 },
			c = { 240, 230, 255 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, 0.06, -0.125, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Cheveux",
			t = { 0.3, 0.12, 0.28 },
			p = { 0, 0.2, 0.02 },
			c = { 120, 200, 255 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Diademe",
			t = { 0.08, 0.08, 0.04 },
			p = { 0, 0.26, -0.13 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		cristal(
			l,
			"Aile",
			{ 0.2, 0.0, 0.16 },
			0.34,
			{ 20, 0, -40 },
			CRISTAL,
			"Aile",
			{ 0.08, -0.06, 0.1 }
		)
		cristal(
			l,
			"Aile2",
			{ -0.2, 0.0, 0.16 },
			0.34,
			{ 20, 0, 40 },
			CRISTAL,
			"Aile",
			{ -0.08, -0.06, 0.1 }
		)
		ajouter(l, {
			n = "Baguette",
			t = { 0.02, 0.2, 0.02 },
			p = { 0.2, -0.16, -0.06 },
			r = { -20, 0, -10 },
			c = BLANC,
			a = "Bras",
			j = { 0.14, -0.08, 0 },
			ph = 0,
		})
		ajouter(l, {
			n = "Etoile",
			t = { 0.06, 0.06, 0.02 },
			p = { 0.22, -0.04, -0.1 },
			r = { 0, 0, 45 },
			c = LUEUR,
			m = "Neon",
			a = "Bras",
			j = { 0.14, -0.08, 0 },
			ph = 0,
		})
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : stalagmite vivante qui mord.
	definir("Stalagmord", 0.85, function(l)
		local tete = { 0, 0.0, 0 }
		ajouter(l, { n = "Base", t = { 0.5, 0.3, 0.5 }, p = { 0, -0.35, 0 }, c = ROCHE })
		ajouter(l, {
			n = "Milieu",
			t = { 0.36, 0.34, 0.36 },
			p = { 0, -0.04, 0 },
			c = ROCHE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.2, 0.26, 0.2 },
			p = { 0, 0.26, 0 },
			c = ROCHE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.05, 0.02 },
			p = { 0.08, 0.04, -0.19 },
			c = { 255, 120, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Gueule",
			t = { 0.24, 0.06, 0.02 },
			p = { 0, -0.1, -0.19 },
			c = NOIR,
			a = "Machoire",
			j = { 0, -0.08, -0.14 },
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.03, 0.05, 0.02 },
			p = { 0.06, -0.08, -0.2 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		cristal(l, "Eclat", { 0.2, -0.24, -0.1 }, 0.16, { 0, 0, -25 }, CRISTAL)
	end)

	-- Moyenne : ver de roche qui surgit du sol.
	definir("Vercaillou", 0.85, function(l)
		local peau = { 140, 110, 100 }
		local tete = { 0, 0.26, -0.04 }
		for k = 0, 3 do
			ajouter(l, {
				n = "Anneau" .. k,
				t = { 0.3 - k * 0.02, 0.18, 0.3 - k * 0.02 },
				p = { math.sin(k) * 0.05, -0.4 + k * 0.17, 0 },
				c = if k % 2 == 0 then peau else ROCHE,
				a = "Queue",
				j = { 0, -0.4, 0 },
				ph = k,
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.22, 0.3 },
			p = { 0, 0.32, -0.06 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Gueule",
			t = { 0.24, 0.1, 0.02 },
			p = { 0, 0.28, -0.215 },
			c = { 60, 30, 30 },
			a = "Machoire",
			j = { 0, 0.3, -0.18 },
		})
		for i, x in { -0.08, 0, 0.08 } do
			ajouter(l, {
				n = "Dent" .. i,
				t = { 0.03, 0.04, 0.02 },
				p = { x, 0.31, -0.22 },
				c = BLANC,
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.1, 0.4, -0.215 },
			c = { 255, 220, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, { n = "Trou", t = { 0.5, 0.04, 0.5 }, p = { 0, -0.48, 0 }, c = { 60, 55, 60 } })
	end)

	-- Lointaine : gros rocher grondeur aux bras de pierre.
	definir("Rocgrondeur", 0.95, function(l)
		local tete = { 0, 0.18, 0 }
		ajouter(l, { n = "Corps", t = { 0.76, 0.6, 0.6 }, p = { 0, -0.06, 0 }, c = ROCHE })
		ajouter(l, {
			n = "Mousse",
			t = { 0.5, 0.06, 0.4 },
			p = { -0.08, 0.27, 0.04 },
			c = { 90, 160, 120 },
			m = "Neon",
			tr = 0.2,
		})
		for i, pos in { { 0.24, 0.3, 0.1 }, { -0.26, 0.28, -0.06 }, { 0.0, 0.34, 0.2 } } do
			cristal(
				l,
				"Cristal" .. i,
				pos,
				0.24,
				{ 0, 0, (i - 2) * 20 },
				if i == 2 then AMETHYSTE else CRISTAL
			)
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.06, 0.03 },
			p = { 0.16, 0.06, -0.31 },
			c = { 255, 90, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.16, 0.05, 0.04 },
			p = { 0.16, 0.13, -0.31 },
			r = { 0, 0, 25 },
			c = { 60, 55, 70 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Gueule",
			t = { 0.3, 0.08, 0.03 },
			p = { 0, -0.12, -0.31 },
			c = NOIR,
			a = "Machoire",
			j = { 0, -0.1, -0.24 },
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.2, 0.46, 0.22 },
			p = { 0.48, -0.08, -0.02 },
			c = ROCHE,
			a = "Bras",
			j = { 0.46, 0.14, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Poing",
			t = { 0.26, 0.2, 0.26 },
			p = { 0.48, -0.36, -0.04 },
			c = { 80, 75, 95 },
			a = "Bras",
			j = { 0.46, 0.14, -0.02 },
			ph = 0,
		}, true)
	end)
end
