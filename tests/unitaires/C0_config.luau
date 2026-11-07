local Config = require("../../src/shared/Config")

return {
	["C0 la configuration a un nom de jeu"] = function()
		assert(type(Config.NomDuJeu) == "string", "Config.NomDuJeu doit être un texte")
	end,
}
