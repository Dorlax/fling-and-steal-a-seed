local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)

local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local function fauxJoueur(attributs: { [string]: any }): any
	return {
		Name = "FauxJoueurPasses",
		UserId = -2,
		Character = nil,
		GetAttribute = function(_, nom: string)
			return attributs[nom]
		end,
		SetAttribute = function(_, nom: string, valeur: any)
			attributs[nom] = valeur
		end,
	}
end

return {
	["C1 mode Double : refusé trop tôt, puis Force et Vitesse montent ensemble à 60 %"] = function()
		local Entrainement = module("Entrainement")
		local niveau = Config.Forge.Double.NiveauMin
		local tot = fauxJoueur({ ModeForge = "Force", NiveauForge = niveau - 1 })
		Entrainement.traiterChoixMode(tot, "Double")
		assert(tot:GetAttribute("ModeForge") == "Force", "Double refusé avant le niveau")
		local j = fauxJoueur({
			Force = 0,
			Vitesse = 0,
			ModeForge = "Force",
			SurForge = true,
			NiveauForge = niveau,
		})
		Entrainement.traiterChoixMode(j, "Double")
		assert(j:GetAttribute("ModeForge") == "Double", "Double accepté")
		Entrainement.tick(j)
		local attendu = math.floor(Forge.gainPour(niveau) * Config.Forge.Double.Part + 0.5)
		assert(j:GetAttribute("Force") == attendu, `Force {j:GetAttribute("Force")} ≠ {attendu}`)
		assert(j:GetAttribute("Vitesse") == attendu, "Vitesse aussi")
	end,

	["C2 passe × 2 Force : gain doublé, Vitesse inchangée"] = function()
		local Entrainement = module("Entrainement")
		local sans =
			fauxJoueur({ Force = 0, ModeForge = "Force", SurForge = true, NiveauForge = 3 })
		local avec = fauxJoueur({
			Force = 0,
			ModeForge = "Force",
			SurForge = true,
			NiveauForge = 3,
			PassX2Force = true,
			PassX2Vitesse = true,
		})
		Entrainement.tick(sans)
		Entrainement.tick(avec)
		assert(avec:GetAttribute("Force") == 2 * sans:GetAttribute("Force"), "× 2")
	end,

	["C3 passe × 2 Pièces : revenus doublés"] = function()
		local Portage = module("Portage")
		local sans = fauxJoueur({ Pieces = 0, RevenuParSeconde = 10 })
		local avec = fauxJoueur({ Pieces = 0, RevenuParSeconde = 10, PassX2Pieces = true })
		Portage.tickRevenus(sans)
		Portage.tickRevenus(avec)
		assert(sans:GetAttribute("Pieces") > 0, "revenu reçu")
		assert(avec:GetAttribute("Pieces") == 2 * sans:GetAttribute("Pieces"), "× 2")
	end,

	["C4 ramassage auto : rien sans le passe"] = function()
		local PassesRobux = module("PassesRobux")
		assert(PassesRobux.ramasser(fauxJoueur({})) == false, "pas de passe, pas de ramassage")
	end,
}
