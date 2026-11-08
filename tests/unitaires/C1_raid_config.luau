local Config = require("../../src/shared/Config")

local CLES = {
	"DistanceVol",
	"DureeVol",
	"Recharge",
	"PrixVerrou",
	"DistanceVerrou",
	"DistanceExpulsion",
	"DureeAlerte",
}

return {
	["C1 Config.Raid existe avec DureeVerrou == 60"] = function()
		local Raid = (Config :: any).Raid
		assert(type(Raid) == "table", "Config.Raid manquant")
		assert(Raid.DureeVerrou == 60, "DureeVerrou doit valoir 60")
	end,

	["C1 les réglages de raid sont des nombres > 0"] = function()
		local Raid = (Config :: any).Raid
		assert(type(Raid) == "table", "Config.Raid manquant")
		for _, cle in CLES do
			local v = Raid[cle]
			assert(type(v) == "number" and v > 0, cle .. " doit être un nombre > 0")
		end
	end,
}
