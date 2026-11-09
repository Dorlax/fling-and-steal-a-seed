local Config = require("../../src/shared/Config")
local Forge = require("../../src/shared/Forge")
local Passes = require("../../src/shared/Passes")

return {
	["C1 mode Double : refusé avant le niveau requis, permis ensuite"] = function()
		local niveau = Config.Forge.Double.NiveauMin
		assert(not Forge.modePermis("Double", niveau - 1), "trop tôt")
		assert(Forge.modePermis("Double", niveau), "débloqué")
		assert(Forge.modePermis("Force", 1) and Forge.modePermis("Vitesse", 1), "modes de base")
		assert(not Forge.modePermis("Triche", 99), "mode inconnu refusé")
		local noms, part = Forge.statsDuMode("Double")
		assert(#noms == 2 and part == 0.6, "deux stats à 60 %")
		local seul, plein = Forge.statsDuMode("Force")
		assert(#seul == 1 and seul[1] == "Force" and plein == 1, "une stat à 100 %")
		assert(#(Forge.statsDuMode("Triche")) == 0, "rien pour un mode inconnu")
	end,

	["C2 passes : 4 passes du Plan, multiplicateurs × 2 seulement si possédés"] = function()
		assert(#Config.Passes.Ordre == 4, "exactement les 4 passes autorisés")
		for _, id in Config.Passes.Ordre do
			assert(Passes.existe(id), id)
		end
		assert(Passes.attribut("X2Force") == "PassX2Force", "attribut")
		assert(Passes.multiplicateurStat("Force", true) == 2, "× 2 Force")
		assert(Passes.multiplicateurStat("Force", nil) == 1, "sans passe")
		assert(Passes.multiplicateurStat("Pieces", true) == 1, "pas une stat")
		assert(Passes.multiplicateurPieces(true) == 2 and Passes.multiplicateurPieces("oui") == 1)
		assert(Passes.depuisNumero(0) == nil, "Id 0 = pas encore créé")
		assert(Passes.depuisNumero("1") == nil, "pas un nombre")
	end,
}
