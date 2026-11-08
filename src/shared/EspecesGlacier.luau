--!strict
-- Bestiaire du biome 4 : Glacier Givré (neige, glace, aurores).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE = o.BLANC, o.NOIR, o.ROSE

	local NEIGE = { 245, 250, 255 }
	local GLACE = { 160, 220, 255 }
	local GLACE_FONCEE = { 90, 160, 220 }
	local AURORE = { 120, 255, 200 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : manchot rond avec une écharpe.
	definir("Pingouinou", 0.68, function(l)
		local nuit = { 40, 45, 70 }
		local tete = { 0, 0.1, -0.02 }
		ajouter(l, { n = "Corps", t = { 0.5, 0.56, 0.44 }, p = { 0, -0.2, 0.02 }, c = nuit })
		ajouter(l, { n = "Ventre", t = { 0.36, 0.44, 0.03 }, p = { 0, -0.22, -0.205 }, c = NEIGE })
		ajouter(l, {
			n = "Tete",
			t = { 0.42, 0.3, 0.38 },
			p = { 0, 0.22, -0.02 },
			c = nuit,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Visage",
			t = { 0.3, 0.18, 0.03 },
			p = { 0, 0.2, -0.215 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.22, -0.235, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Bec",
			t = { 0.1, 0.06, 0.1 },
			p = { 0, 0.14, -0.27 },
			c = { 255, 170, 40 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Joue",
			t = { 0.05, 0.03, 0.02 },
			p = { 0.11, 0.15, -0.235 },
			c = ROSE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(
			l,
			{ n = "Echarpe", t = { 0.46, 0.07, 0.42 }, p = { 0, 0.06, 0.0 }, c = { 230, 70, 80 } }
		)
		ajouter(l, {
			n = "Pan",
			t = { 0.08, 0.16, 0.03 },
			p = { 0.12, -0.04, -0.215 },
			c = { 230, 70, 80 },
		})
		ajouter(l, {
			n = "Aileron",
			t = { 0.06, 0.3, 0.16 },
			p = { 0.28, -0.16, 0.02 },
			r = { 0, 0, -15 },
			c = nuit,
			a = "Aile",
			j = { 0.26, -0.04, 0.02 },
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.14, 0.05, 0.16 },
			p = { 0.1, -0.475, -0.08 },
			c = { 255, 170, 40 },
			a = "Patte",
			j = { 0.1, -0.45, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Commune : petit bonhomme de neige vivant, carotte et bonnet.
	definir("Bonhommeige", 0.82, function(l)
		local tete = { 0, 0.14, 0 }
		ajouter(l, { n = "Bas", t = { 0.5, 0.4, 0.5 }, p = { 0, -0.3, 0 }, c = NEIGE })
		ajouter(l, { n = "Haut", t = { 0.38, 0.3, 0.38 }, p = { 0, 0.04, 0 }, c = NEIGE })
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.3 },
			p = { 0, 0.32, 0 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.35, -0.165, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Carotte",
			t = { 0.05, 0.05, 0.14 },
			p = { 0, 0.3, -0.21 },
			c = { 255, 140, 40 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bonnet",
			t = { 0.32, 0.12, 0.32 },
			p = { 0, 0.5, 0 },
			c = { 80, 120, 230 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pompon",
			t = { 0.08, 0.08, 0.08 },
			p = { 0, 0.6, 0 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		for i, y in { 0.1, -0.02 } do
			ajouter(
				l,
				{ n = "Bouton" .. i, t = { 0.05, 0.05, 0.02 }, p = { 0, y, -0.2 }, c = NOIR }
			)
		end
		ajouter(l, {
			n = "Bras",
			t = { 0.24, 0.03, 0.03 },
			p = { 0.3, 0.06, 0 },
			r = { 0, 0, 25 },
			c = { 110, 75, 50 },
			a = "Bras",
			j = { 0.19, 0.04, 0 },
			ph = 0,
		}, true)
		ajouter(l, { n = "Echarpe", t = { 0.32, 0.05, 0.32 }, p = { 0, 0.2, 0 }, c = "Rarete" })
	end)

	-- Rare : bébé phoque tout blanc aux grands yeux.
	definir("Phoquinet", 0.5, function(l)
		local tete = { 0, -0.2, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.3, 0.7 }, p = { 0, -0.35, 0.06 }, c = NEIGE })
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.3, 0.3 },
			p = { 0, -0.18, -0.34 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.09, -0.13, -0.495, 0.11, "Tete", tete)
		ajouter(l, {
			n = "Truffe",
			t = { 0.06, 0.04, 0.02 },
			p = { 0, -0.22, -0.495 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Moustache",
			t = { 0.12, 0.012, 0.012 },
			p = { 0.1, -0.23, -0.495 },
			c = { 170, 180, 200 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Nageoire",
			t = { 0.16, 0.04, 0.12 },
			p = { 0.25, -0.47, -0.14 },
			r = { 0, 0, -15 },
			c = { 220, 230, 245 },
			a = "Patte",
			j = { 0.2, -0.45, -0.14 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.3, 0.04, 0.14 },
			p = { 0, -0.46, 0.47 },
			c = { 220, 230, 245 },
			a = "Queue",
			j = { 0, -0.44, 0.4 },
		})
		ajouter(
			l,
			{ n = "Tache", t = { 0.1, 0.02, 0.1 }, p = { 0.1, -0.195, 0.1 }, c = GLACE },
			true
		)
	end)

	-- Rare : renard polaire à l'immense queue touffue.
	definir("Renarctique", 0.66, function(l)
		local tete = { 0, 0, -0.2 }
		local queue = { 0, -0.08, 0.3 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.32, 0.6 }, p = { 0, -0.2, 0.02 }, c = NEIGE })
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.3, 0.32 },
			p = { 0, 0.08, -0.32 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.14, 0.1, 0.14 },
			p = { 0, 0.02, -0.53 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.04, 0.03 },
			p = { 0, 0.06, -0.605 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.09, 0.14, -0.485, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.12, 0.05 },
			p = { 0.11, 0.29, -0.3 },
			c = NEIGE,
			a = "Oreille",
			j = { 0.11, 0.23, -0.3 },
		}, true)
		ajouter(l, {
			n = "OreilleInterieur",
			t = { 0.05, 0.07, 0.02 },
			p = { 0.11, 0.28, -0.33 },
			c = GLACE,
			a = "Oreille",
			j = { 0.11, 0.23, -0.3 },
		}, true)
		ajouter(
			l,
			{ n = "Collier", t = { 0.4, 0.06, 0.34 }, p = { 0, -0.06, -0.22 }, c = "Rarete" }
		)
		pattes4(l, 0.13, -0.18, 0.2, { 0.09, 0.14, 0.09 }, NEIGE)
		ajouter(l, {
			n = "Queue",
			t = { 0.24, 0.24, 0.4 },
			p = { 0, 0.0, 0.48 },
			r = { -25, 0, 0 },
			c = NEIGE,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.2, 0.2, 0.12 },
			p = { 0, 0.12, 0.7 },
			r = { -25, 0, 0 },
			c = GLACE,
			a = "Queue",
			j = queue,
		})
	end)

	-- Épique : morse aux défenses de glace.
	definir("Morsabre", 0.62, function(l)
		local brun = { 170, 120, 100 }
		local tete = { 0, -0.1, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.6, 0.44, 0.7 }, p = { 0, -0.26, 0.08 }, c = brun })
		ajouter(l, {
			n = "Tete",
			t = { 0.44, 0.34, 0.32 },
			p = { 0, -0.02, -0.32 },
			c = brun,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Moustache",
			t = { 0.3, 0.12, 0.08 },
			p = { 0, -0.1, -0.5 },
			c = { 220, 190, 170 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Defense",
			t = { 0.05, 0.22, 0.05 },
			p = { 0.08, -0.25, -0.5 },
			c = GLACE,
			m = "Glass",
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.1, 0.06, -0.485, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Nez",
			t = { 0.08, 0.04, 0.02 },
			p = { 0, -0.03, -0.545 },
			c = { 90, 60, 50 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.16, 0.05, 0.16 },
			p = { 0.32, -0.47, -0.12 },
			r = { 0, 20, 0 },
			c = { 140, 95, 80 },
			a = "Patte",
			j = { 0.28, -0.45, -0.12 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.34, 0.05, 0.14 },
			p = { 0, -0.46, 0.48 },
			c = { 140, 95, 80 },
			a = "Queue",
			j = { 0, -0.44, 0.42 },
		})
		ajouter(l, {
			n = "Bonnet",
			t = { 0.24, 0.1, 0.2 },
			p = { 0, 0.19, -0.3 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
	end)

	-- Épique : bébé yéti tout ébouriffé.
	definir("Yetinou", 0.82, function(l)
		local tete = { 0, 0.12, 0 }
		local peau = { 150, 190, 230 }
		ajouter(l, { n = "Corps", t = { 0.54, 0.5, 0.46 }, p = { 0, -0.18, 0 }, c = NEIGE })
		ajouter(l, {
			n = "Tete",
			t = { 0.5, 0.36, 0.44 },
			p = { 0, 0.24, -0.02 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Meche",
			t = { 0.2, 0.1, 0.16 },
			p = { 0.06, 0.45, -0.08 },
			r = { 0, 0, -20 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Visage",
			t = { 0.32, 0.22, 0.03 },
			p = { 0, 0.2, -0.245 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.24, -0.265, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Bouche",
			t = { 0.12, 0.04, 0.02 },
			p = { 0, 0.13, -0.265 },
			c = { 60, 50, 90 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.06, 0.12, 0.06 },
			p = { 0.17, 0.46, 0 },
			r = { 0, 0, -20 },
			c = GLACE_FONCEE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.14, 0.32, 0.14 },
			p = { 0.33, -0.16, 0 },
			c = NEIGE,
			a = "Bras",
			j = { 0.31, 0.0, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Main",
			t = { 0.12, 0.08, 0.12 },
			p = { 0.33, -0.35, -0.02 },
			c = peau,
			a = "Bras",
			j = { 0.31, 0.0, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.18, 0.08, 0.22 },
			p = { 0.14, -0.46, -0.04 },
			c = peau,
			a = "Patte",
			j = { 0.14, -0.4, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Légendaire : bébé mammouth laineux aux défenses dorées.
	definir("Mammouflon", 0.8, function(l)
		local laine = { 150, 95, 70 }
		local tete = { 0, 0.08, -0.26 }
		ajouter(l, { n = "Corps", t = { 0.56, 0.46, 0.66 }, p = { 0, -0.04, 0.06 }, c = laine })
		ajouter(
			l,
			{ n = "Bosse", t = { 0.4, 0.14, 0.4 }, p = { 0, 0.25, -0.04 }, c = { 170, 110, 80 } }
		)
		ajouter(l, {
			n = "Tete",
			t = { 0.42, 0.38, 0.3 },
			p = { 0, 0.1, -0.38 },
			c = laine,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Trompe1",
			t = { 0.12, 0.2, 0.12 },
			p = { 0, -0.08, -0.5 },
			c = laine,
			a = "Machoire",
			j = { 0, 0.02, -0.5 },
		})
		ajouter(l, {
			n = "Trompe2",
			t = { 0.1, 0.14, 0.1 },
			p = { 0, -0.24, -0.47 },
			r = { -20, 0, 0 },
			c = laine,
			a = "Machoire",
			j = { 0, 0.02, -0.5 },
		})
		ajouter(l, {
			n = "Defense",
			t = { 0.05, 0.05, 0.24 },
			p = { 0.13, -0.06, -0.58 },
			r = { 25, 0, 0 },
			c = { 255, 215, 90 },
			m = "Foil",
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.12, 0.16, -0.535, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.2, 0.18 },
			p = { 0.24, 0.1, -0.34 },
			c = { 120, 75, 55 },
			a = "Oreille",
			j = { 0.21, 0.1, -0.34 },
		}, true)
		pattes4(l, 0.18, -0.16, 0.28, { 0.15, 0.26, 0.15 }, { 120, 75, 55 })
		ajouter(
			l,
			{ n = "Couverture", t = { 0.5, 0.04, 0.4 }, p = { 0, 0.33, -0.04 }, c = "Rarete" }
		)
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.14, 0.05 },
			p = { 0, 0.04, 0.4 },
			c = laine,
			a = "Queue",
			j = { 0, 0.1, 0.39 },
		})
	end)

	-- Légendaire : lynx couvert de cristaux de glace.
	definir("Cristalynx", 0.72, function(l)
		local gris = { 210, 220, 235 }
		local tete = { 0, 0.04, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.32, 0.62 }, p = { 0, -0.16, 0.06 }, c = gris })
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.3, 0.3 },
			p = { 0, 0.1, -0.32 },
			c = gris,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Favori",
			t = { 0.1, 0.12, 0.1 },
			p = { 0.2, 0.02, -0.34 },
			r = { 0, 0, 20 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.09, 0.14, -0.475, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Nez",
			t = { 0.05, 0.04, 0.02 },
			p = { 0, 0.06, -0.475 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.14, 0.05 },
			p = { 0.12, 0.31, -0.3 },
			c = gris,
			a = "Oreille",
			j = { 0.12, 0.25, -0.3 },
		}, true)
		ajouter(l, {
			n = "Pinceau",
			t = { 0.03, 0.08, 0.03 },
			p = { 0.12, 0.42, -0.3 },
			c = NOIR,
			a = "Oreille",
			j = { 0.12, 0.25, -0.3 },
		}, true)
		for i, pos in { { 0.0, 0.0, 0.0 }, { 0.12, -0.04, 0.18 }, { -0.1, -0.02, 0.24 } } do
			ajouter(l, {
				n = "Cristal" .. i,
				t = { 0.06, 0.18, 0.06 },
				p = { pos[1], 0.06 + pos[2], pos[3] },
				r = { 15, 0, pos[1] * -100 },
				c = if i == 1 then "Rarete" else GLACE,
				m = "Neon",
			})
		end
		pattes4(l, 0.14, -0.14, 0.26, { 0.1, 0.2, 0.1 }, gris)
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.08, 0.16 },
			p = { 0, -0.06, 0.44 },
			r = { -30, 0, 0 },
			c = NOIR,
			a = "Queue",
			j = { 0, -0.08, 0.38 },
		})
	end)

	-- Mythique : narval flottant à la corne d'aurore.
	definir("Narvalune", 0.7, function(l)
		local bleu = { 120, 160, 230 }
		local queue = { 0, -0.04, 0.24 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.36, 0.66 }, p = { 0, -0.06, 0.02 }, c = bleu })
		ajouter(l, { n = "Ventre", t = { 0.34, 0.06, 0.56 }, p = { 0, -0.25, 0.02 }, c = NEIGE })
		for i, z in { -0.1, 0.06, 0.2 } do
			ajouter(l, {
				n = "Tache" .. i,
				t = { 0.08, 0.02, 0.08 },
				p = { 0.1, 0.125, z },
				c = { 80, 110, 180 },
			}, true)
		end
		yeux(l, 0.11, 0.0, -0.315, 0.09)
		ajouter(
			l,
			{ n = "Sourire", t = { 0.1, 0.02, 0.02 }, p = { 0, -0.1, -0.315 }, c = { 50, 70, 130 } }
		)
		ajouter(l, {
			n = "Corne",
			t = { 0.05, 0.05, 0.4 },
			p = { 0, 0.08, -0.5 },
			r = { -15, 0, 0 },
			c = AURORE,
			m = "Neon",
			a = "Tete",
			j = { 0, 0.04, -0.3 },
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.2, 0.04, 0.12 },
			p = { 0.28, -0.14, -0.08 },
			r = { 0, 0, -25 },
			c = bleu,
			a = "Aile",
			j = { 0.2, -0.12, -0.08 },
		}, true)
		ajouter(l, {
			n = "Queue1",
			t = { 0.2, 0.16, 0.2 },
			p = { 0, -0.04, 0.42 },
			c = bleu,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Caudale",
			t = { 0.4, 0.04, 0.14 },
			p = { 0, -0.02, 0.58 },
			c = "Rarete",
			m = "Neon",
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Bulle",
			f = "Ball",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.15, -0.42, -0.1 },
			c = AURORE,
			tr = 0.4,
		})
	end)

	-- Mythique : petit dragon de glace aux ailes de givre.
	definir("Draconeige", 0.86, function(l)
		local blanc = { 225, 240, 255 }
		local tete = { 0, 0.04, -0.14 }
		local queue = { 0, -0.2, 0.26 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.36, 0.5 }, p = { 0, -0.16, 0.04 }, c = blanc })
		ajouter(l, { n = "Ventre", t = { 0.28, 0.26, 0.03 }, p = { 0, -0.18, -0.215 }, c = GLACE })
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.3, 0.34 },
			p = { 0, 0.16, -0.24 },
			c = blanc,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.22, 0.12, 0.14 },
			p = { 0, 0.1, -0.45 },
			c = blanc,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.1, 0.22, -0.415, 0.1, "Tete", tete)
		ajouter(l, {
			n = "Corne",
			t = { 0.05, 0.2, 0.05 },
			p = { 0.11, 0.38, -0.14 },
			r = { 25, 0, -10 },
			c = GLACE,
			m = "Glass",
			a = "Tete",
			j = tete,
		}, true)
		for i, z in { -0.02, 0.12, 0.26 } do
			ajouter(l, {
				n = "Pic" .. i,
				t = { 0.05, 0.1, 0.06 },
				p = { 0, 0.06, z },
				r = { 30, 0, 0 },
				c = "Rarete",
				m = "Neon",
			})
		end
		pattes4(l, 0.14, -0.1, 0.2, { 0.12, 0.14, 0.14 }, blanc)
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.34, 0.4 },
			p = { 0.3, 0.1, 0.06 },
			r = { 0, 0, -25 },
			c = GLACE,
			tr = 0.25,
			a = "Aile",
			j = { 0.2, 0.02, 0.04 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.12, 0.12, 0.32 },
			p = { 0, -0.2, 0.42 },
			c = blanc,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.14, 0.05, 0.12 },
			p = { 0, -0.18, 0.62 },
			r = { 0, 45, 0 },
			c = GLACE,
			m = "Neon",
			a = "Queue",
			j = queue,
		})
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : boule de neige grognon qui roule.
	definir("Bouleneige", 0.55, function(l)
		ajouter(l, { n = "Boule", t = { 0.86, 0.8, 0.86 }, p = { 0, -0.1, 0 }, c = NEIGE })
		ajouter(l, {
			n = "Bosse",
			t = { 0.5, 0.14, 0.5 },
			p = { 0, 0.33, 0.02 },
			c = NEIGE,
			a = "Antenne",
			j = { 0, 0.28, 0 },
		})
		for i, pos in { { 0.3, 0.1, 0.25 }, { -0.32, -0.2, 0.1 }, { 0.1, -0.3, 0.38 } } do
			ajouter(l, {
				n = "Caillou" .. i,
				t = { 0.08, 0.08, 0.08 },
				p = { pos[1], pos[2], pos[3] + 0.06 },
				c = { 120, 130, 140 },
			})
		end
		yeux(l, 0.18, 0.08, -0.44, 0.18)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.2, 0.05, 0.03 },
			p = { 0.18, 0.22, -0.44 },
			r = { 0, 0, 20 },
			c = GLACE_FONCEE,
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.3, 0.08, 0.02 }, p = { 0, -0.18, -0.435 }, c = { 60, 80, 120 } }
		)
		ajouter(l, {
			n = "Glacon",
			t = { 0.05, 0.12, 0.05 },
			p = { 0.1, -0.27, -0.43 },
			c = GLACE,
			m = "Glass",
		}, true)
	end)

	-- Moyenne : ours polaire bougon.
	definir("Grognours", 0.68, function(l)
		local tete = { 0, 0.06, -0.38 }
		ajouter(l, { n = "Corps", t = { 0.62, 0.5, 0.9 }, p = { 0, -0.06, 0.06 }, c = NEIGE })
		ajouter(l, {
			n = "Tete",
			t = { 0.42, 0.36, 0.38 },
			p = { 0, 0.12, -0.52 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.22, 0.14, 0.14 },
			p = { 0, 0.04, -0.74 },
			c = { 235, 240, 250 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.08, 0.06, 0.03 },
			p = { 0, 0.1, -0.82 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.04, 0.06, 0.02 },
			p = { 0.06, -0.06, -0.815 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.05, 0.03 },
			p = { 0.11, 0.2, -0.71 },
			c = { 255, 80, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.11, 0.03, 0.03 },
			p = { 0.11, 0.25, -0.71 },
			r = { 0, 0, 20 },
			c = GLACE_FONCEE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.1, 0.06 },
			p = { 0.16, 0.33, -0.48 },
			c = NEIGE,
			a = "Oreille",
			j = { 0.16, 0.29, -0.48 },
		}, true)
		pattes4(l, 0.2, -0.26, 0.36, { 0.16, 0.26, 0.16 }, NEIGE)
		ajouter(
			l,
			{ n = "Glacons", t = { 0.5, 0.04, 0.6 }, p = { 0, 0.2, 0.08 }, c = GLACE, m = "Glass" }
		)
	end)

	-- Lointaine : grand yéti des cimes, poings de glace.
	definir("Abominou", 0.86, function(l)
		local tete = { 0, 0.28, 0 }
		local peau = { 120, 160, 210 }
		ajouter(l, { n = "Torse", t = { 0.8, 0.66, 0.6 }, p = { 0, -0.02, 0 }, c = NEIGE })
		ajouter(l, {
			n = "Ventre",
			t = { 0.5, 0.42, 0.03 },
			p = { 0, -0.08, -0.315 },
			c = { 220, 230, 245 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.5, 0.36, 0.46 },
			p = { 0, 0.48, -0.04 },
			c = NEIGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Visage",
			t = { 0.34, 0.24, 0.03 },
			p = { 0, 0.46, -0.275 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.06, 0.03 },
			p = { 0.08, 0.5, -0.295 },
			c = { 255, 220, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.04, 0.03 },
			p = { 0.08, 0.56, -0.295 },
			r = { 0, 0, 20 },
			c = GLACE_FONCEE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Gueule",
			t = { 0.22, 0.07, 0.02 },
			p = { 0, 0.4, -0.295 },
			c = { 50, 40, 80 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.08, 0.26, 0.08 },
			p = { 0.24, 0.72, -0.02 },
			r = { 0, 0, -25 },
			c = GLACE_FONCEE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.22, 0.52, 0.24 },
			p = { 0.52, 0.0, -0.02 },
			c = NEIGE,
			a = "Bras",
			j = { 0.52, 0.22, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Poing",
			t = { 0.28, 0.24, 0.3 },
			p = { 0.52, -0.32, -0.04 },
			c = GLACE,
			m = "Glass",
			a = "Bras",
			j = { 0.52, 0.22, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.26, 0.2, 0.28 },
			p = { 0.2, -0.38, 0 },
			c = NEIGE,
			a = "Patte",
			j = { 0.2, -0.28, 0 },
			ph = math.pi,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.3, 0.07, 0.34 },
			p = { 0.2, -0.465, -0.05 },
			c = peau,
			a = "Patte",
			j = { 0.2, -0.28, 0 },
			ph = math.pi,
		}, true)
	end)
end
