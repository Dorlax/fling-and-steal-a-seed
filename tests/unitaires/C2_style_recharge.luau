local Style = require("../../src/shared/Style")

local function proche(a, b)
	return math.abs(a - b) < 1e-9
end

return {
	["C2 ratioRecharge : moitié restante"] = function()
		assert(proche(Style.ratioRecharge(10, 13, 6), 0.5), "(10, 13, 6) doit donner 0,5")
	end,

	["C2 ratioRecharge : déjà prêt ou absent"] = function()
		assert(Style.ratioRecharge(10, 9, 6) == 0, "prêt dans le passé -> 0")
		assert(Style.ratioRecharge(10, 10, 6) == 0, "prêt maintenant -> 0")
		assert(Style.ratioRecharge(10, nil, 6) == 0, "pretA absent -> 0")
		assert((Style.ratioRecharge :: any)(10, "x", 6) == 0, "pretA non-nombre -> 0")
	end,

	["C2 ratioRecharge : borné à 1"] = function()
		assert(Style.ratioRecharge(10, 30, 6) == 1, "(10, 30, 6) doit donner 1")
	end,

	["C2 ratioRecharge : durée nulle ou négative, NaN"] = function()
		assert(Style.ratioRecharge(10, 13, 0) == 0, "durée 0 -> 0")
		assert(Style.ratioRecharge(10, 13, -5) == 0, "durée négative -> 0")
		assert(Style.ratioRecharge(0 / 0, 13, 6) == 0, "maintenant NaN -> 0")
		assert(Style.ratioRecharge(10, 0 / 0, 6) == 0, "pretA NaN -> 0")
		assert(Style.ratioRecharge(10, 13, 0 / 0) == 0, "durée NaN -> 0")
	end,
}
