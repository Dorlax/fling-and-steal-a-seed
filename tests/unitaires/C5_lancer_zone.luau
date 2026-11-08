local Lancer = require("../../src/shared/Lancer")

return {
	["C5 zone : Proche, Moyenne, Lointaine selon la distance"] = function()
		assert(Lancer.zone(0) == "Proche", "0 -> Proche")
		assert(Lancer.zone(149.9) == "Proche", "149,9 -> Proche")
		assert(Lancer.zone(150) == "Moyenne", "150 -> Moyenne")
		assert(Lancer.zone(299) == "Moyenne", "299 -> Moyenne")
		assert(Lancer.zone(300) == "Lointaine", "300 -> Lointaine")
		assert(Lancer.zone(520) == "Lointaine", "520 -> Lointaine")
	end,
}
