--!strict
-- Bestiaire du biome 8 : Récif Corail (sable clair, coraux, bulles).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
-- Les nageurs flottent un peu au-dessus du sol : leur corps est posé haut.
return function(o: any)
	local definir, ajouter, yeux = o.definir, o.ajouter, o.yeux
	local BLANC, NOIR, ROSE = o.BLANC, o.NOIR, o.ROSE

	local CORAIL = { 255, 120, 110 }
	local TURQUOISE = { 60, 200, 210 }
	local ABYSSE = { 30, 40, 80 }

	-- Nageoire caudale en deux blocs inclinés (queue de poisson).
	local function caudale(l: any, z: number, y: number, h: number, c: any)
		local j = { 0, y, z - 0.04 }
		ajouter(l, {
			n = "Caudale",
			t = { 0.04, h, 0.14 },
			p = { 0, y + h * 0.3, z + 0.06 },
			r = { -30, 0, 0 },
			c = c,
			a = "Queue",
			j = j,
		})
		ajouter(l, {
			n = "Caudale2",
			t = { 0.04, h, 0.14 },
			p = { 0, y - h * 0.3, z + 0.06 },
			r = { 30, 0, 0 },
			c = c,
			a = "Queue",
			j = j,
		})
	end

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : poisson rond à rayures.
	definir("Poissolo", 0.65, function(l)
		local orange = { 255, 150, 50 }
		ajouter(l, { n = "Corps", t = { 0.34, 0.44, 0.52 }, p = { 0, -0.12, 0 }, c = orange })
		for i, z in { -0.1, 0.12 } do
			ajouter(
				l,
				{ n = "Rayure" .. i, t = { 0.35, 0.45, 0.06 }, p = { 0, -0.12, z }, c = BLANC }
			)
		end
		yeux(l, 0.09, -0.04, -0.265, 0.1)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.1, 0.05, 0.03 }, p = { 0, -0.2, -0.275 }, c = { 200, 80, 40 } }
		)
		ajouter(l, {
			n = "Dorsale",
			t = { 0.04, 0.12, 0.24 },
			p = { 0, 0.15, 0.02 },
			c = "Rarete",
			a = "Antenne",
			j = { 0, 0.1, 0 },
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.04, 0.1, 0.14 },
			p = { 0.19, -0.16, 0.0 },
			r = { 0, 20, 0 },
			c = orange,
			a = "Aile",
			j = { 0.17, -0.12, -0.04 },
		}, true)
		caudale(l, 0.3, -0.12, 0.22, orange)
		-- Flaque d'eau sous le nageur : il bondit hors de l'eau.
		ajouter(l, {
			n = "Flaque",
			t = { 0.62, 0.02, 0.52 },
			p = { 0, -0.49, 0.02 },
			c = { 90, 190, 240 },
			tr = 0.35,
		})
		ajouter(l, {
			n = "Goutte",
			t = { 0.05, 0.07, 0.05 },
			p = { 0.22, -0.4, -0.1 },
			c = { 150, 220, 255 },
			tr = 0.2,
		}, true)
	end, "Ecailles")

	-- Commune : étoile de mer souriante.
	definir("Etoilou", 0.3, function(l)
		local rose = { 255, 130, 160 }
		ajouter(l, { n = "Centre", t = { 0.3, 0.14, 0.3 }, p = { 0, -0.43, 0 }, c = rose })
		for i = 0, 4 do
			local angle = math.rad(i * 72)
			local x, z = math.sin(angle) * 0.26, -math.cos(angle) * 0.26
			ajouter(l, {
				n = "Bras" .. i,
				t = { 0.14, 0.1, 0.26 },
				p = { x, -0.45, z },
				r = { 0, -i * 72, 0 },
				c = rose,
				a = "Patte",
				j = { x * 0.5, -0.45, z * 0.5 },
				ph = i,
			})
			ajouter(
				l,
				{ n = "Point" .. i, t = { 0.04, 0.02, 0.04 }, p = { x, -0.39, z }, c = "Rarete" }
			)
		end
		ajouter(
			l,
			{ n = "OeilG", t = { 0.05, 0.02, 0.06 }, p = { -0.06, -0.355, -0.03 }, c = NOIR }
		)
		ajouter(l, { n = "OeilD", t = { 0.05, 0.02, 0.06 }, p = { 0.06, -0.355, -0.03 }, c = NOIR })
		ajouter(
			l,
			{ n = "Joue", t = { 0.04, 0.02, 0.03 }, p = { 0.1, -0.355, 0.04 }, c = ROSE },
			true
		)
	end)

	-- Rare : hippocampe enroulé.
	definir("Hippocampou", 0.9, function(l)
		local jaune = { 250, 200, 70 }
		local tete = { 0, 0.18, 0 }
		ajouter(l, { n = "Ventre", t = { 0.22, 0.34, 0.24 }, p = { 0, -0.02, 0.02 }, c = jaune })
		for i = 0, 4 do
			ajouter(l, {
				n = "Plaque" .. i,
				t = { 0.24, 0.04, 0.2 },
				p = { 0, -0.14 + i * 0.07, 0.06 },
				c = { 220, 170, 50 },
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.2, 0.2, 0.22 },
			p = { 0, 0.26, -0.04 },
			c = jaune,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.08, 0.08, 0.2 },
			p = { 0, 0.24, -0.22 },
			c = jaune,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Couronne",
			t = { 0.04, 0.1, 0.12 },
			p = { 0, 0.4, 0.0 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.05, 0.02 },
			p = { 0.1, 0.28, -0.08 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Nageoire",
			t = { 0.03, 0.12, 0.1 },
			p = { 0, 0.04, 0.17 },
			c = { 255, 230, 140 },
			tr = 0.2,
			a = "Aile",
			j = { 0, 0.04, 0.13 },
		})
		local queue = { 0, -0.2, 0.04 }
		ajouter(l, {
			n = "Queue1",
			t = { 0.14, 0.14, 0.14 },
			p = { 0, -0.26, 0.08 },
			c = jaune,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Queue2",
			t = { 0.1, 0.1, 0.12 },
			p = { 0, -0.36, 0.16 },
			c = jaune,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "Queue3",
			t = { 0.08, 0.08, 0.08 },
			p = { 0, -0.44, 0.08 },
			c = jaune,
			a = "Queue",
			j = queue,
		})
	end)

	-- Rare : petit poulpe aux huit tentacules.
	definir("Poulpinou", 0.7, function(l)
		local violet = { 180, 100, 200 }
		ajouter(l, { n = "Tete", t = { 0.46, 0.42, 0.44 }, p = { 0, 0.0, 0.02 }, c = violet })
		ajouter(l, { n = "Sommet", t = { 0.34, 0.12, 0.32 }, p = { 0, 0.26, 0.04 }, c = violet })
		for i, pos in { { 0.16, 0.12 }, { -0.14, 0.16 }, { 0.04, 0.2 } } do
			ajouter(l, {
				n = "Tache" .. i,
				t = { 0.06, 0.06, 0.02 },
				p = { pos[1], pos[2], -0.205 },
				c = { 220, 150, 230 },
			})
		end
		yeux(l, 0.1, -0.02, -0.205, 0.11)
		ajouter(l, {
			n = "Bouche",
			t = { 0.06, 0.04, 0.02 },
			p = { 0, -0.13, -0.205 },
			c = { 120, 50, 120 },
		})
		for i = 0, 7 do
			local angle = math.rad(i * 45 + 22.5)
			local x, z = math.sin(angle) * 0.2, -math.cos(angle) * 0.2
			ajouter(l, {
				n = "Tentacule" .. i,
				t = { 0.08, 0.3, 0.08 },
				p = { x, -0.34, z },
				r = { -math.cos(angle) * 15, 0, -math.sin(angle) * 15 },
				c = if i % 2 == 0 then violet else "Rarete",
				a = "Patte",
				j = { x, -0.2, z },
				ph = i,
			})
		end
	end, "Gelee")

	-- Épique : raie manta aux ailes étoilées.
	definir("Raietoile", 0.45, function(l)
		local dos = { 40, 60, 110 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.12, 0.5 }, p = { 0, -0.2, 0.0 }, c = dos })
		ajouter(l, { n = "Ventre", t = { 0.3, 0.02, 0.42 }, p = { 0, -0.27, 0.0 }, c = BLANC })
		ajouter(l, {
			n = "Aile",
			t = { 0.36, 0.06, 0.34 },
			p = { 0.34, -0.2, 0.02 },
			r = { 0, 25, 0 },
			c = dos,
			a = "Aile",
			j = { 0.17, -0.2, 0.0 },
		}, true)
		ajouter(l, {
			n = "Etoile",
			t = { 0.06, 0.02, 0.06 },
			p = { 0.32, -0.16, 0.0 },
			r = { 0, 45, 0 },
			c = "Rarete",
			m = "Neon",
			a = "Aile",
			j = { 0.17, -0.2, 0.0 },
		}, true)
		ajouter(l, {
			n = "Etoile2",
			t = { 0.04, 0.02, 0.04 },
			p = { 0.08, -0.135, 0.14 },
			r = { 0, 45, 0 },
			c = "Rarete",
			m = "Neon",
		}, true)
		ajouter(l, {
			n = "Corne",
			t = { 0.05, 0.05, 0.14 },
			p = { 0.13, -0.18, -0.3 },
			r = { 0, -15, 0 },
			c = dos,
			a = "Tete",
			j = { 0, -0.2, -0.24 },
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.04, 0.03 },
			p = { 0.15, -0.15, -0.21 },
			c = { 255, 240, 160 },
			m = "Neon",
		}, true)
		ajouter(l, { n = "Sourire", t = { 0.14, 0.02, 0.02 }, p = { 0, -0.23, -0.255 }, c = NOIR })
		ajouter(l, {
			n = "Queue",
			t = { 0.03, 0.03, 0.4 },
			p = { 0, -0.2, 0.44 },
			c = dos,
			a = "Queue",
			j = { 0, -0.2, 0.25 },
		})
		-- Flaque d'eau sous le nageur : il bondit hors de l'eau.
		ajouter(l, {
			n = "Flaque",
			t = { 0.62, 0.02, 0.52 },
			p = { 0, -0.49, 0.02 },
			c = { 90, 190, 240 },
			tr = 0.35,
		})
		ajouter(l, {
			n = "Goutte",
			t = { 0.05, 0.07, 0.05 },
			p = { 0.22, -0.4, -0.1 },
			c = { 150, 220, 255 },
			tr = 0.2,
		}, true)
	end)

	-- Épique : bébé dauphin joueur.
	definir("Dauphinou", 0.7, function(l)
		local bleu = { 110, 160, 210 }
		local tete = { 0, -0.04, -0.2 }
		ajouter(l, { n = "Corps", t = { 0.32, 0.32, 0.56 }, p = { 0, -0.1, 0.06 }, c = bleu })
		ajouter(l, {
			n = "Ventre",
			t = { 0.24, 0.04, 0.46 },
			p = { 0, -0.27, 0.04 },
			c = { 225, 235, 245 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.28, 0.2 },
			p = { 0, -0.06, -0.3 },
			c = bleu,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Rostre",
			t = { 0.14, 0.08, 0.14 },
			p = { 0, -0.14, -0.46 },
			c = { 225, 235, 245 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.09, -0.02, -0.405, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Joue",
			t = { 0.05, 0.03, 0.02 },
			p = { 0.12, -0.1, -0.405 },
			c = ROSE,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Dorsale",
			t = { 0.04, 0.16, 0.14 },
			p = { 0, 0.12, 0.08 },
			r = { -25, 0, 0 },
			c = bleu,
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.14, 0.03, 0.12 },
			p = { 0.2, -0.2, -0.06 },
			r = { 0, 0, -25 },
			c = bleu,
			a = "Aile",
			j = { 0.16, -0.18, -0.06 },
		}, true)
		ajouter(l, {
			n = "Pedoncule",
			t = { 0.14, 0.14, 0.2 },
			p = { 0, -0.08, 0.42 },
			c = bleu,
			a = "Queue",
			j = { 0, -0.08, 0.32 },
		})
		ajouter(l, {
			n = "Caudale",
			t = { 0.36, 0.03, 0.12 },
			p = { 0, -0.08, 0.54 },
			c = "Rarete",
			a = "Queue",
			j = { 0, -0.08, 0.32 },
		})
		-- Flaque d'eau sous le nageur : il bondit hors de l'eau.
		ajouter(l, {
			n = "Flaque",
			t = { 0.62, 0.02, 0.52 },
			p = { 0, -0.49, 0.02 },
			c = { 90, 190, 240 },
			tr = 0.35,
		})
		ajouter(l, {
			n = "Goutte",
			t = { 0.05, 0.07, 0.05 },
			p = { 0.22, -0.4, -0.1 },
			c = { 150, 220, 255 },
			tr = 0.2,
		}, true)
	end, "Gelee")

	-- Légendaire : requin bébé au sourire plein de dents.
	definir("Requinou", 0.75, function(l)
		local gris = { 120, 140, 165 }
		local tete = { 0, -0.04, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.36, 0.6 }, p = { 0, -0.08, 0.04 }, c = gris })
		ajouter(
			l,
			{ n = "Ventre", t = { 0.3, 0.04, 0.5 }, p = { 0, -0.27, 0.02 }, c = { 235, 240, 245 } }
		)
		ajouter(l, {
			n = "Tete",
			t = { 0.34, 0.3, 0.2 },
			p = { 0, -0.06, -0.34 },
			c = gris,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.28, 0.08, 0.16 },
			p = { 0, -0.22, -0.34 },
			c = { 235, 240, 245 },
			a = "Machoire",
			j = { 0, -0.2, -0.26 },
		})
		for i, x in { -0.09, -0.03, 0.03, 0.09 } do
			ajouter(l, {
				n = "Dent" .. i,
				t = { 0.03, 0.05, 0.02 },
				p = { x, -0.17, -0.445 },
				r = { 0, 0, 45 },
				c = BLANC,
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.06, 0.03 },
			p = { 0.12, 0.02, -0.445 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Reflet",
			t = { 0.02, 0.02, 0.02 },
			p = { 0.13, 0.04, -0.46 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Dorsale",
			t = { 0.05, 0.24, 0.18 },
			p = { 0, 0.18, 0.04 },
			r = { -30, 0, 0 },
			c = "Rarete",
		})
		ajouter(l, {
			n = "Pectorale",
			t = { 0.2, 0.04, 0.14 },
			p = { 0.24, -0.2, -0.08 },
			r = { 0, 20, -20 },
			c = gris,
			a = "Aile",
			j = { 0.18, -0.18, -0.08 },
		}, true)
		caudale(l, 0.42, -0.04, 0.3, gris)
		-- Flaque d'eau sous le nageur : il bondit hors de l'eau.
		ajouter(l, {
			n = "Flaque",
			t = { 0.62, 0.02, 0.52 },
			p = { 0, -0.49, 0.02 },
			c = { 90, 190, 240 },
			tr = 0.35,
		})
		ajouter(l, {
			n = "Goutte",
			t = { 0.05, 0.07, 0.05 },
			p = { 0.22, -0.4, -0.1 },
			c = { 150, 220, 255 },
			tr = 0.2,
		}, true)
	end)

	-- Légendaire : bernard-l'ermite dans une coquille dorée.
	definir("Bernardor", 0.7, function(l)
		local rouge = { 230, 90, 60 }
		ajouter(l, {
			n = "Coquille",
			t = { 0.5, 0.48, 0.46 },
			p = { 0, -0.06, 0.12 },
			c = "Rarete",
			m = "Foil",
		})
		ajouter(l, {
			n = "Spirale",
			t = { 0.32, 0.3, 0.3 },
			p = { 0, 0.26, 0.18 },
			r = { 0, 45, 0 },
			c = "Rarete",
			m = "Foil",
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.14, 0.14, 0.14 },
			p = { 0, 0.44, 0.22 },
			r = { 0, 45, 0 },
			c = { 255, 240, 180 },
		})
		ajouter(l, {
			n = "Perle",
			f = "Ball",
			t = { 0.1, 0.1, 0.1 },
			p = { 0.2, 0.06, -0.12 },
			c = BLANC,
			m = "Neon",
		})
		ajouter(l, { n = "Corps", t = { 0.32, 0.2, 0.16 }, p = { 0, -0.32, -0.18 }, c = rouge })
		ajouter(l, {
			n = "Tige",
			t = { 0.03, 0.14, 0.03 },
			p = { 0.07, -0.16, -0.22 },
			c = rouge,
			a = "Antenne",
			j = { 0.07, -0.22, -0.22 },
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.06, 0.06 },
			p = { 0.07, -0.07, -0.22 },
			c = NOIR,
			a = "Antenne",
			j = { 0.07, -0.22, -0.22 },
		}, true)
		ajouter(l, {
			n = "Pince",
			t = { 0.12, 0.1, 0.14 },
			p = { 0.22, -0.32, -0.3 },
			c = rouge,
			a = "Bras",
			j = { 0.16, -0.32, -0.22 },
			ph = 0,
		}, true)
		for i, z in { -0.1, 0.02 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.04, 0.1, 0.04 },
				p = { 0.2, -0.45, z },
				r = { 0, 0, -20 },
				c = rouge,
				a = "Patte",
				j = { 0.16, -0.4, z },
				ph = i * 2,
			}, true)
		end
	end)

	-- Mythique : petit léviathan à crinière d'algues.
	definir("Leviatou", 0.85, function(l)
		local bleu = { 40, 90, 150 }
		local tete = { 0, 0.16, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.3, 0.3, 0.3 }, p = { 0, -0.12, 0.0 }, c = bleu })
		for i = 1, 3 do
			ajouter(l, {
				n = "Anneau" .. i,
				t = { 0.24 - i * 0.04, 0.24 - i * 0.04, 0.18 },
				p = { 0, -0.2 - i * 0.06, 0.12 + i * 0.14 },
				c = bleu,
				a = "Queue",
				j = { 0, -0.14, 0.12 },
				ph = i,
			})
		end
		ajouter(l, {
			n = "Cou",
			t = { 0.2, 0.3, 0.2 },
			p = { 0, 0.06, -0.16 },
			r = { 20, 0, 0 },
			c = bleu,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.24, 0.32 },
			p = { 0, 0.26, -0.26 },
			c = bleu,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.2, 0.12, 0.12 },
			p = { 0, 0.2, -0.46 },
			c = { 70, 130, 190 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.06, 0.03 },
			p = { 0.1, 0.3, -0.425 },
			c = TURQUOISE,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		for i, z in { -0.24, -0.12, 0.0 } do
			ajouter(l, {
				n = "Criniere" .. i,
				t = { 0.04, 0.18, 0.1 },
				p = { 0, 0.44 - i * 0.02, z - 0.04 },
				r = { -20, 0, 0 },
				c = "Rarete",
				m = "Neon",
				a = "Tete",
				j = tete,
			})
		end
		ajouter(l, {
			n = "Nageoire",
			t = { 0.24, 0.04, 0.16 },
			p = { 0.24, -0.16, -0.04 },
			r = { 0, 0, -25 },
			c = TURQUOISE,
			tr = 0.2,
			a = "Aile",
			j = { 0.15, -0.14, -0.04 },
		}, true)
		ajouter(l, {
			n = "Ventre",
			t = { 0.22, 0.2, 0.03 },
			p = { 0, -0.12, -0.155 },
			c = { 200, 230, 240 },
		})
		-- Flaque d'eau sous le nageur : il bondit hors de l'eau.
		ajouter(l, {
			n = "Flaque",
			t = { 0.62, 0.02, 0.52 },
			p = { 0, -0.49, 0.02 },
			c = { 90, 190, 240 },
			tr = 0.35,
		})
		ajouter(l, {
			n = "Goutte",
			t = { 0.05, 0.07, 0.05 },
			p = { 0.22, -0.4, -0.1 },
			c = { 150, 220, 255 },
			tr = 0.2,
		}, true)
	end, "Ecailles")

	-- Mythique : coquillage qui garde une perle lumineuse.
	definir("Perlune", 0.6, function(l)
		local nacre = { 230, 210, 240 }
		local haut = { 0, -0.2, 0.22 }
		ajouter(l, { n = "Valve", t = { 0.6, 0.12, 0.5 }, p = { 0, -0.44, 0.0 }, c = nacre })
		ajouter(l, {
			n = "Couvercle",
			t = { 0.6, 0.12, 0.5 },
			p = { 0, -0.1, -0.02 },
			r = { -25, 0, 0 },
			c = nacre,
			a = "Machoire",
			j = haut,
		})
		for i, x in { -0.18, 0, 0.18 } do
			ajouter(l, {
				n = "Strie" .. i,
				t = { 0.04, 0.02, 0.44 },
				p = { x, -0.03, -0.02 },
				r = { -25, 0, 0 },
				c = { 200, 170, 220 },
				a = "Machoire",
				j = haut,
			})
		end
		ajouter(l, {
			n = "Perle",
			f = "Ball",
			t = { 0.22, 0.22, 0.22 },
			p = { 0, -0.28, -0.04 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Halo",
			f = "Ball",
			t = { 0.32, 0.32, 0.32 },
			p = { 0, -0.28, -0.04 },
			c = BLANC,
			tr = 0.75,
		})
		ajouter(
			l,
			{ n = "Oeil", t = { 0.05, 0.05, 0.02 }, p = { 0.14, -0.36, -0.255 }, c = NOIR },
			true
		)
		ajouter(
			l,
			{ n = "Joue", t = { 0.05, 0.03, 0.02 }, p = { 0.22, -0.42, -0.255 }, c = ROSE },
			true
		)
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : oursin roulant tout en piquants.
	definir("Oursinou", 0.6, function(l)
		local noir = { 50, 30, 70 }
		local corps = { 0, -0.2, 0 }
		ajouter(l, { n = "Corps", t = { 0.5, 0.5, 0.5 }, p = { 0, -0.2, 0 }, c = noir })
		local dirs = {
			{ 1, 0, 0 },
			{ -1, 0, 0 },
			{ 0, 1, 0 },
			{ 0, 0, 1 },
			{ 0.7, 0.7, 0 },
			{ -0.7, 0.7, 0 },
			{ 0, 0.7, 0.7 },
			{ 0.7, 0, 0.7 },
			{ -0.7, 0, 0.7 },
			{ 0.7, -0.5, 0 },
			{ -0.7, -0.5, 0 },
		}
		for i, d in dirs do
			ajouter(l, {
				n = "Piquant" .. i,
				t = { 0.06, 0.06, 0.24 },
				p = { d[1] * 0.32, -0.2 + d[2] * 0.32, d[3] * 0.32 },
				r = { -math.deg(math.asin(d[2])), math.deg(math.atan2(d[1], d[3])), 0 },
				c = { 110, 60, 150 },
				a = "Antenne",
				j = corps,
				ph = i,
			})
		end
		yeux(l, 0.1, -0.14, -0.255, 0.1)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.12, 0.03, 0.02 },
			p = { 0.1, -0.04, -0.26 },
			r = { 0, 0, 20 },
			c = { 20, 10, 30 },
		}, true)
		ajouter(l, {
			n = "Bouche",
			t = { 0.14, 0.03, 0.02 },
			p = { 0, -0.32, -0.26 },
			c = { 255, 90, 120 },
		})
	end)

	-- Moyenne : murène sombre qui ondule.
	definir("Murenoire", 0.75, function(l)
		local peau = { 40, 50, 40 }
		local tache = { 200, 210, 90 }
		local tete = { 0, 0.14, -0.2 }
		for i = 0, 3 do
			ajouter(l, {
				n = "Anneau" .. i,
				t = { 0.2, 0.22, 0.18 },
				p = { 0, -0.36 + i * 0.02, 0.36 - i * 0.14 },
				c = peau,
				a = "Queue",
				j = { 0, -0.3, 0.1 },
				ph = i,
			})
			ajouter(l, {
				n = "Tache" .. i,
				t = { 0.21, 0.06, 0.06 },
				p = { 0, -0.3 + i * 0.02, 0.36 - i * 0.14 },
				c = tache,
				a = "Queue",
				j = { 0, -0.3, 0.1 },
				ph = i,
			})
		end
		ajouter(l, { n = "Cou", t = { 0.2, 0.36, 0.18 }, p = { 0, -0.08, -0.14 }, c = peau })
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.2, 0.32 },
			p = { 0, 0.16, -0.28 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.2, 0.06, 0.28 },
			p = { 0, 0.03, -0.3 },
			c = peau,
			a = "Machoire",
			j = { 0, 0.06, -0.16 },
		})
		for i, z in { -0.4, -0.32, -0.24 } do
			ajouter(l, {
				n = "Croc" .. i,
				t = { 0.02, 0.04, 0.02 },
				p = { 0.08, 0.08, z },
				c = BLANC,
				a = "Tete",
				j = tete,
			}, true)
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.04, 0.04, 0.04 },
			p = { 0.12, 0.22, -0.34 },
			c = { 255, 220, 50 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Dorsale",
			t = { 0.03, 0.08, 0.5 },
			p = { 0, 0.08, 0.0 },
			r = { 30, 0, 0 },
			c = tache,
		})
	end, "Ecailles")

	-- Lointaine : poisson-lanterne des abysses à la gueule immense.
	definir("Gueulabysse", 0.85, function(l)
		local tete = { 0, 0.0, -0.1 }
		ajouter(l, { n = "Corps", t = { 0.66, 0.6, 0.62 }, p = { 0, -0.06, 0.04 }, c = ABYSSE })
		ajouter(l, {
			n = "Machoire",
			t = { 0.68, 0.2, 0.56 },
			p = { 0, -0.36, -0.04 },
			r = { 10, 0, 0 },
			c = { 50, 60, 100 },
			a = "Machoire",
			j = { 0, -0.3, 0.2 },
		})
		for i, x in { -0.26, -0.13, 0, 0.13, 0.26 } do
			ajouter(l, {
				n = "CrocHaut" .. i,
				t = { 0.04, 0.14, 0.03 },
				p = { x, -0.28, -0.29 },
				c = BLANC,
			})
			ajouter(l, {
				n = "CrocBas" .. i,
				t = { 0.04, 0.12, 0.03 },
				p = { x + 0.06, -0.24, -0.31 },
				c = BLANC,
				a = "Machoire",
				j = { 0, -0.3, 0.2 },
			})
		end
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.1, 0.03 },
			p = { 0.2, 0.08, -0.265 },
			c = { 255, 255, 255 },
			m = "Neon",
		}, true)
		ajouter(
			l,
			{ n = "Pupille", t = { 0.04, 0.04, 0.02 }, p = { 0.2, 0.08, -0.285 }, c = NOIR },
			true
		)
		ajouter(l, {
			n = "Tige",
			t = { 0.04, 0.3, 0.04 },
			p = { 0, 0.36, -0.12 },
			r = { 30, 0, 0 },
			c = ABYSSE,
			a = "Antenne",
			j = tete,
		})
		ajouter(l, {
			n = "Lanterne",
			f = "Ball",
			t = { 0.14, 0.14, 0.14 },
			p = { 0, 0.5, -0.32 },
			c = { 255, 250, 150 },
			m = "Neon",
			a = "Antenne",
			j = tete,
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.04, 0.24, 0.2 },
			p = { 0.34, -0.06, 0.12 },
			c = CORAIL,
			tr = 0.2,
			a = "Aile",
			j = { 0.33, -0.06, 0.04 },
		}, true)
		caudale(l, 0.38, -0.04, 0.34, ABYSSE)
	end)
end
