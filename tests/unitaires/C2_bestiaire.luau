local Bestiaire = require("../../src/shared/Bestiaire")
local Config = require("../../src/shared/Config")

local ROLES = {
	Patte = true,
	Bras = true,
	Aile = true,
	Queue = true,
	Oreille = true,
	Tete = true,
	Antenne = true,
	Machoire = true,
	Toupie = true,
	Helice = true,
	Roue = true,
	Moulin = true,
	Pendule = true,
	Bascule = true,
	Flamme = true,
}

return {
	["C2 chaque rareté a au moins deux espèces, jamais partagées"] = function()
		local vues = {}
		for _, rarete in Config.Raretes.Ordre do
			local liste = (Bestiaire.Creatures :: any)[rarete]
			assert(liste and #liste >= 2, "pas assez d'espèces pour " .. rarete)
			for _, nom in liste do
				assert(Bestiaire.Especes[nom], "espèce inconnue : " .. nom)
				assert(vues[nom] == nil, "espèce partagée : " .. nom)
				vues[nom] = true
			end
			assert(
				Bestiaire.especeCreature(rarete).Nom == liste[1],
				"par défaut : première espèce"
			)
			assert(Bestiaire.especeCreature(rarete, liste[2]).Nom == liste[2], "espèce demandée")
			assert(
				Bestiaire.especeCreature(rarete, "Inconnue").Nom == liste[1],
				"espèce inconnue : première"
			)
			assert(
				Bestiaire.tirerEspece(rarete, 0.999).Nom == liste[#liste],
				"tirage 0.999 : dernière"
			)
		end
	end,

	["C2 chaque zone a au moins deux monstres, le premier porte le nom de Config"] = function()
		for zone, reglage in Config.Monstres.Zones do
			local liste = (Bestiaire.Monstres :: any)[zone]
			assert(liste and #liste >= 2, "pas assez de monstres en " .. zone)
			assert(
				liste[1] == reglage.Nom,
				"le premier monstre de " .. zone .. " doit être " .. reglage.Nom
			)
			for _, nom in liste do
				assert(Bestiaire.Especes[nom], "espèce inconnue : " .. nom)
			end
			assert(Bestiaire.especeMonstre(zone, 0).Nom == liste[1], "tirage 0 = première espèce")
			assert(
				Bestiaire.especeMonstre(zone, 0.999).Nom == liste[#liste],
				"tirage 0.999 = dernière espèce"
			)
		end
	end,

	["C2 chaque bloc est bien formé, chaque espèce a des yeux"] = function()
		for nom, espece in Bestiaire.Especes do
			local yeux = false
			assert(#espece.Blocs >= 8, nom .. " doit avoir au moins 8 blocs")
			for _, b in espece.Blocs do
				assert(#b.t == 3 and #b.p == 3, nom .. "." .. b.n .. " : taille et position en 3D")
				for i = 1, 3 do
					assert(b.t[i] > 0, nom .. "." .. b.n .. " : taille positive")
					assert(math.abs(b.p[i]) <= 1.1, nom .. "." .. b.n .. " : trop loin du centre")
				end
				if b.a then
					assert(ROLES[b.a], nom .. "." .. b.n .. " : rôle d'animation inconnu " .. b.a)
					assert(b.j and #b.j == 3, nom .. "." .. b.n .. " : articulation manquante")
				end
				if string.sub(b.n, 1, 4) == "Oeil" then
					yeux = true
				end
			end
			assert(yeux, nom .. " n'a pas d'yeux")
		end
	end,
}
