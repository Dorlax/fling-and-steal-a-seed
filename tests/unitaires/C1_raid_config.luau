local Config = require("../../src/shared/Config")

local CLES = {
	"DistanceVol",
	"DureeVol",
	"DureeAlerte",
}

return {
	["C1 Config.Raid existe, sans réglages de verrou (supprimé)"] = function()
		local Raid = (Config :: any).Raid
		assert(type(Raid) == "table", "Config.Raid manquant")
		for _, cle in { "DureeVerrou", "Recharge", "PrixVerrou", "DistanceVerrou" } do
			assert(Raid[cle] == nil, cle .. " ne doit plus exister")
		end
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
