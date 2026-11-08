local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Forge = require(ReplicatedStorage.Shared.Forge)

-- Hypothèses sur l'API serveur (à ajuster avec le Bâtisseur si les noms diffèrent) :
--   Server.Bases.creer(joueur) -> Model/Folder de la base ; Server.Bases.liberer(joueur)
--   Server.Entrainement.traiterChoixMode(joueur, valeur)
--   Server.Entrainement.tick(joueur)            (un tick d'entraînement)
--   Server.Entrainement.appliquerVitesse(joueur) -> WalkSpeed appliqué
local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

-- Faux joueur : table avec attributs, suffisante pour la logique serveur testée.
local function fauxJoueur(): any
	local attributs: { [string]: any } =
		{ Force = 0, Vitesse = 0, ModeForge = "Force", SurForge = false }
	return {
		Name = "FauxJoueurTest",
		UserId = -1,
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
	["C9 RemoteEvent ChoisirModeForge présent dans ReplicatedStorage"] = function()
		local remote = ReplicatedStorage:WaitForChild("ChoisirModeForge", 5)
		assert(remote, "ChoisirModeForge introuvable")
		assert(remote:IsA("RemoteEvent"), "ChoisirModeForge doit être un RemoteEvent")
	end,

	["C10 création et libération d'une base avec Forge ancrée"] = function()
		local Bases = module("Bases")
		local joueur = fauxJoueur()
		Bases.creer(joueur)
		local forge = Workspace:FindFirstChild("Forge", true)
		assert(forge and forge:IsA("BasePart"), "Part Forge introuvable dans le Workspace")
		assert(forge.Anchored, "la Forge doit être ancrée")
		Bases.liberer(joueur)
		assert(Workspace:FindFirstChild("Forge", true) == nil, "la base doit être supprimée")
	end,

	["C11 traiterChoixMode accepte Vitesse et rejette le reste"] = function()
		local Entrainement = module("Entrainement")
		local joueur = fauxJoueur()
		Entrainement.traiterChoixMode(joueur, "Vitesse")
		assert(joueur:GetAttribute("ModeForge") == "Vitesse", "Vitesse doit être accepté")
		for _, valeur in { "Triche", 123 } do
			local ok = pcall(Entrainement.traiterChoixMode, joueur, valeur)
			assert(ok, "erreur pour " .. tostring(valeur))
			assert(
				joueur:GetAttribute("ModeForge") == "Vitesse",
				"mode changé par " .. tostring(valeur)
			)
		end
		local ok = pcall(Entrainement.traiterChoixMode, joueur, nil)
		assert(ok, "erreur pour nil")
		assert(joueur:GetAttribute("ModeForge") == "Vitesse", "mode changé par nil")
	end,

	["C12 un tick augmente la stat seulement sur la Forge"] = function()
		local Entrainement = module("Entrainement")
		local joueur = fauxJoueur()
		joueur:SetAttribute("SurForge", true)
		Entrainement.tick(joueur)
		assert(joueur:GetAttribute("Force") > 0, "Force doit monter sur la Forge")
		local avant = joueur:GetAttribute("Force")
		joueur:SetAttribute("SurForge", false)
		Entrainement.tick(joueur)
		assert(joueur:GetAttribute("Force") == avant, "rien ne doit monter hors Forge")
	end,

	["C13 le WalkSpeed appliqué suit la Vitesse"] = function()
		local Entrainement = module("Entrainement")
		local joueur = fauxJoueur()
		joueur:SetAttribute("Vitesse", 250)
		local walkSpeed = Entrainement.appliquerVitesse(joueur)
		assert(
			walkSpeed == Forge.walkSpeedPour(250),
			"WalkSpeed incorrect : " .. tostring(walkSpeed)
		)
	end,
}
