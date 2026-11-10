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

local function fauxJoueur(attributs: { [string]: any }): any
	return {
		Name = "FauxJoueurCadeaux",
		UserId = -3,
		GetAttribute = function(_, nom: string)
			return attributs[nom]
		end,
		SetAttribute = function(_, nom: string, valeur: any)
			attributs[nom] = valeur
		end,
	}
end

local JOUR = 20000 * 86400 + 3600

return {
	["C1 cadeau de connexion : une fois par jour, série qui avance puis repart"] = function()
		local Cadeaux = module("Cadeaux")
		local j = fauxJoueur({
			Pieces = 0,
			RevenuParSeconde = 10,
			QuotidienSerie = 0,
			QuotidienJour = -1,
		})
		Cadeaux.fixerHorloge(function()
			return JOUR
		end)
		assert(Cadeaux.reclamerQuotidien(j) == 1, "jour 1")
		assert(j:GetAttribute("Pieces") == 3000, "5 min de revenu")
		assert(Cadeaux.reclamerQuotidien(j) == nil, "pas deux fois le même jour")
		Cadeaux.fixerHorloge(function()
			return JOUR + 86400
		end)
		assert(Cadeaux.reclamerQuotidien(j) == 2, "lendemain : jour 2")
		assert((j:GetAttribute("BoostJusqua") or 0) > 0, "jour 2 : boost")
		Cadeaux.fixerHorloge(function()
			return JOUR + 4 * 86400
		end)
		assert(Cadeaux.reclamerQuotidien(j) == 1, "jours ratés : retour au jour 1")
		Cadeaux.fixerHorloge(nil)
	end,

	["C2 défi : progrès compté par le serveur, récompense réclamée une seule fois"] = function()
		local Cadeaux = module("Cadeaux")
		Cadeaux.fixerHorloge(function()
			return JOUR
		end)
		local j =
			fauxJoueur({ Pieces = 0, RevenuParSeconde = 0, DefisProgres = "", DefisJour = -1 })
		local ids = Cadeaux.defis(j)
		assert(j:GetAttribute("DefisProgres") == "0,0,0", "remis à zéro")
		assert(not Cadeaux.reclamerDefi(j, 1), "pas encore fini")
		local d = Config.Defis.Liste[ids[1]]
		for _ = 1, d.Objectif * 4 + 5 do
			Cadeaux.progresser(j, ids[1])
		end
		assert(Cadeaux.reclamerDefi(j, 1), "réclamé")
		assert(j:GetAttribute("Pieces") == Config.Quotidien.Min, "récompense donnée")
		assert(not Cadeaux.reclamerDefi(j, 1), "une seule fois")
		assert(
			not Cadeaux.reclamerDefi(j, 9) and not Cadeaux.reclamerDefi(j, "1"),
			"numéros invalides"
		)
		Cadeaux.fixerHorloge(function()
			return JOUR + 86400
		end)
		Cadeaux.defis(j)
		assert(j:GetAttribute("DefisReclames") == "0,0,0", "nouveau jour : nouveaux défis")
		Cadeaux.fixerHorloge(nil)
	end,

	["C3 code promo : une fois par joueur, inconnu refusé ; réglages validés"] = function()
		local Cadeaux = module("Cadeaux")
		local j = fauxJoueur({ Pieces = 0, CodesUtilises = "" })
		assert(Cadeaux.utiliserCode(j, "bienvenue"), "code valide")
		assert(j:GetAttribute("Pieces") > 0, "pièces données")
		assert(not Cadeaux.utiliserCode(j, "BIENVENUE"), "déjà utilisé")
		assert(not Cadeaux.utiliserCode(j, "TRICHE"), "inconnu")
		assert(
			Cadeaux.changerReglage(j, "Son", false) and j:GetAttribute("ReglageSon") == false,
			"son"
		)
		assert(not Cadeaux.changerReglage(j, "Pieces", 1e9), "réglage inconnu refusé")
	end,
}
