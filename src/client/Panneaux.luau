--!strict
-- Restylage LOCAL des affichages créés par le serveur :
--  - panneaux « Panneau » des créatures et des monstres (couleur, taille, police) ;
--  - « BOUM ! » serveur de l'effet de plaquage caché (un seul « BOUM ! » à l'écran) ;
--  - prompts « Recolter », « Voler », « Verrouiller » en gros boutons cartoon.
-- Ne détruit rien, ne change aucun attribut : seules des propriétés d'affichage
-- locales sont modifiées. Le serveur garde toute la validation.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Style = require(Shared:WaitForChild("Style"))
local Revenus = require(Shared:WaitForChild("Revenus"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local Panneaux = {}

local AGRANDISSEMENT = 1.6 -- au moins 1,5 × la taille actuelle
local ESSAIS = 5 -- tentatives (attributs ou texte pas encore répliqués)

-- Couleur du gros bouton de chaque prompt personnalisé.
local PROMPTS: { [string]: string } = {
	Recolter = "Jaune",
	Voler = "Rouge",
	Verrouiller = "Violet",
}

local restyles: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any

-- « BOUM ! » du serveur : caché localement, les étoiles restent.
local function cacherBoum(objet: Instance)
	if objet:IsA("TextLabel") and objet.Name == "Boum" then
		local parent = objet.Parent
		if parent and parent.Name == "EffetPlaquage" then
			objet.Visible = false
		end
	elseif objet:IsA("BillboardGui") and objet.Name == "EffetPlaquage" then
		local boum = objet:FindFirstChild("Boum")
		if boum and boum:IsA("TextLabel") then
			boum.Visible = false
		end
	end
end

type Genre = { couleur: { number }, texte: string }

-- Que montre ce panneau ? Créature (Rarete), fausse graine (déguisée en
-- créature légendaire, pour ne pas la trahir) ou monstre (Monstre = true).
local function genreDe(panneau: BillboardGui, label: TextLabel): Genre?
	local courant = panneau.Parent
	while courant ~= nil and courant ~= Workspace do
		if courant:IsA("Model") then
			local rarete = courant:GetAttribute("Rarete")
			if type(rarete) == "string" then
				local nom = Style.texteRarete(rarete)
				if courant:GetAttribute("Emplacement") ~= nil then
					-- Exposée en base : rareté + revenu actuel.
					nom ..= `\n+{Revenus.parSeconde(rarete)}/s`
				end
				return { couleur = Style.couleurRarete(rarete), texte = nom }
			end
			if courant:GetAttribute("Type") == "FausseGraine" then
				return { couleur = Style.couleurRarete("Legendaire"), texte = label.Text }
			end
			if courant:GetAttribute("Monstre") == true then
				local zone = courant:GetAttribute("Zone")
				return {
					couleur = Style.couleurZone(if type(zone) == "string" then zone else ""),
					texte = label.Text,
				}
			end
		end
		courant = courant.Parent
	end
	return nil
end

local function restyler(panneau: BillboardGui, essai: number)
	if restyles[panneau] or panneau.Parent == nil then
		return
	end
	local label = panneau:FindFirstChildWhichIsA("TextLabel")
	local genre = if label then genreDe(panneau, label) else nil
	if label == nil or genre == nil then
		if essai < ESSAIS then
			task.delay(0.3, restyler, panneau, essai + 1)
		end
		return
	end
	restyles[panneau] = true

	local taille = panneau.Size
	panneau.Size = UDim2.new(
		taille.X.Scale * AGRANDISSEMENT,
		taille.X.Offset * AGRANDISSEMENT,
		taille.Y.Scale * AGRANDISSEMENT,
		taille.Y.Offset * AGRANDISSEMENT
	)
	panneau.LightInfluence = 0

	-- Fond arrondi semi-opaque derrière le texte.
	local fond = Instance.new("Frame")
	fond.Name = "Fond"
	fond.Size = UDim2.fromScale(1, 1)
	fond.BackgroundColor3 = Habillage.couleur(genre.couleur)
	fond.BackgroundTransparency = 0.25
	fond.ZIndex = 0
	Habillage.arrondi(fond, 0.4)
	Habillage.contour(fond, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)
	fond.Parent = panneau

	local l = label :: TextLabel
	l.ZIndex = 2
	l.Size = UDim2.new(1, -12, 1, -6)
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = UDim2.fromScale(0.5, 0.5)
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Font = Habillage.Police
	l.TextStrokeTransparency = 1
	l.Text = genre.texte
	Habillage.contour(l, Style.Contour.Moyen, Enum.ApplyStrokeMode.Contextual)
end

local function examiner(objet: Instance)
	if objet:IsA("BillboardGui") and objet.Name == "Panneau" then
		task.defer(restyler, objet, 1)
	end
	cacherBoum(objet)
end

-- Prompt personnalisé : Style passé à Custom localement (le serveur ne change pas).
local function personnaliser(objet: Instance)
	if objet:IsA("ProximityPrompt") and PROMPTS[objet.Name] then
		objet.Style = Enum.ProximityPromptStyle.Custom
	end
end

local function nomTouche(prompt: ProximityPrompt, entree: Enum.ProximityPromptInputType): string?
	if entree == Enum.ProximityPromptInputType.Keyboard then
		return prompt.KeyboardKeyCode.Name
	elseif entree == Enum.ProximityPromptInputType.Gamepad then
		return (string.gsub(prompt.GamepadKeyCode.Name, "^Button", ""))
	end
	return nil
end

local function montrerPrompt(
	prompt: ProximityPrompt,
	entree: Enum.ProximityPromptInputType,
	interface: Instance
): () -> ()
	local support = prompt.Parent
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Prompt" .. prompt.Name
	billboard.Adornee = if support and support:IsA("BasePart") then support else nil
	billboard.AlwaysOnTop = true
	billboard.Active = true
	billboard.LightInfluence = 0
	billboard.Size = UDim2.fromOffset(200, Style.TailleBoutonMin + 30)
	billboard.StudsOffset = Vector3.new(0, 1.5, 0)
	billboard.ResetOnSpawn = false

	local touche = nomTouche(prompt, entree)
	local libelle = prompt.ActionText
	if touche then
		libelle = `[{touche}] {libelle}`
	end
	local bouton, texte = Habillage.bouton(billboard, "Bouton", {
		couleur = Habillage.nommee(PROMPTS[prompt.Name] or "Bleu"),
		taille = Vector2.new(200, Style.TailleBoutonMin),
	})
	texte.Size = UDim2.new(1, -16, 0.62, 0)
	texte.Position = UDim2.fromScale(0.5, 0.36)
	texte.Text = libelle
	local objetTexte = Habillage.texte(bouton, "Objet", { contour = Style.Contour.Petit })
	objetTexte.AnchorPoint = Vector2.new(0.5, 1)
	objetTexte.Position = UDim2.new(0.5, 0, 1, -4)
	objetTexte.Size = UDim2.new(1, -16, 0.3, 0)
	objetTexte.Text = prompt.ObjectText

	local jauge = Habillage.jauge(billboard, "Maintien", UDim2.new(1, -20, 0, 18))
	jauge.cadre.AnchorPoint = Vector2.new(0.5, 1)
	jauge.cadre.Position = UDim2.new(0.5, 0, 1, 0)

	-- Tactile et souris : maintien sur le gros bouton.
	bouton.InputBegan:Connect(function(input: InputObject)
		local t = input.UserInputType
		if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
			prompt:InputHoldBegin()
		end
	end)
	bouton.InputEnded:Connect(function(input: InputObject)
		local t = input.UserInputType
		if t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1 then
			prompt:InputHoldEnd()
		end
	end)

	-- Jauge de maintien (HoldDuration) en dégradé.
	local debutMaintien: number? = nil
	local connexions: { RBXScriptConnection } = {}
	table.insert(
		connexions,
		prompt.PromptButtonHoldBegan:Connect(function()
			debutMaintien = os.clock()
		end)
	)
	table.insert(
		connexions,
		prompt.PromptButtonHoldEnded:Connect(function()
			debutMaintien = nil
			jauge.maj(0)
		end)
	)
	table.insert(
		connexions,
		RunService.RenderStepped:Connect(function()
			local debut = debutMaintien
			if debut ~= nil and prompt.HoldDuration > 0 then
				jauge.maj((os.clock() - debut) / prompt.HoldDuration)
			end
		end)
	)

	billboard.Parent = interface
	return function()
		for _, c in connexions do
			c:Disconnect()
		end
		billboard:Destroy()
	end
end

local function surveillerPrompts(interface: Instance)
	local fermer: { [ProximityPrompt]: () -> () } = {}
	ProximityPromptService.PromptShown:Connect(function(prompt: ProximityPrompt, entree)
		if PROMPTS[prompt.Name] == nil then
			return
		end
		personnaliser(prompt)
		local precedent = fermer[prompt]
		if precedent then
			precedent()
		end
		local fin = montrerPrompt(prompt, entree, interface)
		fermer[prompt] = fin
		prompt.PromptHidden:Once(function()
			if fermer[prompt] == fin then
				fermer[prompt] = nil
				fin()
			end
		end)
	end)
end

function Panneaux.demarrer()
	local joueur = Players.LocalPlayer
	local interface = joueur:WaitForChild("PlayerGui")

	Workspace.DescendantAdded:Connect(function(objet)
		examiner(objet)
		personnaliser(objet)
	end)
	for _, objet in Workspace:GetDescendants() do
		examiner(objet)
		personnaliser(objet)
	end
	surveillerPrompts(interface)
end

return Panneaux
