--!strict
-- Interface du lancer : bouton LANCER, jauge de timing, message de résultat
-- et panneau des taux de rareté (toujours visible).
-- Le client ne calcule ni distance ni rareté : il affiche ce que le serveur renvoie.
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config")) :: any
local Jauge = require(Shared:WaitForChild("Jauge")) :: any
local Lancer = require(Shared:WaitForChild("Lancer")) :: any

local InterfaceLancer = {}

local COULEUR_FOND = Color3.fromRGB(30, 30, 40)
local COULEUR_BOUTON = Color3.fromRGB(235, 90, 40)
local COULEUR_BOUTON_ATTENTE = Color3.fromRGB(90, 90, 105)
local COULEURS_PALIERS: { [string]: Color3 } = {
	Vert = Color3.fromRGB(80, 220, 90),
	Jaune = Color3.fromRGB(255, 220, 50),
	Orange = Color3.fromRGB(255, 140, 30),
	Rouge = Color3.fromRGB(255, 50, 50),
}

local function arrondi(element: GuiObject, rayon: number)
	local coin = Instance.new("UICorner")
	coin.CornerRadius = UDim.new(0, rayon)
	coin.Parent = element
end

local function contour(element: GuiObject, epaisseur: number)
	local trait = Instance.new("UIStroke")
	trait.Thickness = epaisseur
	trait.Color = Color3.new(0, 0, 0)
	trait.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	trait.Parent = element
end

local function couleurRarete(rarete: string): Color3
	local rgb = Config.Raretes.Couleurs[rarete]
	if type(rgb) ~= "table" then
		return Color3.new(1, 1, 1)
	end
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

-- Dégradé vert -> jaune -> orange -> rouge (bas -> haut), paliers nets.
local function degradeJauge(): ColorSequence
	local points = {}
	local paliers = Config.Lancer.Jauge.Paliers
	for i, palier in paliers do
		local couleur = COULEURS_PALIERS[palier.Couleur] or Color3.new(1, 1, 1)
		local fin = if paliers[i + 1] then paliers[i + 1].Min - 0.001 else 1
		table.insert(points, ColorSequenceKeypoint.new(palier.Min, couleur))
		table.insert(points, ColorSequenceKeypoint.new(fin, couleur))
	end
	return ColorSequence.new(points)
end

local function creerPanneauTaux(ecran: ScreenGui)
	local cadre = Instance.new("Frame")
	cadre.Name = "TauxRarete"
	cadre.AnchorPoint = Vector2.new(0.5, 0)
	cadre.Position = UDim2.new(0.5, 0, 0, 8)
	cadre.Size = UDim2.new(0.6, 0, 0, 0)
	cadre.AutomaticSize = Enum.AutomaticSize.Y
	cadre.BackgroundColor3 = COULEUR_FOND
	cadre.BackgroundTransparency = 0.25
	cadre.Parent = ecran
	arrondi(cadre, 10)

	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MinSize = Vector2.new(300, 0)
	contrainte.MaxSize = Vector2.new(640, math.huge)
	contrainte.Parent = cadre

	local marge = Instance.new("UIPadding")
	marge.PaddingTop = UDim.new(0, 6)
	marge.PaddingBottom = UDim.new(0, 6)
	marge.PaddingLeft = UDim.new(0, 10)
	marge.PaddingRight = UDim.new(0, 10)
	marge.Parent = cadre

	local liste = Instance.new("UIListLayout")
	liste.SortOrder = Enum.SortOrder.LayoutOrder
	liste.Padding = UDim.new(0, 2)
	liste.Parent = cadre

	local titre = Instance.new("TextButton")
	titre.Name = "Titre"
	titre.LayoutOrder = 0
	titre.Size = UDim2.new(1, 0, 0, 24)
	titre.BackgroundTransparency = 1
	titre.Font = Enum.Font.GothamBlack
	titre.TextScaled = true
	titre.TextColor3 = Color3.new(1, 1, 1)
	titre.Text = "Taux de rareté ▲"
	titre.Selectable = true
	titre.Parent = cadre

	local lignes: { TextLabel } = {}
	for i, zone in Config.Lancer.Zones do
		local ligne = Instance.new("TextLabel")
		ligne.Name = "Taux" .. zone.Nom
		ligne.LayoutOrder = i
		ligne.Size = UDim2.new(1, 0, 0, 18)
		ligne.BackgroundTransparency = 1
		ligne.Font = Enum.Font.GothamBold
		ligne.TextScaled = true
		ligne.TextColor3 = Color3.fromRGB(230, 230, 230)
		ligne.Text = Lancer.texteTaux(zone.Nom)
		ligne.Parent = cadre
		table.insert(lignes, ligne)
	end

	local ouvert = true
	titre.Activated:Connect(function()
		ouvert = not ouvert
		titre.Text = if ouvert then "Taux de rareté ▲" else "Taux de rareté ▼"
		for _, ligne in lignes do
			ligne.Visible = ouvert
		end
	end)
