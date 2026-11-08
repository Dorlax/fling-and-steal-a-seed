local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	["C14 Style se charge depuis ReplicatedStorage.Shared sans erreur"] = function()
		local module = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Style", 5)
		assert(module ~= nil, "ReplicatedStorage.Shared.Style introuvable")
		local ok, Style = pcall(require, module)
		assert(ok, "Style ne se charge pas : " .. tostring(Style))
		assert(type(Style) == "table", "Style doit renvoyer une table")
	end,

	["C14 couleurJauge(0.5) renvoie 3 nombres dans [0, 255]"] = function()
		local Style = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Style"))
		local c = Style.couleurJauge(0.5)
		assert(type(c) == "table", "une table est attendue")
		for i = 1, 3 do
			assert(type(c[i]) == "number", "composante " .. i .. " doit être un nombre")
			assert(c[i] >= 0 and c[i] <= 255, "composante " .. i .. " hors de [0, 255]")
		end
	end,
}
