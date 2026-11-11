--!strict
-- Bestiaire du biome 21 : Plage Soleil (sable chaud, vagues, châteaux de sable).
-- Mêmes règles que Bestiaire : boîte de 1 × 1 × 1, pieds à Y = -0.5, avant -Z.
return function(o: any)
	local definir, ajouter, yeux = o.definir, o.ajouter, o.yeux
	local BLANC, NOIR = o.BLANC, o.NOIR

	local SABLE = { 245, 215, 150 }
	local MER = { 70, 180, 230 }
	local CORAIL = { 255, 120, 100 }

	-----------------------------------------------------------------------
	-- Créatures

	-- Commune : crabe rouge qui marche de côté.
	definir("Crabinou", 0.45, function(l)
		local rouge = { 240, 80, 60 }
		ajouter(l, { n = "Carapace", t = { 0.5, 0.2, 0.36 }, p = { 0, -0.3, 0 }, c = rouge })
		ajouter(l, {
			n = "Tige",
			t = { 0.03, 0.12, 0.03 },
			p = { 0.08, -0.14, -0.14 },
			c = rouge,
			a = "Antenne",
			j = { 0.08, -0.2, -0.14 },
		}, true)
		yeux(l, 0.08, -0.06, -0.165, 0.06, "Antenne", { 0, -0.2, -0.14 })
		ajouter(
			l,
			{ n = "Sourire", t = { 0.1, 0.02, 0.02 }, p = { 0, -0.3, -0.185 }, c = { 120, 30, 30 } }
		)
		ajouter(l, {
			n = "Pince",
			t = { 0.14, 0.12, 0.14 },
			p = { 0.34, -0.24, -0.16 },
			c = "Rarete",
			a = "Bras",
			j = { 0.26, -0.28, -0.1 },
			ph = 0,
		}, true)
		for i, z in { -0.08, 0.04, 0.14 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.14, 0.03, 0.03 },
				p = { 0.3, -0.42, z },
				r = { 0, 0, -30 },
				c = rouge,
				a = "Patte",
				j = { 0.22, -0.38, z },
				ph = i * 2,
			}, true)
		end
	end)

	-- Commune : coquillage spirale avec un petit habitant.
	definir("Coquillou", 0.55, function(l)
		ajouter(l, {
			n = "Coquille",
			t = { 0.36, 0.36, 0.4 },
			p = { 0, -0.22, 0.06 },
			r = { 0, 45, 0 },
			c = { 255, 210, 190 },
		})
		ajouter(l, {
			n = "Spirale",
			t = { 0.24, 0.24, 0.26 },
			p = { 0, 0.02, 0.1 },
			r = { 0, 45, 0 },
			c = "Rarete",
		})
		ajouter(l, {
			n = "Pointe",
			t = { 0.12, 0.12, 0.12 },
			p = { 0, 0.18, 0.12 },
			r = { 0, 45, 0 },
			c = { 255, 230, 210 },
		})
		ajouter(l, {
			n = "Habitant",
			t = { 0.24, 0.14, 0.16 },
			p = { 0, -0.38, -0.18 },
			c = { 255, 190, 140 },
		})
		yeux(l, 0.06, -0.34, -0.265, 0.06)
		ajouter(l, {
			n = "Antenne",
			t = { 0.02, 0.1, 0.02 },
			p = { 0.05, -0.26, -0.22 },
			r = { -20, 0, -15 },
			c = { 255, 190, 140 },
			a = "Antenne",
			j = { 0.05, -0.3, -0.2 },
		}, true)
	end)

	-- Rare : bébé tortue de mer qui court vers l'eau.
	definir("Tortuplage", 0.45, function(l)
		local peau = { 120, 190, 150 }
		local tete = { 0, -0.32, -0.26 }
		ajouter(l, {
			n = "Carapace",
			t = { 0.42, 0.18, 0.46 },
			p = { 0, -0.34, 0.02 },
			c = { 90, 140, 90 },
		})
		for i, pos in { { 0, -0.24, -0.08 }, { 0, -0.24, 0.1 } } do
			ajouter(l, {
				n = "Ecaille" .. i,
				t = { 0.18, 0.02, 0.14 },
				p = pos,
				r = { 0, 45, 0 },
				c = "Rarete",
			})
		end
		ajouter(l, {
			n = "Tete",
			t = { 0.18, 0.14, 0.16 },
			p = { 0, -0.32, -0.32 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.05, -0.3, -0.405, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Nageoire",
			t = { 0.2, 0.04, 0.12 },
			p = { 0.28, -0.42, -0.1 },
			r = { 0, 30, 0 },
			c = peau,
			a = "Bras",
			j = { 0.2, -0.42, -0.08 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Nageoire2",
			t = { 0.12, 0.04, 0.1 },
			p = { 0.22, -0.44, 0.2 },
			r = { 0, -30, 0 },
			c = peau,
			a = "Patte",
			j = { 0.18, -0.44, 0.18 },
			ph = math.pi,
		}, true)
	end, "Ecailles")

	-- Rare : mouette coquine aux lunettes de soleil.
	definir("Mouettou", 0.7, function(l)
		local tete = { 0, 0.02, -0.08 }
		ajouter(l, { n = "Corps", t = { 0.32, 0.3, 0.44 }, p = { 0, -0.22, 0.06 }, c = BLANC })
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.2, 0.34 },
			p = { 0.18, -0.18, 0.08 },
			c = { 170, 180, 190 },
			a = "Aile",
			j = { 0.16, -0.1, 0.06 },
		}, true)
		ajouter(l, {
			n = "BoutAile",
			t = { 0.04, 0.1, 0.1 },
			p = { 0.18, -0.14, 0.28 },
			c = NOIR,
			a = "Aile",
			j = { 0.16, -0.1, 0.06 },
		}, true)
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.22, 0.24 },
			p = { 0, 0.04, -0.12 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.06, 0.05, 0.14 },
			p = { 0, 0.0, -0.3 },
			c = { 255, 200, 50 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Lunettes",
			t = { 0.24, 0.06, 0.02 },
			p = { 0, 0.08, -0.245 },
			c = "Rarete",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.07, 0.06, 0.02 },
			p = { 0.06, 0.08, -0.255 },
			c = { 30, 30, 40 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Patte",
			t = { 0.04, 0.12, 0.06 },
			p = { 0.07, -0.44, 0.04 },
			c = { 255, 180, 60 },
			a = "Patte",
			j = { 0.07, -0.38, 0.04 },
			ph = 0,
		}, true)
	end)

	-- Épique : bébé phoque qui fait tourner un ballon.
	definir("Phoquinou", 0.7, function(l)
		local gris = { 200, 205, 215 }
		local tete = { 0, -0.06, -0.14 }
		ajouter(l, {
			n = "Corps",
			t = { 0.36, 0.32, 0.56 },
			p = { 0, -0.34, 0.08 },
			r = { -10, 0, 0 },
			c = gris,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.3, 0.26, 0.26 },
			p = { 0, -0.06, -0.16 },
			c = gris,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.08, -0.02, -0.295, 0.09, "Tete", tete)
		ajouter(l, {
			n = "Truffe",
			t = { 0.05, 0.04, 0.02 },
			p = { 0, -0.1, -0.295 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Moustache",
			t = { 0.1, 0.015, 0.015 },
			p = { 0.1, -0.12, -0.29 },
			c = { 120, 120, 130 },
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Ballon",
			f = "Ball",
			t = { 0.2, 0.2, 0.2 },
			p = { 0, 0.18, -0.16 },
			c = "Rarete",
			a = "Antenne",
			j = { 0, 0.06, -0.16 },
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.16, 0.04, 0.12 },
			p = { 0.22, -0.44, -0.08 },
			r = { 0, 0, -20 },
			c = gris,
			a = "Bras",
			j = { 0.16, -0.42, -0.06 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.24, 0.04, 0.1 },
			p = { 0, -0.46, 0.4 },
			c = gris,
			a = "Queue",
			j = { 0, -0.46, 0.34 },
		})
	end, "Gelee")

	-- Épique : pélican au grand bec plein de poissons.
	definir("Pelicanou", 0.8, function(l)
		local tete = { 0, 0.16, -0.08 }
		ajouter(l, { n = "Corps", t = { 0.36, 0.34, 0.46 }, p = { 0, -0.2, 0.08 }, c = BLANC })
		ajouter(l, {
			n = "Aile",
			t = { 0.04, 0.24, 0.36 },
			p = { 0.2, -0.18, 0.1 },
			c = { 200, 200, 210 },
			a = "Aile",
			j = { 0.18, -0.08, 0.08 },
		}, true)
		ajouter(l, {
			n = "Cou",
			t = { 0.1, 0.2, 0.1 },
			p = { 0, 0.04, -0.08 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.18, 0.16, 0.18 },
			p = { 0, 0.2, -0.1 },
			c = BLANC,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bec",
			t = { 0.08, 0.05, 0.34 },
			p = { 0, 0.18, -0.34 },
			c = { 255, 200, 70 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Poche",
			t = { 0.1, 0.12, 0.28 },
			p = { 0, 0.09, -0.32 },
			c = { 255, 170, 90 },
			a = "Machoire",
			j = { 0, 0.14, -0.2 },
		})
		ajouter(l, {
			n = "Poisson",
			t = { 0.03, 0.05, 0.1 },
			p = { 0.05, 0.16, -0.46 },
			c = "Rarete",
			a = "Machoire",
			j = { 0, 0.14, -0.2 },
		})
		yeux(l, 0.06, 0.23, -0.195, 0.05, "Tete", tete)
		ajouter(l, {
			n = "Patte",
			t = { 0.06, 0.16, 0.1 },
			p = { 0.08, -0.42, 0.04 },
			c = { 255, 180, 60 },
			a = "Patte",
			j = { 0.08, -0.34, 0.04 },
			ph = 0,
		}, true)
	end)

	-- Légendaire : morse moustachu aux défenses brillantes.
	definir("Morsou", 0.65, function(l)
		local peau = { 170, 120, 100 }
		local tete = { 0, -0.12, -0.22 }
		ajouter(l, { n = "Corps", t = { 0.52, 0.4, 0.6 }, p = { 0, -0.28, 0.08 }, c = peau })
		ajouter(l, {
			n = "Tete",
			t = { 0.36, 0.3, 0.28 },
			p = { 0, -0.1, -0.26 },
			c = peau,
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Moustache",
			t = { 0.24, 0.1, 0.08 },
			p = { 0, -0.18, -0.42 },
			c = { 230, 200, 170 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Defense",
			t = { 0.04, 0.2, 0.04 },
			p = { 0.07, -0.32, -0.42 },
			c = "Rarete",
			m = "Foil",
			a = "Tete",
			j = tete,
		}, true)
		ajouter(l, {
			n = "Truffe",
			t = { 0.06, 0.04, 0.02 },
			p = { 0, -0.12, -0.465 },
			c = NOIR,
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.09, -0.02, -0.405, 0.05, "Tete", tete)
		ajouter(l, {
			n = "Nageoire",
			t = { 0.2, 0.04, 0.14 },
			p = { 0.3, -0.46, -0.06 },
			r = { 0, 0, -20 },
			c = peau,
			a = "Bras",
			j = { 0.22, -0.44, -0.04 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Queue",
			t = { 0.3, 0.04, 0.12 },
			p = { 0, -0.46, 0.42 },
			c = peau,
			a = "Queue",
			j = { 0, -0.46, 0.36 },
		})
	end)

	-- Légendaire : château de sable vivant au drapeau.
	definir("Chateausable", 0.95, function(l)
		ajouter(l, { n = "Base", t = { 0.6, 0.3, 0.5 }, p = { 0, -0.35, 0 }, c = SABLE })
		for _, x in { -0.22, 0.22 } do
			ajouter(l, {
				n = "Tour" .. (if x < 0 then "G" else "D"),
				t = { 0.18, 0.36, 0.18 },
				p = { x, -0.02, 0 },
				c = SABLE,
			})
			ajouter(l, {
				n = "Creneau" .. (if x < 0 then "G" else "D"),
				t = { 0.22, 0.06, 0.22 },
				p = { x, 0.19, 0 },
				c = { 230, 195, 130 },
			})
		end
		ajouter(l, { n = "Donjon", t = { 0.22, 0.5, 0.22 }, p = { 0, 0.05, 0.04 }, c = SABLE })
		ajouter(
			l,
			{ n = "Mat", t = { 0.02, 0.2, 0.02 }, p = { 0, 0.4, 0.04 }, c = { 120, 80, 50 } }
		)
		ajouter(l, {
			n = "Drapeau",
			t = { 0.14, 0.08, 0.02 },
			p = { 0.08, 0.46, 0.04 },
			c = "Rarete",
			a = "Antenne",
			j = { 0.01, 0.46, 0.04 },
		})
		ajouter(l, {
			n = "Porte",
			t = { 0.14, 0.14, 0.02 },
			p = { 0, -0.42, -0.255 },
			c = { 200, 160, 100 },
			a = "Machoire",
			j = { 0, -0.35, -0.255 },
		})
		yeux(l, 0.08, -0.24, -0.255, 0.07)
		ajouter(
			l,
			{ n = "Coquille", t = { 0.08, 0.06, 0.02 }, p = { 0.2, -0.3, -0.255 }, c = CORAIL },
			true
		)
	end)

	-- Mythique : petite sirène à la queue nacrée.
	definir("Sirenelle", 0.9, function(l)
		local tete = { 0, 0.14, 0 }
		ajouter(
			l,
			{ n = "Rocher", t = { 0.5, 0.2, 0.4 }, p = { 0, -0.4, 0.06 }, c = { 150, 140, 130 } }
		)
		ajouter(
			l,
			{ n = "Buste", t = { 0.24, 0.24, 0.2 }, p = { 0, -0.06, 0 }, c = { 255, 220, 190 } }
		)
		ajouter(
			l,
			{ n = "Coquilles", t = { 0.22, 0.06, 0.03 }, p = { 0, -0.02, -0.105 }, c = CORAIL }
		)
		ajouter(l, {
			n = "Queue",
			t = { 0.2, 0.2, 0.3 },
			p = { 0, -0.24, 0.08 },
			c = "Rarete",
			m = "Foil",
			a = "Queue",
			j = { 0, -0.2, 0.0 },
		})
		ajouter(l, {
			n = "Nageoire",
			t = { 0.28, 0.04, 0.14 },
			p = { 0.1, -0.3, 0.3 },
			r = { 0, -30, 0 },
			c = MER,
			tr = 0.2,
			a = "Queue",
			j = { 0, -0.2, 0.0 },
		})
		ajouter(l, {
			n = "Tete",
			t = { 0.24, 0.24, 0.22 },
			p = { 0, 0.18, 0 },
			c = { 255, 220, 190 },
			a = "Tete",
			j = tete,
		})
		yeux(l, 0.06, 0.2, -0.115, 0.06, "Tete", tete)
		ajouter(l, {
			n = "Cheveux",
			t = { 0.28, 0.32, 0.26 },
			p = { 0, 0.18, 0.04 },
			c = { 255, 140, 120 },
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Etoile",
			t = { 0.06, 0.06, 0.02 },
			p = { 0.1, 0.3, -0.1 },
			r = { 0, 0, 45 },
			c = { 255, 230, 100 },
			m = "Neon",
			a = "Tete",
			j = tete,
		})
		ajouter(l, {
			n = "Bras",
			t = { 0.06, 0.18, 0.06 },
			p = { 0.15, -0.04, -0.02 },
			r = { 0, 0, -20 },
			c = { 255, 220, 190 },
			a = "Bras",
			j = { 0.13, 0.04, 0 },
			ph = 0,
		}, true)
	end)

	-- Mythique : esprit de vague à la crête d'écume.
	definir("Vaguelette", 0.85, function(l)
		local vague = { 0, -0.2, 0 }
		ajouter(l, {
			n = "Base",
			t = { 0.6, 0.24, 0.4 },
			p = { 0, -0.38, 0 },
			c = MER,
			tr = 0.15,
			a = "Antenne",
			j = vague,
		})
		ajouter(l, {
			n = "Corps",
			t = { 0.42, 0.34, 0.34 },
			p = { 0, -0.1, 0.04 },
			c = { 90, 200, 240 },
			tr = 0.15,
			a = "Antenne",
			j = vague,
		})
		ajouter(l, {
			n = "Rouleau",
			t = { 0.38, 0.2, 0.3 },
			p = { 0, 0.14, -0.06 },
			r = { -30, 0, 0 },
			c = { 120, 215, 245 },
			tr = 0.15,
			a = "Antenne",
			j = vague,
		})
		ajouter(l, {
			n = "Ecume",
			t = { 0.4, 0.08, 0.16 },
			p = { 0, 0.24, -0.16 },
			r = { -30, 0, 0 },
			c = BLANC,
			a = "Antenne",
			j = vague,
		})
		yeux(l, 0.08, -0.06, -0.135, 0.08, "Antenne", vague)
		ajouter(l, {
			n = "Sourire",
			t = { 0.1, 0.02, 0.02 },
			p = { 0, -0.16, -0.135 },
			c = { 30, 80, 120 },
			a = "Antenne",
			j = vague,
		})
		for i, pos in { { 0.3, 0.2, 0.0 }, { -0.3, 0.1, 0.06 }, { 0.2, -0.34, -0.2 } } do
			ajouter(l, {
				n = "Goutte" .. i,
				f = "Ball",
				t = { 0.07, 0.07, 0.07 },
				p = pos,
				c = "Rarete",
				m = "Neon",
				a = "Antenne",
				j = vague,
			})
		end
	end, "Gelee")

	-----------------------------------------------------------------------
	-- Monstres

	-- Proche : gros crabe grognon aux pinces énormes.
	definir("Crabogre", 0.6, function(l)
		local rouge = { 200, 60, 50 }
		ajouter(l, { n = "Carapace", t = { 0.62, 0.3, 0.5 }, p = { 0, -0.22, 0.02 }, c = rouge })
		ajouter(l, {
			n = "Pic",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.16, -0.04, 0.0 },
			r = { 0, 45, 0 },
			c = { 160, 40, 40 },
		}, true)
		ajouter(l, {
			n = "Oeil",
			t = { 0.08, 0.08, 0.08 },
			p = { 0.1, 0.02, -0.18 },
			c = { 255, 220, 60 },
			m = "Neon",
			a = "Antenne",
			j = { 0.1, -0.08, -0.18 },
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.1, 0.03, 0.03 },
			p = { 0.1, 0.08, -0.22 },
			r = { 0, 0, 25 },
			c = NOIR,
			a = "Antenne",
			j = { 0.1, -0.08, -0.18 },
		}, true)
		ajouter(l, { n = "Bouche", t = { 0.16, 0.03, 0.02 }, p = { 0, -0.24, -0.255 }, c = NOIR })
		ajouter(l, {
			n = "Pince",
			t = { 0.22, 0.18, 0.24 },
			p = { 0.42, -0.14, -0.24 },
			c = rouge,
			a = "Bras",
			j = { 0.32, -0.2, -0.12 },
			ph = 0,
		}, true)
		ajouter(l, {
			n = "Doigt",
			t = { 0.06, 0.06, 0.14 },
			p = { 0.42, -0.02, -0.36 },
			c = rouge,
			a = "Machoire",
			j = { 0.42, -0.06, -0.3 },
		}, true)
		for i, z in { -0.08, 0.06, 0.18 } do
			ajouter(l, {
				n = "Patte" .. i,
				t = { 0.2, 0.04, 0.04 },
				p = { 0.38, -0.38, z },
				r = { 0, 0, -30 },
				c = rouge,
				a = "Patte",
				j = { 0.28, -0.32, z },
				ph = i * 2,
			}, true)
		end
	end)

	-- Moyenne : méduse qui pique et flotte.
	definir("Meduselle", 0.85, function(l)
		local chapeau = { 0, 0.16, 0 }
		ajouter(l, {
			n = "Ombrelle",
			f = "Ball",
			t = { 0.6, 0.42, 0.6 },
			p = { 0, 0.16, 0 },
			c = { 220, 140, 255 },
			m = "Neon",
			tr = 0.3,
			a = "Antenne",
			j = chapeau,
		})
		ajouter(l, {
			n = "Coeur",
			f = "Ball",
			t = { 0.24, 0.18, 0.24 },
			p = { 0, 0.14, 0 },
			c = { 255, 100, 200 },
			m = "Neon",
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.06, 0.08, 0.02 },
			p = { 0.1, 0.16, -0.29 },
			c = BLANC,
			m = "Neon",
		}, true)
		ajouter(
			l,
			{ n = "Bouche", t = { 0.1, 0.03, 0.02 }, p = { 0, 0.04, -0.28 }, c = { 120, 40, 120 } }
		)
		for k = 0, 5 do
			local a = math.rad(k * 60)
			ajouter(l, {
				n = "Tentacule" .. k,
				t = { 0.03, 0.5, 0.03 },
				p = { math.cos(a) * 0.18, -0.2, math.sin(a) * 0.18 },
				c = { 240, 180, 255 },
				tr = 0.2,
				a = "Patte",
				j = { math.cos(a) * 0.18, 0.0, math.sin(a) * 0.18 },
				ph = k,
			})
		end
	end)

	-- Lointaine : rouleau de vague géant qui écrase tout.
	definir("Rouleaugre", 0.95, function(l)
		local vague = { 0, -0.1, 0.1 }
		ajouter(l, {
			n = "Base",
			t = { 0.9, 0.3, 0.6 },
			p = { 0, -0.35, 0.1 },
			c = { 40, 140, 200 },
			tr = 0.1,
		})
		ajouter(l, {
			n = "Mur",
			t = { 0.86, 0.5, 0.3 },
			p = { 0, 0.0, 0.16 },
			c = { 60, 160, 220 },
			tr = 0.1,
			a = "Antenne",
			j = vague,
		})
		ajouter(l, {
			n = "Rouleau",
			t = { 0.84, 0.26, 0.4 },
			p = { 0, 0.3, -0.08 },
			r = { -35, 0, 0 },
			c = { 90, 190, 240 },
			tr = 0.1,
			a = "Antenne",
			j = vague,
		})
		ajouter(l, {
			n = "Ecume",
			t = { 0.88, 0.1, 0.2 },
			p = { 0, 0.42, -0.26 },
			r = { -35, 0, 0 },
			c = BLANC,
			a = "Antenne",
			j = vague,
		})
		ajouter(l, {
			n = "Oeil",
			t = { 0.12, 0.08, 0.03 },
			p = { 0.2, 0.1, -0.005 },
			c = { 255, 240, 80 },
			m = "Neon",
			a = "Antenne",
			j = vague,
		}, true)
		ajouter(l, {
			n = "Sourcil",
			t = { 0.16, 0.04, 0.03 },
			p = { 0.2, 0.18, -0.01 },
			r = { 0, 0, 25 },
			c = { 20, 60, 100 },
			a = "Antenne",
			j = vague,
		}, true)
		ajouter(l, {
			n = "Gueule",
			t = { 0.4, 0.08, 0.03 },
			p = { 0, -0.1, -0.005 },
			c = { 20, 60, 100 },
			a = "Machoire",
			j = { 0, -0.08, 0.04 },
		})
		ajouter(l, {
			n = "Planche",
			t = { 0.1, 0.03, 0.4 },
			p = { 0.38, 0.5, 0.0 },
			r = { 30, 20, 40 },
			c = { 255, 200, 80 },
			a = "Antenne",
			j = vague,
		})
	end)
end
