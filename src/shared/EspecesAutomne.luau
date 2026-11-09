--!strict
-- Bestiaire du biome 18 : Forêt d'Automne (feuilles rousses, glands, champignons).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local ROUX = { 210, 110, 50 }
	local BRUN = { 120, 80, 55 }
	local FEUILLES = { { 230, 90, 40 }, { 245, 170, 50 }, { 200, 60, 40 } }

	-- Petite feuille d'automne (rouge, orange ou dorée).
	local function feuille(
		l: any,
		nom: string,
		p: { number },
		i: number,
		role: string?,
		j: { number }?
	)
		ajouter(l, {
			n = nom,
			t = { 0.12, 0.02, 0.08 },
			p = p,
			r = { 0, i * 40, 20 },
			c = FEUILLES[(i % 3) + 1],
			a = role,
			j = j,
		})
	end

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : hérisson qui porte une pomme sur ses piquants.
	definir("Herissou", 0.5, function(l)
		local tete = { 0, -0.28, -0.2 }
		ajouter(l, { n = "Piquants", t = { 0.46, 0.32, 0.46 }, p = { 0, -0.28, 0.06 }, c = BRUN })
		for i, pos in { { 0.16, -0.08, 0.0 }, { -0.14, -0.1, 0.14 }, { 0.0, -0.06, 0.2 } } do
			ajouter(l, {
				n = "Pic" .. i,
				t = { 0.06, 0.12, 0.06 },
				p = pos,
				r = { 20, i * 50, 0 },
				c = { 90, 60, 40 },
			})
		end
		ajouter(l, {
			n = "Pomme",
			f = "Ball",
			t = { 0.14, 0.14, 0.14 },
			p = { 0.06, -0.04, 0.04 },
			c = "Rarete",
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.18, 0.2 },
			p = { 0, -0.32, -0.24 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.08, 0.06, 0.08 },
			p = { 0, -0.34, -0.37 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.04, 0.04, 0.02 },
			p = { 0, -0.32, -0.42 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, -0.28, -0.345, 0.05, "Tete", tete)
		ajouter(l, {
			n = "Pied",
			t = { 0.08, 0.06, 0.08 },
			p = { 0.12, -0.47, -0.08 },
			c = CREME,
			a = "Patte",
			j = { 0.12, -0.44, -0.06 },
			ph = 0,
		}, true)
	end)

	-- Commune : écureuil au gros panache.
	definir("Ecurouille", 0.75, function(l)
		local tete = { 0, 0.02, -0.08 }
		ajouter(l, { n = "Corps", t = { 0.26, 0.32, 0.26 }, p = { 0, -0.26, -0.02 }, c = ROUX })
		ajouter(l, { n = "Ventre", t = { 0.16, 0.22, 0.03 }, p = { 0, -0.26, -0.155 }, c = CREME })
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.24 },
			p = { 0, 0.04, -0.08 },
			c = ROUX,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.06, -0.205, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.05, 0.1, 0.04 },
			p = { 0.09, 0.2, -0.06 },
			c = ROUX,
			a = "Oreille",
			j = { 0.09, 0.16, -0.06 },
		}, true)
		ajouter(l, {
			n = "Gland",
			t = { 0.08, 0.1, 0.08 },
			p = { 0, -0.12, -0.2 },
			c = { 170, 120, 60 },
			a = "Bras",
			j = { 0, -0.1, -0.14 },
			ph = 0,
		})
		ajouter(l, {
			n = "Chapeau",
			t = { 0.1, 0.04, 0.1 },
			p = { 0, -0.06, -0.2 },
			c = BRUN,
			a = "Bras",
			j = { 0, -0.1, -0.14 },
			ph = 0,
		})
		local queue = { 0, -0.34, 0.12 }
		ajouter(l, {
			n = "Queue",
			t = { 0.2, 0.2, 0.2 },
			p = { 0, -0.26, 0.24 },
			c = ROUX,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Queue2",
			t = { 0.22, 0.28, 0.18 },
			p = { 0, 0.0, 0.3 },
			c = ROUX,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.18, 0.1, 0.14 },
			p = { 0, 0.16, 0.24 },
			c = "Rarete",
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Pied",
			t = { 0.08, 0.06, 0.12 },
			p = { 0.08, -0.47, -0.04 },
			c = ROUX,
			a = "Patte",
			j = { 0.08, -0.44, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Rare : gland à chapeau qui sautille.
	definir("Glandou", 0.6, function(l)
		local corps = { 0, -0.24, 0 }
		ajouter(l, {
			n = "Gland",
			f = "Ball",
			t = { 0.42, 0.5, 0.42 },
			p = { 0, -0.24, 0 },
			c = { 190, 140, 70 },
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Chapeau",
			t = { 0.48, 0.16, 0.48 },
			p = { 0, 0.02, 0 },
			c = BRUN,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.1, 0.04 },
			p = { 0, 0.14, 0 },
			r = { 0, 0, 15 },
			c = BRUN,
			a = "Antenne",
			j = corps,
		})
		feuille(l, "Feuille", { 0.08, 0.14, 0.0 }, 1, "Antenne", corps)
		yeux(l, 0.08, -0.18, -0.21, 0.08, "Antenne", corps)
		ajouter(l, {
			n = "Joue",
			t = { 0.05, 0.03, 0.02 },
			p = { 0.13, -0.26, -0.205 },
			c = ROSE,
			a = "Antenne",
			j = corps,
		}, true)
		ajouter(l, {
			n = "Rayure",
			t = { 0.43, 0.03, 0.43 },
			p = { 0, -0.06, 0 },
			c = "Rarete",
			a = "Antenne",
			j = corps,
		})
	end)

	-- Rare : faon roux tacheté de blanc.
	definir("Faonroux", 0.85, function(l)
		local tete = { 0, 0.1, -0.18 }
		ajouter(l, { n = "Corps", t = { 0.26, 0.24, 0.44 }, p = { 0, -0.08, 0.06 }, c = ROUX })
		for i, pos in { { 0.131, -0.04, -0.04 }, { 0.131, -0.1, 0.12 }, { 0.131, 0.0, 0.2 } } do
			ajouter(l, { n = "Tache" .. i, t = { 0.02, 0.04, 0.04 }, p = pos, c = BLANC }, true)
		end
		pattes4(l, 0.08, -0.08, 0.22, { 0.05, 0.3, 0.05 }, ROUX)
		ajouter(l, {
			n = "Cou",
			t = { 0.1, 0.18, 0.1 },
			p = { 0, 0.08, -0.16 },
			r = { -20, 0, 0 },
			c = ROUX,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.2, 0.18, 0.22 },
			p = { 0, 0.22, -0.24 },
			c = ROUX,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.1, 0.08, 0.06 },
			p = { 0, 0.18, -0.37 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.04, 0.03, 0.02 },
			p = { 0, 0.2, -0.405 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, 0.26, -0.355, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.06, 0.03 },
			p = { 0.13, 0.3, -0.22 },
			r = { 0, 0, -20 },
			c = ROUX,
			a = "Oreille",
			j = { 0.1, 0.3, -0.22 },
		}, true)
		feuille(l, "Feuille", { 0.06, 0.33, -0.22 }, 2, "Tete", tete)
		ajouter(l, {
			n = "Queue",
			t = { 0.06, 0.08, 0.04 },
			p = { 0, 0.0, 0.3 },
			c = "Rarete",
			a = "Queue",
			j = { 0, 0.02, 0.28 },
		})
	end, "Pelage")

	-- Épique : blaireau au masque rayé.
	definir("Blairou", 0.55, function(l)
		local gris = { 140, 140, 145 }
		local tete = { 0, -0.24, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.38, 0.26, 0.56 }, p = { 0, -0.3, 0.06 }, c = gris })
		pattes4(l, 0.13, -0.12, 0.22, { 0.1, 0.1, 0.1 }, NOIR)
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.22, 0.24 },
			p = { 0, -0.24, -0.32 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bande",
			t = { 0.06, 0.225, 0.25 },
			p = { 0.08, -0.24, -0.32 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Museau",
			t = { 0.12, 0.08, 0.08 },
			p = { 0, -0.28, -0.47 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.04, 0.02 },
			p = { 0, -0.26, -0.515 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.08, -0.2, -0.445 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(
			l,
			{ n = "Echarpe", t = { 0.32, 0.06, 0.08 }, p = { 0, -0.3, -0.18 }, c = "Rarete" }
		)
		ajouter(l, {
			n = "Pan",
			t = { 0.06, 0.14, 0.04 },
			p = { 0.1, -0.36, -0.22 },
			c = "Rarete",
			a = "Queue",
			j = { 0.1, -0.3, -0.22 },
		})
	end)

	-- Épique : chouette rousse aux grands yeux ronds.
	definir("Chouetterousse", 0.75, function(l)
		local plume = { 190, 110, 60 }
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Corps", t = { 0.38, 0.42, 0.34 }, p = { 0, -0.2, 0.02 }, c = plume })
		ajouter(
			l,
			{ n = "Plastron", t = { 0.26, 0.28, 0.03 }, p = { 0, -0.22, -0.155 }, c = CREME }
		)
		ajouter(l, {
			n = "Tete",
			t = { 0.42, 0.28, 0.34 },
			p = { 0, 0.14, 0 },
			c = plume,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Disque",
			t = { 0.34, 0.22, 0.03 },
			p = { 0, 0.14, -0.175 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.16, -0.195, 0.11, "Tete", tete)
		ajouter(l, {
			n = "Bec",
			t = { 0.05, 0.06, 0.04 },
			p = { 0, 0.07, -0.2 },
			c = { 240, 190, 70 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.3, 0.26 },
			p = { 0.21, -0.18, 0.04 },
			c = BRUN,
			a = "Aile",
			j = { 0.19, -0.06, 0.02 },
		}, true)
		feuille(l, "Feuille", { 0.1, 0.3, 0.0 }, 0, "Tete", tete)
		ajouter(l, {
			n = "Plume",
			t = { 0.06, 0.1, 0.04 },
			p = { -0.1, 0.31, 0.02 },
			r = { 0, 0, 20 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Serre",
			t = { 0.06, 0.06, 0.08 },
			p = { 0.08, -0.45, -0.04 },
			c = { 240, 190, 70 },
			a = "Patte",
			j = { 0.08, -0.4, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Légendaire : ourson brun avec un pot de miel.
	definir("Oursautomne", 0.85, function(l)
		local tete = { 0, 0.12, -0.04 }
		ajouter(l, { n = "Corps", t = { 0.46, 0.42, 0.38 }, p = { 0, -0.24, 0.04 }, c = BRUN })
		ajouter(l, {
			n = "Ventre",
			t = { 0.28, 0.28, 0.03 },
			p = { 0, -0.24, -0.165 },
			c = { 190, 150, 110 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.38, 0.32, 0.32 },
			p = { 0, 0.16, -0.04 },
			c = BRUN,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.16, 0.1, 0.06 },
			p = { 0, 0.1, -0.22 },
			c = { 190, 150, 110 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.06, 0.04, 0.02 },
			p = { 0, 0.13, -0.255 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.2, -0.205, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.1, 0.06 },
			p = { 0.15, 0.34, -0.04 },
			c = BRUN,
			a = "Oreille",
			j = { 0.13, 0.3, -0.04 },
		}, true)
		ajouter(
			l,
			{ n = "Pot", t = { 0.18, 0.18, 0.16 }, p = { 0, -0.22, -0.26 }, c = { 220, 160, 80 } }
		)
		ajouter(l, {
			n = "Miel",
			t = { 0.19, 0.06, 0.17 },
			p = { 0, -0.12, -0.26 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.12, 0.24, 0.12 },
			p = { 0.24, -0.16, -0.12 },
			r = { -40, 0, -20 },
			c = BRUN,
			a = "Bras",
			j = { 0.22, -0.06, -0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.14, 0.1, 0.18 },
			p = { 0.14, -0.45, -0.04 },
			c = BRUN,
			a = "Patte",
			j = { 0.14, -0.4, 0 },
			ph = math.pi,
		}, true)
	end, "Pelage")

	-- Légendaire : sanglier aux défenses dorées.
	definir("Sanglor", 0.65, function(l)
		local poil = { 90, 70, 60 }
		local tete = { 0, -0.12, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.34, 0.56 }, p = { 0, -0.18, 0.06 }, c = poil })
		ajouter(
			l,
			{ n = "Hure", t = { 0.06, 0.12, 0.44 }, p = { 0, 0.02, 0.04 }, c = { 60, 45, 40 } }
		)
		pattes4(l, 0.13, -0.1, 0.24, { 0.09, 0.14, 0.09 }, poil)
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.28, 0.26 },
			p = { 0, -0.12, -0.32 },
			c = poil,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Groin",
			t = { 0.16, 0.12, 0.06 },
			p = { 0, -0.18, -0.47 },
			c = { 200, 150, 140 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Defense",
			t = { 0.04, 0.12, 0.04 },
			p = { 0.1, -0.1, -0.46 },
			r = { -20, 0, -25 },
			c = "Rarete",
			m = "Foil",
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.08, -0.04, -0.455, 0.05, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.1, 0.04 },
			p = { 0.13, 0.06, -0.28 },
			c = poil,
			a = "Oreille",
			j = { 0.12, 0.02, -0.28 },
		}, true)
		feuille(l, "Feuille", { -0.06, 0.08, -0.04 }, 2)
		ajouter(l, {
			n = "Queue",
			t = { 0.03, 0.14, 0.03 },
			p = { 0, -0.08, 0.36 },
			c = poil,
			a = "Queue",
			j = { 0, -0.02, 0.34 },
		})
	end)

	-- Mythique : tourbillon de feuilles avec deux yeux.
	definir("Tourbillonne", 0.85, function(l)
		local axe = { 0, -0.1, 0 }
		for i = 0, 11 do
			local a = math.rad(i * 30)
			local r = 0.12 + i * 0.016
			feuille(
				l,
				"Feuille" .. i,
				{ math.cos(a) * r, -0.42 + i * 0.07, math.sin(a) * r },
				i,
				"Antenne",
				axe
			)
		end
		ajouter(l, {
			n = "Coeur",
			f = "Ball",
			t = { 0.24, 0.24, 0.24 },
			p = { 0, -0.06, 0 },
			c = "Rarete",
			m = "Neon",
			tr = 0.3,
		})
		ajouter(l, { n = "OeilG", t = { 0.05, 0.07, 0.02 }, p = { -0.06, -0.04, -0.13 }, c = NOIR })
		ajouter(l, { n = "OeilD", t = { 0.05, 0.07, 0.02 }, p = { 0.06, -0.04, -0.13 }, c = NOIR })
		ajouter(l, { n = "Sourire", t = { 0.08, 0.02, 0.02 }, p = { 0, -0.12, -0.13 }, c = NOIR })
	end)

	-- Mythique : cerf royal aux bois couverts de feuilles d'or.
	definir("Cerfroi", 0.98, function(l)
		local robe = { 170, 100, 60 }
		local tete = { 0, 0.12, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.28, 0.5 }, p = { 0, -0.1, 0.06 }, c = robe })
		ajouter(l, { n = "Poitrail", t = { 0.26, 0.2, 0.06 }, p = { 0, -0.04, -0.2 }, c = CREME })
		pattes4(l, 0.1, -0.1, 0.24, { 0.06, 0.28, 0.06 }, robe)
		ajouter(l, {
			n = "Cou",
			t = { 0.12, 0.2, 0.12 },
			p = { 0, 0.1, -0.18 },
			r = { -20, 0, 0 },
			c = robe,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.18, 0.18, 0.24 },
			p = { 0, 0.22, -0.26 },
			c = robe,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.04, 0.02 },
			p = { 0, 0.18, -0.385 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, 0.26, -0.385, 0.05, "Tete", tete)
		ajouter(l, {
			n = "Bois",
			t = { 0.03, 0.22, 0.03 },
			p = { 0.08, 0.42, -0.22 },
			r = { 0, 0, -25 },
			c = { 220, 200, 160 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Andouiller",
			t = { 0.12, 0.03, 0.03 },
			p = { 0.16, 0.46, -0.22 },
			r = { 0, 0, 20 },
			c = { 220, 200, 160 },
			a = "Tete",
			j = tete,
		}, true)
		for i, pos in
			{
				{ 0.2, 0.52, -0.22 },
				{ -0.2, 0.52, -0.22 },
				{ 0.12, 0.56, -0.2 },
				{ -0.12, 0.56, -0.2 },
			}
		do
			ajouter(l, {
				n = "FeuilleOr" .. i,
				t = { 0.08, 0.02, 0.06 },
				p = pos,
				r = { 0, i * 40, 20 },
				c = "Rarete",
				m = "Neon",
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Queue",
			t = { 0.06, 0.08, 0.04 },
			p = { 0, 0.0, 0.32 },
			c = CREME,
			a = "Queue",
			j = { 0, 0.02, 0.3 },
		})
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : bogue de châtaigne hérissée.
	definir("Chataigneux", 0.55, function(l)
		local corps = { 0, -0.24, 0 }
		ajouter(l, {
			n = "Bogue",
			f = "Ball",
			t = { 0.54, 0.5, 0.54 },
			p = { 0, -0.24, 0 },
			c = { 150, 180, 70 },
			a = "Antenne",
			j = corps,
		})
		for i = 0, 9 do
			local a = math.rad(i * 36)
			ajouter(l, {
				n = "Pic" .. i,
				t = { 0.04, 0.04, 0.16 },
				p = { math.cos(a) * 0.3, -0.16 + (i % 2) * 0.1, math.sin(a) * 0.3 },
				r = { 0, -i * 36 + 90, 0 },
				c = { 120, 150, 50 },
				a = "Antenne",
				j = corps,
			})
		end
		ajouter(
			l,
			{ n = "Fente", t = { 0.3, 0.14, 0.02 }, p = { 0, -0.2, -0.27 }, c = { 140, 80, 50 } }
		)
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.05, 0.02 },
			p = { 0.07, -0.18, -0.285 },
			c = { 255, 220, 60 },
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.08, 0.03, 0.02 },
			p = { 0.07, -0.12, -0.29 },
			r = { 0, 0, 25 },
			c = NOIR,
		}, true)
	end)

	-- Moyenne : épouvantail qui se met à courir.
	definir("Epouvantou", 0.95, function(l)
		local tete = { 0, 0.26, 0 }
		ajouter(l, {
			n = "Piquet",
			t = { 0.06, 0.6, 0.06 },
			p = { 0, -0.2, 0 },
			c = BRUN,
			a = "Patte",
			j = { 0, 0.0, 0 },
		})
		ajouter(
			l,
			{ n = "Chemise", t = { 0.34, 0.3, 0.2 }, p = { 0, 0.02, 0 }, c = { 90, 130, 190 } }
		)
		ajouter(l, {
			n = "Carreau",
			t = { 0.1, 0.1, 0.02 },
			p = { 0.08, 0.04, -0.105 },
			c = { 220, 70, 60 },
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.3, 0.06, 0.06 },
			p = { 0.3, 0.1, 0 },
			c = BRUN,
			a = "Bras",
			j = { 0.16, 0.1, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Paille",
			t = { 0.08, 0.1, 0.08 },
			p = { 0.46, 0.06, 0 },
			c = { 240, 200, 90 },
			a = "Bras",
			j = { 0.16, 0.1, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.24 },
			p = { 0, 0.3, 0 },
			c = { 220, 190, 130 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.06, 0.32, -0.125 },
			c = { 255, 140, 40 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Couture",
			t = { 0.14, 0.02, 0.02 },
			p = { 0, 0.24, -0.125 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Chapeau",
			t = { 0.36, 0.04, 0.36 },
			p = { 0, 0.43, 0 },
			r = { 0, 0, 8 },
			c = BRUN,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Calotte",
			t = { 0.2, 0.12, 0.2 },
			p = { 0, 0.5, 0 },
			r = { 0, 0, 8 },
			c = BRUN,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corbeau",
			t = { 0.1, 0.08, 0.14 },
			p = { 0.12, 0.6, 0.02 },
			c = NOIR,
			a = "Antenne",
			j = { 0.12, 0.56, 0 },
		})
	end)

	-- Lointaine : vieille souche grognonne aux racines-pattes.
	definir("Souchegrogne", 0.85, function(l)
		local ecorce = { 110, 80, 60 }
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Souche", t = { 0.7, 0.6, 0.66 }, p = { 0, -0.1, 0 }, c = ecorce })
		ajouter(
			l,
			{ n = "Cernes", t = { 0.6, 0.04, 0.56 }, p = { 0, 0.22, 0 }, c = { 210, 170, 120 } }
		)
		ajouter(
			l,
			{ n = "Cerne", t = { 0.3, 0.045, 0.28 }, p = { 0, 0.22, 0 }, c = { 170, 130, 90 } }
		)
		for i, pos in { { 0.2, 0.25, 0.1 }, { -0.18, 0.25, -0.12 } } do
			ajouter(
				l,
				{ n = "Champignon" .. i, t = { 0.14, 0.06, 0.14 }, p = pos, c = { 220, 70, 50 } }
			)
		end
		feuille(l, "Feuille", { -0.1, 0.25, 0.16 }, 1)
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.07, 0.03 },
			p = { 0.14, 0.06, -0.335 },
			c = { 255, 200, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.16, 0.05, 0.04 },
			p = { 0.14, 0.13, -0.335 },
			r = { 0, 0, 25 },
			c = { 70, 50, 40 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.3, 0.08, 0.03 },
			p = { 0, -0.14, -0.335 },
			c = { 50, 30, 25 },
			a = "Machoire",
			j = { 0, -0.12, -0.28 },
		})
		ajouter(l, {
			n = "Racine",
			t = { 0.12, 0.12, 0.3 },
			p = { 0.3, -0.44, -0.1 },
			r = { 0, 30, 0 },
			c = ecorce,
			a = "Patte",
			j = { 0.24, -0.4, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Branche",
			t = { 0.28, 0.08, 0.08 },
			p = { 0.44, 0.06, 0 },
			r = { 0, 0, 30 },
			c = ecorce,
			a = "Bras",
			j = { 0.32, 0.0, 0 },
			ph = 0,
		}, true)
	end)
end
