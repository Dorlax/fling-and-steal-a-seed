local Jauge = require("../../src/shared/Jauge")

local function proche(a: number, b: number): boolean
	return math.abs(a - b) < 1e-9
end

return {
	["C2 position : valeurs clés de l'onde triangle (période 1,6)"] = function()
		assert(proche(Jauge.position(0, 1.6), 0), "p(0) doit valoir 0")
		assert(proche(Jauge.position(0.8, 1.6), 1), "p(0,8) doit valoir 1")
		assert(proche(Jauge.position(0.4, 1.6), 0.5), "p(0,4) doit valoir 0,5")
		assert(proche(Jauge.position(1.6, 1.6), 0), "p(1,6) doit valoir 0")
		assert(proche(Jauge.position(2.4, 1.6), 1), "p(2,4) doit valoir 1")
	end,

	["C2 position reste toujours dans [0, 1]"] = function()
		for i = 0, 500 do
			local p = Jauge.position(i * 0.037, 1.6)
			assert(p >= 0 and p <= 1, "hors de [0, 1] : " .. p)
		end
	end,

	["C2 position : t négatif traité comme 0"] = function()
		assert(Jauge.position(-1, 1.6) == 0, "p(-1) doit valoir 0")
	end,
}
