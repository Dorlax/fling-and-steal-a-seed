--!strict
-- Raids côté client (affichage seulement, le serveur revérifie tout) :
-- cache les prompts inutiles, alerte « VOLÉ ! » et compteur du verrou.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local InterfaceRaid = {}

local raretes: any = Config.Raretes
local ROUGE = Color3.fromRGB(255, 60, 60)
local VERT = Color3.fromRGB(120, 255, 90)
local JAUNE = Color3.fromRGB(255, 220, 60)

local function contour(element: GuiObject, epaisseur: number)
	local trait = Instance.new("UIStroke")
	trait.Thickness = epaisseur
	trait.Color = Color3.new(0, 0, 0)
	trait.Parent = element
end

local function texte(parent: Instance, nom: string, couleur: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = nom
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = couleur
	label.Parent = parent
	return label
end

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

	-- Alerte « VOLÉ ! » : gros titre rebondissant + sous-titre.
	local titre = texte(ecran, "Titre", ROUGE)
	titre.AnchorPoint = Vector2.new(0.5, 0.5)
	titre.Position = UDim2.fromScale(0.5, 0.3)
	titre.Size = UDim2.fromOffset(420, 110)
	titre.Visible = false
	contour(titre, 6)

	local sousTitre = texte(ecran, "SousTitre", Color3.new(1, 1, 1))
	sousTitre.AnchorPoint = Vector2.new(0.5, 0.5)
	sousTitre.Position = UDim2.new(0.5, 0, 0.3, 70)
	sousTitre.Size = UDim2.fromOffset(560, 40)
	sousTitre.Visible = false
	contour(sousTitre, 3)

	-- Compteur du verrou (propriétaire).
	local compteur = texte(ecran, "CompteurVerrou", ROUGE)
	compteur.AnchorPoint = Vector2.new(1, 0)
	compteur.Position = UDim2.new(1, -16, 0, 16)
	compteur.Size = UDim2.fromOffset(200, 44)
	compteur.Visible = false
	contour(compteur, 3)

	local alerte = ReplicatedStorage:WaitForChild("AlerteVol") :: RemoteEvent
	local numero = 0
	alerte.OnClientEvent:Connect(function(role: any, rarete: any, autre: any)
		if type(role) ~= "string" or type(rarete) ~= "string" or type(autre) ~= "string" then
			return
		end
		local nomRarete = raretes.Noms[rarete] or rarete
		numero += 1
		local actuel = numero
		titre.Text = "VOLÉ !"
		if role == "victime" then
			titre.TextColor3 = ROUGE
			sousTitre.TextColor3 = Color3.new(1, 1, 1)
			sousTitre.Text = string.sub(`{autre} a pris ta créature {nomRarete} !`, 1, 100)
		else
			titre.TextColor3 = VERT
			sousTitre.TextColor3 = JAUNE
			sousTitre.Text = "Ramène-la dans ta base !"
		end
		titre.Visible = true
		sousTitre.Visible = true
		titre.Size = UDim2.fromOffset(60, 16)
		titre.Rotation = -12
		TweenService:Create(
			titre,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = UDim2.fromOffset(420, 110), Rotation = 4 }
		):Play()
		task.delay(Config.Raid.DureeAlerte, function()
			if actuel == numero then
				titre.Visible = false
				sousTitre.Visible = false
			end
		end)
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
			elseif pretA and maintenant < pretA then
				compteur.Visible = true
				compteur.TextColor3 = JAUNE
				compteur.Text = "Prêt dans " .. math.ceil(pretA - maintenant) .. " s"
			else
				compteur.Visible = false
			end
			task.wait(0.25)
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceRaid
