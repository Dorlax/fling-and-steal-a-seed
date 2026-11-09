--!strict
-- Bestiaire du biome 11 : Îles Célestes (nuages, vent, soleil et lune).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local NUAGE = { 245, 248, 255 }
	local CIEL = { 150, 200, 255 }
	local OR = { 255, 210, 80 }
	local ORAGE = { 90, 95, 120 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : mouton dont la laine est un nuage.
	definir("Nuageon", 0.6, function(l)
		local tete = { 0, -0.12, -0.24 }
		ajouter(l, { n = "Laine", t = { 0.5, 0.36, 0.52 }, p = { 0, -0.12, 0.04 }, c = NUAGE })
		ajouter(l, { n = "Bosse", t = { 0.28, 0.16, 0.28 }, p = { 0.08, 0.1, 0.06 }, c = NUAGE })
		ajouter(l, { n = "Bosse2", t = { 0.22, 0.14, 0.22 }, p = { -0.12, 0.08, 0.14 }, c = NUAGE })
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.24, 0.18 },
			p = { 0, -0.12, -0.3 },
			c = { 120, 130, 160 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, -0.1, -0.395, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.1, 0.04, 0.06 },
			p = { 0.16, -0.06, -0.3 },
			r = { 0, 0, -20 },
			c = { 120, 130, 160 },
			a = "Oreille",
			j = { 0.12, -0.06, -0.3 },
		}, true)
		ajouter(l, {
			n = "Frange",
			t = { 0.2, 0.06, 0.08 },
			p = { 0, 0.02, -0.3 },
			c = NUAGE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Goutte",
			t = { 0.04, 0.06, 0.04 },
			p = { 0.18, -0.36, 0.2 },
			c = "Rarete",
			m = "Neon",
		})
		pattes4(l, 0.14, -0.1, 0.2, { 0.08, 0.16, 0.08 }, { 120, 130, 160 })
	end)

	-- Commune : poussin aux ailes trop grandes.
	definir("Plumichou", 0.55, function(l)
		local jaune = { 255, 235, 150 }
		ajouter(l, { n = "Corps", t = { 0.4, 0.38, 0.38 }, p = { 0, -0.26, 0 }, c = jaune })
		yeux(l, 0.09, -0.18, -0.195, 0.08)
		ajouter(
			l,
			{ n = "Bec", t = { 0.08, 0.06, 0.06 }, p = { 0, -0.27, -0.22 }, c = { 255, 160, 60 } }
		)
		ajouter(
			l,
			{ n = "Joue", t = { 0.05, 0.03, 0.02 }, p = { 0.15, -0.25, -0.195 }, c = ROSE },
			true
		)
		ajouter(l, {
			n = "Aile",
			t = { 0.3, 0.06, 0.2 },
			p = { 0.32, -0.16, 0.02 },
			r = { 0, 0, 20 },
			c = BLANC,
			a = "Aile",
			j = { 0.18, -0.2, 0.02 },
		}, true)
		ajouter(l, {
			n = "Plume",
			t = { 0.14, 0.04, 0.12 },
			p = { 0.46, -0.1, 0.04 },
			r = { 0, 0, 30 },
			c = "Rarete",
			a = "Aile",
			j = { 0.18, -0.2, 0.02 },
		}, true)
		ajouter(l, {
			n = "Meche",
			t = { 0.04, 0.1, 0.04 },
			p = { 0, -0.02, -0.02 },
			r = { 0, 0, 20 },
			c = jaune,
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.06, 0.06, 0.08 },
			p = { 0.08, -0.47, -0.02 },
			c = { 255, 160, 60 },
			a = "Patte",
			j = { 0.08, -0.44, -0.02 },
			ph = 0,
		}, true)
	end)

	-- Rare : petite montgolfière vivante.
	definir("Ballonard", 0.95, function(l)
		local ballon = { 0, 0.16, 0 }
		ajouter(l, {
			n = "Ballon",
			t = { 0.56, 0.52, 0.56 },
			p = { 0, 0.18, 0 },
			c = { 255, 110, 110 },
			a = "Antenne",
			j = ballon,
		})
		for i, x in { -0.18, 0, 0.18 } do
			ajouter(l, {
				n = "Bande" .. i,
				t = { 0.08, 0.53, 0.57 },
				p = { x, 0.18, 0 },
				c = if i == 2 then "Rarete" else { 255, 230, 120 },
				a = "Antenne",
				j = ballon,
			})
		end
		ajouter(l, {
			n = "Haut",
			t = { 0.36, 0.08, 0.36 },
			p = { 0, 0.47, 0 },
			c = { 255, 110, 110 },
			a = "Antenne",
			j = ballon,
		})
		yeux(l, 0.1, 0.22, -0.285, 0.1, "Antenne", ballon)
		ajouter(l, {
			n = "Sourire",
			t = { 0.12, 0.025, 0.02 },
			p = { 0, 0.08, -0.285 },
			c = { 120, 40, 40 },
			a = "Antenne",
			j = ballon,
		})
		for i, x in { -0.12, 0.12 } do
			ajouter(l, {
				n = "Corde" .. i,
				t = { 0.02, 0.2, 0.02 },
				p = { x, -0.17, 0 },
				c = { 120, 90, 60 },
			})
		end
		ajouter(l, {
			n = "Panier",
			t = { 0.3, 0.2, 0.3 },
			p = { 0, -0.38, 0 },
			c = { 190, 140, 80 },
			a = "Patte",
			j = { 0, -0.28, 0 },
		})
		ajouter(l, {
			n = "Rebord",
			t = { 0.32, 0.04, 0.32 },
			p = { 0, -0.27, 0 },
			c = { 150, 100, 60 },
			a = "Patte",
			j = { 0, -0.28, 0 },
		})
	end)

	-- Rare : poisson-cerf-volant qui nage dans le vent.
	definir("Cerfvolant", 0.7, function(l)
		local corps = { 0, -0.04, 0 }
		ajouter(l, {
			n = "Losange",
			t = { 0.4, 0.4, 0.06 },
			p = { 0, 0.02, 0 },
			r = { 0, 0, 45 },
			c = { 120, 180, 255 },
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Croix",
			t = { 0.04, 0.5, 0.07 },
			p = { 0, 0.02, 0 },
			c = { 255, 255, 255 },
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Croix2",
			t = { 0.5, 0.04, 0.07 },
			p = { 0, 0.02, 0 },
			c = { 255, 255, 255 },
			a = "Antenne",
			j = corps,
		})
		yeux(l, 0.08, 0.06, -0.04, 0.08, "Antenne", corps)
		ajouter(l, {
			n = "Bouche",
			t = { 0.06, 0.04, 0.02 },
			p = { 0, -0.05, -0.04 },
			c = ROSE,
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.16, 0.04, 0.1 },
			p = { 0.3, 0.02, 0.02 },
			r = { 0, 0, -20 },
			c = { 255, 200, 90 },
			a = "Aile",
			j = { 0.2, 0.02, 0.02 },
		}, true)
		local fil = { 0, -0.26, 0.04 }
		for i = 1, 3 do
			ajouter(l, {
				n = "Noeud" .. i,
				t = { 0.08, 0.04, 0.04 },
				p = { (i % 2) * 0.06 - 0.03, -0.24 - i * 0.07, 0.04 },
				r = { 0, 0, 45 },
				c = if i == 3 then "Rarete" else { 255, 120, 160 },
				a = "Queue",
				j = fil,
				ph = i,
			})
		end
		ajouter(l, { n = "Fil", t = { 0.015, 0.26, 0.015 }, p = { 0, -0.36, 0.04 }, c = BLANC })
	end)

	-- Épique : bébé griffon (tête d'aigle, corps de lion).
	definir("Griffonnet", 0.8, function(l)
		local fauve = { 220, 170, 90 }
		local tete = { 0, 0.08, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.3, 0.5 }, p = { 0, -0.18, 0.06 }, c = fauve })
		pattes4(l, 0.11, -0.12, 0.22, { 0.1, 0.18, 0.1 }, fauve)
		ajouter(l, { n = "Plumage", t = { 0.32, 0.3, 0.2 }, p = { 0, 0.0, -0.18 }, c = BLANC })
		ajouter(l, {
			n = "Tete",
			t = { 0.28, 0.26, 0.26 },
			p = { 0, 0.18, -0.26 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.1, 0.1, 0.12 },
			p = { 0, 0.12, -0.44 },
			r = { 25, 0, 0 },
			c = OR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, 0.22, -0.395, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.26, 0.34 },
			p = { 0.2, 0.06, 0.02 },
			r = { 15, 0, -20 },
			c = { 255, 240, 200 },
			a = "Aile",
			j = { 0.16, -0.04, 0.02 },
		}, true)
		ajouter(l, {
			n = "BoutAile",
			t = { 0.04, 0.12, 0.14 },
			p = { 0.25, 0.22, 0.1 },
			r = { 15, 0, -20 },
			c = "Rarete",
			a = "Aile",
			j = { 0.16, -0.04, 0.02 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.05, 0.26 },
			p = { 0, -0.1, 0.42 },
			r = { 30, 0, 0 },
			c = fauve,
			a = "Queue",
			j = { 0, -0.14, 0.3 },
		})
		ajouter(l, {
			n = "Pompon",
			t = { 0.1, 0.1, 0.1 },
			p = { 0, -0.02, 0.54 },
			c = { 170, 120, 60 },
			a = "Queue",
			j = { 0, -0.14, 0.3 },
		})
	end)

	-- Épique : poulain ailé à la crinière de nuage.
	definir("Pegasou", 0.85, function(l)
		local robe = { 245, 240, 255 }
		local tete = { 0, 0.12, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.3, 0.52 }, p = { 0, -0.12, 0.06 }, c = robe })
		pattes4(l, 0.11, -0.12, 0.24, { 0.09, 0.24, 0.09 }, robe)
		ajouter(
			l,
			{ n = "Sabot", t = { 0.1, 0.04, 0.1 }, p = { 0.11, -0.48, -0.12 }, c = CIEL },
			true
		)
		ajouter(l, {
			n = "Cou",
			t = { 0.16, 0.24, 0.16 },
			p = { 0, 0.08, -0.2 },
			r = { -15, 0, 0 },
			c = robe,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.2, 0.3 },
			p = { 0, 0.26, -0.3 },
			c = robe,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.16, 0.1, 0.08 },
			p = { 0, 0.2, -0.47 },
			c = { 255, 210, 230 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.06, 0.02 },
			p = { 0.115, 0.3, -0.36 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Criniere",
			t = { 0.08, 0.14, 0.26 },
			p = { 0, 0.38, -0.18 },
			c = CIEL,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.24, 0.3 },
			p = { 0.24, 0.12, 0.02 },
			r = { 20, 0, -35 },
			c = BLANC,
			a = "Aile",
			j = { 0.16, 0.0, 0.02 },
		}, true)
		ajouter(l, {
			n = "Plume",
			t = { 0.04, 0.1, 0.12 },
			p = { 0.32, 0.26, 0.1 },
			r = { 20, 0, -35 },
			c = "Rarete",
			a = "Aile",
			j = { 0.16, 0.0, 0.02 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.22, 0.08 },
			p = { 0, -0.06, 0.36 },
			r = { 30, 0, 0 },
			c = CIEL,
			a = "Queue",
			j = { 0, 0.02, 0.32 },
		})
	end)

	-- Légendaire : lionceau à la crinière de soleil.
	definir("Soleillon", 0.8, function(l)
		local fauve = { 255, 200, 110 }
		local tete = { 0, 0.04, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.3, 0.5 }, p = { 0, -0.18, 0.08 }, c = fauve })
		pattes4(l, 0.11, -0.1, 0.24, { 0.1, 0.18, 0.1 }, fauve)
		for i = 0, 7 do
			local angle = math.rad(i * 45)
			ajouter(l, {
				n = "Rayon" .. i,
				t = { 0.1, 0.18, 0.06 },
				p = { math.sin(angle) * 0.24, 0.08 + math.cos(angle) * 0.24, -0.2 },
				r = { 0, 0, -i * 45 },
				c = if i % 2 == 0 then "Rarete" else { 255, 150, 40 },
				m = "Neon",
				a = "Antenne",
				j = tete,
				ph = i,
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.28, 0.24 },
			p = { 0, 0.08, -0.26 },
			c = fauve,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.14, 0.08, 0.06 },
			p = { 0, 0.0, -0.4 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.03, 0.02 },
			p = { 0, 0.03, -0.435 },
			c = { 150, 80, 60 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.12, -0.385, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Queue",
			t = { 0.05, 0.05, 0.3 },
			p = { 0, -0.1, 0.46 },
			r = { 30, 0, 0 },
			c = fauve,
			a = "Queue",
			j = { 0, -0.14, 0.32 },
		})
		ajouter(l, {
			n = "Flamme",
			t = { 0.1, 0.1, 0.1 },
			p = { 0, 0.0, 0.6 },
			c = OR,
			m = "Neon",
			a = "Queue",
			j = { 0, -0.14, 0.32 },
		})
	end)

	-- Légendaire : chatte endormie sur un croissant de lune.
	definir("Lunarelle", 0.75, function(l)
		local nuit = { 70, 80, 150 }
		local lune = { 0, -0.2, 0 }
		ajouter(l, {
			n = "Croissant",
			t = { 0.7, 0.14, 0.24 },
			p = { 0, -0.36, 0 },
			c = { 255, 240, 170 },
			m = "Neon",
			a = "Antenne",
			j = lune,
		})
		ajouter(l, {
			n = "Corne",
			t = { 0.12, 0.26, 0.2 },
			p = { 0.32, -0.2, 0 },
			r = { 0, 0, -20 },
			c = { 255, 240, 170 },
			m = "Neon",
			a = "Antenne",
			j = lune,
		}, true)
		ajouter(l, { n = "Corps", t = { 0.38, 0.22, 0.3 }, p = { 0, -0.18, 0.02 }, c = nuit })
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.22, 0.22 },
			p = { -0.14, -0.08, -0.08 },
			c = nuit,
			a = "Tete",
			j = { -0.12, -0.12, -0.06 },
		})
		ajouter(l, {
			n = "OeilFerme",
			t = { 0.06, 0.02, 0.02 },
			p = { -0.2, -0.06, -0.195 },
			c = BLANC,
			a = "Tete",
			j = { -0.12, -0.12, -0.06 },
		})
		ajouter(l, {
			n = "OeilFerme2",
			t = { 0.06, 0.02, 0.02 },
			p = { -0.08, -0.06, -0.195 },
			c = BLANC,
			a = "Tete",
			j = { -0.12, -0.12, -0.06 },
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.08, 0.04 },
			p = { -0.08, 0.06, -0.08 },
			c = nuit,
			a = "Oreille",
			j = { -0.08, 0.02, -0.08 },
		})
		ajouter(l, {
			n = "Oreille2",
			t = { 0.06, 0.08, 0.04 },
			p = { -0.22, 0.06, -0.08 },
			c = nuit,
			a = "Oreille",
			j = { -0.22, 0.02, -0.08 },
		})
		ajouter(l, {
			n = "Etoile",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.06, -0.12, -0.13 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Bonnet",
			t = { 0.12, 0.12, 0.12 },
			p = { -0.12, 0.06, -0.04 },
			r = { 0, 0, 30 },
			c = { 120, 140, 230 },
			a = "Tete",
			j = { -0.12, -0.12, -0.06 },
		})
		ajouter(l, {
			n = "Queue",
			t = { 0.06, 0.06, 0.3 },
			p = { 0.16, -0.24, 0.12 },
			r = { 0, 50, 0 },
			c = nuit,
			a = "Queue",
			j = { 0.14, -0.22, 0.1 },
		})
	end)

	-- Mythique : esprit d'aurore aux voiles changeants.
	definir("Aurorine", 0.9, function(l)
		local esprit = { 0, 0.0, 0 }
		ajouter(l, {
			n = "Coeur",
			t = { 0.3, 0.3, 0.3 },
			p = { 0, 0.04, 0 },
			c = { 220, 255, 240 },
			m = "Neon",
			tr = 0.1,
		})
		yeux(l, 0.07, 0.07, -0.155, 0.07)
		ajouter(l, {
			n = "Sourire",
			t = { 0.06, 0.02, 0.02 },
			p = { 0, -0.03, -0.155 },
			c = { 60, 90, 90 },
		})
		for i, c in { { 120, 255, 180 }, { 120, 200, 255 }, { 200, 140, 255 }, { 255, 140, 200 } } do
			ajouter(l, {
				n = "Voile" .. i,
				t = { 0.12, 0.5, 0.03 },
				p = { (i - 2.5) * 0.14, -0.22, 0.12 },
				r = { 15, 0, (i - 2.5) * 10 },
				c = c,
				m = "Neon",
				tr = 0.35,
				a = "Queue",
				j = { 0, 0.0, 0.1 },
				ph = i,
			})
		end
		ajouter(l, {
			n = "Couronne",
			t = { 0.2, 0.06, 0.2 },
			p = { 0, 0.22, 0 },
			r = { 0, 45, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = esprit,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.2, 0.04, 0.04 },
			p = { 0.24, 0.02, 0 },
			r = { 0, 0, -20 },
			c = { 180, 255, 230 },
			m = "Neon",
			tr = 0.2,
			a = "Bras",
			j = { 0.15, 0.04, 0 },
			ph = 0,
		}, true)
	end)

	-- Mythique : petite baleine du ciel qui souffle des nuages.
	definir("Baleinuage", 0.65, function(l)
		local bleu = { 110, 150, 230 }
		ajouter(l, { n = "Corps", t = { 0.46, 0.4, 0.66 }, p = { 0, -0.08, 0.04 }, c = bleu })
		ajouter(l, { n = "Ventre", t = { 0.38, 0.04, 0.56 }, p = { 0, -0.29, 0.02 }, c = CREME })
		for i, z in { -0.18, -0.06, 0.06, 0.18 } do
			ajouter(l, {
				n = "Strie" .. i,
				t = { 0.3, 0.02, 0.03 },
				p = { 0, -0.27, z },
				c = { 230, 210, 190 },
			})
		end
		yeux(l, 0.12, 0.0, -0.305, 0.08)
		ajouter(
			l,
			{ n = "Joue", t = { 0.06, 0.03, 0.02 }, p = { 0.17, -0.08, -0.305 }, c = ROSE },
			true
		)
		ajouter(l, {
			n = "Nageoire",
			t = { 0.22, 0.04, 0.14 },
			p = { 0.3, -0.18, -0.04 },
			r = { 0, 0, -20 },
			c = bleu,
			a = "Aile",
			j = { 0.22, -0.16, -0.04 },
		}, true)
		ajouter(l, {
			n = "Caudale",
			t = { 0.4, 0.04, 0.14 },
			p = { 0, -0.02, 0.44 },
			r = { -15, 0, 0 },
			c = bleu,
			a = "Queue",
			j = { 0, -0.06, 0.34 },
		})
		local jet = { 0, 0.14, -0.04 }
		ajouter(l, {
			n = "Jet",
			t = { 0.06, 0.14, 0.06 },
			p = { 0, 0.2, -0.04 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = jet,
		})
		ajouter(l, {
			n = "Nuage",
			t = { 0.22, 0.1, 0.16 },
			p = { 0, 0.32, -0.04 },
			c = BLANC,
			a = "Antenne",
			j = jet,
		})
		ajouter(l, {
			n = "Nuage2",
			t = { 0.12, 0.08, 0.12 },
			p = { 0.1, 0.38, -0.04 },
			c = BLANC,
			a = "Antenne",
			j = jet,
		})
	end, "Gelee")

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : petit nuage d'orage grognon.
	definir("Orageon", 0.65, function(l)
		local nuage = { 0, 0.0, 0 }
		ajouter(l, {
			n = "Nuage",
			t = { 0.8, 0.4, 0.6 },
			p = { 0, 0.06, 0 },
			c = ORAGE,
			a = "Antenne",
			j = nuage,
		})
		ajouter(l, {
			n = "Bosse",
			t = { 0.4, 0.24, 0.4 },
			p = { -0.16, 0.32, 0 },
			c = ORAGE,
			a = "Antenne",
			j = nuage,
		})
		ajouter(l, {
			n = "Bosse2",
			t = { 0.3, 0.2, 0.3 },
			p = { 0.2, 0.28, 0.04 },
			c = ORAGE,
			a = "Antenne",
			j = nuage,
		})
		yeux(l, 0.16, 0.1, -0.305, 0.12, "Antenne", nuage)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.16, 0.04, 0.02 },
			p = { 0.16, 0.2, -0.31 },
			r = { 0, 0, 25 },
			c = { 40, 40, 55 },
			a = "Antenne",
			j = nuage,
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.2, 0.04, 0.02 },
			p = { 0, -0.04, -0.31 },
			c = { 40, 40, 55 },
			a = "Antenne",
			j = nuage,
		})
		ajouter(l, {
			n = "Eclair",
			t = { 0.08, 0.2, 0.04 },
			p = { 0.08, -0.26, 0 },
			r = { 0, 0, 20 },
			c = { 255, 240, 80 },
			m = "Neon",
			a = "Patte",
			j = { 0.06, -0.14, 0 },
		})
		ajouter(l, {
			n = "Eclair2",
			t = { 0.08, 0.16, 0.04 },
			p = { 0.03, -0.42, 0 },
			r = { 0, 0, -20 },
			c = { 255, 240, 80 },
			m = "Neon",
			a = "Patte",
			j = { 0.06, -0.14, 0 },
		})
	end)

	-- Moyenne : corbeau du vent aux plumes en bourrasque.
	definir("Corbeauvent", 0.75, function(l)
		local plume = { 50, 55, 80 }
		local tete = { 0, 0.14, -0.08 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.38, 0.48 }, p = { 0, -0.12, 0.06 }, c = plume })
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.28 },
			p = { 0, 0.2, -0.14 },
			c = plume,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.1, 0.08, 0.2 },
			p = { 0, 0.16, -0.36 },
			r = { 10, 0, 0 },
			c = { 60, 60, 70 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.05, 0.03 },
			p = { 0.1, 0.24, -0.285 },
			c = { 120, 220, 255 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.08, 0.03, 0.02 },
			p = { 0.1, 0.29, -0.29 },
			r = { 0, 0, 25 },
			c = { 20, 20, 30 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Aile",
			t = { 0.42, 0.04, 0.3 },
			p = { 0.36, 0.0, 0.04 },
			r = { 0, 0, 15 },
			c = plume,
			a = "Aile",
			j = { 0.18, -0.04, 0.04 },
		}, true)
		ajouter(l, {
			n = "Rafale",
			t = { 0.3, 0.03, 0.06 },
			p = { 0.4, 0.06, 0.24 },
			c = { 200, 230, 255 },
			tr = 0.3,
			a = "Aile",
			j = { 0.18, -0.04, 0.04 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.2, 0.04, 0.24 },
			p = { 0, -0.12, 0.42 },
			c = plume,
			a = "Queue",
			j = { 0, -0.12, 0.3 },
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.16, 0.04 },
			p = { 0.08, -0.42, 0.04 },
			c = { 60, 60, 70 },
			a = "Patte",
			j = { 0.08, -0.34, 0.04 },
			ph = 0,
		}, true)
	end)

	-- Lointaine : tornade aux yeux furieux qui aspire tout.
	definir("Tornadogre", 0.95, function(l)
		local axe = { 0, -0.1, 0 }
		for i = 0, 5 do
			local largeur = 0.24 + i * 0.13
			ajouter(l, {
				n = "Spire" .. i,
				t = { largeur, 0.14, largeur },
				p = { math.sin(i) * 0.06, -0.42 + i * 0.16, math.cos(i) * 0.04 },
				r = { 0, i * 25, 0 },
				c = if i % 2 == 0 then { 170, 185, 210 } else { 130, 145, 175 },
				tr = 0.15,
				a = "Antenne",
				j = axe,
				ph = i,
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.12, 0.08, 0.03 },
			p = { 0.16, 0.18, -0.38 },
			c = { 255, 80, 80 },
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.16, 0.04, 0.03 },
			p = { 0.16, 0.26, -0.38 },
			r = { 0, 0, 25 },
			c = { 50, 50, 70 },
		}, true)
		ajouter(
			l,
			{ n = "Gueule", t = { 0.3, 0.08, 0.03 }, p = { 0, 0.02, -0.33 }, c = { 50, 50, 70 } }
		)
		ajouter(l, {
			n = "Debris",
			t = { 0.1, 0.1, 0.1 },
			p = { 0.48, 0.32, 0.1 },
			r = { 30, 30, 0 },
			c = { 120, 90, 60 },
			a = "Antenne",
			j = axe,
		})
		ajouter(l, {
			n = "Debris2",
			t = { 0.08, 0.08, 0.08 },
			p = { -0.42, 0.0, -0.12 },
			r = { 10, 50, 0 },
			c = { 90, 160, 80 },
			a = "Antenne",
			j = axe,
		})
	end)
end
