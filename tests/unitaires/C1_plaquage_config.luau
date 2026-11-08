local Config = require("../../src/shared/Config")

local CLES = {
	"Portee",
	"DelaiRecuperation",
	"DureeAuSol",
	"DureeProtection",
	"DistanceChute",
	"DureeVieLachee",
	"IntervalleMinRequetes",
}

return {
	["C1 Config.Plaquage contient toutes les clés avec des nombres > 0"] = function()
		assert(type(Config.Plaquage) == "table", "Config.Plaquage manquant")
		for _, cle in CLES do
			local v = Config.Plaquage[cle]
			assert(type(v) == "number" and v > 0, "Config.Plaquage." .. cle .. " doit être un nombre > 0")
		end
	end,

	["C1 DureeProtection >= DureeAuSol"] = function()
		assert(Config.Plaquage.DureeProtection >= Config.Plaquage.DureeAuSol, "protection plus courte que le temps au sol")
	end,

	["C2 touches : F au clavier, ButtonY à la manette"] = function()
		local t = Config.Plaquage.Touches
		assert(t.Clavier == "F", "Clavier doit valoir F : " .. tostring(t.Clavier))
		assert(t.Manette == "ButtonY", "Manette doit valoir ButtonY : " .. tostring(t.Manette))
	end,

	["C2 les touches ne sont pas celles de la récolte"] = function()
		local t = Config.Plaquage.Touches
		assert(t.Clavier ~= "E" and t.Manette ~= "ButtonX", "touches réservées à la récolte")
	end,
}
