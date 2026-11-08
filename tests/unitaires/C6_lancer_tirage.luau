local Config = require("../../src/shared/Config")
local Lancer = require("../../src/shared/Lancer")

return {
	["C6 tirerRarete : bornes de la zone Proche"] = function()
		assert(Lancer.tirerRarete("Proche", 0) == "Commune", "0 -> Commune")
		assert(Lancer.tirerRarete("Proche", 0.6999) == "Commune", "0,6999 -> Commune")
		assert(Lancer.tirerRarete("Proche", 0.70) == "Rare", "0,70 -> Rare")
		assert(Lancer.tirerRarete("Proche", 0.9999) == "Mythique", "0,9999 -> Mythique")
	end,

	["C6 tirerRarete : Lointaine 0,95 -> Legendaire"] = function()
		assert(Lancer.tirerRarete("Lointaine", 0.95) == "Legendaire", "0,95 -> Legendaire")
	end,

	["C6 tirerRarete : toutes les raretés restent possibles dans chaque zone"] = function()
		for zone, _ in Config.Raretes.Taux do
			local vues: { [string]: boolean } = {}
			for i = 0, 9999 do
				vues[Lancer.tirerRarete(zone, i / 10000)] = true
			end
			for _, rarete in Config.Raretes.Ordre do
				assert(vues[rarete], rarete .. " jamais atteinte en zone " .. zone)
			end
		end
	end,
}
