--!strict
-- Bestiaire du biome 7 : Marais Brumeux (vase, nénuphars, feux follets).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux, pattes4 = o.definir, o.ajouter, o.yeux, o.pattes4
	local BLANC, NOIR, ROSE = o.BLANC, o.NOIR, o.ROSE

	local VASE = { 95, 115, 70 }
	local VERT = { 110, 170, 90 }
	local MAUVE = { 160, 110, 200 }
	local LUEUR = { 170, 255, 190 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : têtard tout rond à la queue frétillante.
	definir("Tetardou", 0.5, function(l)
		local corps = { 70, 90, 120 }
		ajouter(l, { n = "Corps", t = { 0.52, 0.42, 0.5 }, p = { 0, -0.29, -0.06 }, c = corps })
		ajouter(l, {
			n = "Ventre",
			t = { 0.36, 0.06, 0.36 },
			p = { 0, -0.47, -0.06 },
			c = { 200, 210, 220 },
		})
		yeux(l, 0.12, -0.2, -0.315, 0.13)
		ajouter(l, {
			n = "Sourire",
			t = { 0.14, 0.025, 0.02 },
			p = { 0, -0.34, -0.315 },
			c = { 30, 40, 60 },
		})
		ajouter(
			l,
			{ n = "Joue", t = { 0.06, 0.03, 0.02 }, p = { 0.18, -0.3, -0.315 }, c = ROSE },
			true
		)
		ajouter(l, {
			n = "Queue",
			t = { 0.06, 0.28, 0.36 },
			p = { 0, -0.3, 0.36 },
			c = corps,
			a = "Queue",
			j = { 0, -0.3, 0.2 },
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.05, 0.18, 0.12 },
			p = { 0, -0.3, 0.58 },
			c = { 110, 140, 170 },
			a = "Queue",
			j = { 0, -0.3, 0.2 },
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.08, 0.06, 0.1 },
			p = { 0.22, -0.47, 0.14 },
			c = corps,
			a = "Patte",
			j = { 0.2, -0.45, 0.14 },
			ph = 0,
		}, true)
	end)

	-- Commune : petite grenouille cachée sous une feuille de nénuphar.
	definir("Nenuflou", 0.55, function(l)
		local tete = { 0, -0.2, -0.1 }
		ajouter(
			l,
			{ n = "Corps", t = { 0.44, 0.3, 0.4 }, p = { 0, -0.34, 0.02 }, c = { 140, 210, 120 } }
		)
		yeux(l, 0.1, -0.24, -0.185, 0.1, "Tete", tete)
		ajouter(l, {
			n = "Sourire",
			t = { 0.14, 0.02, 0.02 },
			p = { 0, -0.36, -0.185 },
			c = { 50, 90, 50 },
		})
		ajouter(l, {
			n = "Feuille",
			t = { 0.7, 0.04, 0.66 },
			p = { 0, -0.12, 0.04 },
			r = { 0, 0, 6 },
			c = VERT,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Encoche",
			t = { 0.12, 0.05, 0.3 },
			p = { 0, -0.12, 0.25 },
			c = { 75, 120, 65 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Fleur",
			t = { 0.16, 0.08, 0.16 },
			p = { 0.16, -0.06, -0.04 },
			r = { 0, 45, 0 },
			c = { 255, 170, 210 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Coeur",
			t = { 0.06, 0.04, 0.06 },
			p = { 0.16, -0.01, -0.04 },
			c = { 255, 230, 90 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.14, 0.06, 0.16 },
			p = { 0.2, -0.47, 0.08 },
			c = { 120, 190, 100 },
			a = "Patte",
			j = { 0.16, -0.44, 0.08 },
			ph = 0,
		}, true)
	end)

	-- Rare : libellule aux ailes iridescentes et à la queue lumineuse.
	definir("Libellume", 0.6, function(l)
		local bleu = { 70, 160, 220 }
		local tete = { 0, 0.0, -0.22 }
		ajouter(l, { n = "Thorax", t = { 0.2, 0.2, 0.24 }, p = { 0, -0.06, -0.12 }, c = bleu })
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.2, 0.18 },
			p = { 0, 0.0, -0.3 },
			c = bleu,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "OeilGlobe",
			t = { 0.1, 0.12, 0.08 },
			p = { 0.08, 0.04, -0.36 },
			c = { 40, 220, 160 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Reflet",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.1, 0.07, -0.405 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		for i = 0, 3 do
			ajouter(l, {
				n = "Abdomen" .. i,
				t = { 0.1, 0.1, 0.12 },
				p = { 0, -0.08, 0.04 + i * 0.12 },
				c = if i == 3 then "Rarete" else bleu,
				m = if i == 3 then "Neon" else nil,
				a = "Queue",
				j = { 0, -0.08, 0.0 },
			})
		end
		ajouter(l, {
			n = "Aile",
			t = { 0.42, 0.02, 0.12 },
			p = { 0.24, 0.04, -0.16 },
			r = { 0, 10, -8 },
			c = { 200, 240, 255 },
			tr = 0.35,
			a = "Aile",
			j = { 0.06, 0.02, -0.14 },
		}, true)
		ajouter(l, {
			n = "Aile2",
			t = { 0.38, 0.02, 0.11 },
			p = { 0.22, 0.03, -0.03 },
			r = { 0, -10, -8 },
			c = { 220, 200, 255 },
			tr = 0.35,
			a = "Aile",
			j = { 0.06, 0.02, -0.04 },
		}, true)
		for i, z in { -0.16, -0.08 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.025, 0.36, 0.025 },
				p = { 0.06, -0.32, z },
				c = { 40, 60, 90 },
				a = "Patte",
				j = { 0.06, -0.14, z },
				ph = i,
			}, true)
		end
	end)

	-- Rare : petit héron perché sur ses longues pattes.
	definir("Heronet", 0.95, function(l)
		local gris = { 190, 200, 215 }
		local tete = { 0, 0.18, -0.08 }
		ajouter(l, { n = "Corps", t = { 0.28, 0.26, 0.42 }, p = { 0, 0.02, 0.06 }, c = gris })
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.22, 0.38 },
			p = { 0.155, 0.02, 0.08 },
			c = { 150, 160, 180 },
			a = "Aile",
			j = { 0.14, 0.12, 0.06 },
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.03, 0.36, 0.03 },
			p = { 0.06, -0.32, 0.06 },
			c = { 230, 190, 80 },
			a = "Patte",
			j = { 0.06, -0.14, 0.06 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.1, 0.02, 0.12 },
			p = { 0.06, -0.49, 0.02 },
			c = { 230, 190, 80 },
			a = "Patte",
			j = { 0.06, -0.14, 0.06 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Cou",
			t = { 0.07, 0.26, 0.07 },
			p = { 0, 0.24, -0.1 },
			r = { -15, 0, 0 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.14, 0.12, 0.16 },
			p = { 0, 0.4, -0.16 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Huppe",
			t = { 0.03, 0.03, 0.18 },
			p = { 0, 0.45, -0.02 },
			r = { 15, 0, 0 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.04, 0.04, 0.22 },
			p = { 0, 0.39, -0.33 },
			c = { 240, 200, 60 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.03, 0.03, 0.02 },
			p = { 0.07, 0.42, -0.2 },
			c = NOIR,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Plume",
			t = { 0.14, 0.04, 0.14 },
			p = { 0, -0.04, 0.32 },
			c = "Rarete",
			a = "Queue",
			j = { 0, -0.02, 0.27 },
		})
	end)

	-- Épique : bébé crocodile au grand sourire.
	definir("Crocodouille", 0.5, function(l)
		local vert = { 90, 150, 80 }
		local tete = { 0, -0.24, -0.26 }
		local queue = { 0, -0.32, 0.28 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.22, 0.56 }, p = { 0, -0.34, 0.02 }, c = vert })
		for i, z in { -0.16, -0.02, 0.12, 0.26 } do
			ajouter(l, {
				n = "Ecaille" .. i,
				t = { 0.24, 0.04, 0.06 },
				p = { 0, -0.215, z },
				c = { 70, 120, 60 },
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.16, 0.22 },
			p = { 0, -0.28, -0.36 },
			c = vert,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Machoire",
			t = { 0.26, 0.08, 0.26 },
			p = { 0, -0.38, -0.52 },
			c = vert,
			a = "Machoire",
			j = { 0, -0.34, -0.38 },
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.24, 0.08, 0.24 },
			p = { 0, -0.27, -0.52 },
			c = vert,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Dent",
			t = { 0.03, 0.04, 0.02 },
			p = { 0.08, -0.33, -0.63 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Bosse",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.09, -0.16, -0.36 },
			c = vert,
			a = "Tete",
			j = tete,
		}, true)
		yeux(l, 0.09, -0.16, -0.405, 0.07, "Tete", tete)
		ajouter(l, {
			n = "PatteAv",
			t = { 0.12, 0.08, 0.1 },
			p = { 0.22, -0.44, -0.14 },
			c = vert,
			a = "Patte",
			j = { 0.16, -0.42, -0.14 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "PatteAr",
			t = { 0.12, 0.08, 0.12 },
			p = { 0.22, -0.44, 0.2 },
			c = vert,
			a = "Patte",
			j = { 0.16, -0.42, 0.2 },
			ph = math.pi,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.16, 0.14, 0.34 },
			p = { 0, -0.36, 0.46 },
			c = vert,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.08, 0.08, 0.2 },
			p = { 0, -0.38, 0.7 },
			c = vert,
			a = "Queue",
			j = queue,
		})
		ajouter(l, { n = "Noeud", t = { 0.12, 0.08, 0.04 }, p = { 0, -0.2, -0.28 }, c = "Rarete" })
	end, "Ecailles")

	-- Épique : loutre qui flotte sur le dos avec son coquillage.
	definir("Loutrine", 0.55, function(l)
		local brun = { 130, 90, 60 }
		local tete = { 0, -0.2, -0.24 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.24, 0.6 }, p = { 0, -0.36, 0.04 }, c = brun })
		ajouter(l, {
			n = "Ventre",
			t = { 0.26, 0.03, 0.44 },
			p = { 0, -0.235, 0.06 },
			c = { 220, 190, 150 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.24, 0.24 },
			p = { 0, -0.24, -0.34 },
			c = brun,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Museau",
			t = { 0.16, 0.1, 0.06 },
			p = { 0, -0.29, -0.48 },
			c = { 220, 190, 150 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.04, 0.02 },
			p = { 0, -0.25, -0.515 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, -0.18, -0.465, 0.07, "Tete", tete)
		ajouter(l, {
			n = "Oreille",
			t = { 0.05, 0.05, 0.04 },
			p = { 0.12, -0.11, -0.32 },
			c = brun,
			a = "Oreille",
			j = { 0.12, -0.13, -0.32 },
		}, true)
		ajouter(l, {
			n = "Coquillage",
			t = { 0.14, 0.04, 0.12 },
			p = { 0, -0.2, -0.04 },
			c = "Rarete",
			m = "Neon",
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.06, 0.12, 0.06 },
			p = { 0.1, -0.18, -0.08 },
			r = { -30, 0, 0 },
			c = brun,
			a = "Bras",
			j = { 0.12, -0.24, -0.1 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.12, 0.06, 0.3 },
			p = { 0, -0.42, 0.46 },
			c = brun,
			a = "Queue",
			j = { 0, -0.42, 0.34 },
		})
	end)

	-- Légendaire : corbeau sorcier coiffé d'un chapeau pointu.
	definir("Sorcicroa", 0.88, function(l)
		local plume = { 45, 40, 70 }
		local tete = { 0, 0.1, -0.06 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.38, 0.44 }, p = { 0, -0.16, 0.04 }, c = plume })
		ajouter(l, {
			n = "Aile",
			t = { 0.05, 0.3, 0.38 },
			p = { 0.2, -0.14, 0.06 },
			c = { 60, 55, 95 },
			a = "Aile",
			j = { 0.18, -0.02, 0.04 },
		}, true)
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.28 },
			p = { 0, 0.15, -0.12 },
			c = plume,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.06, 0.14 },
			p = { 0, 0.1, -0.32 },
			c = { 240, 200, 60 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.05, 0.05, 0.02 },
			p = { 0.08, 0.18, -0.265 },
			c = LUEUR,
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Chapeau",
			t = { 0.42, 0.04, 0.42 },
			p = { 0, 0.3, -0.1 },
			c = MAUVE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Cone1",
			t = { 0.24, 0.14, 0.24 },
			p = { 0, 0.39, -0.1 },
			c = MAUVE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Cone2",
			t = { 0.14, 0.12, 0.14 },
			p = { 0.02, 0.51, -0.08 },
			r = { 0, 0, -10 },
			c = MAUVE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.06, 0.08, 0.06 },
			p = { 0.05, 0.6, -0.06 },
			r = { 0, 0, -20 },
			c = MAUVE,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Ruban",
			t = { 0.25, 0.04, 0.25 },
			p = { 0, 0.34, -0.1 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.16, 0.04 },
			p = { 0.08, -0.42, 0.02 },
			c = { 240, 200, 60 },
			a = "Patte",
			j = { 0.08, -0.34, 0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.2, 0.05, 0.2 },
			p = { 0, -0.22, 0.34 },
			c = plume,
			a = "Queue",
			j = { 0, -0.22, 0.26 },
		})
	end)

	-- Légendaire : bébé hydre à deux têtes.
	definir("Hydranou", 0.85, function(l)
		local vert = { 70, 160, 130 }
		local queue = { 0, -0.3, 0.22 }
		ajouter(l, { n = "Corps", t = { 0.44, 0.34, 0.5 }, p = { 0, -0.24, 0.06 }, c = vert })
		ajouter(l, {
			n = "Ventre",
			t = { 0.3, 0.24, 0.03 },
			p = { 0, -0.26, -0.205 },
			c = { 200, 230, 170 },
		})
		for i, x in { -0.13, 0.13 } do
			local j = { x, 0.0, -0.1 }
			ajouter(l, {
				n = "Cou" .. i,
				t = { 0.1, 0.3, 0.1 },
				p = { x, 0.08, -0.12 },
				r = { -10, 0, x * 60 },
				c = vert,
				a = "Tete",
				j = j,
				ph = i,
			})
			ajouter(l, {
				n = "Tete" .. i,
				t = { 0.2, 0.16, 0.24 },
				p = { x * 1.4, 0.28, -0.18 },
				c = vert,
				a = "Tete",
				j = j,
				ph = i,
			})
			ajouter(l, {
				n = "OeilG" .. i,
				t = { 0.04, 0.04, 0.02 },
				p = { x * 1.4 - 0.05, 0.32, -0.305 },
				c = { 255, 230, 60 },
				m = "Neon",
				a = "Tete",
				j = j,
				ph = i,
			})
			ajouter(l, {
				n = "OeilD" .. i,
				t = { 0.04, 0.04, 0.02 },
				p = { x * 1.4 + 0.05, 0.32, -0.305 },
				c = { 255, 230, 60 },
				m = "Neon",
				a = "Tete",
				j = j,
				ph = i,
			})
			ajouter(l, {
				n = "Corne" .. i,
				t = { 0.04, 0.1, 0.04 },
				p = { x * 1.4, 0.4, -0.14 },
				r = { 25, 0, 0 },
				c = "Rarete",
				m = "Neon",
				a = "Tete",
				j = j,
				ph = i,
			})
		end
		pattes4(l, 0.16, -0.08, 0.22, { 0.12, 0.14, 0.12 }, vert)
		ajouter(l, {
			n = "Queue",
			t = { 0.12, 0.12, 0.3 },
			p = { 0, -0.3, 0.42 },
			c = vert,
			a = "Queue",
			j = queue,
		})
		ajouter(l, {
			n = "BoutQueue",
			t = { 0.16, 0.04, 0.12 },
			p = { 0, -0.28, 0.6 },
			r = { 0, 45, 0 },
			c = { 50, 120, 100 },
			a = "Queue",
			j = queue,
		})
	end, "Ecailles")

	-- Mythique : feu follet, petite flamme de brume qui flotte.
	definir("Feufollet", 0.75, function(l)
		local flamme = { 0, -0.1, 0 }
		ajouter(l, {
			n = "Coeur",
			t = { 0.36, 0.36, 0.36 },
			p = { 0, -0.12, 0 },
			c = LUEUR,
			m = "Neon",
			tr = 0.1,
		})
		ajouter(l, {
			n = "Halo",
			t = { 0.56, 0.56, 0.56 },
			p = { 0, -0.12, 0 },
			c = { 150, 255, 200 },
			tr = 0.7,
		})
		ajouter(l, {
			n = "Pointe1",
			t = { 0.22, 0.2, 0.22 },
			p = { 0, 0.14, 0.02 },
			c = LUEUR,
			m = "Neon",
			tr = 0.2,
			a = "Antenne",
			j = flamme,
		})
		ajouter(l, {
			n = "Pointe2",
			t = { 0.1, 0.14, 0.1 },
			p = { 0.03, 0.3, 0.04 },
			r = { 0, 0, -15 },
			c = "Rarete",
			m = "Neon",
			a = "Antenne",
			j = flamme,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.08, 0.02 },
			p = { 0.07, -0.08, -0.185 },
			c = { 30, 60, 50 },
		}, true)
		ajouter(l, {
			n = "Sourire",
			t = { 0.08, 0.02, 0.02 },
			p = { 0, -0.18, -0.185 },
			c = { 30, 60, 50 },
		})
		for i, pos in { { 0.3, -0.3, 0.1 }, { -0.28, -0.38, -0.06 }, { 0.12, -0.46, 0.2 } } do
			ajouter(l, {
				n = "Etincelle" .. i,
				t = { 0.05, 0.05, 0.05 },
				p = pos,
				c = LUEUR,
				m = "Neon",
				a = "Antenne",
				j = flamme,
			})
		end
	end)

	-- Mythique : kappa, petit esprit des mares au crâne-coupelle.
	definir("Kappanou", 0.82, function(l)
		local peau = { 90, 180, 140 }
		local tete = { 0, 0.12, 0 }
		ajouter(l, { n = "Corps", t = { 0.38, 0.36, 0.34 }, p = { 0, -0.22, 0.02 }, c = peau })
		ajouter(
			l,
			{ n = "Carapace", t = { 0.36, 0.32, 0.1 }, p = { 0, -0.2, 0.22 }, c = { 120, 90, 60 } }
		)
		ajouter(l, {
			n = "Plastron",
			t = { 0.26, 0.26, 0.03 },
			p = { 0, -0.22, -0.155 },
			c = { 240, 220, 130 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.3, 0.32 },
			p = { 0, 0.18, -0.02 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.12, 0.06, 0.08 },
			p = { 0, 0.1, -0.21 },
			c = { 240, 200, 60 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.09, 0.22, -0.185, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Coupelle",
			t = { 0.24, 0.04, 0.24 },
			p = { 0, 0.35, -0.02 },
			c = { 200, 240, 255 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Eau",
			t = { 0.18, 0.02, 0.18 },
			p = { 0, 0.37, -0.02 },
			c = "Rarete",
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Cheveux",
			t = { 0.38, 0.06, 0.34 },
			p = { 0, 0.31, -0.02 },
			c = { 60, 120, 90 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.08, 0.2, 0.08 },
			p = { 0.23, -0.2, 0 },
			c = peau,
			a = "Bras",
			j = { 0.22, -0.1, 0 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Pied",
			t = { 0.14, 0.06, 0.16 },
			p = { 0.1, -0.47, -0.04 },
			c = peau,
			a = "Patte",
			j = { 0.1, -0.4, 0 },
			ph = math.pi,
		}, true)
	end)

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : tas de vase grognon qui fait des bulles.
	definir("Vasepouf", 0.55, function(l)
		ajouter(l, { n = "Vase", t = { 0.9, 0.62, 0.9 }, p = { 0, -0.19, 0 }, c = VASE })
		ajouter(l, {
			n = "Dessus",
			t = { 0.56, 0.16, 0.56 },
			p = { 0, 0.2, 0.04 },
			c = { 110, 130, 80 },
			a = "Antenne",
			j = { 0, 0.14, 0 },
		})
		yeux(l, 0.18, -0.04, -0.455, 0.17)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.2, 0.05, 0.03 },
			p = { 0.18, 0.1, -0.455 },
			r = { 0, 0, 20 },
			c = { 50, 60, 35 },
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.3, 0.07, 0.02 }, p = { 0, -0.27, -0.455 }, c = { 40, 45, 25 } }
		)
		for i, pos in { { 0.24, 0.3, 0.1 }, { -0.2, 0.32, -0.12 }, { 0.0, 0.34, 0.24 } } do
			ajouter(l, {
				n = "Bulle" .. i,
				f = "Ball",
				t = { 0.1, 0.1, 0.1 },
				p = pos,
				c = { 170, 200, 120 },
				tr = 0.3,
				a = "Antenne",
				j = { 0, 0.14, 0 },
			})
		end
		ajouter(l, {
			n = "Herbe",
			t = { 0.04, 0.16, 0.04 },
			p = { -0.3, 0.2, 0.2 },
			r = { 0, 0, 15 },
			c = VERT,
		})
	end)

	-- Moyenne : moustique géant à l'aiguillon pointu.
	definir("Moustiroc", 0.7, function(l)
		local corps = { 80, 70, 60 }
		local tete = { 0, 0.04, -0.22 }
		ajouter(l, { n = "Thorax", t = { 0.32, 0.3, 0.34 }, p = { 0, 0.0, -0.04 }, c = corps })
		ajouter(l, {
			n = "Abdomen",
			t = { 0.26, 0.24, 0.44 },
			p = { 0, -0.04, 0.34 },
			r = { 10, 0, 0 },
			c = { 150, 60, 50 },
		})
		for i, z in { 0.22, 0.36, 0.5 } do
			ajouter(l, {
				n = "Rayure" .. i,
				t = { 0.27, 0.25, 0.04 },
				p = { 0, -0.04, z },
				r = { 10, 0, 0 },
				c = corps,
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.22, 0.22 },
			p = { 0, 0.04, -0.3 },
			c = corps,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.09, 0.1, 0.04 },
			p = { 0.08, 0.08, -0.415 },
			c = { 255, 60, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Dard",
			t = { 0.03, 0.03, 0.3 },
			p = { 0, -0.02, -0.55 },
			r = { 15, 0, 0 },
			c = { 40, 30, 30 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Aile",
			t = { 0.42, 0.02, 0.16 },
			p = { 0.24, 0.18, 0.0 },
			r = { 0, -15, -10 },
			c = { 220, 230, 240 },
			tr = 0.4,
			a = "Aile",
			j = { 0.06, 0.14, 0 },
		}, true)
		for i, z in { -0.12, 0.0, 0.12 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.025, 0.42, 0.025 },
				p = { 0.16, -0.28, z },
				r = { 0, 0, -15 },
				c = corps,
				a = "Patte",
				j = { 0.12, -0.1, z },
				ph = i * 2,
			}, true)
		end
	end)

	-- Lointaine : monstre du marais, couvert d'algues et de nénuphars.
	definir("Croquemarais", 0.9, function(l)
		local peau = { 70, 110, 80 }
		local algue = { 60, 140, 70 }
		local tete = { 0, 0.3, 0 }
		ajouter(l, { n = "Torse", t = { 0.76, 0.66, 0.56 }, p = { 0, 0.0, 0 }, c = peau })
		for i, x in { -0.24, -0.08, 0.1, 0.26 } do
			ajouter(
				l,
				{ n = "Algue" .. i, t = { 0.08, 0.5, 0.03 }, p = { x, 0.02, -0.29 }, c = algue }
			)
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.5, 0.34, 0.46 },
			p = { 0, 0.48, -0.04 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.1, 0.07, 0.03 },
			p = { 0.12, 0.52, -0.285 },
			c = { 255, 230, 60 },
			m = "Neon",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.14, 0.04, 0.03 },
			p = { 0.12, 0.58, -0.285 },
			r = { 0, 0, 20 },
			c = { 40, 60, 40 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Gueule",
			t = { 0.3, 0.08, 0.02 },
			p = { 0, 0.4, -0.285 },
			c = { 40, 30, 30 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Croc",
			t = { 0.05, 0.08, 0.02 },
			p = { 0.1, 0.36, -0.29 },
			c = BLANC,
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Nenuphar",
			t = { 0.34, 0.04, 0.3 },
			p = { 0.08, 0.67, 0.0 },
			r = { 0, 0, 8 },
			c = algue,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Fleur",
			t = { 0.1, 0.06, 0.1 },
			p = { 0.12, 0.71, -0.04 },
			c = { 255, 170, 210 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.2, 0.52, 0.22 },
			p = { 0.5, 0.0, -0.02 },
			c = peau,
			a = "Bras",
			j = { 0.5, 0.22, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Main",
			t = { 0.26, 0.2, 0.26 },
			p = { 0.5, -0.32, -0.04 },
			c = algue,
			a = "Bras",
			j = { 0.5, 0.22, -0.02 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Jambe",
			t = { 0.24, 0.22, 0.26 },
			p = { 0.2, -0.38, 0 },
			c = peau,
			a = "Patte",
			j = { 0.2, -0.27, 0 },
			ph = math.pi,
		}, true)
	end)
end
