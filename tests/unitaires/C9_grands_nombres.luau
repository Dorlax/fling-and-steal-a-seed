local Nombres = require("../../src/shared/Nombres")
local Revenus = require("../../src/shared/Revenus")
local Config = require("../../src/shared/Config")

return {
	["C9 grands nombres : suffixes jusqu'à Vg, puis notation scientifique"] = function()
		assert(Nombres.abreger(1.5e33) == "1,5 Dc", Nombres.abreger(1.5e33))
		assert(Nombres.abreger(2e63) == "2 Vg", Nombres.abreger(2e63))
		assert(Nombres.abreger(1.23e75) == "1,23e75", Nombres.abreger(1.23e75))
		assert(Nombres.abreger(math.huge) == "∞", "infini")
	end,

	["C9 pièces : la progression ne bloque plus à 1e15"] = function()
		assert(Config.Creatures.PiecesMax >= 1e300, "plafond très haut")
		assert(Revenus.ajouter(1e15, 1e15) == 2e15, "au-delà de 1e15")
		assert(Revenus.ajouter(1e200, 1e200) == 2e200, "très grands nombres")
	end,
}
