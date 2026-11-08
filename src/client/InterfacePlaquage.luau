--!strict
-- Gros bouton rond « PLAQUER ! » (bas à droite) + touche clavier et manette.
-- Le client envoie seulement Plaquer:FireServer() sans argument : la cible,
-- la portée et les délais sont décidés par le serveur. L'affichage du délai
-- vient de l'attribut PlaquagePretA écrit par le serveur.
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Plaquage = require(Shared:WaitForChild("Plaquage"))

local InterfacePlaquage = {}

local COULEUR_PRET = Color3.fromRGB(255, 120, 40)
local COULEUR_ATTENTE = Color3.fromRGB(130, 130, 130)
local TAILLE = 120 -- pixels : assez grand pour le tactile
local MARGE_PORTEE = 2 -- studs : tolérance de l'aide côté client (le serveur tranche)

-- Noms d'Enum.KeyCode venant de Config (« F », « ButtonY »).
local function codeTouche(nom: string): Enum.KeyCode
	return (Enum.KeyCode :: any)[nom] :: Enum.KeyCode
end

local function racineDe(joueur: Player): BasePart?
	local personnage = joueur.Character
	if personnage == nil then
		return nil
	end
	local racine = (personnage :: Model):FindFirstChild("HumanoidRootPart")
	if racine and racine:IsA("BasePart") then
		return racine
	end
	return nil
end

function InterfacePlaquage.demarrer()
	local joueur = Players.LocalPlayer
	local remote = ReplicatedStorage:WaitForChild("Plaquer") :: RemoteEvent

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfacePlaquage"
	ecran.ResetOnSpawn = false

	-- À gauche du bouton LANCER (bas à droite de l'écran).
	local bouton = Instance.new("TextButton")
	bouton.Name = "BoutonPlaquer"
	bouton.AnchorPoint = Vector2.new(1, 1)
	bouton.Position = UDim2.new(1, -210, 1, -20)
	bouton.Size = UDim2.fromOffset(TAILLE, TAILLE)
	bouton.BackgroundColor3 = COULEUR_PRET
	bouton.Font = Enum.Font.FredokaOne
	bouton.TextScaled = true
	bouton.TextColor3 = Color3.new(1, 1, 1)
	bouton.Text = "PLAQUER !"
	bouton.Selectable = true
	bouton.AutoButtonColor = true
	bouton.Parent = ecran

	local arrondi = Instance.new("UICorner")
	arrondi.CornerRadius = UDim.new(0.5, 0)
	arrondi.Parent = bouton
	local bord = Instance.new("UIStroke")
	bord.Thickness = 4
	bord.Color = Color3.new(0, 0, 0)
	bord.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bord.Parent = bouton
	local marge = Instance.new("UIPadding")
	marge.PaddingLeft = UDim.new(0, 12)
	marge.PaddingRight = UDim.new(0, 12)
	marge.Parent = bouton
	local echelle = Instance.new("UIScale")
	echelle.Parent = bouton

	local function pret(): boolean
		local pretA = joueur:GetAttribute("PlaquagePretA")
		return not (type(pretA) == "number" and Workspace:GetServerTimeNow() < pretA)
	end

	-- Aide côté client seulement : y a-t-il un porteur à peu près à portée ?
	local function porteurProche(): boolean
		local maRacine = racineDe(joueur)
		if maRacine == nil then
			return false
		end
		local maPosition = (maRacine :: BasePart).Position
		for _, autre in Players:GetPlayers() do
			if autre ~= joueur and autre:GetAttribute("Porte") ~= nil then
				local racine = racineDe(autre)
				if racine ~= nil then
					local distance = ((racine :: BasePart).Position - maPosition).Magnitude
					if distance <= Config.Plaquage.Portee + MARGE_PORTEE then
						return true
					end
				end
			end
		end
		return false
	end

	local function rebondir()
		echelle.Scale = 0.8
		TweenService:Create(
			echelle,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end

	local function plaquer()
		rebondir()
		remote:FireServer()
	end

	bouton.Activated:Connect(plaquer)

	local clavier = codeTouche(Config.Plaquage.Touches.Clavier)
	local manette = codeTouche(Config.Plaquage.Touches.Manette)
	-- La touche clavier est partagée avec LANCER : si personne n'est à
	-- plaquer, l'appui est laissé au lancer (Pass). Manette et bouton
	-- envoient toujours la demande.
	ContextActionService:BindAction(
		"Plaquer",
		function(_, etat: Enum.UserInputState, entree: InputObject)
			if etat ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Pass
			end
			if entree.KeyCode == clavier and not (pret() and porteurProche()) then
				return Enum.ContextActionResult.Pass
			end
			plaquer()
			return Enum.ContextActionResult.Sink
		end,
		false,
		clavier,
		manette
	)

	-- Délai : bouton grisé et secondes restantes.
	task.spawn(function()
		while true do
			local estPret = pret()
			bouton.Text = Plaquage.texteBouton(
				Workspace:GetServerTimeNow(),
				joueur:GetAttribute("PlaquagePretA") :: number?
			)
			bouton.BackgroundColor3 = if estPret then COULEUR_PRET else COULEUR_ATTENTE
			bouton.TextTransparency = if estPret then 0 else 0.15
			task.wait(0.1)
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfacePlaquage
