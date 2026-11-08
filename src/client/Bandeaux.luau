--!strict
-- Bandeau unique de messages en haut de l'écran (sous le compteur de pièces).
-- Les messages attendent leur tour dans une file pure (Shared.Style) :
-- jamais deux bandeaux à la fois. Affichage seulement.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Style = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local Bandeaux = {}

local HAUT = 202 -- pixels : sous le compteur de pièces et le revenu
local HAUTEUR = 64
local DEHORS_GAUCHE = UDim2.new(-0.6, 0, 0, HAUT)
local DEDANS = UDim2.new(0.5, 0, 0, HAUT)
local DEHORS_DROITE = UDim2.new(1.6, 0, 0, HAUT)

local file = Style.nouvelleFile()

-- Met un message dans la file (ignoré s'il n'est pas une chaîne non vide).
function Bandeaux.afficher(texte: any)
	Style.ajouter(file, texte, os.clock())
end

function Bandeaux.demarrer()
	local joueur = Players.LocalPlayer

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "Bandeaux"
	ecran.ResetOnSpawn = false
	ecran.DisplayOrder = 5

	local bandeau = Instance.new("Frame")
	bandeau.Name = "Bandeau"
	bandeau.AnchorPoint = Vector2.new(0.5, 0)
	bandeau.Position = DEHORS_GAUCHE
	bandeau.Size = UDim2.new(0.8, 0, 0, HAUTEUR)
	bandeau.BackgroundColor3 = Habillage.couleur(Style.couleurBandeau(""))
	bandeau.Visible = false
	bandeau.Parent = ecran
	Habillage.arrondi(bandeau, 0.3)
	Habillage.contour(bandeau, Style.Contour.Moyen, Enum.ApplyStrokeMode.Border)
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(560, HAUTEUR)
	limite.Parent = bandeau

	local texte = Habillage.texte(bandeau, "Texte", { contour = Style.Contour.Moyen })
	texte.AnchorPoint = Vector2.new(0.5, 0.5)
	texte.Position = UDim2.fromScale(0.5, 0.5)
	texte.Size = UDim2.new(1, -24, 1, -10)

	local glisse =
		TweenInfo.new(Style.Bandeau.Glisse, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local sortie =
		TweenInfo.new(Style.Bandeau.Glisse, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	local affiche: string? = nil
	local numero = 0

	local function montrer(message: string)
		numero += 1
		local actuel = numero
		texte.Text = message
		bandeau.BackgroundColor3 = Habillage.couleur(Style.couleurBandeau(message))
		bandeau.Position = DEHORS_GAUCHE
		bandeau.Visible = true
		TweenService:Create(bandeau, glisse, { Position = DEDANS }):Play()
		task.delay(Style.Bandeau.Glisse + Style.Bandeau.Duree, function()
			if actuel == numero then
				TweenService:Create(bandeau, sortie, { Position = DEHORS_DROITE }):Play()
			end
		end)
	end

	task.spawn(function()
		while true do
			local courant = Style.courant(file, os.clock())
			if courant ~= affiche then
				affiche = courant
				if courant == nil then
					numero += 1
					bandeau.Visible = false
				else
					montrer(courant)
				end
			end
			task.wait(0.05)
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return Bandeaux
