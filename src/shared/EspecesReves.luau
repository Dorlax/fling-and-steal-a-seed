--!strict
-- Bestiaire du biome 20 : Royaume des Rêves (nuit violette, oreillers, étoiles).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE, CREME = o.BLANC, o.NOIR, o.ROSE, o.CREME

	local LAVANDE = { 200, 180, 255 }
	local NUIT = { 70, 60, 130 }
	local ETOILE = { 255, 240, 150 }

	-- Yeux fermés de sommeil (deux traits).
	local function dodo(l: any, x: number, y: number, z: number, role: string?, j: { number }?)
		ajouter(
			l,
			{ n = "Oeil", t = { 0.07, 0.02, 0.02 }, p = { x, y, z }, c = NOIR, a = role, j = j },
			true
		)
	end

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : oreiller moelleux qui bâille.
	definir("Oreillou", 0.45, function(l)
		ajouter(l, { n = "Coussin", t = { 0.6, 0.3, 0.44 }, p = { 0, -0.35, 0 }, c = LAVANDE })
		for _, x in { -0.3, 0.3 } do
			ajouter(l, {
				n = "Coin" .. (if x < 0 then "G" else "D"),
				t = { 0.08, 0.2, 0.1 },
				p = { x, -0.35, -0.2 },
				c = LAVANDE,
			})
		end
		dodo(l, 0.1, -0.3, -0.225)
		ajouter(l, {
			n = "Baillement",
			t = { 0.08, 0.08, 0.02 },
			p = { 0, -0.4, -0.225 },
			c = { 120, 80, 120 },
		})
		ajouter(
			l,
			{ n = "Joue", t = { 0.06, 0.03, 0.02 }, p = { 0.18, -0.36, -0.225 }, c = ROSE },
			true
		)
		ajouter(l, {
			n = "Zz",
			t = { 0.08, 0.08, 0.02 },
			p = { 0.2, -0.08, -0.1 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = { 0.16, -0.18, -0.1 },
		})
	end)

	-- Commune : petit doudou lapin tout doux.
	definir("Doudouce", 0.75, function(l)
		local tete = { 0, -0.02, 0 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.32, 0.26 }, p = { 0, -0.32, 0.02 }, c = CREME })
		ajouter(l, {
			n = "Tete",
			t = { 0.32, 0.28, 0.28 },
			p = { 0, 0.0, 0 },
			c = CREME,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.07, 0.02, -0.145, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Nez",
			t = { 0.04, 0.03, 0.02 },
			p = { 0, -0.04, -0.145 },
			c = ROSE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oreille",
			t = { 0.08, 0.3, 0.05 },
			p = { 0.09, 0.26, 0 },
			r = { 0, 0, -10 },
			c = CREME,
			a = "Oreille",
			j = { 0.08, 0.12, 0 },
		}, true)
		ajouter(l, {
			n = "InterOreille",
			t = { 0.04, 0.22, 0.02 },
			p = { 0.09, 0.26, -0.03 },
			r = { 0, 0, -10 },
			c = ROSE,
			a = "Oreille",
			j = { 0.08, 0.12, 0 },
		}, true)
		ajouter(l, { n = "Ruban", t = { 0.32, 0.05, 0.28 }, p = { 0, -0.16, 0.02 }, c = "Rarete" })
		ajouter(l, {
			n = "Patte",
			t = { 0.1, 0.06, 0.12 },
			p = { 0.08, -0.47, -0.04 },
			c = CREME,
			a = "Patte",
			j = { 0.08, -0.44, -0.02 },
			ph = 0,
		}, true)
	end, "Pelage")

	-- Rare : mouton de nuit qu'on compte pour s'endormir.
	definir("Moutonuit", 0.7, function(l)
		local tete = { 0, -0.02, -0.24 }
		ajouter(
			l,
			{ n = "Laine", t = { 0.46, 0.36, 0.5 }, p = { 0, -0.1, 0.04 }, c = { 140, 130, 210 } }
		)
		ajouter(l, {
			n = "Bosse",
			t = { 0.26, 0.14, 0.26 },
			p = { 0.06, 0.12, 0.06 },
			c = { 140, 130, 210 },
		})
		pattes4(l, 0.13, -0.1, 0.2, { 0.07, 0.24, 0.07 }, NUIT)
		ajouter(l, {
			n = "Tete",
			t = { 0.22, 0.22, 0.18 },
			p = { 0, -0.02, -0.3 },
			c = NUIT,
			a = "Tete",
			j = tete,
		})
		dodo(l, 0.06, 0.0, -0.395, "Tete", tete)
		ajouter(l, {
			n = "Bonnet",
			t = { 0.12, 0.14, 0.12 },
			p = { 0.04, 0.16, -0.28 },
			r = { 0, 0, -25 },
			c = { 90, 110, 220 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pompon",
			f = "Ball",
			t = { 0.06, 0.06, 0.06 },
			p = { 0.12, 0.24, -0.28 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Numero",
			t = { 0.1, 0.1, 0.02 },
			p = { 0.231, -0.08, 0.04 },
			r = { 0, 90, 0 },
			c = "Rarete",
			m = "Neon",
		})
	end)

	-- Rare : veilleuse en forme de lune.
	definir("Veilleusou", 0.75, function(l)
		ajouter(l, { n = "Socle", t = { 0.36, 0.1, 0.36 }, p = { 0, -0.45, 0 }, c = BLANC })
		ajouter(
			l,
			{ n = "Lune", t = { 0.42, 0.42, 0.2 }, p = { 0, -0.1, 0 }, c = ETOILE, m = "Neon" }
		)
		ajouter(
			l,
			{ n = "Ombre", t = { 0.3, 0.36, 0.21 }, p = { 0.12, -0.06, 0 }, c = { 255, 210, 120 } }
		)
		dodo(l, -0.06, -0.08, -0.105)
		ajouter(l, { n = "Joue", t = { 0.05, 0.03, 0.02 }, p = { -0.14, -0.14, -0.105 }, c = ROSE })
		ajouter(l, {
			n = "Etoile",
			t = { 0.08, 0.08, 0.02 },
			p = { 0.2, 0.18, -0.06 },
			r = { 0, 0, 45 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = { 0.12, 0.08, -0.06 },
		})
	end)

	-- Épique : licorne de rêve aux ailes de nuage.
	definir("Licorneve", 0.9, function(l)
		local tete = { 0, 0.12, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.32, 0.28, 0.5 }, p = { 0, -0.1, 0.06 }, c = BLANC })
		pattes4(l, 0.1, -0.1, 0.24, { 0.08, 0.24, 0.08 }, BLANC)
		ajouter(l, {
			n = "Cou",
			t = { 0.14, 0.24, 0.14 },
			p = { 0, 0.08, -0.2 },
			r = { -15, 0, 0 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.2, 0.2, 0.3 },
			p = { 0, 0.26, -0.3 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		dodo(l, 0.06, 0.3, -0.455, "Tete", tete)
		ajouter(l, {
			n = "Corne",
			t = { 0.05, 0.18, 0.05 },
			p = { 0, 0.44, -0.34 },
			r = { -20, 0, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Criniere",
			t = { 0.08, 0.16, 0.26 },
			p = { 0, 0.36, -0.18 },
			c = LAVANDE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.24, 0.16, 0.2 },
			p = { 0.22, 0.08, 0.04 },
			c = { 240, 240, 255 },
			a = "Aile",
			j = { 0.14, 0.0, 0.04 },
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.08, 0.22, 0.08 },
			p = { 0, -0.04, 0.36 },
			r = { 25, 0, 0 },
			c = LAVANDE,
			a = "Queue",
			j = { 0, 0.04, 0.32 },
		})
	end)

	-- Épique : pantoufle-chien en peluche.
	definir("Pantoufard", 0.45, function(l)
		local peluche = { 150, 200, 255 }
		ajouter(l, { n = "Semelle", t = { 0.42, 0.08, 0.66 }, p = { 0, -0.46, 0.02 }, c = BLANC })
		ajouter(l, { n = "Chausson", t = { 0.38, 0.24, 0.6 }, p = { 0, -0.3, 0.04 }, c = peluche })
		ajouter(l, {
			n = "Ouverture",
			t = { 0.26, 0.04, 0.26 },
			p = { 0, -0.17, 0.16 },
			c = { 90, 130, 200 },
		})
		yeux(l, 0.08, -0.26, -0.265, 0.07)
		ajouter(l, { n = "Truffe", t = { 0.06, 0.05, 0.03 }, p = { 0, -0.34, -0.275 }, c = NOIR })
		ajouter(l, {
			n = "Oreille",
			t = { 0.06, 0.16, 0.12 },
			p = { 0.2, -0.26, -0.14 },
			r = { 0, 0, 20 },
			c = "Rarete",
			a = "Oreille",
			j = { 0.17, -0.2, -0.14 },
		}, true)
		ajouter(l, {
			n = "Langue",
			t = { 0.06, 0.02, 0.06 },
			p = { 0, -0.4, -0.29 },
			c = ROSE,
			a = "Machoire",
			j = { 0, -0.38, -0.25 },
		})
	end, "Pelage")

	-- Légendaire : marchand de sable au sac d'étoiles.
	definir("Sablinou", 0.9, function(l)
		local tete = { 0, 0.14, 0 }
		ajouter(l, { n = "Robe", t = { 0.36, 0.46, 0.3 }, p = { 0, -0.27, 0 }, c = NUIT })
		for i, pos in { { 0.1, -0.2, -0.155 }, { -0.12, -0.36, -0.155 }, { 0.04, -0.42, -0.155 } } do
			ajouter(l, {
				n = "EtoileRobe" .. i,
				t = { 0.05, 0.05, 0.02 },
				p = pos,
				r = { 0, 0, 45 },
				c = ETOILE,
				m = "Neon",
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.26, 0.24, 0.24 },
			p = { 0, 0.08, 0 },
			c = { 255, 220, 190 },
			a = "Tete",
			j = tete,
		})
		dodo(l, 0.06, 0.1, -0.125, "Tete", tete)
		ajouter(l, {
			n = "Barbe",
			t = { 0.24, 0.14, 0.04 },
			p = { 0, -0.04, -0.12 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bonnet",
			t = { 0.26, 0.24, 0.24 },
			p = { 0.04, 0.3, 0.02 },
			r = { 0, 0, -20 },
			c = NUIT,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pompon",
			f = "Ball",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.18, 0.4, 0.02 },
			c = ETOILE,
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Sac",
			f = "Ball",
			t = { 0.22, 0.24, 0.22 },
			p = { 0.26, -0.24, 0.1 },
			c = { 200, 170, 120 },
			a = "Bras",
			j = { 0.2, -0.08, 0.04 },
			ph = 0,
		})
		ajouter(l, {
			n = "Sable",
			t = { 0.12, 0.04, 0.12 },
			p = { 0.26, -0.11, 0.1 },
			c = "Rarete",
			m = "Neon",
			a = "Bras",
			j = { 0.2, -0.08, 0.04 },
			ph = 0,
		})
	end)

	-- Légendaire : hibou rêveur en pyjama.
	definir("Hiboureve", 0.75, function(l)
		local plume = { 120, 100, 200 }
		local tete = { 0, 0.1, 0 }
		ajouter(l, { n = "Corps", t = { 0.38, 0.42, 0.34 }, p = { 0, -0.2, 0.02 }, c = plume })
		for i, y in { -0.1, -0.24 } do
			ajouter(
				l,
				{ n = "Rayure" .. i, t = { 0.39, 0.04, 0.35 }, p = { 0, y, 0.02 }, c = LAVANDE }
			)
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.4, 0.28, 0.34 },
			p = { 0, 0.14, 0 },
			c = plume,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Lunettes",
			t = { 0.3, 0.12, 0.02 },
			p = { 0, 0.16, -0.175 },
			c = { 255, 220, 120 },
			a = "Tete",
			j = tete,
		})
		dodo(l, 0.08, 0.16, -0.19, "Tete", tete)
		ajouter(l, {
			n = "Bec",
			t = { 0.05, 0.06, 0.04 },
			p = { 0, 0.07, -0.19 },
			c = { 255, 200, 90 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bonnet",
			t = { 0.18, 0.2, 0.18 },
			p = { -0.06, 0.36, 0.0 },
			r = { 0, 0, 25 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.28, 0.26 },
			p = { 0.21, -0.18, 0.04 },
			c = plume,
			a = "Aile",
			j = { 0.19, -0.06, 0.02 },
		}, true)
		ajouter(
			l,
			{ n = "Livre", t = { 0.16, 0.12, 0.04 }, p = { 0, -0.18, -0.19 }, c = { 220, 80, 90 } }
		)
	end)

	-- Mythique : étoile filante à la longue traîne.
	definir("Filetoile", 0.7, function(l)
		local etoile = { 0, 0.0, 0 }
		ajouter(l, {
			n = "Coeur",
			t = { 0.3, 0.3, 0.12 },
			p = { 0, 0.02, -0.1 },
			r = { 0, 0, 45 },
			c = ETOILE,
			m = "Neon",
			a = "Antenne",
			j = etoile,
		})
		for k = 0, 4 do
			local a = math.rad(k * 72)
			ajouter(l, {
				n = "Branche" .. k,
				t = { 0.12, 0.18, 0.1 },
				p = { math.sin(a) * 0.2, 0.02 + math.cos(a) * 0.2, -0.1 },
				r = { 0, 0, -k * 72 },
				c = ETOILE,
				m = "Neon",
				a = "Antenne",
				j = etoile,
			})
		end
		yeux(l, 0.06, 0.04, -0.17, 0.06, "Antenne", etoile)
		for k = 1, 4 do
			ajouter(l, {
				n = "Traine" .. k,
				t = { 0.14 - k * 0.025, 0.14 - k * 0.025, 0.12 },
				p = { 0, -0.04 - k * 0.04, k * 0.12 },
				c = if k % 2 == 0 then "Rarete" else LAVANDE,
				m = "Neon",
				tr = k * 0.15,
				a = "Queue",
				j = { 0, 0, 0.04 },
				ph = k,
			})
		end
	end)

	-- Mythique : esprit de la lune qui berce les rêves.
	definir("Revelune", 0.95, function(l)
		local tete = { 0, 0.14, 0 }
		ajouter(l, {
			n = "Voile",
			t = { 0.44, 0.5, 0.3 },
			p = { 0, -0.22, 0 },
			c = { 150, 130, 230 },
			tr = 0.2,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.28, 0.26 },
			p = { 0, 0.12, 0 },
			c = { 230, 230, 255 },
			a = "Tete",
			j = tete,
		})
		dodo(l, 0.07, 0.14, -0.135, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.06, 0.02, 0.02 },
			p = { 0, 0.06, -0.135 },
			c = { 150, 100, 150 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Croissant",
			t = { 0.26, 0.06, 0.06 },
			p = { 0, 0.32, 0 },
			c = ETOILE,
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.06, 0.12, 0.06 },
			p = { 0.13, 0.36, 0 },
			r = { 0, 0, -20 },
			c = ETOILE,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bras",
			t = { 0.16, 0.06, 0.06 },
			p = { 0.26, -0.04, -0.04 },
			r = { 0, 0, 20 },
			c = { 230, 230, 255 },
			a = "Bras",
			j = { 0.18, -0.04, 0 },
			ph = 0,
		}, true)
		for i, pos in { { 0.34, 0.2, -0.1 }, { -0.36, 0.06, 0.04 }, { 0.3, -0.24, 0.08 } } do
			ajouter(l, {
				n = "Bulle" .. i,
				f = "Ball",
				t = { 0.08, 0.08, 0.08 },
				p = pos,
				c = "Rarete",
				m = "Neon",
				tr = 0.3,
				a = "Antenne",
				j = { 0, 0, 0 },
				ph = i,
			})
		end
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : petit cauchemar en drap noir qui fait « bouh ».
	definir("Cauchemou", 0.7, function(l)
		local drap = { 0, -0.1, 0 }
		ajouter(l, {
			n = "Drap",
			t = { 0.46, 0.52, 0.42 },
			p = { 0, -0.04, 0 },
			c = { 40, 30, 60 },
			tr = 0.1,
			a = "Antenne",
			j = drap,
		})
		for i, x in { -0.16, 0, 0.16 } do
			ajouter(l, {
				n = "Frange" .. i,
				t = { 0.12, 0.14, 0.4 },
				p = { x, -0.36 - (i % 2) * 0.04, 0 },
				c = { 40, 30, 60 },
				tr = 0.1,
				a = "Patte",
				j = { x, -0.3, 0 },
				ph = i,
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.1, 0.02 },
			p = { 0.09, 0.06, -0.215 },
			c = { 255, 80, 200 },
			m = "Neon",
			a = "Antenne",
			j = drap,
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.12, 0.1, 0.02 },
			p = { 0, -0.1, -0.215 },
			c = { 255, 80, 200 },
			m = "Neon",
			a = "Antenne",
			j = drap,
		})
	end)

	-- Moyenne : ronfleur géant qui souffle des bulles.
	definir("Ronfleur", 0.75, function(l)
		local corps = { 0, -0.2, 0 }
		ajouter(l, {
			n = "Corps",
			f = "Ball",
			t = { 0.7, 0.6, 0.6 },
			p = { 0, -0.2, 0 },
			c = { 110, 100, 170 },
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Bonnet",
			t = { 0.3, 0.3, 0.3 },
			p = { 0.1, 0.14, 0 },
			r = { 0, 0, -30 },
			c = { 220, 70, 90 },
		})
		ajouter(
			l,
			{ n = "Pompon", f = "Ball", t = { 0.1, 0.1, 0.1 }, p = { 0.26, 0.3, 0 }, c = BLANC }
		)
		ajouter(
			l,
			{ n = "Oeil", t = { 0.1, 0.03, 0.02 }, p = { 0.12, -0.1, -0.3 }, c = NOIR },
			true
		)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.03, 0.02 },
			p = { 0.12, -0.03, -0.3 },
			r = { 0, 0, 20 },
			c = NOIR,
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.14, 0.1, 0.02 }, p = { 0, -0.26, -0.3 }, c = { 60, 30, 60 } }
		)
		ajouter(l, {
			n = "Bulle",
			f = "Ball",
			t = { 0.2, 0.2, 0.2 },
			p = { 0, -0.24, -0.44 },
			c = LAVANDE,
			tr = 0.4,
			a = "Machoire",
			j = { 0, -0.26, -0.32 },
		})
		ajouter(l, {
			n = "Zz",
			t = { 0.1, 0.1, 0.02 },
			p = { 0.3, 0.1, -0.2 },
			c = ETOILE,
			m = "Neon",
			a = "Antenne",
			j = corps,
		})
		ajouter(l, {
			n = "Pied",
			t = { 0.14, 0.08, 0.18 },
			p = { 0.16, -0.46, 0 },
			c = { 110, 100, 170 },
			a = "Patte",
			j = { 0.16, -0.4, 0 },
			ph = 0,
		}, true)
	end)

	-- Lointaine : monstre du placard aux yeux dans le noir.
	definir("Placardeur", 0.95, function(l)
		local porte = { 0.3, -0.04, -0.2 }
		ajouter(
			l,
			{ n = "Armoire", t = { 0.7, 0.9, 0.4 }, p = { 0, -0.04, 0.04 }, c = { 120, 80, 60 } }
		)
		ajouter(
			l,
			{ n = "Fronton", t = { 0.76, 0.08, 0.46 }, p = { 0, 0.44, 0.04 }, c = { 100, 65, 50 } }
		)
		ajouter(l, {
			n = "Interieur",
			t = { 0.6, 0.8, 0.02 },
			p = { 0, -0.04, -0.165 },
			c = { 15, 10, 25 },
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.06, 0.02 },
			p = { 0.12, 0.12, -0.18 },
			c = { 255, 240, 80 },
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Sourire",
			t = { 0.3, 0.04, 0.02 },
			p = { 0, -0.06, -0.18 },
			c = { 255, 240, 80 },
			m = "Neon",
		})
		ajouter(l, {
			n = "Porte",
			t = { 0.3, 0.8, 0.04 },
			p = { 0.3, -0.04, -0.3 },
			r = { 0, -60, 0 },
			c = { 140, 95, 70 },
			a = "Machoire",
			j = porte,
		})
		ajouter(l, {
			n = "Poignee",
			t = { 0.04, 0.08, 0.04 },
			p = { 0.2, -0.04, -0.4 },
			r = { 0, -60, 0 },
			c = { 220, 180, 80 },
			a = "Machoire",
			j = porte,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.1, 0.1, 0.36 },
			p = { -0.2, 0.0, -0.34 },
			c = { 40, 30, 60 },
			a = "Bras",
			j = { -0.2, 0.0, -0.16 },
			ph = 0,
		})
		ajouter(l, {
			n = "Pied",
			t = { 0.1, 0.06, 0.1 },
			p = { 0.28, -0.52, 0.04 },
			c = { 100, 65, 50 },
			a = "Patte",
			j = { 0.28, -0.48, 0.04 },
			ph = 0,
		}, true)
	end)
end
