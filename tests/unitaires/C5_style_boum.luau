local Style = require("../../src/shared/Style")

return {
	["C5 estBoum : vrai pour BOUM !"] = function()
		assert(Style.estBoum("BOUM !") == true, '"BOUM !" doit être vrai')
	end,

	["C5 estBoum : faux pour tout le reste"] = function()
		local estBoum: any = Style.estBoum
		for _, v in { "BOUM", "boum !", "Personne à plaquer !", "BOUM ! ", "" } do
			assert(estBoum(v) == false, "faux attendu pour " .. v)
		end
		assert(estBoum(nil) == false, "faux attendu pour nil")
		assert(estBoum(5) == false, "faux attendu pour 5")
	end,
}
