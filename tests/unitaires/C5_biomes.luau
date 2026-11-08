local Biomes = require("../../src/shared/Biomes")
local Bestiaire = require("../../src/shared/Bestiaire")
local Config = require("../../src/shared/Config")
local Lancer = require("../../src/shared/Lancer")
local Forge = require("../../src/shared/Forge")
local Revenus = require("../../src/shared/Revenus")
local Nombres = require("../../src/shared/Nombres")

local L = Biomes.Longueur

return {
	["C5 biomes : numéro, position dans le biome et valeur ×1,5"] = function()
		assert(Biomes.index(0) == 1 and Biomes.index(L - 1) == 1, "début et fin du biome 1")
		assert(Biomes.index(L) == 2, "début du biome 2")
		assert(Biomes.index(-5) == 1 and Biomes.index(0 / 0) == 1, "valeurs invalides -> 1")
		assert(Biomes.index(1e9) == Biomes.nombre(), "au-delà : dernier biome défini")
		assert(Biomes.dansBiome(L + 160) == 160, "position dans le biome")
		assert(Biomes.multiplicateur(1) == 1 and Biomes.multiplicateur(3) == 2.25, "× 1,5 par biome")
		assert(Biomes.texteMultiplicateur(2) == "1,5", "texte du multiplicateur")
	end,

	["C5 chaque biome a 2 créatures par rareté et au moins 1 monstre par sous-zone, toutes dessinées"] = function()
		local vues = {}
		for numero, biome in Biomes.Liste do
			for _, rarete in Config.Raretes.Ordre do
				local liste = biome.Creatures[rarete]
				assert(liste and #liste >= 2, biome.Nom .. " : 2 espèces " .. rarete .. " attendues")
				for _, nom in liste do
					assert(Bestiaire.Especes[nom], "espèce non dessinée : " .. nom)
					assert(vues[nom] == nil, "espèce dans deux biomes : " .. nom)
					vues[nom] = true
					assert(Biomes.indexEspece(nom) == numero, "biome de " .. nom)
				end
			end
			for _, zone in Config.Lancer.Zones do
				local liste = biome.Monstres[zone.Nom]
				assert(liste and #liste >= 1, biome.Nom .. " : monstre " .. zone.Nom .. " attendu")
				for _, nom in liste do
					assert(Bestiaire.Especes[nom], "monstre non dessiné : " .. nom)
				end
			end
		end
	end,

	["C5 on tire l'espèce dans le biome d'atterrissage"] = function()
		local espece = Bestiaire.tirerEspece("Rare", 0, 2)
		assert(Biomes.indexEspece(espece.Nom) == 2, "espèce du biome 2 attendue")
		assert(Bestiaire.especeMonstre("Lointaine", 0, 3).Nom == "Golemsable", "monstre du biome 3")
	end,

	["C5 une créature d'un biome lointain rapporte plus"] = function()
		local prairie = Revenus.parSeconde("Epique:Normale:Renardelle")
		local dunes = Revenus.parSeconde("Epique:Normale:Dromadune")
		assert(prairie == 10, "Épique de la Prairie : 10")
		assert(dunes == math.floor(10 * 2.25 + 0.5), "Épique des Dunes : × 2,25")
	end,

	["C6 au-delà de 1 000 de Force, chaque doublement avance d'un biome"] = function()
		local base = Lancer.distance(1000, 0)
		local double = Lancer.distance(2000, 0)
		assert(math.abs(double - base - L) < 1e-6, "doublement = un biome")
		assert(Lancer.distance(1e15, 1e6) <= Biomes.distanceMax(), "jamais au-delà du dernier biome")
		assert(Lancer.zone(L + 10) == "Proche", "chaque biome recommence à Proche")
	end,

	["C6 niveaux de Forge : gain et coût croissants, Vitesse sans le plafond de 50"] = function()
		assert(Forge.gainPour(1) == Config.Forge.GainParTick, "niveau 1 = gain de base")
		assert(Forge.gainPour(10) > Forge.gainPour(5), "gain croissant")
		assert(Forge.coutNiveau(2) > Forge.coutNiveau(1), "coût croissant")
		assert(Forge.walkSpeedPour(1e6) > 50, "la vitesse dépasse l'ancien plafond")
		assert(Forge.walkSpeedPour(1e15) <= Config.Forge.WalkSpeedMax, "plafond de sécurité")
		local stats = Forge.appliquerGain({ Force = 0, Vitesse = 0 }, "Force", nil, 3)
		assert(stats.Force == Forge.gainPour(3), "le gain dépend du niveau")
	end,

	["C6 grands nombres raccourcis"] = function()
		assert(Nombres.abreger(999) == "999", "999")
		assert(Nombres.abreger(12345) == "12 345", "12 345")
		assert(Nombres.abreger(1234567) == "1,23 M", "1,23 M : " .. Nombres.abreger(1234567))
		assert(Nombres.abreger(4.5e12) == "4,5 T", "4,5 T : " .. Nombres.abreger(4.5e12))
		assert(Nombres.abreger(0 / 0) == "0", "NaN")
	end,
}
