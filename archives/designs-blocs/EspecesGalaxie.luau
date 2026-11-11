--!strict
-- Bestiaire du biome 6 : Galaxie Étoilée (espace, néons, planètes).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE = o.BLANC, o.NOIR, o.ROSE

	local NUIT = { 40, 30, 80 }
	local VIOLET = { 150, 90, 255 }
	local CYAN = { 80, 230, 255 }
	local ETOILE = { 255, 240, 140 }
	local METAL = { 190, 200, 215 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : goutte d'étoile qui scintille.
	definir("Astrogoutte", 0.6, function(l)
		ajouter(l, { n = "Corps", t = { 0.5, 0.46, 0.5 }, p = { 0, -0.27, 0 }, c = VIOLET })
		ajouter(l, { n = "Haut", t = { 0.32, 0.16, 0.32 }, p = { 0, 0.04, 0 }, c = VIOLET })
		ajouter(l, {
			n = "Pointe",
			t = { 0.14, 0.12, 0.14 },
			p = { 0, 0.18, 0 },
			c = { 190, 140, 255 },
			a = "Antenne",
			j = { 0, 0.12, 0 },
		})
		for i, pos in { { 0.18, -0.1, -0.255 }, { -0.2, -0.38, -0.255 }, { 0.12, -0.44, -0.255 } } do
			ajouter(
				l,
				{ n = "Paillette" .. i, t = { 0.04, 0.04, 0.02 }, p = pos, c = ETOILE, m = "Neon" }
			)
		end
		yeux(l, 0.1, -0.2, -0.255, 0.11)
		ajouter(
			l,
			{ n = "Joue", t = { 0.06, 0.03, 0.02 }, p = { 0.17, -0.28, -0.255 }, c = ROSE },
			true
		)
		ajouter(l, { n = "Bouche", t = { 0.08, 0.03, 0.02 }, p = { 0, -0.3, -0.255 }, c = NUIT })
	end)

	-- Commune : petit extraterrestre vert à antennes.
	definir("Alienou", 0.8, function(l)
		local vert = { 120, 230, 110 }
		local tete = { 0, 0.04, 0 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.32, 0.26 }, p = { 0, -0.28, 0 }, c = vert })
		ajouter(l, { n = "Combinaison", t = { 0.31, 0.12, 0.27 }, p = { 0, -0.38, 0 }, c = METAL })
		ajouter(l, {
			n = "Tete",
			t = { 0.46, 0.36, 0.38 },
			p = { 0, 0.12, 0 },
			c = vert,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilGrand",
			t = { 0.16, 0.2, 0.04 },
			p = { 0.11, 0.12, -0.2 },
			r = { 0, 0, 15 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Reflet",
			t = { 0.04, 0.05, 0.02 },
			p = { 0.13, 0.17, -0.225 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.06, 0.02, 0.02 },
			p = { 0, -0.01, -0.2 },
			c = { 50, 110, 50 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Antenne",
			t = { 0.03, 0.16, 0.03 },
			p = { 0.1, 0.37, 0 },
			r = { 0, 0, -15 },
			c = vert,
			a = "Antenne",
			j = { 0.08, 0.3, 0 },
		}, true)
		ajouter(l, {
			n = "Boule",
			t = { 0.07, 0.07, 0.07 },
			p = { 0.13, 0.47, 0 },
			c = CYAN,
			m = "Neon",
			a = "Antenne",
			j = { 0.08, 0.3, 0 },
		}, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.05, 0.18, 0.05 },
			p = { 0.19, -0.26, 0 },
			c = vert,
			a = "Bras",
			j = { 0.18, -0.18, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Botte",
			t = { 0.1, 0.08, 0.14 },
			p = { 0.08, -0.46, -0.02 },
			c = METAL,
			a = "Patte",
			j = { 0.08, -0.42, 0 },
			ph = 0,
		}, true)
	end)

	-- Rare : lapin astronaute dans sa bulle.
	definir("Satellapin", 0.85, function(l)
		local tete = { 0, 0.02, -0.04 }
		ajouter(l, { n = "Combinaison", t = { 0.4, 0.36, 0.4 }, p = { 0, -0.26, 0.02 }, c = BLANC })
		ajouter(l, {
			n = "Badge",
			t = { 0.1, 0.1, 0.02 },
			p = { 0.08, -0.2, -0.185 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, { n = "SacDos", t = { 0.3, 0.26, 0.12 }, p = { 0, -0.22, 0.27 }, c = METAL })
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.28, 0.28 },
			p = { 0, 0.12, -0.04 },
			c = { 230, 220, 235 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.15, -0.185, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Nez",
			t = { 0.04, 0.03, 0.02 },
			p = { 0, 0.08, -0.185 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.26, 0.05 },
			p = { 0.08, 0.38, -0.04 },
			c = { 230, 220, 235 },
			a = "Oreille",
			j = { 0.08, 0.26, -0.04 },
		}, true)
		ajouter(l, {
			n = "Casque",
			t = { 0.46, 0.66, 0.44 },
			p = { 0, 0.22, -0.04 },
			c = { 200, 240, 255 },
			tr = 0.7,
			m = "Glass",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.08, 0.2, 0.08 },
			p = { 0.24, -0.24, 0.0 },
			c = BLANC,
			a = "Bras",
			j = { 0.22, -0.14, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Botte",
			t = { 0.12, 0.08, 0.16 },
			p = { 0.1, -0.46, -0.02 },
			c = METAL,
			a = "Patte",
			j = { 0.1, -0.42, 0 },
			ph = 0,
		}, true)
	end)

	-- Rare : tortue dont la carapace est une planète à anneaux.
	definir("Planetortue", 0.68, function(l)
		local peau = { 140, 200, 230 }
		local tete = { 0, -0.2, -0.3 }
		ajouter(
			l,
			{ n = "Planete", t = { 0.5, 0.44, 0.5 }, p = { 0, -0.08, 0.06 }, c = { 255, 150, 90 } }
		)
		ajouter(
			l,
			{ n = "Bande", t = { 0.51, 0.08, 0.51 }, p = { 0, -0.02, 0.06 }, c = { 240, 110, 70 } }
		)
		ajouter(
			l,
			{ n = "Bande2", t = { 0.51, 0.05, 0.51 }, p = { 0, 0.1, 0.06 }, c = { 255, 200, 140 } }
		)
		ajouter(l, {
			n = "Anneau",
			t = { 0.82, 0.03, 0.82 },
			p = { 0, -0.04, 0.06 },
			r = { 0, 0, 12 },
			c = ETOILE,
			m = "Neon",
		})
		ajouter(l, {
			n = "Lune",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.3, 0.26, -0.1 },
			c = METAL,
			a = "Antenne",
			j = { 0.1, 0.16, 0 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.2, 0.22 },
			p = { 0, -0.2, -0.38 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, -0.17, -0.495, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.08, 0.02, 0.02 },
			p = { 0, -0.25, -0.495 },
			c = { 60, 100, 130 },
			a = "Tete",
			j = tete,
		})
		pattes4(l, 0.2, -0.14, 0.26, { 0.12, 0.2, 0.12 }, peau)
		ajouter(l, {
			n = "Joyau",
			t = { 0.06, 0.06, 0.06 },
			p = { 0, 0.2, 0.06 },
			r = { 0, 45, 0 },
			c = "Rarete",
			m = "Neon",
		})
	end)

	-- Épique : méduse de l'espace aux filaments lumineux.
	definir("Meduspace", 0.8, function(l)
		local rose = { 255, 120, 220 }
		ajouter(
			l,
			{ n = "Ombrelle", t = { 0.6, 0.3, 0.6 }, p = { 0, 0.14, 0 }, c = rose, tr = 0.2 }
		)
		ajouter(l, { n = "Sommet", t = { 0.4, 0.14, 0.4 }, p = { 0, 0.34, 0 }, c = rose, tr = 0.2 })
		ajouter(
			l,
			{ n = "Coeur", t = { 0.2, 0.16, 0.2 }, p = { 0, 0.16, 0 }, c = CYAN, m = "Neon" }
		)
		yeux(l, 0.1, 0.12, -0.305, 0.1)
		ajouter(l, {
			n = "Sourire",
			t = { 0.08, 0.02, 0.02 },
			p = { 0, 0.04, -0.305 },
			c = { 140, 40, 120 },
		})
		for i, pos in
			{ { -0.2, -0.14 }, { 0.0, -0.18 }, { 0.2, -0.14 }, { -0.1, 0.16 }, { 0.12, 0.16 } }
		do
			ajouter(l, {
				n = "Filament" .. i,
				t = { 0.04, 0.46, 0.04 },
				p = { pos[1], -0.24, pos[2] },
				c = if i % 2 == 0 then CYAN else rose,
				m = "Neon",
				a = "Antenne",
				j = { pos[1], -0.02, pos[2] },
			})
		end
		ajouter(l, {
			n = "Etoile",
			t = { 0.07, 0.07, 0.03 },
			p = { 0, 0.42, -0.2 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
		})
	end)

	-- Épique : chat robot aux yeux d'écran.
	definir("Robochat", 0.72, function(l)
		local tete = { 0, 0.04, -0.18 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.32, 0.56 }, p = { 0, -0.18, 0.06 }, c = METAL })
		ajouter(l, {
			n = "Panneau",
			t = { 0.2, 0.12, 0.02 },
			p = { 0.215, -0.16, 0.06 },
			c = CYAN,
			m = "Neon",
		}, true)
		for i, z in { -0.08, 0.12 } do
			ajouter(l, {
				n = "Rivet" .. i,
				t = { 0.04, 0.04, 0.04 },
				p = { 0, -0.02, z },
				c = { 120, 130, 150 },
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.38, 0.3, 0.3 },
			p = { 0, 0.1, -0.3 },
			c = METAL,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Ecran",
			t = { 0.3, 0.18, 0.02 },
			p = { 0, 0.1, -0.455 },
			c = NUIT,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.07, 0.02 },
			p = { 0.07, 0.12, -0.465 },
			c = CYAN,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourire",
			t = { 0.1, 0.02, 0.02 },
			p = { 0, 0.05, -0.465 },
			c = CYAN,
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.12, 0.05 },
			p = { 0.12, 0.3, -0.3 },
			c = METAL,
			a = "Oreille",
			j = { 0.12, 0.25, -0.3 },
		}, true)
		ajouter(l, {
			n = "Antenne",
			t = { 0.02, 0.12, 0.02 },
			p = { 0.12, 0.42, -0.3 },
			c = "Rarete",
			m = "Neon",
			a = "Oreille",
			j = { 0.12, 0.25, -0.3 },
		}, true)
		pattes4(l, 0.14, -0.14, 0.24, { 0.1, 0.16, 0.1 }, { 140, 150, 170 })
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.05, 0.3 },
			p = { 0, 0.0, 0.44 },
			r = { -40, 0, 0 },
			c = METAL,
			a = "Queue",
			j = { 0, -0.08, 0.34 },
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.07, 0.07, 0.07 },
			p = { 0, 0.13, 0.55 },
			c = CYAN,
			m = "Neon",
			a = "Queue",
			j = { 0, -0.08, 0.34 },
		})
	end)

	-- Légendaire : lion dont la crinière est une nébuleuse.
	definir("Nebulion", 0.82, function(l)
		local pelage = { 90, 70, 170 }
		local tete = { 0, 0.02, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.34, 0.62 }, p = { 0, -0.12, 0.1 }, c = pelage })
		for i, pos in { { 0.1, 0.055, 0.04 }, { -0.12, 0.055, 0.2 }, { 0.06, 0.055, 0.3 } } do
			ajouter(l, {
				n = "Etoile" .. i,
				t = { 0.05, 0.02, 0.05 },
				p = pos,
				r = { 0, 45, 0 },
				c = ETOILE,
				m = "Neon",
			})
		end
		ajouter(l, {
			n = "Criniere",
			t = { 0.62, 0.58, 0.24 },
			p = { 0, 0.12, -0.28 },
			c = { 220, 90, 230 },
			m = "Neon",
			tr = 0.1,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Criniere2",
			t = { 0.5, 0.46, 0.06 },
			p = { 0, 0.12, -0.39 },
			c = CYAN,
			m = "Neon",
			tr = 0.2,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.34, 0.3, 0.26 },
			p = { 0, 0.1, -0.44 },
			c = pelage,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.18, 0.12, 0.06 },
			p = { 0, 0.03, -0.59 },
			c = { 170, 150, 230 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Nez",
			t = { 0.07, 0.04, 0.02 },
			p = { 0, 0.07, -0.625 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.16, -0.575, 0.08, "Tete", tete)
		ajouter(l, {
			n = "Couronne",
			t = { 0.2, 0.06, 0.16 },
			p = { 0, 0.28, -0.44 },
			c = ETOILE,
			m = "Foil",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Joyau",
			t = { 0.05, 0.05, 0.03 },
			p = { 0, 0.3, -0.53 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		pattes4(l, 0.14, -0.1, 0.3, { 0.12, 0.22, 0.12 }, pelage)
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.05, 0.3 },
			p = { 0, 0.0, 0.52 },
			r = { -35, 0, 0 },
			c = pelage,
			a = "Queue",
			j = { 0, -0.06, 0.4 },
		})
		ajouter(l, {
			n = "Touffe",
			t = { 0.12, 0.12, 0.12 },
			p = { 0, 0.1, 0.66 },
			c = CYAN,
			m = "Neon",
			a = "Queue",
			j = { 0, -0.06, 0.4 },
		})
	end)

	-- Légendaire : petite soucoupe vivante, pilote compris.
	definir("Ovniouf", 0.66, function(l)
		local vert = { 120, 230, 110 }
		ajouter(l, { n = "Soucoupe", t = { 0.8, 0.14, 0.8 }, p = { 0, -0.2, 0 }, c = METAL })
		ajouter(
			l,
			{ n = "Dessous", t = { 0.5, 0.1, 0.5 }, p = { 0, -0.32, 0 }, c = { 140, 150, 170 } }
		)
		ajouter(l, {
			n = "Faisceau",
			t = { 0.3, 0.12, 0.3 },
			p = { 0, -0.43, 0 },
			c = CYAN,
			m = "Neon",
			tr = 0.3,
		})
		for i = 1, 6 do
			local a = (i / 6) * 2 * math.pi
			ajouter(l, {
				n = "Lumiere" .. i,
				t = { 0.06, 0.06, 0.06 },
				p = { math.cos(a) * 0.36, -0.2, math.sin(a) * 0.36 },
				c = if i % 2 == 0 then "Rarete" else ETOILE,
				m = "Neon",
			})
		end
		ajouter(l, {
			n = "Pilote",
			t = { 0.22, 0.2, 0.2 },
			p = { 0, -0.04, 0 },
			c = vert,
			a = "Tete",
			j = { 0, -0.1, 0 },
		})
		ajouter(l, {
			n = "OeilPilote",
			t = { 0.06, 0.08, 0.02 },
			p = { 0.05, -0.02, -0.105 },
			c = NOIR,
			a = "Tete",
			j = { 0, -0.1, 0 },
		}, true)
		ajouter(l, {
			n = "Dome",
			t = { 0.36, 0.3, 0.36 },
			p = { 0, 0.0, 0 },
			c = { 200, 240, 255 },
			tr = 0.65,
			m = "Glass",
			a = "Tete",
			j = { 0, -0.1, 0 },
		})
		ajouter(l, {
			n = "Antenne",
			t = { 0.03, 0.14, 0.03 },
			p = { 0, 0.22, 0 },
			c = METAL,
			a = "Antenne",
			j = { 0, 0.15, 0 },
		})
		ajouter(l, {
			n = "Bout",
			t = { 0.06, 0.06, 0.06 },
			p = { 0, 0.3, 0 },
			c = ROSE,
			m = "Neon",
			a = "Antenne",
			j = { 0, 0.15, 0 },
		})
	end)

	-- Mythique : petit trou noir entouré d'un disque de lumière.
	definir("Trounoir", 0.7, function(l)
		ajouter(l, { n = "Coeur", t = { 0.4, 0.4, 0.4 }, p = { 0, -0.06, 0 }, c = { 15, 10, 25 } })
		ajouter(l, {
			n = "Disque",
			t = { 0.86, 0.04, 0.86 },
			p = { 0, -0.06, 0 },
			r = { 15, 0, 0 },
			c = { 255, 170, 80 },
			m = "Neon",
			a = "Antenne",
			j = { 0, -0.06, 0 },
		})
		ajouter(l, {
			n = "Disque2",
			t = { 0.62, 0.05, 0.62 },
			p = { 0, -0.06, 0 },
			r = { 15, 0, 0 },
			c = ETOILE,
			m = "Neon",
			a = "Antenne",
			j = { 0, -0.06, 0 },
		})
		ajouter(
			l,
			{ n = "Halo", t = { 0.5, 0.5, 0.5 }, p = { 0, -0.06, 0 }, c = VIOLET, tr = 0.75 }
		)
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.1, 0.02 },
			p = { 0.09, -0.02, -0.21 },
			c = BLANC,
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Sourire",
			t = { 0.1, 0.02, 0.02 },
			p = { 0, -0.14, -0.21 },
			c = "Rarete",
			m = "Neon",
		})
		for i, pos in { { 0.36, 0.28, 0.1 }, { -0.34, 0.2, -0.12 }, { 0.1, 0.36, 0.3 } } do
			ajouter(l, {
				n = "Debris" .. i,
				t = { 0.06, 0.06, 0.06 },
				p = pos,
				r = { 30, 30, 0 },
				c = METAL,
				a = "Antenne",
				j = { 0, -0.06, 0 },
			})
		end
	end)

	-- Mythique : baleine cosmique constellée d'étoiles.
	definir("Baleinastrale", 0.72, function(l)
		local bleu = { 50, 60, 150 }
		local queue = { 0, -0.06, 0.24 }
		ajouter(l, { n = "Corps", t = { 0.5, 0.42, 0.72 }, p = { 0, -0.08, 0.0 }, c = bleu })
		ajouter(
			l,
			{ n = "Ventre", t = { 0.4, 0.06, 0.6 }, p = { 0, -0.3, 0.0 }, c = { 140, 160, 230 } }
		)
		for i, pos in
			{
				{ 0.12, 0.135, -0.1 },
				{ -0.1, 0.135, 0.08 },
				{ 0.06, 0.135, 0.24 },
				{ -0.16, 0.135, -0.2 },
			}
		do
			ajouter(l, {
				n = "Constellation" .. i,
				t = { 0.05, 0.02, 0.05 },
				p = pos,
				r = { 0, 45, 0 },
				c = ETOILE,
				m = "Neon",
			})
		end
		yeux(l, 0.14, -0.02, -0.365, 0.09)
		ajouter(l, {
			n = "Sourire",
			t = { 0.22, 0.02, 0.02 },
			p = { 0, -0.16, -0.365 },
			c = { 25, 30, 80 },
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.24, 0.04, 0.14 },
			p = { 0.32, -0.2, -0.08 },
			r = { 0, 0, -25 },
			c = bleu,
			a = "Aile",
			j = { 0.24, -0.18, -0.08 },
		}, true)
		ajouter(l, {
			n = "Queue1",
			t = { 0.24, 0.18, 0.2 },
			p = { 0, -0.06, 0.44 },
			c = bleu,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Caudale",
			t = { 0.5, 0.04, 0.16 },
			p = { 0, -0.04, 0.6 },
			c = "Rarete",
			m = "Neon",
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Jet",
			t = { 0.06, 0.16, 0.06 },
			p = { 0, 0.22, -0.16 },
			c = CYAN,
			m = "Neon",
			a = "Antenne",
			j = { 0, 0.14, -0.16 },
		})
		ajouter(l, {
			n = "Goutte",
			t = { 0.05, 0.05, 0.05 },
			p = { 0.06, 0.32, -0.16 },
			c = ETOILE,
			m = "Neon",
			a = "Antenne",
			j = { 0, 0.14, -0.16 },
		}, true)
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : astéroïde furieux qui fonce.
	definir("Asteroidon", 0.55, function(l)
		local roche = { 110, 100, 120 }
		ajouter(l, { n = "Roche", t = { 0.84, 0.76, 0.84 }, p = { 0, -0.1, 0 }, c = roche })
		ajouter(l, {
			n = "Bloc",
			t = { 0.4, 0.3, 0.4 },
			p = { 0.2, 0.24, 0.16 },
			r = { 0, 25, 0 },
			c = { 90, 80, 100 },
		})
		ajouter(l, {
			n = "Bloc2",
			t = { 0.3, 0.26, 0.3 },
			p = { -0.28, -0.3, 0.2 },
			r = { 0, -20, 0 },
			c = { 90, 80, 100 },
		})
		for i, pos in { { 0.26, 0.1, -0.425 }, { -0.24, -0.3, -0.425 } } do
			ajouter(
				l,
				{ n = "Cratere" .. i, t = { 0.12, 0.12, 0.02 }, p = pos, c = { 70, 60, 80 } }
			)
		end
		yeux(l, 0.16, 0.06, -0.43, 0.16)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.2, 0.05, 0.03 },
			p = { 0.16, 0.2, -0.43 },
			r = { 0, 0, 20 },
			c = NUIT,
		}, true)
		ajouter(l, { n = "Bouche", t = { 0.26, 0.06, 0.02 }, p = { 0, -0.18, -0.425 }, c = NUIT })
		ajouter(l, {
			n = "Trainee",
			t = { 0.5, 0.4, 0.1 },
			p = { 0, -0.1, 0.47 },
			c = { 255, 150, 60 },
			m = "Neon",
			tr = 0.3,
			a = "Queue",
			j = { 0, -0.1, 0.42 },
		})
	end)

	-- Moyenne : soldat extraterrestre à trois yeux et casque.
	definir("Zorglouf", 0.82, function(l)
		local peau = { 150, 90, 220 }
		local tete = { 0, 0.14, 0 }
		ajouter(l, { n = "Corps", t = { 0.46, 0.46, 0.36 }, p = { 0, -0.14, 0 }, c = METAL })
		ajouter(l, { n = "Ceinture", t = { 0.47, 0.06, 0.37 }, p = { 0, -0.26, 0 }, c = NUIT })
		ajouter(l, {
			n = "Voyant",
			t = { 0.08, 0.08, 0.02 },
			p = { 0, -0.06, -0.19 },
			c = { 255, 60, 80 },
			m = "Neon",
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.4, 0.34, 0.34 },
			p = { 0, 0.26, -0.02 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		for i, x in { -0.1, 0.0, 0.1 } do
			ajouter(l, {
				n = "Oeil" .. i,
				t = { 0.07, 0.08, 0.02 },
				p = { x, 0.28 + (if i == 2 then 0.06 else 0), -0.195 },
				c = { 255, 230, 60 },
				m = "Neon",
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Bouche",
			t = { 0.16, 0.04, 0.02 },
			p = { 0, 0.16, -0.195 },
			c = NUIT,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Casque",
			t = { 0.42, 0.1, 0.36 },
			p = { 0, 0.46, -0.02 },
			c = METAL,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Antenne",
			t = { 0.03, 0.14, 0.03 },
			p = { 0.12, 0.58, -0.02 },
			c = METAL,
			a = "Antenne",
			j = { 0.12, 0.51, -0.02 },
		}, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.12, 0.32, 0.12 },
			p = { 0.3, -0.12, 0 },
			c = peau,
			a = "Bras",
			j = { 0.29, 0.02, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pistolet",
			t = { 0.08, 0.08, 0.18 },
			p = { 0.3, -0.28, -0.08 },
			c = CYAN,
			m = "Neon",
			a = "Bras",
			j = { 0.29, 0.02, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.14, 0.14, 0.14 },
			p = { 0.12, -0.43, 0 },
			c = METAL,
			a = "Patte",
			j = { 0.12, -0.37, 0 },
			ph = math.pi,
		}, true)
	end)

	-- Lointaine : kraken cosmique aux tentacules lumineux.
	definir("Krakosmos", 0.82, function(l)
		local chair = { 120, 40, 140 }
		local tete = { 0, 0.18, 0 }
		ajouter(l, { n = "Manteau", t = { 0.62, 0.62, 0.56 }, p = { 0, 0.14, 0.02 }, c = chair })
		ajouter(l, {
			n = "Pointe",
			t = { 0.4, 0.2, 0.36 },
			p = { 0, 0.52, 0.06 },
			c = chair,
			a = "Antenne",
			j = { 0, 0.44, 0.04 },
		})
		for i, pos in { { 0.18, 0.3, 0.29 }, { -0.16, 0.1, 0.29 }, { 0.2, -0.04, 0.29 } } do
			ajouter(
				l,
				{ n = "Ventouse" .. i, t = { 0.08, 0.08, 0.02 }, p = pos, c = CYAN, m = "Neon" }
			)
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.14, 0.1, 0.03 },
			p = { 0.15, 0.2, -0.265 },
			r = { 0, 0, -12 },
			c = { 255, 230, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.18, 0.04, 0.03 },
			p = { 0.15, 0.3, -0.265 },
			r = { 0, 0, 20 },
			c = NUIT,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bec",
			t = { 0.12, 0.1, 0.06 },
			p = { 0, 0.02, -0.28 },
			c = NUIT,
			a = "Machoire",
			j = { 0, 0.06, -0.26 },
		})
		for i = 1, 6 do
			local a = (i / 6) * 2 * math.pi
			local x, z = math.cos(a) * 0.3, math.sin(a) * 0.3
			ajouter(l, {
				n = "Tentacule" .. i,
				t = { 0.1, 0.4, 0.1 },
				p = { x, -0.3, z },
				r = { z * 40, 0, -x * 40 },
				c = chair,
				a = if i % 2 == 0 then "Bras" else "Patte",
				j = { x * 0.8, -0.12, z * 0.8 },
				ph = i,
			})
			ajouter(l, {
				n = "BoutTentacule" .. i,
				t = { 0.08, 0.08, 0.08 },
				p = { x * 1.25, -0.48, z * 1.25 },
				c = CYAN,
				m = "Neon",
				a = if i % 2 == 0 then "Bras" else "Patte",
				j = { x * 0.8, -0.12, z * 0.8 },
				ph = i,
			})
		end
	end)
end
