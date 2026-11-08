local Style = require("../../src/shared/Style")

local function egal(c, attendu)
	return c[1] == attendu[1] and c[2] == attendu[2] and c[3] == attendu[3]
end

return {
	["C4 couleurZone : danger des monstres"] = function()
		assert(egal(Style.couleurZone("Proche"), { 70, 220, 90 }), "Proche -> Vert")
		assert(egal(Style.couleurZone("Moyenne"), { 255, 140, 30 }), "Moyenne -> Orange")
		assert(egal(Style.couleurZone("Lointaine"), { 240, 50, 50 }), "Lointaine -> Rouge")
	end,

	["C4 couleurZone : zone inconnue -> blanc"] = function()
		assert(egal(Style.couleurZone("Ailleurs"), { 255, 255, 255 }), "blanc attendu")
	end,
}
