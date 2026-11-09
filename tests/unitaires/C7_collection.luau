local Collection = require("../../src/shared/Collection")
local Biomes = require("../../src/shared/Biomes")
local Donnees = require("../../src/shared/Donnees")
local Bestiaire = require("../../src/shared/Bestiaire")

local premiere = Biomes.Liste[1].Creatures.Commune[1]
local monstre = Biomes.Liste[1].Monstres.Proche[1]

return {
	["C1 collection : 10 créatures par biome, monstres exclus"] = function()
		assert(Collection.total() == 10 * Biomes.nombre(), "10 créatures par biome")
		assert(Collection.estCreature(premiere), "créature collectionnable")
		assert(not Collection.estCreature(monstre), "un monstre ne se collectionne pas")
		assert(not Collection.estCreature("Inconnue"), "espèce inconnue")
	end,

	["C2 collection : ajout unique, encodage et progression"] = function()
		local liste = {}
		assert(Collection.ajouter(liste, premiere) == true, "nouvelle espèce")
		assert(Collection.ajouter(liste, premiere) == false, "déjà connue")
		assert(Collection.ajouter(liste, monstre) == false, "monstre refusé")
		local n, total = Collection.progression(liste, 1)
		assert(n == 1 and total == 10, "1/10 dans le biome 1")
		local texte = Collection.encoder(liste)
		local retour = Collection.decoder(texte)
		assert(#retour == 1 and retour[1] == premiere, "encodage réversible")
		assert(#Collection.decoder("") == 0 and #Collection.decoder(nil) == 0, "vide")
	end,

	["C3 données : Decouvertes nettoyées (inconnues, monstres et doublons retirés)"] = function()
		assert(#Donnees.parDefaut().Decouvertes == 0, "vide par défaut")
		local d =
			Donnees.nettoyer({ Decouvertes = { premiere, premiere, monstre, "Inconnue", 42 } })
		assert(#d.Decouvertes == 1 and d.Decouvertes[1] == premiere, "une seule espèce gardée")
	end,

	["C4 bestiaire : le haut du modèle est mesuré sur les blocs"] = function()
		for nom, espece in Bestiaire.Especes do
			local haut = -1
			for _, b in espece.Blocs do
				haut = math.max(haut, b.p[2])
			end
			assert(espece.Hauteur >= haut, nom .. " : panneau sous le centre d'un bloc")
			assert(espece.Hauteur <= 1.2, nom .. " : hauteur raisonnable")
		end
	end,
}
