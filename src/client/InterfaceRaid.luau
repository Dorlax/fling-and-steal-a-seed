--!strict
-- Raids côté client (affichage seulement, le serveur revérifie tout) :
-- cache les prompts inutiles, alerte « VOLÉ ! » (bandeau) et compteur du verrou
-- avec sa jauge.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Style = require(Shared:WaitForChild("Style"))
local Bandeaux = require(script.Parent:WaitForChild("Bandeaux"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfaceRaid = {}

local ROUGE = Habillage.nommee("Rouge")
local JAUNE = Habillage.nommee("Jaune")

-- Base (enfant direct de Workspace.Bases) contenant `objet`, ou nil.
local function baseDe(objet: Instance, dossier: Instance): Instance?
	local courant: Instance? = objet
	while courant ~= nil and courant.Parent ~= dossier do
		courant = courant.Parent
	end
	return courant
end

-- « Voler » caché sur ses propres créatures, « Verrouiller » caché ailleurs.
local function ajusterPrompt(objet: Instance, dossier: Instance, joueur: Player)
	if not objet:IsA("ProximityPrompt") then
		return
	end
	local prompt = objet :: ProximityPrompt
	if prompt.Name ~= "Voler" and prompt.Name ~= "Verrouiller" then
		return
	end
	local base = baseDe(prompt, dossier)
	if base == nil then
		return
	end
	local estMaBase = (base :: Instance):GetAttribute("ProprietaireId") == joueur.UserId
	if prompt.Name == "Voler" then
		prompt.Enabled = not estMaBase
	else
		prompt.Enabled = estMaBase
	end
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

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceRaid"
	ecran.ResetOnSpawn = false

	-- Compteur du verrou (propriétaire) + jauge en dégradé.
	local compteur = Habillage.texte(ecran, "CompteurVerrou", { couleur = ROUGE })
	compteur.AnchorPoint = Vector2.new(1, 0)
	compteur.Position = UDim2.new(1, -16, 0, 16)
	compteur.Size = UDim2.fromOffset(200, 44)
	compteur.Visible = false
	local jauge = Habillage.jauge(ecran, "JaugeVerrou", UDim2.fromOffset(180, 16))
	jauge.cadre.AnchorPoint = Vector2.new(1, 0)
	jauge.cadre.Position = UDim2.new(1, -26, 0, 66)

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

	local function nombre(nom: string): number?
		local valeur = joueur:GetAttribute(nom)
		if type(valeur) == "number" and valeur == valeur then
			return valeur
		end
		return nil
	end

	task.spawn(function()
		while true do
			local maintenant = Workspace:GetServerTimeNow()
			local jusqua = nombre("VerrouJusqua")
			local pretA = nombre("VerrouPretA")
			if jusqua and maintenant < jusqua then
				compteur.Visible = true
				compteur.TextColor3 = ROUGE
				compteur.Text = "🔒 " .. math.ceil(jusqua - maintenant) .. " s"
				jauge.maj(Style.ratioRecharge(maintenant, jusqua, Config.Raid.DureeVerrou))
			elseif pretA and maintenant < pretA then
				compteur.Visible = true
				compteur.TextColor3 = JAUNE
				compteur.Text = "Prêt dans " .. math.ceil(pretA - maintenant) .. " s"
				jauge.maj(Style.ratioRecharge(maintenant, pretA, Config.Raid.Recharge))
			else
				compteur.Visible = false
				jauge.maj(0)
			end
			task.wait(0.25)
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceRaid
