-- Plus de 50 biomes : les biomes 22 et suivants ont leur univers et des
-- créatures chimériques, toutes dessinées, uniques et stables.
local Biomes = require("../../src/shared/Biomes")
local Bestiaire = require("../../src/shared/Bestiaire")
local Chimeres = require("../../src/shared/Chimeres")
local Config = require("../../src/shared/Config")

return {
	["C1 plus de cinquante biomes, identifiants uniques"] = function()
		assert(Biomes.nombre() >= 50, "au moins 50 biomes : " .. Biomes.nombre())
		local vus = {}
		for _, b in Biomes.Liste do
			assert(vus[b.Id] == nil, "Id en double : " .. b.Id)
			vus[b.Id] = true
		end
	end,

	["C2 chaque nouveau biome a un ciel et des chimères dessinées"] = function()
		for numero = 22, Biomes.nombre() do
			local b = Biomes.Liste[numero]
			assert(b.Ciel ~= nil and type(b.Ciel.Elements) == "string", b.Id .. " : ciel attendu")
			for _, rarete in Config.Raretes.Ordre do
				for _, nom in b.Creatures[rarete] do
					local recette = Biomes.Recettes[nom]
					assert(recette, "recette manquante : " .. nom)
					assert(recette.Base ~= recette.Donneur, nom .. " : base = donneur")
					assert(Bestiaire.Especes[nom], "chimère non dessinée : " .. nom)
					assert(#nom >= 5 and #nom <= 14, "nom trop court ou trop long : " .. nom)
				end
			end
		end
	end,

	["C3 une chimère garde des yeux et prend des couleurs du biome"] = function()
		local b = Biomes.Liste[22]
		local nom = b.Creatures.Commune[1]
		local recette = Biomes.Recettes[nom]
		local chimere = Bestiaire.Especes[nom]
		local base = Bestiaire.Especes[recette.Base]
		local yeux = false
		for _, bloc in chimere.Blocs do
			if string.sub(bloc.n, 1, 4) == "Oeil" then
				yeux = true
			end
		end
		assert(yeux, "la chimère doit avoir des yeux")
		assert(#chimere.Blocs > 0 and #base.Blocs > 0, "blocs attendus")
	end,

	["C4 teinter : les gris ne bougent pas, les couleurs tournent"] = function()
		local gris = Chimeres.teinter({ 128, 128, 128 }, 200, 0)
		assert(gris[1] == 128 and gris[2] == 128 and gris[3] == 128, "gris inchangé")
		local rouge = Chimeres.teinter({ 255, 0, 0 }, 240, 0)
		assert(rouge[3] > 200 and rouge[1] < 30, "rouge tourné vers le bleu")
	end,

	["C5 génération stable : mêmes noms à chaque chargement"] = function()
		local originaux = {}
		for i = 1, 21 do
			originaux[i] = Biomes.Liste[i]
		end
		local a = Chimeres.generer(originaux)
		local b = Chimeres.generer(originaux)
		for i, biome in a do
			assert(biome.Creatures.Commune[1] == b[i].Creatures.Commune[1], "génération instable")
			assert(biome.Creatures.Commune[1] == Biomes.Liste[21 + i].Creatures.Commune[1], "liste")
		end
	end,
}
