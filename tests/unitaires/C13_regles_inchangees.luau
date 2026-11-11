local Config = require("../../src/shared/Config")

return {
	["C13 délais et durées inchangés"] = function()
		assert(Config.Plaquage.DelaiRecuperation == 6, "Plaquage.DelaiRecuperation == 6")
		assert(Config.Pieges.DelaiPose == 5, "Pieges.DelaiPose == 5")
	end,

	["C13 paliers de la jauge de lancer inchangés"] = function()
		local p = Config.Lancer.Jauge.Paliers
		assert(#p == 4, "4 paliers attendus")
		local mins = { 0, 0.5, 0.75, 0.92 }
		local bonus = { 0, 15, 35, 60 }
		for i = 1, 4 do
			assert(p[i].Min == mins[i], "Min du palier " .. i)
			assert(p[i].Bonus == bonus[i], "Bonus du palier " .. i)
		end
	end,

	["C13 taux de rareté du Plan inchangés"] = function()
		local t = Config.Raretes.Taux
		local attendu = {
			Proche = { Commune = 70, Rare = 22, Epique = 6, Legendaire = 1.8, Mythique = 0.2 },
			Moyenne = { Commune = 55, Rare = 28, Epique = 12, Legendaire = 4, Mythique = 1 },
			Lointaine = { Commune = 40, Rare = 30, Epique = 18, Legendaire = 9, Mythique = 3 },
		}
		for zone, taux in attendu do
			for rarete, valeur in taux do
				assert(t[zone][rarete] == valeur, "taux " .. zone .. "/" .. rarete)
			end
		end
	end,
}
