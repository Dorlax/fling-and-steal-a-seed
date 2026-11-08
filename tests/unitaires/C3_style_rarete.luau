local Config = require("../../src/shared/Config")
local Style = require("../../src/shared/Style")

return {
	["C3 couleurRarete : couleur de Config pour les 5 raretés"] = function()
		assert(#Config.Raretes.Ordre == 5, "5 raretés attendues")
		for _, r in Config.Raretes.Ordre do
			local attendu = Config.Raretes.Couleurs[r]
			local c = Style.couleurRarete(r)
			assert(
				c[1] == attendu[1] and c[2] == attendu[2] and c[3] == attendu[3],
				"couleur différente pour " .. r
			)
		end
	end,

	["C3 couleurRarete : rareté inconnue -> blanc"] = function()
		local c = Style.couleurRarete("Inconnue")
		assert(c[1] == 255 and c[2] == 255 and c[3] == 255, "blanc attendu")
	end,

	["C3 texteRarete : nom affiché"] = function()
		assert(Style.texteRarete("Epique") == "Épique", "Epique -> Épique")
		assert(Style.texteRarete("Legendaire") == "Légendaire", "Legendaire -> Légendaire")
		assert(Style.texteRarete("Commune") == "Commune", "Commune -> Commune")
	end,

	["C3 texteRarete : inconnue -> la chaîne reçue"] = function()
		assert(Style.texteRarete("Zzz") == "Zzz", "la chaîne reçue doit être renvoyée")
	end,
}
