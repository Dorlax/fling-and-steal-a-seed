local Config = require("../../src/shared/Config")

local attendu: { [string]: { [string]: number } } = {
	Proche = { Commune = 70, Rare = 22, Epique = 6, Legendaire = 1.8, Mythique = 0.2 },
	Moyenne = { Commune = 55, Rare = 28, Epique = 12, Legendaire = 4, Mythique = 1 },
	Lointaine = { Commune = 40, Rare = 30, Epique = 18, Legendaire = 9, Mythique = 3 },
}

return {
	["C1 la somme des taux de chaque zone vaut 100 et chaque taux est > 0"] = function()
		for zone, _ in attendu do
			local somme = 0
			for _, rarete in Config.Raretes.Ordre do
				local taux = Config.Raretes.Taux[zone][rarete]
				assert(
					type(taux) == "number" and taux > 0,
					"taux invalide : " .. zone .. " " .. rarete
				)
				somme += taux
			end
			assert(math.abs(somme - 100) < 1e-9, "somme != 100 pour " .. zone .. " : " .. somme)
		end
	end,

	["C1 les taux sont exactement ceux du Plan"] = function()
		for zone, taux in attendu do
			for rarete, valeur in taux do
				assert(
					Config.Raretes.Taux[zone][rarete] == valeur,
					"taux différent : " .. zone .. " " .. rarete
				)
			end
		end
		assert(Config.Raretes.Taux.Proche.Mythique == 0.2, "Proche Mythique doit valoir 0,2")
		assert(Config.Raretes.Taux.Lointaine.Legendaire == 9, "Lointaine Légendaire doit valoir 9")
	end,
}
