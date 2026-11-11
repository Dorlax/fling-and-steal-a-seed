--!strict
-- Bestiaire du biome 13 : Savane Dorée (herbes hautes, acacias, coucher de soleil).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local SABLE = { 230, 190, 120 }
	local GRIS = { 150, 150, 160 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : petit zèbre rayé à la crinière en brosse.
	definir("Zebrinou", 0.75, function(l)
		local tete = { 0, 0.04, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.32, 0.28, 0.5 }, p = { 0, -0.14, 0.06 }, c = BLANC })
		for i, z in { -0.12, 0.02, 0.16, 0.28 } do
			ajouter(
				l,
				{ n = "Rayure" .. i, t = { 0.33, 0.29, 0.05 }, p = { 0, -0.14, z }, c = NOIR }
			)
		end
		pattes4(l, 0.1, -0.1, 0.24, { 0.08, 0.22, 0.08 }, BLANC)
		ajouter(l, {
			n = "Cou",
			t = { 0.14, 0.24, 0.14 },
			p = { 0, 0.04, -0.18 },
			r = { -15, 0, 0 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.2, 0.2, 0.28 },
			p = { 0, 0.2, -0.28 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.16, 0.12, 0.08 },
			p = { 0, 0.14, -0.44 },
			c = { 60, 60, 70 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.05, 0.02 },
			p = { 0.105, 0.24, -0.32 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Criniere",
			t = { 0.05, 0.08, 0.3 },
			p = { 0, 0.32, -0.18 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.05, 0.1, 0.04 },
			p = { 0.07, 0.34, -0.22 },
			c = BLANC,
			a = "Oreille",
			j = { 0.07, 0.3, -0.22 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.2, 0.04 },
			p = { 0, -0.1, 0.34 },
			r = { 20, 0, 0 },
			c = NOIR,
			a = "Queue",
			j = { 0, -0.02, 0.31 },
		})
	end)

	-- Commune : suricate debout qui fait le guet.
	definir("Suricatou", 0.8, function(l)
		local tete = { 0, 0.14, 0 }
		ajouter(l, { n = "Corps", t = { 0.24, 0.5, 0.22 }, p = { 0, -0.2, 0.02 }, c = SABLE })
		ajouter(l, { n = "Ventre", t = { 0.16, 0.36, 0.03 }, p = { 0, -0.22, -0.095 }, c = CREME })
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.2, 0.22 },
			p = { 0, 0.16, -0.02 },
			c = SABLE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.1, 0.08, 0.08 },
			p = { 0, 0.12, -0.16 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.04, 0.03, 0.02 },
			p = { 0, 0.14, -0.205 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Masque",
			t = { 0.06, 0.05, 0.02 },
			p = { 0.06, 0.18, -0.135 },
			c = { 90, 60, 40 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.06, 0.18, -0.145 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.04, 0.05, 0.03 },
			p = { 0.11, 0.2, 0.0 },
			c = { 90, 60, 40 },
			a = "Oreille",
			j = { 0.1, 0.18, 0 },
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.05, 0.12, 0.05 },
			p = { 0.08, -0.04, -0.12 },
			r = { -40, 0, 0 },
			c = SABLE,
			a = "Bras",
			j = { 0.08, 0.0, -0.1 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.08, 0.06, 0.12 },
			p = { 0.07, -0.47, -0.04 },
			c = SABLE,
			a = "Patte",
			j = { 0.07, -0.44, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.04, 0.3 },
			p = { 0, -0.44, 0.22 },
			c = SABLE,
			a = "Queue",
			j = { 0, -0.42, 0.1 },
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.05, 0.05, 0.06 },
			p = { 0, -0.44, 0.38 },
			c = "Rarete",
			a = "Queue",
			j = { 0, -0.42, 0.1 },
		})
	end)

	-- Rare : girafon au long cou tacheté.
	definir("Girafon", 0.98, function(l)
		local jaune = { 245, 200, 90 }
		local tache = { 180, 110, 50 }
		local tete = { 0, 0.18, -0.12 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.24, 0.4 }, p = { 0, -0.16, 0.08 }, c = jaune })
		pattes4(l, 0.09, -0.04, 0.2, { 0.07, 0.26, 0.07 }, jaune)
		ajouter(l, {
			n = "Cou",
			t = { 0.12, 0.44, 0.12 },
			p = { 0, 0.12, -0.08 },
			r = { -10, 0, 0 },
			c = jaune,
			a = "Tete",
			j = tete,
		})
		for i, pos in
			{
				{ 0.15, -0.12, 0.0 },
				{ 0.15, -0.2, 0.18 },
				{ 0.061, 0.14, -0.1 },
				{ 0.061, 0.26, -0.12 },
			}
		do
			ajouter(l, { n = "Tache" .. i, t = { 0.02, 0.07, 0.07 }, p = pos, c = tache }, true)
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.18, 0.16, 0.26 },
			p = { 0, 0.38, -0.18 },
			c = jaune,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.14, 0.1, 0.06 },
			p = { 0, 0.34, -0.33 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.05, 0.02 },
			p = { 0.095, 0.41, -0.22 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Corne",
			t = { 0.03, 0.08, 0.03 },
			p = { 0.04, 0.5, -0.14 },
			c = jaune,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Pompon",
			t = { 0.05, 0.05, 0.05 },
			p = { 0.04, 0.55, -0.14 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.03, 0.18, 0.03 },
			p = { 0, -0.14, 0.3 },
			r = { 25, 0, 0 },
			c = tache,
			a = "Queue",
			j = { 0, -0.06, 0.28 },
		})
	end)

	-- Rare : phacochère aux défenses recourbées.
	definir("Phacochou", 0.6, function(l)
		local peau = { 140, 100, 80 }
		local tete = { 0, -0.18, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.38, 0.3, 0.5 }, p = { 0, -0.22, 0.06 }, c = peau })
		ajouter(l, { n = "Crete", t = { 0.06, 0.08, 0.4 }, p = { 0, -0.04, 0.04 }, c = "Rarete" })
		pattes4(l, 0.12, -0.1, 0.22, { 0.08, 0.12, 0.08 }, peau)
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.26, 0.22 },
			p = { 0, -0.18, -0.28 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Groin",
			t = { 0.14, 0.1, 0.06 },
			p = { 0, -0.24, -0.42 },
			c = { 220, 150, 140 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Narine",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.03, -0.24, -0.455 },
			c = { 90, 50, 50 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Defense",
			t = { 0.03, 0.1, 0.03 },
			p = { 0.1, -0.18, -0.42 },
			r = { -20, 0, -20 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.08, -0.12, -0.395, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.06, 0.04 },
			p = { 0.17, -0.06, -0.24 },
			r = { 0, 0, -30 },
			c = peau,
			a = "Oreille",
			j = { 0.14, -0.08, -0.24 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.03, 0.2, 0.03 },
			p = { 0, -0.02, 0.32 },
			c = peau,
			a = "Queue",
			j = { 0, -0.1, 0.31 },
		})
	end)

	-- Épique : éléphanteau à la trompe levée.
	definir("Elephanteau", 0.85, function(l)
		local tete = { 0, 0.06, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.48, 0.42, 0.56 }, p = { 0, -0.1, 0.08 }, c = GRIS })
		pattes4(l, 0.15, -0.08, 0.26, { 0.14, 0.2, 0.14 }, GRIS)
		ajouter(l, {
			n = "Tete",
			t = { 0.38, 0.36, 0.3 },
			p = { 0, 0.12, -0.26 },
			c = GRIS,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.24, 0.32, 0.04 },
			p = { 0.3, 0.12, -0.2 },
			r = { 0, -25, 0 },
			c = { 170, 165, 180 },
			a = "Oreille",
			j = { 0.18, 0.12, -0.22 },
		}, true)
		ajouter(l, {
			n = "InterOreille",
			t = { 0.16, 0.22, 0.02 },
			p = { 0.3, 0.12, -0.225 },
			r = { 0, -25, 0 },
			c = ROSE,
			a = "Oreille",
			j = { 0.18, 0.12, -0.22 },
		}, true)
		yeux(l, 0.09, 0.18, -0.415, 0.07, "Tete", tete)
		local trompe = { 0, 0.02, -0.42 }
		ajouter(l, {
			n = "Trompe",
			t = { 0.1, 0.18, 0.1 },
			p = { 0, -0.06, -0.46 },
			c = GRIS,
			a = "Antenne",
			j = trompe,
		})
		ajouter(l, {
			n = "Trompe2",
			t = { 0.08, 0.14, 0.08 },
			p = { 0, 0.04, -0.56 },
			r = { -40, 0, 0 },
			c = GRIS,
			a = "Antenne",
			j = trompe,
		})
		ajouter(l, {
			n = "Jet",
			t = { 0.06, 0.06, 0.06 },
			p = { 0, 0.16, -0.6 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = trompe,
		})
		ajouter(l, {
			n = "Defense",
			t = { 0.04, 0.04, 0.1 },
			p = { 0.08, -0.04, -0.44 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.18, 0.04 },
			p = { 0, -0.04, 0.38 },
			r = { 20, 0, 0 },
			c = GRIS,
			a = "Queue",
			j = { 0, 0.04, 0.36 },
		})
	end)

	-- Épique : gazelle aux cornes en spirale de lune.
	definir("Gazellune", 0.85, function(l)
		local fauve = { 220, 160, 100 }
		local tete = { 0, 0.14, -0.18 }
		ajouter(l, { n = "Corps", t = { 0.26, 0.24, 0.46 }, p = { 0, -0.08, 0.06 }, c = fauve })
		ajouter(l, { n = "Ventre", t = { 0.27, 0.06, 0.4 }, p = { 0, -0.18, 0.06 }, c = BLANC })
		ajouter(
			l,
			{ n = "Bande", t = { 0.27, 0.04, 0.4 }, p = { 0, -0.13, 0.06 }, c = { 90, 60, 40 } }
		)
		pattes4(l, 0.08, -0.08, 0.22, { 0.05, 0.3, 0.05 }, fauve)
		ajouter(l, {
			n = "Cou",
			t = { 0.1, 0.2, 0.1 },
			p = { 0, 0.1, -0.16 },
			r = { -20, 0, 0 },
			c = fauve,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.16, 0.16, 0.24 },
			p = { 0, 0.24, -0.24 },
			c = fauve,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.05, 0.02 },
			p = { 0.085, 0.27, -0.3 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		for k = 0, 2 do
			ajouter(l, {
				n = "Corne" .. k,
				t = { 0.03, 0.08, 0.03 },
				p = { 0.05, 0.36 + k * 0.07, -0.18 + k * 0.03 },
				r = { 20, k * 40, 0 },
				c = if k == 2 then "Rarete" else { 240, 230, 200 },
				m = if k == 2 then "Neon" else nil,
				a = "Tete",
				j = tete,
			}, true)
		end
		ajouter(l, {
			n = "Oreille",
			t = { 0.04, 0.08, 0.03 },
			p = { 0.1, 0.32, -0.2 },
			r = { 0, 0, -40 },
			c = fauve,
			a = "Oreille",
			j = { 0.08, 0.3, -0.2 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.1, 0.04 },
			p = { 0, -0.02, 0.3 },
			c = NOIR,
			a = "Queue",
			j = { 0, 0.02, 0.29 },
		})
	end)

	-- Légendaire : rhinocéros à la corne dorée.
	definir("Rhinocorne", 0.75, function(l)
		local peau = { 140, 140, 150 }
		local tete = { 0, -0.04, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.44, 0.38, 0.6 }, p = { 0, -0.1, 0.08 }, c = peau })
		ajouter(
			l,
			{ n = "Plaque", t = { 0.46, 0.04, 0.3 }, p = { 0, 0.04, 0.0 }, c = { 120, 120, 130 } }
		)
		pattes4(l, 0.14, -0.1, 0.28, { 0.13, 0.16, 0.13 }, peau)
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.28, 0.3 },
			p = { 0, -0.04, -0.34 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.08, 0.2, 0.08 },
			p = { 0, 0.12, -0.46 },
			r = { -20, 0, 0 },
			c = "Rarete",
			m = "Foil",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Corne2",
			t = { 0.06, 0.08, 0.06 },
			p = { 0, 0.12, -0.36 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.1, 0.0, -0.495, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.1, 0.04 },
			p = { 0.12, 0.14, -0.26 },
			c = peau,
			a = "Oreille",
			j = { 0.12, 0.1, -0.26 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.16, 0.04 },
			p = { 0, -0.04, 0.4 },
			r = { 20, 0, 0 },
			c = peau,
			a = "Queue",
			j = { 0, 0.02, 0.38 },
		})
	end, "Ecailles")

	-- Légendaire : autruche aux plumes multicolores.
	definir("Autruchou", 0.98, function(l)
		local tete = { 0, 0.3, -0.12 }
		ajouter(
			l,
			{ n = "Plumage", t = { 0.38, 0.3, 0.42 }, p = { 0, -0.02, 0.06 }, c = { 40, 35, 45 } }
		)
		for i, c in { { 255, 90, 120 }, { 255, 200, 60 }, { 90, 200, 255 } } do
			ajouter(l, {
				n = "Plume" .. i,
				t = { 0.08, 0.2, 0.06 },
				p = { (i - 2) * 0.1, 0.08, 0.3 },
				r = { 30, 0, (i - 2) * 25 },
				c = c,
				a = "Queue",
				j = { 0, 0.0, 0.26 },
				ph = i,
			})
		end
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.16, 0.26 },
			p = { 0.21, 0.0, 0.06 },
			c = BLANC,
			a = "Aile",
			j = { 0.19, 0.06, 0.04 },
		}, true)
		ajouter(l, {
			n = "Cou",
			t = { 0.07, 0.36, 0.07 },
			p = { 0, 0.26, -0.1 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.14, 0.12, 0.16 },
			p = { 0, 0.46, -0.14 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.04, 0.1 },
			p = { 0, 0.44, -0.26 },
			c = { 255, 200, 120 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.05, 0.02 },
			p = { 0.075, 0.48, -0.17 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Huppe",
			t = { 0.03, 0.06, 0.03 },
			p = { 0, 0.55, -0.12 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.34, 0.04 },
			p = { 0.08, -0.32, 0.04 },
			c = ROSE,
			a = "Patte",
			j = { 0.08, -0.15, 0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.08, 0.04, 0.12 },
			p = { 0.08, -0.48, 0.0 },
			c = ROSE,
			a = "Patte",
			j = { 0.08, -0.15, 0.04 },
			ph = 0,
		}, true)
	end)

	-- Mythique : petit baobab vivant aux branches-bras.
	definir("Baobabou", 0.95, function(l)
		local ecorce = { 160, 120, 90 }
		local tete = { 0, 0.3, 0 }
		ajouter(l, { n = "Tronc", t = { 0.44, 0.6, 0.42 }, p = { 0, -0.18, 0 }, c = ecorce })
		ajouter(l, {
			n = "Racine",
			t = { 0.12, 0.1, 0.2 },
			p = { 0.22, -0.45, -0.1 },
			r = { 0, 30, 0 },
			c = ecorce,
			a = "Patte",
			j = { 0.18, -0.42, -0.06 },
			ph = 0,
		}, true)
		yeux(l, 0.1, -0.04, -0.215, 0.1)
		ajouter(
			l,
			{ n = "Sourire", t = { 0.16, 0.03, 0.02 }, p = { 0, -0.2, -0.215 }, c = { 90, 60, 40 } }
		)
		ajouter(l, {
			n = "Branche",
			t = { 0.24, 0.06, 0.06 },
			p = { 0.3, 0.16, 0 },
			r = { 0, 0, 30 },
			c = ecorce,
			a = "Bras",
			j = { 0.2, 0.1, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Feuillage",
			t = { 0.7, 0.14, 0.5 },
			p = { 0, 0.22, 0 },
			c = { 110, 170, 70 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Feuillage2",
			t = { 0.46, 0.1, 0.36 },
			p = { 0, 0.32, 0 },
			c = { 140, 200, 90 },
			a = "Tete",
			j = tete,
		})
		for i, x in { -0.22, 0, 0.22 } do
			ajouter(l, {
				n = "Fruit" .. i,
				t = { 0.06, 0.08, 0.06 },
				p = { x, 0.12, -0.18 },
				c = "Rarete",
				m = "Neon",
				a = "Tete",
				j = tete,
			})
		end
	end)

	-- Mythique : guépard doré, éclair de la savane.
	definir("Guepardor", 0.7, function(l)
		local or_ = { 255, 210, 90 }
		local tete = { 0, 0.0, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.28, 0.26, 0.6 }, p = { 0, -0.14, 0.08 }, c = or_ })
		for i, pos in
			{
				{ 0.141, -0.08, -0.08 },
				{ 0.141, -0.18, 0.08 },
				{ 0.141, -0.06, 0.22 },
				{ 0.141, -0.16, 0.32 },
			}
		do
			ajouter(
				l,
				{ n = "Tache" .. i, t = { 0.02, 0.05, 0.05 }, p = pos, c = { 60, 40, 30 } },
				true
			)
		end
		pattes4(l, 0.09, -0.12, 0.3, { 0.07, 0.22, 0.07 }, or_)
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.22, 0.22 },
			p = { 0, 0.02, -0.32 },
			c = or_,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Larme",
			t = { 0.02, 0.1, 0.02 },
			p = { 0.07, -0.04, -0.435 },
			c = { 60, 40, 30 },
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.07, 0.06, -0.435, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.03, 0.02 },
			p = { 0, -0.02, -0.435 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.06, 0.03 },
			p = { 0.09, 0.15, -0.3 },
			c = or_,
			a = "Oreille",
			j = { 0.09, 0.12, -0.3 },
		}, true)
		ajouter(l, {
			n = "Eclair",
			t = { 0.04, 0.12, 0.02 },
			p = { 0.15, -0.12, 0.0 },
			r = { 0, 0, 25 },
			c = "Rarete",
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.05, 0.36 },
			p = { 0, -0.04, 0.52 },
			r = { 20, 0, 0 },
			c = or_,
			a = "Queue",
			j = { 0, -0.08, 0.36 },
		})
	end, "Pelage")

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : hyène ricaneuse.
	definir("Hyenard", 0.65, function(l)
		local peau = { 170, 150, 110 }
		local tete = { 0, -0.04, -0.22 }
		ajouter(l, {
			n = "Corps",
			t = { 0.32, 0.32, 0.5 },
			p = { 0, -0.14, 0.06 },
			r = { -8, 0, 0 },
			c = peau,
		})
		for i, pos in { { 0.161, -0.06, 0.0 }, { 0.161, -0.16, 0.16 } } do
			ajouter(
				l,
				{ n = "Tache" .. i, t = { 0.02, 0.07, 0.07 }, p = pos, c = { 90, 70, 50 } },
				true
			)
		end
		ajouter(
			l,
			{ n = "Criniere", t = { 0.06, 0.1, 0.36 }, p = { 0, 0.06, 0.0 }, c = { 90, 70, 50 } }
		)
		pattes4(l, 0.1, -0.1, 0.24, { 0.08, 0.22, 0.08 }, peau)
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.22, 0.24 },
			p = { 0, 0.0, -0.32 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.2, 0.06, 0.16 },
			p = { 0, -0.12, -0.42 },
			c = peau,
			a = "Machoire",
			j = { 0, -0.1, -0.34 },
		})
		ajouter(l, {
			n = "Rire",
			t = { 0.18, 0.04, 0.02 },
			p = { 0, -0.06, -0.445 },
			c = { 60, 30, 30 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Dent",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.05, -0.05, -0.45 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.04, 0.02 },
			p = { 0.08, 0.06, -0.445 },
			c = { 255, 220, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.08, 0.03 },
			p = { 0.1, 0.14, -0.28 },
			c = peau,
			a = "Oreille",
			j = { 0.1, 0.1, -0.28 },
		}, true)
	end)

	-- Moyenne : vautour chauve qui fond sur sa proie.
	definir("Vautourbe", 0.75, function(l)
		local plume = { 70, 55, 50 }
		local tete = { 0, 0.18, -0.12 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.36, 0.42 }, p = { 0, -0.12, 0.06 }, c = plume })
		ajouter(l, { n = "Collerette", t = { 0.4, 0.1, 0.3 }, p = { 0, 0.08, -0.04 }, c = CREME })
		ajouter(l, {
			n = "Cou",
			t = { 0.08, 0.16, 0.08 },
			p = { 0, 0.2, -0.12 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.18, 0.16, 0.2 },
			p = { 0, 0.32, -0.18 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.08, 0.12 },
			p = { 0, 0.28, -0.32 },
			r = { 20, 0, 0 },
			c = { 240, 220, 150 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.04, 0.02 },
			p = { 0.07, 0.35, -0.285 },
			c = { 255, 80, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.06, 0.02, 0.02 },
			p = { 0.07, 0.39, -0.29 },
			r = { 0, 0, 25 },
			c = { 60, 30, 30 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.44, 0.04, 0.3 },
			p = { 0.38, 0.0, 0.04 },
			r = { 0, 0, 20 },
			c = plume,
			a = "Aile",
			j = { 0.18, -0.04, 0.04 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.2, 0.04, 0.2 },
			p = { 0, -0.14, 0.34 },
			c = plume,
			a = "Queue",
			j = { 0, -0.14, 0.26 },
		})
		ajouter(l, {
			n = "Serre",
			t = { 0.06, 0.14, 0.08 },
			p = { 0.08, -0.38, -0.02 },
			c = { 240, 200, 90 },
			a = "Patte",
			j = { 0.08, -0.3, 0 },
			ph = 0,
		}, true)
	end)

	-- Lointaine : buffle grognon qui charge tête baissée.
	definir("Bufflegrogne", 0.85, function(l)
		local peau = { 70, 55, 60 }
		local tete = { 0, 0.06, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.6, 0.5, 0.66 }, p = { 0, -0.04, 0.12 }, c = peau })
		ajouter(l, { n = "Bosse", t = { 0.46, 0.16, 0.3 }, p = { 0, 0.26, -0.02 }, c = peau })
		pattes4(l, 0.2, -0.1, 0.32, { 0.16, 0.2, 0.16 }, peau)
		ajouter(l, {
			n = "Tete",
			t = { 0.42, 0.36, 0.3 },
			p = { 0, 0.0, -0.34 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.26, 0.14, 0.06 },
			p = { 0, -0.1, -0.51 },
			c = { 110, 90, 95 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Fumee",
			t = { 0.06, 0.06, 0.06 },
			p = { 0.08, -0.1, -0.56 },
			c = BLANC,
			tr = 0.4,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Corne",
			t = { 0.3, 0.08, 0.1 },
			p = { 0.28, 0.16, -0.32 },
			r = { 0, 0, 20 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Pointe",
			t = { 0.08, 0.14, 0.08 },
			p = { 0.44, 0.26, -0.32 },
			c = CREME,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.05, 0.03 },
			p = { 0.12, 0.06, -0.495 },
			c = { 255, 60, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.1, 0.03, 0.03 },
			p = { 0.12, 0.11, -0.495 },
			r = { 0, 0, 25 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.04, 0.24, 0.04 },
			p = { 0, 0.04, 0.46 },
			r = { 25, 0, 0 },
			c = peau,
			a = "Queue",
			j = { 0, 0.14, 0.44 },
		})
	end)
end
