local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	["C0 la configuration partagée est chargée en jeu"] = function()
		local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
		assert(Config.NomDuJeu ~= nil, "Config.NomDuJeu manquant")
	end,
}
