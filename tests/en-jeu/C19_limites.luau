local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Biomes = require(ReplicatedStorage.Shared.Biomes)

return {
	["C19 un rempart décoré par biome et des murs invisibles autour de la carte"] = function()
		local decor = Workspace:FindFirstChild("Decor")
		if decor == nil or decor:FindFirstChild("Limites") == nil then
			local serveur = ServerScriptService:WaitForChild("Server", 5)
			assert(serveur, "dossier Server introuvable")
			decor = (require :: any)(serveur:FindFirstChild("Decor")).creer()
		end
		assert(decor, "dossier Decor attendu")
		local limites = decor:FindFirstChild("Limites")
		assert(limites, "dossier Limites attendu")
		for _, biome in Biomes.Liste do
			local groupe = limites:FindFirstChild(biome.Id)
			assert(groupe and #groupe:GetChildren() > 0, "rempart du biome " .. biome.Id)
		end
		local murs = 0
		for _, p in limites:GetChildren() do
			if p.Name == "MurInvisible" then
				murs += 1
				assert(
					p:IsA("BasePart") and p.CanCollide and p.Transparency == 1,
					"mur invisible solide"
				)
				assert(p.Size.Y >= 500, "mur assez haut")
			end
		end
		assert(murs >= 4, "au moins 4 murs invisibles")
	end,
}
