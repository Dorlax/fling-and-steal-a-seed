--!strict
-- Interface des stats : Force, Vitesse, mode actif et indicateur d'entraînement.
-- Les valeurs viennent des attributs du Player, écrits par le serveur.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InterfaceStats = {}

local COULEUR_FOND = Color3.fromRGB(30, 30, 40)
local COULEUR_ACTIF = Color3.fromRGB(214, 102, 38)
local COULEUR_INACTIF = Color3.fromRGB(70, 70, 85)

local function arrondi(element: GuiObject, rayon: number)
	local coin = Instance.new("UICorner")
	coin.CornerRadius = UDim.new(0, rayon)
	coin.Parent = element
end

local function etiquette(parent: Instance, nom: string, ordre: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = nom
	label.LayoutOrder = ordre
	label.Size = UDim2.new(1, 0, 0, 30)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function bouton(parent: Instance, mode: string): TextButton
	local b = Instance.new("TextButton")
	b.Name = "Mode" .. mode
	b.Text = mode
	b.Size = UDim2.new(0.5, -4, 1, 0)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.TextColor3 = Color3.new(1, 1, 1)
	b.BackgroundColor3 = COULEUR_INACTIF
	b.AutoButtonColor = true
	b.Selectable = true -- manette
	b.Parent = parent
	arrondi(b, 8)
	return b
end

function InterfaceStats.demarrer()
	local joueur = Players.LocalPlayer
	local remote = ReplicatedStorage:WaitForChild("ChoisirModeForge") :: RemoteEvent

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceStats"
	ecran.ResetOnSpawn = false
	ecran.IgnoreGuiInset = false

	local cadre = Instance.new("Frame")
	cadre.Name = "Cadre"
	cadre.AnchorPoint = Vector2.new(0, 0.5)
	cadre.Position = UDim2.new(0, 12, 0.5, 0)
	cadre.Size = UDim2.fromOffset(220, 170)
	cadre.BackgroundColor3 = COULEUR_FOND
	cadre.BackgroundTransparency = 0.2
	cadre.Parent = ecran
	arrondi(cadre, 12)

	local marge = Instance.new("UIPadding")
	marge.PaddingTop = UDim.new(0, 10)
	marge.PaddingBottom = UDim.new(0, 10)
	marge.PaddingLeft = UDim.new(0, 10)
	marge.PaddingRight = UDim.new(0, 10)
	marge.Parent = cadre

	local liste = Instance.new("UIListLayout")
	liste.SortOrder = Enum.SortOrder.LayoutOrder
	liste.Padding = UDim.new(0, 6)
	liste.Parent = cadre

	local labelForce = etiquette(cadre, "Force", 1)
	local labelVitesse = etiquette(cadre, "Vitesse", 2)
	local labelEntrainement = etiquette(cadre, "Entrainement", 3)
	labelEntrainement.Text = "Entraînement en cours…"
	labelEntrainement.TextColor3 = COULEUR_ACTIF

	local rangee = Instance.new("Frame")
	rangee.Name = "Modes"
	rangee.LayoutOrder = 4
	rangee.Size = UDim2.new(1, 0, 0, 44)
	rangee.BackgroundTransparency = 1
	rangee.Parent = cadre
	local disposition = Instance.new("UIListLayout")
	disposition.FillDirection = Enum.FillDirection.Horizontal
	disposition.Padding = UDim.new(0, 8)
	disposition.Parent = rangee

	local boutons = {
		Force = bouton(rangee, "Force"),
		Vitesse = bouton(rangee, "Vitesse"),
	}
	for mode, b in boutons do
		b.Activated:Connect(function()
			remote:FireServer(mode)
		end)
	end

	local function nombre(nom: string): number
		local valeur = joueur:GetAttribute(nom)
		return if type(valeur) == "number" then valeur else 0
	end

	local function rafraichir()
		labelForce.Text = `Force : {math.floor(nombre("Force"))}`
		labelVitesse.Text = `Vitesse : {math.floor(nombre("Vitesse"))}`
		labelEntrainement.Visible = joueur:GetAttribute("SurForge") == true
		local modeActif = joueur:GetAttribute("ModeForge")
		for mode, b in boutons do
			b.BackgroundColor3 = if mode == modeActif then COULEUR_ACTIF else COULEUR_INACTIF
		end
	end

	for _, nom in { "Force", "Vitesse", "ModeForge", "SurForge" } do
		joueur:GetAttributeChangedSignal(nom):Connect(rafraichir)
	end
	rafraichir()

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceStats
