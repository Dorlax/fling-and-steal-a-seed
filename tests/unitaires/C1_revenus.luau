local Config = require("../../src/shared/Config")
local Revenus = require("../../src/shared/Revenus")

local plafond = Config.Creatures.PiecesMax

return {
	["C1 parSeconde renvoie 1, 3, 10, 30, 100 selon la rareté"] = function()
		local attendu = { Commune = 1, Rare = 3, Epique = 10, Legendaire = 30, Mythique = 100 }
		for rarete, valeur in attendu do
			assert(Revenus.parSeconde(rarete) == valeur, "revenu incorrect pour " .. rarete)
		end
	end,

	["C1 parSeconde renvoie 0 pour une rareté inconnue ou non-chaîne"] = function()
		for _, v in { "Triche", "", 5, true, {} } do
			assert(Revenus.parSeconde(v :: any) == 0, "0 attendu pour " .. tostring(v))
		end
		assert(Revenus.parSeconde(nil :: any) == 0, "0 attendu pour nil")
	end,

	["C2 total Commune + Rare + Mythique = 104"] = function()
		assert(Revenus.total({ "Commune", "Rare", "Mythique" }) == 104)
	end,

	["C2 total d'une liste vide = 0"] = function()
		assert(Revenus.total({}) == 0)
	end,

	["C2 total: les entrées invalides comptent 0"] = function()
		assert(Revenus.total({ "Commune", "Triche", 42 :: any, false :: any, "Rare" }) == 4)
	end,

	["C3 ajouter 10 + 5 = 15"] = function()
		assert(Revenus.ajouter(10, 5) == 15)
	end,

	["C3 ajouter renvoie un entier"] = function()
		local r = Revenus.ajouter(10, 2.7)
		assert(r == math.floor(r), "résultat non entier : " .. tostring(r))
	end,

	["C3 ajouter ne renvoie jamais un nombre négatif"] = function()
		assert(Revenus.ajouter(10, -50) >= 0)
		assert(Revenus.ajouter(0, -1) >= 0)
	end,

	["C3 ajouter est plafonné à PiecesMax"] = function()
		assert(Revenus.ajouter(plafond - 1, 1000) == plafond)
		assert(Revenus.ajouter(plafond, 1) == plafond)
	end,

	["C3 un gain NaN, infini ou non numérique laisse les pièces inchangées"] = function()
		for _, gain in { 0 / 0, math.huge, -math.huge, "abc", true, {} } do
			assert(
				Revenus.ajouter(10, gain :: any) == 10,
				"pièces changées par " .. tostring(gain)
			)
		end
		assert(Revenus.ajouter(10, nil :: any) == 10, "pièces changées par nil")
	end,

	["C4 walkSpeedPortage(20) = 16"] = function()
		assert(math.abs(Revenus.walkSpeedPortage(20) - 16) < 1e-9)
	end,

	["C4 walkSpeedPortage est strictement inférieur à l'entrée (> 0)"] = function()
		for _, v in { 0.5, 1, 16, 50, 1000 } do
			assert(Revenus.walkSpeedPortage(v) < v, "pas inférieur pour " .. v)
		end
	end,
}
