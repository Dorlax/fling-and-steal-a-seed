local fs = require("@lune/fs")

local function lire(nom: string)
	return fs.readFile("src/client/" .. nom .. ".luau")
end

return {
	["C12 Habillage utilise TweenService, UIScale, UICorner et UIStroke"] = function()
		local src = lire("Habillage")
		for _, mot in { "TweenService", "UIScale", "UICorner", "UIStroke" } do
			assert(string.find(src, mot, 1, true), "Habillage doit utiliser " .. mot)
		end
	end,

	["C12 les interfaces de boutons utilisent Habillage"] = function()
		for _, nom in
			{ "InterfaceLancer", "InterfacePlaquage", "InterfaceStats", "InterfacePieges" }
		do
			local src = lire(nom)
			assert(
				string.find(src, "require%([^\n]*Habillage[^\n]*%)") ~= nil,
				nom .. " doit faire require(Habillage)"
			)
		end
	end,
}
