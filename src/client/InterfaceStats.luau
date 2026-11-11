--!strict
-- Interface des stats : Force et Vitesse en permanence (petit encart) ; les
-- boutons de la Forge (modes, amélioration) n'apparaissent que sur sa Forge.
-- Les valeurs viennent des attributs du Player, écrits par le serveur.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Style = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Style"))
local Forge = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Forge"))
local Nombres = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Nombres"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfaceStats = {}

local COULEUR_INACTIF = Habillage.nommee("Gris")
-- Couleurs franches des boutons de la Forge.
local COULEURS_MODES: { [string]: Color3 } = {
	Force = Habillage.nommee("Rouge"),
	Vitesse = Habillage.nommee("Bleu"),
	Double = Color3.fromRGB(170, 90, 230),
}
local LARGEUR = 2 * Style.TailleBoutonMin + 8

local function etiquette(parent: Instance, nom: string, ordre: number): TextLabel
	local label = Habillage.texte(parent, nom)
	label.LayoutOrder = ordre
	label.Size = UDim2.new(1, 0, 0, 24)
	label.TextXAlignment = Enum.TextXAlignment.Left
	return label
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
	cadre.Position = UDim2.new(0, 12, 0.42, 0)
	cadre.Size = UDim2.fromOffset(LARGEUR + 20, 0)
	cadre.AutomaticSize = Enum.AutomaticSize.Y
	cadre.BackgroundColor3 = Habillage.nommee("Fond")
	cadre.BackgroundTransparency = 0.2
	cadre.Parent = ecran
	Habillage.panneau(cadre, Habillage.nommee("Bleu"))

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
	labelForce.TextColor3 = COULEURS_MODES.Force
	local labelVitesse = etiquette(cadre, "Vitesse", 2)
	labelVitesse.TextColor3 = COULEURS_MODES.Vitesse

	local rangee = Instance.new("Frame")
	rangee.Name = "Modes"
	rangee.LayoutOrder = 4
	rangee.Size = UDim2.new(1, 0, 0, Style.TailleBoutonMin)
	rangee.BackgroundTransparency = 1
	rangee.Parent = cadre
	local disposition = Instance.new("UIListLayout")
	disposition.FillDirection = Enum.FillDirection.Horizontal
	disposition.SortOrder = Enum.SortOrder.LayoutOrder
	disposition.Padding = UDim.new(0, 8)
	disposition.Parent = rangee

	local boutons: { [string]: TextButton } = {}
	for ordre, mode in { "Force", "Vitesse" } do
		local b = Habillage.bouton(rangee, "Mode" .. mode, {
			texte = mode,
			couleur = COULEURS_MODES[mode],
		})
		b.LayoutOrder = ordre
		b.Activated:Connect(function()
			remote:FireServer(mode)
		end)
		boutons[mode] = b
	end

	-- Mode Double (Force et Vitesse à la fois), visible à partir du niveau requis.
	local boutonDouble = Habillage.bouton(cadre, "ModeDouble", {
		texte = "Double",
		couleur = COULEURS_MODES.Double,
	})
	boutonDouble.LayoutOrder = 5
	boutonDouble.Size = UDim2.new(1, 0, 0, Style.TailleBoutonMin)
	boutonDouble.Activated:Connect(function()
		remote:FireServer("Double")
	end)
	boutons.Double = boutonDouble

	-- Achat du niveau de Forge suivant (vérifié par le serveur).
	local ameliorer = ReplicatedStorage:WaitForChild("AmeliorerForge") :: RemoteEvent
	local boutonNiveau, texteNiveau = Habillage.bouton(cadre, "AmeliorerForge", {
		texte = "Forge niv. 1",
		couleur = Color3.fromRGB(255, 170, 40),
	})
	boutonNiveau.LayoutOrder = 6
	boutonNiveau.Size = UDim2.new(1, 0, 0, Style.TailleBoutonMin)
	boutonNiveau.Activated:Connect(function()
		ameliorer:FireServer()
	end)

	local function nombre(nom: string): number
		local valeur = joueur:GetAttribute(nom)
		return if type(valeur) == "number" then valeur else 0
	end

	local function rafraichir()
		labelForce.Text = `💪 {Nombres.abreger(nombre("Force"))}`
		labelVitesse.Text = `⚡ {Nombres.abreger(nombre("Vitesse"))}`
		local niveau = math.max(1, math.floor(nombre("NiveauForge")))
		local cout = Forge.coutNiveau(niveau)
		local suivant = Forge.agres("Vitesse", niveau + 1) ~= Forge.agres("Vitesse", niveau)
		local gain = Nombres.abreger(Forge.gainPour(niveau + 1))
		local etoile = if suivant then " ✨" else ""
		texteNiveau.Text = `⬆ Forge +{gain}/s{etoile}\n{Nombres.abreger(cout)} 💰`
		boutonNiveau.BackgroundColor3 = if nombre("Pieces") >= cout
			then Color3.fromRGB(255, 170, 40)
			else COULEUR_INACTIF
		-- Boutons de la Forge : seulement quand on est dessus.
		local surForge = joueur:GetAttribute("SurForge") == true
		rangee.Visible = surForge
		boutonNiveau.Visible = surForge
		boutonDouble.Visible = surForge
			and Forge.modePermis("Double", joueur:GetAttribute("NiveauForge"))
		local modeActif = joueur:GetAttribute("ModeForge")
		for mode, b in boutons do
			b.BackgroundColor3 = if mode == modeActif then COULEURS_MODES[mode] else COULEUR_INACTIF
		end
	end

	for _, nom in
		{
			"Force",
			"Vitesse",
			"ModeForge",
			"SurForge",
			"NiveauForge",
			"Pieces",
		}
	do
		joueur:GetAttributeChangedSignal(nom):Connect(rafraichir)
	end
	rafraichir()

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceStats
