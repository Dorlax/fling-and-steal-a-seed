local Config = require("../../src/shared/Config")
local Donnees = require("../../src/shared/Donnees")

local plafond = Config.Forge.PlafondStat

return {
	["C6 parDefaut renvoie les valeurs de départ"] = function()
		local d = Donnees.parDefaut()
		assert(d.Force == 0 and d.Vitesse == 0, "stats à 0")
		assert(d.ModeForge == "Force", "mode par défaut Force")
		assert(d.NiveauForge == 1, "NiveauForge = 1")
	end,

	["C6 parDefaut renvoie des tables distinctes"] = function()
		local a, b = Donnees.parDefaut(), Donnees.parDefaut()
		assert(a ~= b, "tables identiques")
		a.Force = 99
		assert(b.Force == 0, "b ne doit pas être affectée")
	end,

	["C7 nettoyer(nil) renvoie les données par défaut"] = function()
		local d = Donnees.nettoyer(nil)
		assert(d.Force == 0 and d.Vitesse == 0 and d.ModeForge == "Force" and d.NiveauForge == 1)
	end,

	["C7 Force invalide devient 0"] = function()
		for _, v in { "abc", -5, 0 / 0 } do
			local d =
				Donnees.nettoyer({ Force = v, Vitesse = 3, ModeForge = "Force", NiveauForge = 1 })
			assert(d.Force == 0, "Force doit valoir 0 pour " .. tostring(v))
		end
	end,

	["C7 Vitesse au-dessus du plafond est ramenée au plafond"] = function()
		local d = Donnees.nettoyer({
			Force = 1,
			Vitesse = plafond + 500,
			ModeForge = "Force",
			NiveauForge = 1,
		})
		assert(d.Vitesse == plafond)
	end,

	["C7 mode inconnu devient Force"] = function()
		local d =
			Donnees.nettoyer({ Force = 1, Vitesse = 1, ModeForge = "Triche", NiveauForge = 1 })
		assert(d.ModeForge == "Force")
	end,

	["C7 champs manquants complétés"] = function()
		local d = Donnees.nettoyer({ Force = 7 })
		assert(d.Force == 7)
		assert(d.Vitesse == 0 and d.ModeForge == "Force" and d.NiveauForge == 1)
	end,

	["C7 valeurs valides conservées"] = function()
		local d =
			Donnees.nettoyer({ Force = 12, Vitesse = 34, ModeForge = "Vitesse", NiveauForge = 1 })
		assert(
			d.Force == 12 and d.Vitesse == 34 and d.ModeForge == "Vitesse" and d.NiveauForge == 1
		)
	end,
}
