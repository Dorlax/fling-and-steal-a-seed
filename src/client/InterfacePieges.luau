--!strict
-- Trois gros boutons de pièges (colonne à gauche) + touches clavier et manette.
-- Le client envoie seulement PoserPiege:FireServer(type) : position, prix,
-- délai et limite sont décidés par le serveur. L'affichage vient des
-- attributs PiegePretA, PiegesActifs et ImmobileJusqua écrits par le serveur.
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Piege = require(Shared:WaitForChild("Piege"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfacePieges = {}

local reglages = Config.Pieges
local TAILLE = math.max(96, Style.TailleBoutonMin) -- pixels : assez grand pour le tactile
local ECART = 12
local COULEUR_ATTENTE = Habillage.nommee("Gris")
local ICONES: { [string]: string } = { Filet = "#", Glu = "~", FausseGraine = "●" }

-- Noms d'Enum.KeyCode venant de Config.
local function codeTouche(nom: string): Enum.KeyCode
	return (Enum.KeyCode :: any)[nom] :: Enum.KeyCode
end

local function couleurDe(rgb: { number }): Color3
	return Habillage.couleur(rgb)
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
		jauge: { maj: (number) -> () },
		couleur: Color3,
	}
	local boutons: { Bouton } = {}

	for ordre, typePiege in reglages.Ordre do
		local infos = reglages.Types[typePiege]
		local couleur = couleurDe(infos.Couleur)

		local bouton, texte = Habillage.bouton(colonne, "Bouton" .. typePiege, {
			couleur = couleur,
			taille = Vector2.new(TAILLE, TAILLE),
		})
		bouton.LayoutOrder = ordre
		texte.AnchorPoint = Vector2.new(0.5, 1)
		texte.Position = UDim2.new(0.5, 0, 1, -6)
		texte.Size = UDim2.new(1, -10, 0.38, 0)
		texte.Text = Piege.texteBouton(typePiege, 0, nil, 0)

		local icone = Habillage.texte(bouton, "Icone", { contour = Style.Contour.Petit })
		icone.Position = UDim2.fromOffset(0, 8)
		icone.Size = UDim2.new(1, 0, 0.5, -4)
		icone.Text = ICONES[typePiege] or "?"

		-- Jauge de recharge (délai de pose), en haut du bouton.
		local jauge = Habillage.jauge(bouton, "Recharge", UDim2.new(1, -16, 0, 10))
		jauge.cadre.AnchorPoint = Vector2.new(0.5, 0)
		jauge.cadre.Position = UDim2.new(0.5, 0, 0, 4)

		local function poser()
			Habillage.rebondir(bouton)
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
			jauge = jauge,
			couleur = couleur,
		})
	end

	-- « PIÉGÉ ! » rebondissant au centre pendant l'immobilisation.
	local piege = Habillage.texte(
		ecran,
		"Piege",
		{ couleur = Habillage.nommee("Orange"), contour = Style.Contour.Gros }
	)
	piege.AnchorPoint = Vector2.new(0.5, 0.5)
	piege.Position = UDim2.fromScale(0.5, 0.35)
	piege.Size = UDim2.fromOffset(420, 110)
	piege.Text = "PIÉGÉ !"
	piege.Visible = false
	local echellePiege = Habillage.echelle(piege)

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
			local recharge = Style.ratioRecharge(maintenant, pretA :: number?, reglages.DelaiPose)
			for _, b in boutons do
				b.texte.Text = Piege.texteBouton(b.typePiege, maintenant, pretA :: number?, nombre)
				b.bouton.BackgroundColor3 = if disponible then b.couleur else COULEUR_ATTENTE
				b.jauge.maj(recharge)
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
