local ServerScriptService = game:GetService("ServerScriptService")

local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local function creature(rarete: string): Model
	return module("Lancers").creerCreaturePortable({ UserId = -950 }, rarete, Vector3.new(0, 5, 200))
end

return {
	["C15 chaque rareté donne son espèce en blocs, avec un Corps invisible"] = function()
		local attendues = { Commune = "Poussigraine", Mythique = "Dragonnet" }
		for rarete, espece in attendues do
			local m = creature(rarete)
			local ok, err = pcall(function()
				assert(m:GetAttribute("Espece") == espece, rarete .. " doit être un " .. espece)
				local corps = m:FindFirstChild("Corps") :: BasePart
				assert(corps and corps.Transparency == 1, "le Corps doit être invisible")
				local animees = 0
				for _, objet in m:GetDescendants() do
					if objet:IsA("BasePart") and objet:GetAttribute("Anim") ~= nil then
						animees += 1
					end
				end
				assert(animees >= 4, rarete .. " doit avoir des pièces animées")
			end)
			m:Destroy()
			assert(ok, err)
		end
	end,

	["C15 une Mythique a ses étincelles et son aura"] = function()
		local m = creature("Mythique")
		local ok, err = pcall(function()
			local corps = m:FindFirstChild("Corps") :: BasePart
			assert(corps:FindFirstChild("Etincelles"), "étincelles attendues")
			assert(corps:FindFirstChild("Aura"), "aura attendue")
		end)
		m:Destroy()
		assert(ok, err)
	end,

	["C15 les pièces de détail ne bloquent rien et sont ancrées"] = function()
		local m = creature("Legendaire")
		local ok, err = pcall(function()
			for _, objet in m:GetDescendants() do
				if objet:IsA("BasePart") then
					assert(objet.CanCollide == false, objet.Name .. " ne doit pas bloquer")
					assert(objet.Anchored == true, objet.Name .. " doit être ancrée")
				end
			end
		end)
		m:Destroy()
		assert(ok, err)
	end,
}
