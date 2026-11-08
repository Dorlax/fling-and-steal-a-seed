local Jauge = require("../../src/shared/Jauge")

return {
	["C3 palier : seuils Vert / Jaune / Orange / Rouge"] = function()
		assert(Jauge.palier(0).Couleur == "Vert", "0 -> Vert")
		assert(Jauge.palier(0.49).Couleur == "Vert", "0,49 -> Vert")
		assert(Jauge.palier(0.5).Couleur == "Jaune", "0,5 -> Jaune")
		assert(Jauge.palier(0.8).Couleur == "Orange", "0,8 -> Orange")
		assert(Jauge.palier(0.92).Couleur == "Rouge", "0,92 -> Rouge")
		assert(Jauge.palier(1).Couleur == "Rouge", "1 -> Rouge")
	end,

	["C3 palier rouge : message PERFECT !"] = function()
		assert(Jauge.palier(0.92).Message == "PERFECT !", "message du rouge incorrect")
	end,

	["C3 palier : bonus croissants Vert < Jaune < Orange < Rouge"] = function()
		local vert = Jauge.palier(0).Bonus
		local jaune = Jauge.palier(0.5).Bonus
		local orange = Jauge.palier(0.8).Bonus
		local rouge = Jauge.palier(1).Bonus
		assert(vert < jaune and jaune < orange and orange < rouge, "bonus non croissants")
	end,
}
