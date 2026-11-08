local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.Shared.Config)

local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

return {
	["C16 une créature Titan est plus grosse et garde sa taille et son espèce"] = function()
		local m = module("Lancers").creerCreaturePortable({ UserId = -960 }, "Epique:Titan:Hibouflor", Vector3.new(0, 5, 200))
		local ok, err = pcall(function()
			assert(m:GetAttribute("Taille") == "Titan", "attribut Taille attendu")
			assert(m:GetAttribute("Espece") == "Hibouflor", "espèce demandée attendue")
			local corps = m:FindFirstChild("Corps") :: BasePart
			local attendu = 3 * Config.Tailles.Echelle.Titan
			assert(math.abs(corps.Size.Y - attendu) < 0.01, "diamètre d'un Titan attendu")
		end)
		m:Destroy()
		assert(ok, err)
	end,

	["C16 la sauvegarde refuse une fiche invalide et accepte une fiche complète"] = function()
		local Sauvegarde = module("Sauvegarde")
		local faux = { UserId = -961, SetAttribute = function() end }
		assert(Sauvegarde.ajouterCreature(faux, "Rare:Enorme") == false, "taille inconnue refusée")
		assert(Sauvegarde.ajouterCreature(faux, "Rare:Grande:Tortipousse") == true, "fiche complète acceptée")
		assert(Sauvegarde.creaturesDe(faux)[1] == "Rare:Grande:Tortipousse", "fiche conservée telle quelle")
	end,
}
