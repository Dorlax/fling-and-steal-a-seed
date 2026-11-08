--!strict
-- Trois gros boutons de pièges (colonne à gauche) + touches clavier et manette.
-- Le client envoie seulement PoserPiege:FireServer(type) : position, prix,
-- délai et limite sont décidés par le serveur. L'affichage vient des
-- attributs PiegePretA, PiegesActifs et ImmobileJusqua écrits par le serveur.
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Piege = require(Shared:WaitForChild("Piege"))

local InterfacePieges = {}

local reglages = Config.Pieges
local TAILLE = 96 -- pixels : assez grand pour le tactile
local ECART = 12
local COULEUR_ATTENTE = Color3.fromRGB(130, 130, 130)
local ICONES: { [string]: string } = { Filet = "#", Glu = "~", FausseGraine = "●" }

-- Noms d'Enum.KeyCode venant de Config.
local function codeTouche(nom: string): Enum.KeyCode
	return (Enum.KeyCode :: any)[nom] :: Enum.KeyCode
end

local function couleurDe(rgb: { number }): Color3
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local function contour(element: GuiObject, epaisseur: number, mode: Enum.ApplyStrokeMode)
	local trait = Instance.new("UIStroke")
	trait.Thickness = epaisseur
	trait.Color = Color3.new(0, 0, 0)
	trait.ApplyStrokeMode = mode
	trait.Parent = element
end

function InterfacePieges.demarrer()
	local joueur = Players.LocalPlayer
	local remote = ReplicatedStorage:WaitForChild("PoserPiege") :: RemoteEvent

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfacePieges"
	ecran.ResetOnSpawn = false

	local colonne = Instance.new("Frame")
	colonne.Name = "Colonne"
	colonne.AnchorPoint = Vector2.new(0, 0.5)
	colonne.Position = UDim2.new(0, 16, 0.5, 0)
	local n = #reglages.Ordre
	colonne.Size = UDim2.fromOffset(TAILLE, n * TAILLE + (n - 1) * ECART)
	colonne.BackgroundTransparency = 1
	colonne.Parent = ecran
	local liste = Instance.new("UIListLayout")
	liste.Padding = UDim.new(0, ECART)
	liste.SortOrder = Enum.SortOrder.LayoutOrder
	liste.Parent = colonne

	type Bouton = {
		typePiege: string,
		bouton: TextButton,
		texte: TextLabel,
		echelle: UIScale,
		couleur: Color3,
	}
	local boutons: { Bouton } = {}

	local function rebondir(echelle: UIScale)
		echelle.Scale = 0.8
		TweenService:Create(
			echelle,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end

	for ordre, typePiege in reglages.Ordre do
		local infos = reglages.Types[typePiege]
		local couleur = couleurDe(infos.Couleur)

		local bouton = Instance.new("TextButton")
		bouton.Name = "Bouton" .. typePiege
		bouton.LayoutOrder = ordre
		bouton.Size = UDim2.fromOffset(TAILLE, TAILLE)
		bouton.BackgroundColor3 = couleur
		bouton.Font = Enum.Font.FredokaOne
		bouton.TextScaled = true
		bouton.TextColor3 = Color3.new(1, 1, 1)
		bouton.Text = ""
		bouton.Selectable = true
		bouton.AutoButtonColor = true
		bouton.Parent = colonne
		local arrondi = Instance.new("UICorner")
		arrondi.CornerRadius = UDim.new(0.25, 0)
		arrondi.Parent = bouton
		contour(bouton, 4, Enum.ApplyStrokeMode.Border)
		local echelle = Instance.new("UIScale")
		echelle.Parent = bouton

		local icone = Instance.new("TextLabel")
		icone.Name = "Icone"
		icone.Size = UDim2.fromScale(1, 0.55)
		icone.BackgroundTransparency = 1
		icone.Font = Enum.Font.FredokaOne
		icone.TextScaled = true
		icone.TextColor3 = Color3.new(1, 1, 1)
		icone.Text = ICONES[typePiege] or "?"
		icone.Parent = bouton
		contour(icone, 3, Enum.ApplyStrokeMode.Contextual)

		local texte = Instance.new("TextLabel")
		texte.Name = "Texte"
		texte.AnchorPoint = Vector2.new(0.5, 1)
		texte.Position = UDim2.new(0.5, 0, 1, -6)
		texte.Size = UDim2.new(1, -10, 0.38, 0)
		texte.BackgroundTransparency = 1
		texte.Font = Enum.Font.FredokaOne
		texte.TextScaled = true
		texte.TextColor3 = Color3.new(1, 1, 1)
		texte.Text = Piege.texteBouton(typePiege, 0, nil, 0)
		texte.Parent = bouton
		contour(texte, 2, Enum.ApplyStrokeMode.Contextual)

		local function poser()
			rebondir(echelle)
			remote:FireServer(typePiege)
		end
		bouton.Activated:Connect(poser)

		ContextActionService:BindAction(
			"PoserPiege" .. typePiege,
			function(_, etat: Enum.UserInputState)
				if etat ~= Enum.UserInputState.Begin then
					return Enum.ContextActionResult.Pass
				end
				poser()
				return Enum.ContextActionResult.Sink
			end,
			false,
			codeTouche(reglages.Touches.Clavier[typePiege]),
			codeTouche(reglages.Touches.Manette[typePiege])
		)

		table.insert(boutons, {
			typePiege = typePiege,
			bouton = bouton,
			texte = texte,
			echelle = echelle,
			couleur = couleur,
		})
	end

	-- « PIÉGÉ ! » rebondissant au centre pendant l'immobilisation.
	local piege = Instance.new("TextLabel")
	piege.Name = "Piege"
	piege.AnchorPoint = Vector2.new(0.5, 0.5)
	piege.Position = UDim2.fromScale(0.5, 0.35)
	piege.Size = UDim2.fromOffset(420, 110)
	piege.BackgroundTransparency = 1
	piege.Font = Enum.Font.FredokaOne
	piege.TextScaled = true
	piege.TextColor3 = Color3.fromRGB(255, 140, 30)
	piege.Text = "PIÉGÉ !"
	piege.Visible = false
	piege.Parent = ecran
	contour(piege, 5, Enum.ApplyStrokeMode.Contextual)
	local echellePiege = Instance.new("UIScale")
	echellePiege.Parent = piege

	-- Mise à jour : prix, délai restant, « MAX », grisé, « PIÉGÉ ! ».
	task.spawn(function()
		local debut = os.clock()
		while true do
			local maintenant = Workspace:GetServerTimeNow()
			local pretA = joueur:GetAttribute("PiegePretA")
			local actifs = joueur:GetAttribute("PiegesActifs")
			local nombre = if type(actifs) == "number" then actifs else 0
			local enAttente = type(pretA) == "number" and maintenant < pretA
			local disponible = not enAttente and nombre < reglages.MaxParJoueur
			for _, b in boutons do
				b.texte.Text = Piege.texteBouton(b.typePiege, maintenant, pretA :: number?, nombre)
				b.bouton.BackgroundColor3 = if disponible then b.couleur else COULEUR_ATTENTE
			end
			local immobile = joueur:GetAttribute("ImmobileJusqua")
			piege.Visible = type(immobile) == "number"
			if piege.Visible then
				echellePiege.Scale = 1 + 0.12 * math.abs(math.sin((os.clock() - debut) * 8))
			end
			task.wait(0.05)
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfacePieges
