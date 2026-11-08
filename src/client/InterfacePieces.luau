--!strict
-- Compteur de pièces (haut de l'écran, au centre), revenu « +X / s »,
-- « +N » flottant à chaque gain et messages courts du serveur (MessageJeu).
-- Les messages passent par le bandeau unique (Bandeaux), sauf « BOUM ! »
-- qui rebondit en gros au centre. Affichage seulement : les valeurs viennent
-- des attributs écrits par le serveur.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Style = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Style"))
local Nombres = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Nombres"))
local Bandeaux = require(script.Parent:WaitForChild("Bandeaux"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfacePieces = {}

local COULEUR_PIECES = Habillage.nommee("Pieces")
local COULEUR_REVENU = Color3.fromRGB(150, 255, 140)
local DESCENTE = 112 -- sous le panneau des taux de rareté

-- 1234 -> « 1 234 », 1234567 -> « 1,23 M » (voir Shared.Nombres)
local function formater(n: number): string
	return Nombres.abreger(n)
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

	local compteur =
		Habillage.texte(ecran, "Pieces", { couleur = COULEUR_PIECES, contour = Style.Contour.Gros })
	compteur.AnchorPoint = Vector2.new(0.5, 0)
	compteur.Position = UDim2.new(0.5, 0, 0, DESCENTE)
	compteur.Size = UDim2.fromOffset(360, 56)

	local revenu = Habillage.texte(
		ecran,
		"Revenu",
		{ couleur = COULEUR_REVENU, contour = Style.Contour.Petit }
	)
	revenu.AnchorPoint = Vector2.new(0.5, 0)
	revenu.Position = UDim2.new(0.5, 0, 0, DESCENTE + 56)
	revenu.Size = UDim2.fromOffset(200, 28)

	-- « BOUM ! » du plaquage : un seul, gros, blanc, au centre.
	local boum = Habillage.texte(ecran, "Boum", { contour = Style.Contour.Gros })
	boum.AnchorPoint = Vector2.new(0.5, 0.5)
	boum.Position = UDim2.fromScale(0.5, 0.45)
	boum.Size = UDim2.fromOffset(460, 110)
	boum.Text = "BOUM !"
	boum.Rotation = -6
	boum.Visible = false
	local traitBoum = boum:FindFirstChildOfClass("UIStroke") :: UIStroke
	local echelleBoum = Habillage.echelle(boum)

	local precedent = nombre(joueur, "Pieces")

	local function rafraichirPieces()
		local pieces = nombre(joueur, "Pieces")
		compteur.Text = formater(pieces) .. " pièces"
		if pieces > precedent then
			Habillage.flotter(
				ecran,
				"+" .. formater(pieces - precedent),
				COULEUR_PIECES,
				UDim2.new(0.5, 150, 0, DESCENTE + 10),
				UDim2.fromOffset(140, 36)
			)
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

	-- Apparition 0,3 -> 1,2 -> 1 (Back), puis fondu après ~1 s.
	local numeroBoum = 0
	local function afficherBoum()
		numeroBoum += 1
		local actuel = numeroBoum
		boum.TextTransparency = 0
		traitBoum.Transparency = 0
		boum.Visible = true
		echelleBoum.Scale = 0.3
		local monte = TweenService:Create(
			echelleBoum,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1.2 }
		)
		monte:Play()
		task.wait(0.25)
		if actuel ~= numeroBoum then
			return
		end
		TweenService:Create(
			echelleBoum,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
		task.wait(1)
		if actuel ~= numeroBoum then
			return
		end
		local fondu = TweenInfo.new(0.3)
		TweenService:Create(boum, fondu, { TextTransparency = 1 }):Play()
		TweenService:Create(traitBoum, fondu, { Transparency = 1 }):Play()
		task.wait(0.3)
		if actuel == numeroBoum then
			boum.Visible = false
		end
	end

	messageJeu.OnClientEvent:Connect(function(contenu: any)
		if type(contenu) ~= "string" then
			return
		end
		if Style.estBoum(contenu) then
			task.spawn(afficherBoum)
		else
			Bandeaux.afficher(contenu)
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfacePieces
