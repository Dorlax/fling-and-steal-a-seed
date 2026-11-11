--!strict
-- Raids côté client (affichage seulement, le serveur revérifie tout) :
-- cache « Voler » sur ses propres créatures et affiche l'alerte « VOLÉ ! ».
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Style = require(Shared:WaitForChild("Style"))
local Bandeaux = require(script.Parent:WaitForChild("Bandeaux"))

local InterfaceRaid = {}

-- Base (enfant direct de Workspace.Bases) contenant `objet`, ou nil.
local function baseDe(objet: Instance, dossier: Instance): Instance?
	local courant: Instance? = objet
	while courant ~= nil and courant.Parent ~= dossier do
		courant = courant.Parent
	end
	return courant
end

-- « Voler » caché sur ses propres créatures.
local function ajusterPrompt(objet: Instance, dossier: Instance, joueur: Player)
	if not objet:IsA("ProximityPrompt") then
		return
	end
	local prompt = objet :: ProximityPrompt
	if prompt.Name ~= "Voler" then
		return
	end
	local base = baseDe(prompt, dossier)
	if base == nil then
		return
	end
	local estMaBase = (base :: Instance):GetAttribute("ProprietaireId") == joueur.UserId
	prompt.Enabled = not estMaBase
end

local function surveillerPrompts(joueur: Player)
	task.spawn(function()
		local dossier = Workspace:WaitForChild("Bases")
		dossier.DescendantAdded:Connect(function(objet)
			ajusterPrompt(objet, dossier, joueur)
		end)
		for _, objet in dossier:GetDescendants() do
			ajusterPrompt(objet, dossier, joueur)
		end
	end)
end

function InterfaceRaid.demarrer()
	local joueur = Players.LocalPlayer
	surveillerPrompts(joueur)

	-- Alerte « VOLÉ ! » : passe par le bandeau unique (deux lignes).
	local alerte = ReplicatedStorage:WaitForChild("AlerteVol") :: RemoteEvent
	alerte.OnClientEvent:Connect(function(role: any, rarete: any, autre: any)
		if type(role) ~= "string" or type(rarete) ~= "string" or type(autre) ~= "string" then
			return
		end
		local phrase = if role == "victime"
			then `{autre} a pris ta créature {Style.texteRarete(rarete)} !`
			else "Ramène-la dans ta base !"
		Bandeaux.afficher("VOLÉ !\n" .. phrase)
	end)
end

return InterfaceRaid
