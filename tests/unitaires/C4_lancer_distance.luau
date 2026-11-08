local Config = require("../../src/shared/Config")
local Lancer = require("../../src/shared/Lancer")

return {
	["C4 distance : Force 0 et bonus 0 = 30, Force 100 = 70"] = function()
		assert(Lancer.distance(0, 0) == 30, "Force 0 -> 30")
		assert(Lancer.distance(100, 0) == 70, "Force 100 -> 70")
	end,

	["C4 distance : la jauge s'ajoute à la Force"] = function()
		assert(Lancer.distance(100, 60) == 130, "Force 100 + bonus 60 -> 130")
	end,

	["C4 distance : plus de Force donne plus de distance à bonus égal"] = function()
		assert(
			Lancer.distance(200, 15) > Lancer.distance(100, 15),
			"la Force doit augmenter la distance"
		)
	end,

	["C4 distance : Force invalide (texte, NaN, négative) donne 30"] = function()
		assert(Lancer.distance("abc" :: any, 0) == 30, "texte -> 30")
		assert(Lancer.distance(0 / 0, 0) == 30, "NaN -> 30")
		assert(Lancer.distance(-5, 0) == 30, "négative -> 30")
	end,

	["C4 distance : jamais supérieure à DistanceMax"] = function()
		for _, force in { 0, 500, 1000, 5000, 1e9 } do
			for _, bonus in { 0, 60, 1e6 } do
				assert(
					Lancer.distance(force, bonus) <= Config.Lancer.DistanceMax,
					"dépasse DistanceMax"
				)
			end
		end
	end,
}
