local ServerScriptService = game:GetService("ServerScriptService")

local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local function compter(modele: Model, nom: string): number
	local n = 0
	for _, objet in modele:GetDescendants() do
		if objet.Name == nom then
			n += 1
		end
	end
	return n
end

local function creature(rarete: string): Model
	return module("Lancers").creerCreaturePortable({ UserId = -950 }, rarete, Vector3.new(0, 5, 200))
end

return {
	["C15 une créature Commune a une pousse, une Mythique une couronne, une auréole et des étincelles"] = function()
		local commune = creature("Commune")
		local mythique = creature("Mythique")
		local ok, err = pcall(function()
			assert(compter(commune, "Feuille") == 2, "pousse attendue sur une Commune")
			assert(compter(commune, "Aile") == 0, "pas d'ailes sur une Commune")
			assert(compter(mythique, "Couronne") > 0, "couronne attendue sur une Mythique")
			assert(compter(mythique, "Aureole") > 0, "auréole attendue sur une Mythique")
			assert(compter(mythique, "Etincelles") == 1, "étincelles attendues sur une Mythique")
		end)
		commune:Destroy()
		mythique:Destroy()
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