end

function InterfaceLancer.demarrer()
	local joueur = Players.LocalPlayer
	local demarrerJauge = ReplicatedStorage:WaitForChild("DemarrerJauge") :: RemoteEvent
	local lacherJauge = ReplicatedStorage:WaitForChild("LacherJauge") :: RemoteEvent
	local resultatLancer = ReplicatedStorage:WaitForChild("ResultatLancer") :: RemoteEvent

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceLancer"
	ecran.ResetOnSpawn = false

	-- Bouton LANCER (souris et toucher via Activated).
	local bouton = Instance.new("TextButton")
	bouton.Name = "Lancer"
	bouton.AnchorPoint = Vector2.new(1, 1)
	bouton.Position = UDim2.new(1, -20, 1, -20)
	bouton.Size = UDim2.fromOffset(170, 80)
	bouton.BackgroundColor3 = COULEUR_BOUTON
	bouton.Font = Enum.Font.GothamBlack
	bouton.TextScaled = true
	bouton.TextColor3 = Color3.new(1, 1, 1)
	bouton.Text = "LANCER"
	bouton.Selectable = true
	bouton.Parent = ecran
	arrondi(bouton, 14)
	contour(bouton, 3)

	-- Jauge verticale, au-dessus du bouton.
	local jauge = Instance.new("Frame")
	jauge.Name = "Jauge"
	jauge.AnchorPoint = Vector2.new(1, 1)
	jauge.Position = UDim2.new(1, -85, 1, -115)
	jauge.Size = UDim2.fromOffset(44, 260)
	jauge.BackgroundColor3 = Color3.new(1, 1, 1)
	jauge.Visible = false
	jauge.Parent = ecran
	arrondi(jauge, 10)
	contour(jauge, 3)
	local degrade = Instance.new("UIGradient")
	degrade.Color = degradeJauge()
	degrade.Rotation = -90 -- 0 en bas, 1 en haut
	degrade.Parent = jauge

	local curseur = Instance.new("Frame")
	curseur.Name = "Curseur"
	curseur.AnchorPoint = Vector2.new(0.5, 0.5)
	curseur.Position = UDim2.fromScale(0.5, 1)
	curseur.Size = UDim2.new(1, 16, 0, 6)
	curseur.BackgroundColor3 = Color3.new(1, 1, 1)
	curseur.ZIndex = 2
	curseur.Parent = jauge
	contour(curseur, 2)

	-- Message de résultat.
	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.AnchorPoint = Vector2.new(0.5, 0.5)
	message.Position = UDim2.fromScale(0.5, 0.32)
	message.Size = UDim2.fromOffset(520, 90)
	message.BackgroundTransparency = 1
	message.Font = Enum.Font.FredokaOne
	message.TextScaled = true
	message.Visible = false
	message.Parent = ecran
	local traitMessage = Instance.new("UIStroke")
	traitMessage.Thickness = 4
	traitMessage.Color = Color3.new(0, 0, 0)
	traitMessage.Parent = message
	local echelle = Instance.new("UIScale")
	echelle.Parent = message

	creerPanneauTaux(ecran)

	-- État local (affichage seulement : le serveur valide tout).
	local enCours = false
	local debutLocal = 0
	local attenteJusqua = 0
	local animation: RBXScriptConnection? = nil
	local numeroMessage = 0

	local function cacherJauge()
		enCours = false
		jauge.Visible = false
		if animation then
			animation:Disconnect()
			animation = nil
		end
	end

	local function rafraichirBouton()
		local enAttente = os.clock() < attenteJusqua
		bouton.BackgroundColor3 = if enAttente then COULEUR_BOUTON_ATTENTE else COULEUR_BOUTON
		bouton.Text = if enCours then "LÂCHER !" else "LANCER"
	end

	local function actionner()
		if enCours then
			lacherJauge:FireServer()
			cacherJauge()
			attenteJusqua = os.clock() + Config.Lancer.DelaiEntreLancers
		else
			if os.clock() < attenteJusqua then
				return
			end
			demarrerJauge:FireServer()
			enCours = true
			debutLocal = os.clock()
			jauge.Visible = true
			animation = RunService.RenderStepped:Connect(function()
				local ecoule = os.clock() - debutLocal
				if ecoule > Config.Lancer.DureeMaxJauge then
					cacherJauge() -- annulée côté serveur aussi
					rafraichirBouton()
					return
				end
				curseur.Position = UDim2.fromScale(0.5, 1 - Jauge.position(ecoule))
			end)
		end
		rafraichirBouton()
		task.delay(Config.Lancer.DelaiEntreLancers, rafraichirBouton)
	end

	bouton.Activated:Connect(actionner)
	-- Manette (R2) et clavier (F) : même action que le bouton.
	ContextActionService:BindAction("LancerGraine", function(_, etat: Enum.UserInputState)
		if etat == Enum.UserInputState.Begin then
			actionner()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.ButtonR2, Enum.KeyCode.F)

	local function afficher(texte: string, couleur: Color3, taille: number)
		message.Text = texte
		message.TextColor3 = couleur
		message.Visible = true
		echelle.Scale = 0.3
		TweenService:Create(
			echelle,
			TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = taille }
		):Play()
	end

	resultatLancer.OnClientEvent:Connect(function(resultat: any)
		if type(resultat) ~= "table" then
			return
		end
		local distance = resultat.Distance
		local rarete = resultat.Rarete
		if type(distance) ~= "number" or type(rarete) ~= "string" then
			return
		end
		numeroMessage += 1
		local numero = numeroMessage
		local couleurPalier = COULEURS_PALIERS[resultat.Couleur] or Color3.new(1, 1, 1)
		local rangRarete = table.find(Config.Raretes.Ordre, rarete) or 1
		local genereux = rangRarete >= 3 -- Épique et au-dessus

		local tailleMessage = if resultat.Couleur == "Rouge" then 1.25 else 1
		afficher(tostring(resultat.Message or ""), couleurPalier, tailleMessage)
		task.wait(1)
		if numero ~= numeroMessage then
			return
		end
		local nom = Config.Raretes.Noms[rarete] or rarete
		afficher(
			`+{math.floor(distance)} m · {nom}`,
			couleurRarete(rarete),
			if genereux then 1.4 else 1
		)
		if genereux then
			-- Effet plus généreux : pulsations de la taille.
			for _ = 1, 3 do
				task.wait(0.25)
				if numero ~= numeroMessage then
					return
				end
				TweenService:Create(echelle, TweenInfo.new(0.12), { Scale = 1.6 }):Play()
				task.wait(0.12)
				TweenService:Create(echelle, TweenInfo.new(0.12), { Scale = 1.4 }):Play()
			end
		end
		task.wait(if genereux then 2 else 1.5)
		if numero == numeroMessage then
			message.Visible = false
		end
	end)

	rafraichirBouton()
	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceLancer
