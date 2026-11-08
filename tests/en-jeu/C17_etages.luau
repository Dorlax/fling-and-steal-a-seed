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

local prochainId = -970

local function fauxJoueur(pieces: number): any
	prochainId -= 1
	local attributs: { [string]: any } = { Pieces = pieces, Etages = 1 }
	return {
		Name = "FauxEtage" .. prochainId,
		UserId = prochainId,
		GetAttribute = function(_, nom: string)
			return attributs[nom]
		end,
		SetAttribute = function(_, nom: string, valeur: any)
			attributs[nom] = valeur
		end,
	}
end

return {
	["C17 acheter un étage : pièces retirées, 10 socles de plus, plancher créé"] = function()
		local Bases, Sauvegarde = module("Bases"), module("Sauvegarde")
		local prix = Config.Bases.PrixEtages[1]
		local j = fauxJoueur(prix + 5)
		local base = Bases.creer(j)
		local ok, err = pcall(function()
			assert(base, "base attendue")
			assert(
				Sauvegarde.capacite(j) == Config.Creatures.MaxCreaturesBase,
				"10 places au départ"
			)
			assert(Bases.acheterEtage(j) == true, "achat attendu")
			assert(j:GetAttribute("Pieces") == 5, "prix retiré")
			assert(j:GetAttribute("Etages") == 2, "2 étages")
			assert(Sauvegarde.capacite(j) == 2 * Config.Creatures.MaxCreaturesBase, "20 places")
			Bases.afficherCreatures(j, {})
			local etages = (base :: Model):FindFirstChild("Etages")
			assert(etages and etages:FindFirstChild("Plancher2"), "plancher de l'étage 2 attendu")
			local socles = (base :: Model):FindFirstChild("Socles")
			assert(
				socles and #socles:GetChildren() == 2 * Config.Creatures.MaxCreaturesBase,
				"20 socles"
			)
		end)
		Bases.liberer(j)
		assert(ok, err)
	end,

	["C17 achat refusé sans assez de pièces"] = function()
		local Bases = module("Bases")
		local j = fauxJoueur(1)
		Bases.creer(j)
		local achete = Bases.acheterEtage(j)
		Bases.liberer(j)
		assert(achete == false and j:GetAttribute("Etages") == 1, "achat refusé attendu")
	end,

	["C17 agrandir : sol plus grand, bord avant au même Z, créatures plus grandes permises"] = function()
		local Bases = module("Bases")
		local prix = Config.Bases.PrixAgrandissement[1]
		local j = fauxJoueur(prix)
		Bases.creer(j)
		local ok, err = pcall(function()
			local sol1 = Bases.solDe(j) :: BasePart
			local avant = sol1.Position.Z + sol1.Size.Z / 2
			assert(Bases.agrandir(j) == true, "agrandissement attendu")
			assert(
				j:GetAttribute("Pieces") == 0 and j:GetAttribute("Agrandissement") == 2,
				"prix retiré, niveau 2"
			)
			local sol2 = Bases.solDe(j) :: BasePart
			assert(sol2.Size.X == Config.Bases.Tailles[2], "sol agrandi")
			assert(
				math.abs(sol2.Position.Z + sol2.Size.Z / 2 - avant) < 0.01,
				"bord avant inchangé"
			)
		end)
		Bases.liberer(j)
		assert(ok, err)
	end,
}
