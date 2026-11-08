--!strict
-- Compteur de pièces (haut de l'écran, au centre), revenu « +X / s »,
-- « +N » flottant à chaque gain et messages courts du serveur (MessageJeu).
-- Affichage seulement : les valeurs viennent des attributs écrits par le serveur.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local InterfacePieces = {}

local COULEUR_PIECES = Color3.fromRGB(255, 215, 60)
local COULEUR_REVENU = Color3.fromRGB(150, 255, 140)
local DESCENTE = 112 -- sous le panneau des taux de rareté

local function contour(element: GuiObject, epaisseur: number)
	local trait = Instance.new("UIStroke")
	trait.Thickness = epaisseur
	trait.Color = Color3.new(0, 0, 0)
	trait.Parent = element
end

local function texte(parent: Instance, nom: string, police: Enum.Font, couleur: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = nom
	label.BackgroundTransparency = 1
	label.Font = police
	label.TextScaled = true
	label.TextColor3 = couleur
	label.Parent = parent
	return label
end

-- 1234567 -> « 1 234 567 »
local function formater(n: number): string
	local brut = string.format("%d", math.floor(n))
	local resultat = string.gsub(string.reverse(brut), "(%d%d%d)", "%1 ")
	return (string.gsub(string.reverse(resultat), "^ ", ""))
end

local function nombre(joueur: Player, nom: string): number
	local valeur = joueur:GetAttribute(nom)
	if type(valeur) == "number" and valeur == valeur then
		return valeur
	end
	return 0
end

function InterfacePieces.demarrer()
	local joueur = Players.LocalPlayer
	local messageJeu = ReplicatedStorage:WaitForChild("MessageJeu") :: RemoteEvent

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfacePieces"
	ecran.ResetOnSpawn = false

	local compteur = texte(ecran, "Pieces", Enum.Font.FredokaOne, COULEUR_PIECES)
	compteur.AnchorPoint = Vector2.new(0.5, 0)
	compteur.Position = UDim2.new(0.5, 0, 0, DESCENTE)
	compteur.Size = UDim2.fromOffset(360, 56)
	contour(compteur, 4)

	local revenu = texte(ecran, "Revenu", Enum.Font.GothamBlack, COULEUR_REVENU)
	revenu.AnchorPoint = Vector2.new(0.5, 0)
	revenu.Position = UDim2.new(0.5, 0, 0, DESCENTE + 56)
	revenu.Size = UDim2.fromOffset(200, 26)
	contour(revenu, 2)

	local message = texte(ecran, "Message", Enum.Font.FredokaOne, Color3.new(1, 1, 1))
	message.AnchorPoint = Vector2.new(0.5, 0.5)
	message.Position = UDim2.fromScale(0.5, 0.45)
	message.Size = UDim2.fromOffset(460, 70)
	message.Visible = false
	contour(message, 4)

	local precedent = nombre(joueur, "Pieces")

	-- « +N » qui flotte vers le haut et s'efface.
	local function flotter(gain: number)
		local bulle = texte(ecran, "Gain", Enum.Font.FredokaOne, COULEUR_PIECES)
		bulle.AnchorPoint = Vector2.new(0.5, 0)
		bulle.Position = UDim2.new(0.5, 150, 0, DESCENTE + 10)
		bulle.Size = UDim2.fromOffset(140, 36)
		bulle.Text = "+" .. formater(gain)
		local trait = Instance.new("UIStroke")
		trait.Thickness = 3
		trait.Parent = bulle
		local info = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(bulle, info, {
			Position = UDim2.new(0.5, 150, 0, DESCENTE - 30),
			TextTransparency = 1,
		}):Play()
		TweenService:Create(trait, info, { Transparency = 1 }):Play()
		task.delay(1, function()
			bulle:Destroy()
		end)
	end

	local function rafraichirPieces()
		local pieces = nombre(joueur, "Pieces")
		compteur.Text = formater(pieces) .. " pièces"
		if pieces > precedent then
			flotter(pieces - precedent)
		end
		precedent = pieces
	end

	local function rafraichirRevenu()
		revenu.Text = `+{formater(nombre(joueur, "RevenuParSeconde"))} / s`
	end

	joueur:GetAttributeChangedSignal("Pieces"):Connect(rafraichirPieces)
	joueur:GetAttributeChangedSignal("RevenuParSeconde"):Connect(rafraichirRevenu)
	rafraichirPieces()
	rafraichirRevenu()

	local numero = 0
	messageJeu.OnClientEvent:Connect(function(contenu: any)
		if type(contenu) ~= "string" then
			return
		end
		numero += 1
		local actuel = numero
		message.Text = string.sub(contenu, 1, 80)
		message.Visible = true
		task.delay(2, function()
			if actuel == numero then
				message.Visible = false
			end
		end)
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfacePieces
