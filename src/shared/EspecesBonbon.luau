--!strict
-- Bestiaire du biome 9 : Royaume Bonbon (guimauve, sucre, glaçage).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local GUIMAUVE = { 255, 210, 230 }
	local MENTHE = { 160, 240, 200 }
	local BISCUIT = { 210, 150, 90 }
	local CHOCO = { 110, 65, 45 }
	local GLACAGE = { 255, 150, 200 }
	local ARC = {
		{ 255, 90, 90 },
		{ 255, 170, 60 },
		{ 255, 230, 80 },
		{ 110, 220, 120 },
		{ 90, 170, 255 },
		{ 180, 120, 255 },
	}

	-- Vermicelles colorés posés sur un dessus (y), sur une surface (demi-taille).
	local function vermicelles(l: any, y: number, demi: number, role: string?, j: { number }?)
		local positions = {
			{ -0.6, -0.4 },
			{ 0.5, -0.5 },
			{ -0.2, 0.3 },
			{ 0.6, 0.4 },
			{ 0.1, -0.1 },
			{ -0.6, 0.6 },
		}
		for i, p in positions do
			ajouter(l, {
				n = "Vermicelle" .. i,
				t = { 0.06, 0.025, 0.025 },
				p = { p[1] * demi, y, p[2] * demi },
				r = { 0, i * 37, 0 },
				c = ARC[i],
				a = role,
				j = j,
			})
		end
	end

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : petit cube de guimauve tout mou.
	definir("Guimauvette", 0.5, function(l)
		ajouter(l, { n = "Corps", t = { 0.52, 0.46, 0.5 }, p = { 0, -0.27, 0 }, c = GUIMAUVE })
		ajouter(l, { n = "Dessus", t = { 0.44, 0.04, 0.42 }, p = { 0, -0.02, 0 }, c = BLANC })
		yeux(l, 0.11, -0.2, -0.255, 0.1)
		ajouter(
			l,
			{
				n = "Sourire",
				t = { 0.1, 0.025, 0.02 },
				p = { 0, -0.32, -0.255 },
				c = { 150, 70, 100 },
			}
		)
		ajouter(
			l,
			{ n = "Joue", t = { 0.06, 0.03, 0.02 }, p = { 0.19, -0.28, -0.255 }, c = ROSE },
			true
		)
		ajouter(
			l,
			{
				n = "Pique",
				t = { 0.03, 0.18, 0.03 },
				p = { 0.0, 0.07, 0.04 },
				r = { 0, 0, 10 },
				c = BISCUIT,
				a = "Antenne",
				j = { 0, 0.0, 0.04 },
			}
		)
		ajouter(
			l,
			{
				n = "Pied",
				t = { 0.12, 0.04, 0.12 },
				p = { 0.14, -0.48, 0 },
				c = GUIMAUVE,
				a = "Patte",
				j = { 0.14, -0.46, 0 },
				ph = 0,
			},
			true
		)
	end, "Gelee")

	-- Commune : boule de chewing-gum qui rebondit.
	definir("Bonbouboule", 0.6, function(l)
		ajouter(
			l,
			{ n = "Boule", f = "Ball", t = { 0.56, 0.56, 0.56 }, p = { 0, -0.2, 0 }, c = "Rarete" }
		)
		ajouter(
			l,
			{
				n = "Brillance",
				f = "Ball",
				t = { 0.12, 0.12, 0.12 },
				p = { 0.14, 0.0, -0.18 },
				c = BLANC,
				tr = 0.3,
			}
		)
		yeux(l, 0.1, -0.16, -0.27, 0.1)
		ajouter(
			l,
			{
				n = "Bulle",
				f = "Ball",
				t = { 0.16, 0.16, 0.16 },
				p = { 0, -0.32, -0.32 },
				c = GLACAGE,
				tr = 0.3,
				a = "Machoire",
				j = { 0, -0.32, -0.24 },
			}
		)
		ajouter(
			l,
			{
				n = "Pied",
				t = { 0.14, 0.06, 0.16 },
				p = { 0.13, -0.47, -0.02 },
				c = { 255, 120, 170 },
				a = "Patte",
				j = { 0.13, -0.44, -0.02 },
				ph = 0,
			},
			true
		)
	end)

	-- Rare : chat-cupcake avec sa cerise.
	definir("Cupcaket", 0.85, function(l)
		local tete = { 0, -0.04, 0 }
		ajouter(
			l,
			{ n = "Moule", t = { 0.44, 0.3, 0.44 }, p = { 0, -0.35, 0 }, c = { 120, 200, 240 } }
		)
		for i, x in { -0.15, -0.05, 0.05, 0.15 } do
			ajouter(
				l,
				{
					n = "Pli" .. i,
					t = { 0.03, 0.3, 0.02 },
					p = { x, -0.35, -0.225 },
					c = { 90, 170, 220 },
				}
			)
		end
		ajouter(
			l,
			{
				n = "Glacage",
				t = { 0.52, 0.18, 0.52 },
				p = { 0, -0.12, 0 },
				c = GLACAGE,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Glacage2",
				t = { 0.38, 0.14, 0.38 },
				p = { 0, 0.04, 0.02 },
				c = GLACAGE,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Oreille",
				t = { 0.12, 0.14, 0.08 },
				p = { 0.16, 0.16, 0.0 },
				r = { 0, 0, -15 },
				c = GLACAGE,
				a = "Oreille",
				j = { 0.14, 0.1, 0 },
			},
			true
		)
		yeux(l, 0.1, -0.12, -0.265, 0.09, "Tete", tete)
		ajouter(
			l,
			{
				n = "Truffe",
				t = { 0.05, 0.03, 0.02 },
				p = { 0, -0.18, -0.265 },
				c = ROSE,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Moustache",
				t = { 0.12, 0.015, 0.015 },
				p = { 0.18, -0.17, -0.265 },
				c = CHOCO,
				a = "Tete",
				j = tete,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Cerise",
				f = "Ball",
				t = { 0.14, 0.14, 0.14 },
				p = { 0, 0.18, 0.02 },
				c = "Rarete",
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Queue",
				t = { 0.06, 0.06, 0.24 },
				p = { 0, -0.3, 0.32 },
				r = { -30, 0, 0 },
				c = GLACAGE,
				a = "Queue",
				j = { 0, -0.32, 0.22 },
			}
		)
		vermicelles(l, 0.115, 0.17, "Tete", tete)
	end)

	-- Rare : ourson en gomme translucide.
	definir("Oursongomme", 0.8, function(l)
		local gomme = { 255, 110, 110 }
		local tete = { 0, 0.04, 0 }
		ajouter(
			l,
			{ n = "Ventre", t = { 0.42, 0.42, 0.34 }, p = { 0, -0.24, 0.02 }, c = gomme, tr = 0.25 }
		)
		ajouter(
			l,
			{
				n = "Coeur",
				t = { 0.2, 0.2, 0.2 },
				p = { 0, -0.22, 0.02 },
				c = "Rarete",
				m = "Neon",
				tr = 0.3,
			}
		)
		ajouter(
			l,
			{
				n = "Tete",
				t = { 0.38, 0.32, 0.32 },
				p = { 0, 0.14, -0.02 },
				c = gomme,
				tr = 0.2,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Oreille",
				t = { 0.12, 0.12, 0.1 },
				p = { 0.16, 0.34, -0.02 },
				c = gomme,
				tr = 0.2,
				a = "Oreille",
				j = { 0.14, 0.28, -0.02 },
			},
			true
		)
		ajouter(
			l,
			{
				n = "Museau",
				t = { 0.14, 0.1, 0.06 },
				p = { 0, 0.06, -0.2 },
				c = { 255, 160, 160 },
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Oeil",
				t = { 0.05, 0.06, 0.02 },
				p = { 0.09, 0.18, -0.185 },
				c = NOIR,
				a = "Tete",
				j = tete,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Bras",
				t = { 0.1, 0.18, 0.1 },
				p = { 0.25, -0.18, -0.02 },
				r = { 0, 0, -20 },
				c = gomme,
				tr = 0.25,
				a = "Bras",
				j = { 0.22, -0.1, -0.02 },
				ph = 0,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Jambe",
				t = { 0.14, 0.1, 0.16 },
				p = { 0.12, -0.45, -0.02 },
				c = gomme,
				tr = 0.25,
				a = "Patte",
				j = { 0.12, -0.4, -0.02 },
				ph = math.pi,
			},
			true
		)
	end, "Gelee")

	-- Épique : licorne en nougat à la corne en sucre d'orge.
	definir("Licornougat", 0.9, function(l)
		local tete = { 0, 0.12, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.32, 0.56 }, p = { 0, -0.12, 0.06 }, c = CREME })
		for i, z in { -0.12, 0.06, 0.24 } do
			ajouter(
				l,
				{
					n = "Noisette" .. i,
					t = { 0.06, 0.05, 0.06 },
					p = { 0.185, -0.08 + i * 0.03, z },
					c = BISCUIT,
				},
				true
			)
		end
		pattes4(l, 0.12, -0.12, 0.24, { 0.1, 0.24, 0.1 }, CREME)
		ajouter(
			l,
			{
				n = "Cou",
				t = { 0.18, 0.24, 0.16 },
				p = { 0, 0.1, -0.2 },
				r = { -15, 0, 0 },
				c = CREME,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Tete",
				t = { 0.24, 0.22, 0.3 },
				p = { 0, 0.26, -0.3 },
				c = CREME,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Museau",
				t = { 0.18, 0.12, 0.1 },
				p = { 0, 0.2, -0.48 },
				c = GLACAGE,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Oeil",
				t = { 0.04, 0.06, 0.02 },
				p = { 0.125, 0.3, -0.36 },
				c = NOIR,
				a = "Tete",
				j = tete,
			},
			true
		)
		for i = 0, 2 do
			ajouter(
				l,
				{
					n = "Corne" .. i,
					t = { 0.08 - i * 0.02, 0.08, 0.08 - i * 0.02 },
					p = { 0, 0.41 + i * 0.07, -0.36 - i * 0.02 },
					r = { 0, i * 30, 0 },
					c = if i == 1 then BLANC else "Rarete",
					a = "Tete",
					j = tete,
				}
			)
		end
		for i, c in { ARC[1], ARC[3], ARC[5] } do
			ajouter(
				l,
				{
					n = "Criniere" .. i,
					t = { 0.06, 0.1, 0.1 },
					p = { 0, 0.4 - i * 0.07, -0.22 + i * 0.07 },
					c = c,
					a = "Tete",
					j = tete,
				}
			)
		end
		ajouter(
			l,
			{
				n = "Queue",
				t = { 0.08, 0.24, 0.08 },
				p = { 0, -0.06, 0.38 },
				r = { 30, 0, 0 },
				c = ARC[6],
				a = "Queue",
				j = { 0, 0.02, 0.32 },
			}
		)
	end)

	-- Épique : escargot à coquille de cookie.
	definir("Escarbiscuit", 0.7, function(l)
		local peau = MENTHE
		ajouter(l, { n = "Pied", t = { 0.3, 0.14, 0.72 }, p = { 0, -0.43, 0.0 }, c = peau })
		ajouter(l, { n = "Coquille", t = { 0.3, 0.46, 0.46 }, p = { 0, -0.13, 0.1 }, c = BISCUIT })
		for i, pos in
			{
				{ 0.16, -0.0, 0.0 },
				{ 0.16, -0.2, 0.18 },
				{ 0.16, 0.02, 0.24 },
				{ 0.16, -0.24, -0.02 },
			}
		do
			ajouter(l, { n = "Pepite" .. i, t = { 0.02, 0.06, 0.06 }, p = pos, c = CHOCO }, true)
		end
		ajouter(l, { n = "Spirale", t = { 0.32, 0.18, 0.18 }, p = { 0, -0.1, 0.1 }, c = "Rarete" })
		ajouter(
			l,
			{
				n = "Tete",
				t = { 0.22, 0.24, 0.18 },
				p = { 0, -0.26, -0.3 },
				c = peau,
				a = "Tete",
				j = { 0, -0.36, -0.28 },
			}
		)
		yeux(l, 0.06, -0.24, -0.395, 0.06, "Tete", { 0, -0.36, -0.28 })
		ajouter(
			l,
			{
				n = "Antenne",
				t = { 0.03, 0.16, 0.03 },
				p = { 0.06, -0.06, -0.32 },
				r = { 0, 0, -15 },
				c = peau,
				a = "Antenne",
				j = { 0.05, -0.14, -0.32 },
			},
			true
		)
		ajouter(
			l,
			{
				n = "Bille",
				f = "Ball",
				t = { 0.06, 0.06, 0.06 },
				p = { 0.08, 0.03, -0.32 },
				c = GLACAGE,
				a = "Antenne",
				j = { 0.05, -0.14, -0.32 },
			},
			true
		)
	end, "Gelee")

	-- Légendaire : dino-gâteau à étages avec bougies.
	definir("Gateaurex", 0.95, function(l)
		local tete = { 0, 0.1, -0.2 }
		ajouter(l, { n = "Etage1", t = { 0.48, 0.24, 0.56 }, p = { 0, -0.2, 0.08 }, c = BISCUIT })
		ajouter(l, { n = "Creme1", t = { 0.5, 0.05, 0.58 }, p = { 0, -0.07, 0.08 }, c = CREME })
		ajouter(l, { n = "Etage2", t = { 0.38, 0.16, 0.42 }, p = { 0, 0.03, 0.12 }, c = GLACAGE })
		ajouter(
			l,
			{ n = "Fraise", t = { 0.08, 0.08, 0.08 }, p = { 0.12, 0.15, 0.26 }, c = { 240, 60, 70 } },
			true
		)
		ajouter(
			l,
			{ n = "Bougie", t = { 0.04, 0.12, 0.04 }, p = { 0.08, 0.17, 0.06 }, c = MENTHE },
			true
		)
		ajouter(
			l,
			{
				n = "Flamme",
				t = { 0.04, 0.05, 0.04 },
				p = { 0.08, 0.255, 0.06 },
				c = "Rarete",
				m = "Neon",
				a = "Antenne",
				j = { 0.08, 0.23, 0.06 },
			},
			true
		)
		ajouter(
			l,
			{
				n = "Tete",
				t = { 0.3, 0.26, 0.32 },
				p = { 0, 0.2, -0.32 },
				c = BISCUIT,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Machoire",
				t = { 0.28, 0.08, 0.26 },
				p = { 0, 0.04, -0.34 },
				c = CREME,
				a = "Machoire",
				j = { 0, 0.08, -0.22 },
			}
		)
		ajouter(
			l,
			{
				n = "Dent",
				t = { 0.03, 0.04, 0.02 },
				p = { 0.09, 0.06, -0.475 },
				c = BLANC,
				a = "Tete",
				j = tete,
			},
			true
		)
		yeux(l, 0.08, 0.26, -0.485, 0.08, "Tete", tete)
		ajouter(
			l,
			{
				n = "Bras",
				t = { 0.06, 0.12, 0.06 },
				p = { 0.2, -0.04, -0.2 },
				r = { -30, 0, 0 },
				c = BISCUIT,
				a = "Bras",
				j = { 0.2, 0.0, -0.18 },
				ph = 0,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Jambe",
				t = { 0.14, 0.18, 0.18 },
				p = { 0.17, -0.41, 0.12 },
				c = BISCUIT,
				a = "Patte",
				j = { 0.17, -0.33, 0.12 },
				ph = 0,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Queue",
				t = { 0.14, 0.12, 0.3 },
				p = { 0, -0.2, 0.5 },
				r = { -10, 0, 0 },
				c = BISCUIT,
				a = "Queue",
				j = { 0, -0.2, 0.36 },
			}
		)
		vermicelles(l, 0.115, 0.15)
	end)

	-- Légendaire : lama piñata à franges colorées.
	definir("Pinatou", 0.95, function(l)
		local tete = { 0, 0.2, -0.16 }
		for i = 0, 3 do
			ajouter(
				l,
				{
					n = "Frange" .. i,
					t = { 0.38, 0.08, 0.5 },
					p = { 0, -0.24 + i * 0.08, 0.06 },
					c = ARC[i + 1],
				}
			)
		end
		pattes4(l, 0.12, -0.12, 0.24, { 0.1, 0.18, 0.1 }, ARC[5])
		for i = 0, 2 do
			ajouter(
				l,
				{
					n = "Cou" .. i,
					t = { 0.18, 0.08, 0.16 },
					p = { 0, 0.14 + i * 0.08, -0.16 },
					c = ARC[6 - i],
					a = "Tete",
					j = tete,
				}
			)
		end
		ajouter(
			l,
			{
				n = "Tete",
				t = { 0.22, 0.16, 0.28 },
				p = { 0, 0.42, -0.22 },
				c = ARC[3],
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Oreille",
				t = { 0.05, 0.14, 0.04 },
				p = { 0.08, 0.56, -0.14 },
				c = ARC[1],
				a = "Oreille",
				j = { 0.08, 0.5, -0.14 },
			},
			true
		)
		ajouter(
			l,
			{
				n = "Oeil",
				t = { 0.04, 0.05, 0.02 },
				p = { 0.07, 0.45, -0.365 },
				c = NOIR,
				a = "Tete",
				j = tete,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Pompon",
				f = "Ball",
				t = { 0.1, 0.1, 0.1 },
				p = { 0, 0.52, -0.26 },
				c = "Rarete",
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Queue",
				t = { 0.08, 0.14, 0.08 },
				p = { 0, 0.02, 0.34 },
				c = ARC[2],
				a = "Queue",
				j = { 0, 0.06, 0.3 },
			}
		)
	end)

	-- Mythique : petit nuage arc-en-ciel.
	definir("Arcencielle", 0.8, function(l)
		local nuage = { 0, -0.04, 0 }
		for i, c in ARC do
			ajouter(
				l,
				{
					n = "Arc" .. i,
					t = { 0.06, 0.06, 0.08 + (6 - i) * 0.02 },
					p = { 0, 0.28 - i * 0.06, 0.24 },
					c = c,
					m = "Neon",
					tr = 0.1,
				}
			)
		end
		ajouter(
			l,
			{
				n = "Nuage",
				t = { 0.6, 0.3, 0.42 },
				p = { 0, -0.02, 0 },
				c = BLANC,
				a = "Antenne",
				j = nuage,
			}
		)
		ajouter(
			l,
			{
				n = "Bosse",
				t = { 0.3, 0.2, 0.3 },
				p = { -0.12, 0.2, 0.0 },
				c = BLANC,
				a = "Antenne",
				j = nuage,
			}
		)
		ajouter(
			l,
			{
				n = "Bosse2",
				t = { 0.2, 0.16, 0.24 },
				p = { 0.16, 0.16, 0.02 },
				c = BLANC,
				a = "Antenne",
				j = nuage,
			}
		)
		yeux(l, 0.1, -0.0, -0.215, 0.09, "Antenne", nuage)
		ajouter(
			l,
			{
				n = "Joue",
				t = { 0.06, 0.03, 0.02 },
				p = { 0.2, -0.08, -0.215 },
				c = ROSE,
				a = "Antenne",
				j = nuage,
			},
			true
		)
		for i, x in { -0.16, 0.0, 0.16 } do
			ajouter(
				l,
				{
					n = "Goutte" .. i,
					t = { 0.05, 0.08, 0.05 },
					p = { x, -0.3 - i * 0.04, 0.0 },
					c = "Rarete",
					m = "Neon",
					a = "Patte",
					j = { x, -0.2, 0 },
					ph = i,
				}
			)
		end
	end)

	-- Mythique : fée en sucre filé aux ailes de dragée.
	definir("Dragefee", 0.85, function(l)
		local peau = { 255, 225, 235 }
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Robe", t = { 0.34, 0.3, 0.3 }, p = { 0, -0.3, 0 }, c = MENTHE })
		ajouter(l, { n = "Jupon", t = { 0.42, 0.06, 0.38 }, p = { 0, -0.44, 0 }, c = GLACAGE })
		ajouter(l, { n = "Buste", t = { 0.22, 0.16, 0.18 }, p = { 0, -0.08, 0 }, c = MENTHE })
		ajouter(
			l,
			{
				n = "Tete",
				t = { 0.3, 0.28, 0.28 },
				p = { 0, 0.14, -0.02 },
				c = peau,
				a = "Tete",
				j = tete,
			}
		)
		yeux(l, 0.07, 0.14, -0.165, 0.07, "Tete", tete)
		ajouter(
			l,
			{
				n = "Cheveux",
				t = { 0.32, 0.12, 0.3 },
				p = { 0, 0.3, 0.0 },
				c = GLACAGE,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Chignon",
				f = "Ball",
				t = { 0.14, 0.14, 0.14 },
				p = { 0, 0.38, 0.1 },
				c = GLACAGE,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Diademe",
				t = { 0.06, 0.06, 0.02 },
				p = { 0, 0.33, -0.16 },
				c = "Rarete",
				m = "Neon",
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Aile",
				f = "Ball",
				t = { 0.04, 0.3, 0.2 },
				p = { 0.16, 0.0, 0.2 },
				r = { 0, -30, -20 },
				c = { 220, 200, 255 },
				tr = 0.3,
				a = "Aile",
				j = { 0.06, -0.04, 0.1 },
			},
			true
		)
		ajouter(
			l,
			{
				n = "Bras",
				t = { 0.05, 0.16, 0.05 },
				p = { 0.14, -0.12, -0.02 },
				r = { 0, 0, -20 },
				c = peau,
				a = "Bras",
				j = { 0.12, -0.04, -0.02 },
				ph = 0,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Baguette",
				t = { 0.02, 0.18, 0.02 },
				p = { 0.2, -0.16, -0.08 },
				r = { -30, 0, 0 },
				c = BLANC,
				a = "Bras",
				j = { 0.12, -0.04, -0.02 },
				ph = 0,
			}
		)
		ajouter(
			l,
			{
				n = "EtoileBaguette",
				t = { 0.06, 0.06, 0.02 },
				p = { 0.2, -0.06, -0.14 },
				r = { 0, 0, 45 },
				c = { 255, 240, 120 },
				m = "Neon",
				a = "Bras",
				j = { 0.12, -0.04, -0.02 },
				ph = 0,
			}
		)
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : gelée tremblotante qui avale tout.
	definir("Gelatinou", 0.6, function(l)
		local vert = { 120, 230, 120 }
		ajouter(l, { n = "Gelee", t = { 0.8, 0.6, 0.8 }, p = { 0, -0.2, 0 }, c = vert, tr = 0.3 })
		ajouter(
			l,
			{
				n = "Base",
				t = { 0.86, 0.06, 0.86 },
				p = { 0, -0.47, 0 },
				c = { 80, 190, 90 },
				tr = 0.2,
			}
		)
		ajouter(
			l,
			{
				n = "Cerise",
				f = "Ball",
				t = { 0.14, 0.14, 0.14 },
				p = { 0.1, 0.17, 0.08 },
				c = { 230, 40, 60 },
				a = "Antenne",
				j = { 0, 0.1, 0 },
			}
		)
		ajouter(
			l,
			{
				n = "Tige",
				t = { 0.02, 0.12, 0.02 },
				p = { 0.12, 0.28, 0.08 },
				r = { 0, 0, -20 },
				c = CHOCO,
				a = "Antenne",
				j = { 0, 0.1, 0 },
			}
		)
		yeux(l, 0.16, -0.1, -0.405, 0.15)
		ajouter(
			l,
			{
				n = "Sourcil",
				t = { 0.18, 0.04, 0.02 },
				p = { 0.16, 0.02, -0.405 },
				r = { 0, 0, 20 },
				c = { 40, 100, 40 },
			},
			true
		)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.32, 0.08, 0.02 }, p = { 0, -0.3, -0.405 }, c = { 40, 100, 40 } }
		)
		ajouter(
			l,
			{
				n = "Bonbon",
				t = { 0.1, 0.1, 0.1 },
				p = { -0.14, -0.3, 0.1 },
				r = { 30, 30, 0 },
				c = GLACAGE,
			}
		)
	end, "Gelee")

	-- Moyenne : bonhomme en pain d'épice très en colère.
	definir("Croquebiscuit", 0.85, function(l)
		local tete = { 0, 0.16, 0 }
		ajouter(l, { n = "Corps", t = { 0.42, 0.36, 0.14 }, p = { 0, -0.08, 0 }, c = BISCUIT })
		ajouter(
			l,
			{
				n = "Tete",
				t = { 0.34, 0.3, 0.14 },
				p = { 0, 0.26, 0 },
				c = BISCUIT,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Oeil",
				t = { 0.06, 0.06, 0.02 },
				p = { 0.07, 0.3, -0.08 },
				c = { 255, 60, 60 },
				m = "Neon",
				a = "Tete",
				j = tete,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Sourcil",
				t = { 0.1, 0.03, 0.02 },
				p = { 0.07, 0.36, -0.08 },
				r = { 0, 0, 25 },
				c = BLANC,
				a = "Tete",
				j = tete,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Bouche",
				t = { 0.14, 0.03, 0.02 },
				p = { 0, 0.18, -0.08 },
				r = { 0, 0, 0 },
				c = BLANC,
				a = "Tete",
				j = tete,
			}
		)
		for i, y in { 0.02, -0.1 } do
			ajouter(
				l,
				{
					n = "Bouton" .. i,
					t = { 0.06, 0.06, 0.02 },
					p = { 0, y, -0.08 },
					c = if i == 1 then GLACAGE else MENTHE,
				}
			)
		end
		ajouter(l, { n = "Glacage", t = { 0.3, 0.025, 0.02 }, p = { 0, 0.1, -0.075 }, c = BLANC })
		ajouter(
			l,
			{
				n = "Bras",
				t = { 0.24, 0.12, 0.12 },
				p = { 0.32, -0.0, 0 },
				r = { 0, 0, 20 },
				c = BISCUIT,
				a = "Bras",
				j = { 0.2, 0.04, 0 },
				ph = 0,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Jambe",
				t = { 0.14, 0.24, 0.12 },
				p = { 0.12, -0.38, 0 },
				c = BISCUIT,
				a = "Patte",
				j = { 0.12, -0.26, 0 },
				ph = 0,
			},
			true
		)
		ajouter(
			l,
			{ n = "Bordure", t = { 0.16, 0.025, 0.02 }, p = { 0.12, -0.44, -0.07 }, c = BLANC },
			true
		)
	end)

	-- Lointaine : énorme gâteau d'anniversaire à la gueule pleine de crème.
	definir("Gateaugeant", 0.95, function(l)
		local tete = { 0, 0.12, 0.2 }
		ajouter(l, { n = "Etage1", t = { 0.9, 0.36, 0.9 }, p = { 0, -0.32, 0 }, c = CHOCO })
		ajouter(l, { n = "Creme", t = { 0.92, 0.06, 0.92 }, p = { 0, -0.14, 0 }, c = CREME })
		ajouter(
			l,
			{ n = "Machoire", t = { 0.7, 0.1, 0.04 }, p = { 0, -0.3, -0.465 }, c = { 60, 25, 25 } }
		)
		for i, x in { -0.24, -0.08, 0.08, 0.24 } do
			ajouter(
				l,
				{ n = "Croc" .. i, t = { 0.06, 0.1, 0.03 }, p = { x, -0.24, -0.47 }, c = BLANC }
			)
		end
		ajouter(
			l,
			{
				n = "Etage2",
				t = { 0.66, 0.28, 0.66 },
				p = { 0, 0.0, 0 },
				c = GLACAGE,
				a = "Tete",
				j = tete,
			}
		)
		ajouter(
			l,
			{
				n = "Oeil",
				t = { 0.12, 0.08, 0.03 },
				p = { 0.15, 0.02, -0.34 },
				c = { 255, 230, 60 },
				m = "Neon",
				a = "Tete",
				j = tete,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Sourcil",
				t = { 0.16, 0.04, 0.03 },
				p = { 0.15, 0.1, -0.34 },
				r = { 0, 0, 20 },
				c = CHOCO,
				a = "Tete",
				j = tete,
			},
			true
		)
		ajouter(
			l,
			{
				n = "Etage3",
				t = { 0.42, 0.18, 0.42 },
				p = { 0, 0.23, 0 },
				c = BLANC,
				a = "Tete",
				j = tete,
			}
		)
		for i, pos in { { 0.12, 0.12 }, { -0.12, 0.08 }, { 0.0, -0.12 } } do
			ajouter(
				l,
				{
					n = "Bougie" .. i,
					t = { 0.05, 0.14, 0.05 },
					p = { pos[1], 0.39, pos[2] },
					c = ARC[i * 2],
					a = "Tete",
					j = tete,
				}
			)
			ajouter(
				l,
				{
					n = "Flamme" .. i,
					t = { 0.05, 0.06, 0.05 },
					p = { pos[1], 0.49, pos[2] },
					c = { 255, 200, 60 },
					m = "Neon",
					a = "Antenne",
					j = { pos[1], 0.46, pos[2] },
				}
			)
		end
		ajouter(
			l,
			{
				n = "Fraise",
				t = { 0.12, 0.12, 0.12 },
				p = { 0.32, 0.2, -0.32 },
				r = { 0, 45, 0 },
				c = { 240, 60, 70 },
			},
			true
		)
		vermicelles(l, -0.105, 0.42)
	end)
end
