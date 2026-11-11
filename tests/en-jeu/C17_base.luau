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
	local attributs: { [string]: any } = { Pieces = pieces, Agrandissement = 1 }
	return {
		Name = "FauxBase" .. prochainId,
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
	["C17 agrandir : sol plus grand, bord avant au même Z, plus de places"] = function()
		local Bases, Sauvegarde = module("Bases"), module("Sauvegarde")
		local prix = Config.Bases.PrixAgrandissement[1]
		local j = fauxJoueur(prix)
		Bases.creer(j)
		local ok, err = pcall(function()
			assert(Sauvegarde.capacite(j) == Config.Bases.Capacites[1], "places du niveau 1")
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
			assert(Sauvegarde.capacite(j) == Config.Bases.Capacites[2], "places du niveau 2")
		end)
		Bases.liberer(j)
		assert(ok, err)
	end,

	["C17 agrandissement refusé sans assez de pièces"] = function()
		local Bases = module("Bases")
		local j = fauxJoueur(1)
		Bases.creer(j)
		local achete = Bases.agrandir(j)
		Bases.liberer(j)
		assert(achete == false and j:GetAttribute("Agrandissement") == 1, "refus attendu")
	end,

	["C17 base pleine au plus grand niveau : toutes les créatures sur un seul niveau, dans la base"] = function()
		local Bases = module("Bases")
		local niveau = #Config.Bases.Tailles
		local j = fauxJoueur(0)
		j:SetAttribute("Agrandissement", niveau)
		local base = Bases.creer(j)
		local ok, err = pcall(function()
			assert(base, "base attendue")
			local liste = {}
			for i = 1, Config.Bases.Capacites[niveau] do
				liste[i] = "Commune"
			end
			Bases.afficherCreatures(j, liste)
			assert((base :: Model):FindFirstChild("Etages") == nil, "plus d'étages")
			assert((base :: Model):FindFirstChild("Socles") == nil, "plus de socles")
			local sol = Bases.solDe(j) :: BasePart
			local dossier = (base :: Model):FindFirstChild("CreaturesBase")
			assert(dossier, "créatures attendues")
			local n = 0
			for _, c in dossier:GetChildren() do
				n += 1
				local centre = c:GetAttribute("PromenadeCentre")
				assert(typeof(centre) == "Vector3", "centre de promenade attendu")
				local relatif = centre - sol.Position
				assert(relatif.Y < 6, "créature au rez-de-chaussée attendue")
				assert(
					math.abs(relatif.X) < sol.Size.X / 2 and math.abs(relatif.Z) < sol.Size.Z / 2,
					"créature hors du sol"
				)
			end
			assert(n == Config.Bases.Capacites[niveau], "toutes les places affichées : " .. n)
		end)
		Bases.liberer(j)
		assert(ok, err)
	end,
}
