local Jauge = require("../../src/shared/Jauge")
local Lancer = require("../../src/shared/Lancer")

return {
	["C7 tirerRarete n'a que deux paramètres (zone, aleatoire)"] = function()
		local nombre = debug.info(Lancer.tirerRarete, "a")
		assert(nombre == 2, "tirerRarete doit avoir 2 paramètres, trouvé " .. tostring(nombre))
	end,

	["C7 même zone et même aléatoire : même rareté quel que soit le palier"] = function()
		local force = 100
		local bonusA = Jauge.palier(0).Bonus
		local bonusB = Jauge.palier(0.5).Bonus -- 70 vs 85 : les deux restent en zone Proche
		local zoneA = Lancer.zone(Lancer.distance(force, bonusA))
		local zoneB = Lancer.zone(Lancer.distance(force, bonusB))
		assert(zoneA == zoneB, "les deux bonus doivent rester dans la même zone")
		for i = 0, 99 do
			local alea = i / 100
			assert(
				Lancer.tirerRarete(zoneA, alea) == Lancer.tirerRarete(zoneB, alea),
				"la rareté dépend du palier pour " .. alea
			)
		end
	end,
}
