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
}

return {
	["C2 chaque rareté a sa propre espèce de créature"] = function()
		local vues = {}
		for _, rarete in Config.Raretes.Ordre do
			local espece = Bestiaire.especeCreature(rarete)
			assert(espece ~= nil, "pas d'espèce pour " .. rarete)
			assert(vues[espece.Nom] == nil, "espèce partagée : " .. espece.Nom)
			vues[espece.Nom] = true
		end
	end,

	["C2 chaque zone a au moins deux monstres, le premier porte le nom de Config"] = function()
		for zone, reglage in Config.Monstres.Zones do
			local liste = (Bestiaire.Monstres :: any)[zone]
			assert(liste and #liste >= 2, "pas assez de monstres en " .. zone)
			assert(liste[1] == reglage.Nom, "le premier monstre de " .. zone .. " doit être " .. reglage.Nom)
			for _, nom in liste do
				assert(Bestiaire.Especes[nom], "espèce inconnue : " .. nom)
			end
			assert(Bestiaire.especeMonstre(zone, 0).Nom == liste[1], "tirage 0 = première espèce")
			assert(Bestiaire.especeMonstre(zone, 0.999).Nom == liste[#liste], "tirage 0.999 = dernière espèce")
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
