--!strict
-- Bouton « Base » (à droite, sous « Livre ») et panneau de la base : liste
-- des créatures (rareté, taille, espèce, revenu), vente (deux appuis pour
-- confirmer) et rangement par valeur. Le client n'envoie qu'un numéro ;
-- le serveur vérifie tout. La liste vient de l'attribut « CreaturesBase ».
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Bestiaire = require(Shared:WaitForChild("Bestiaire"))
local Config = require(Shared:WaitForChild("Config"))
local Fiche = require(Shared:WaitForChild("Fiche"))
local GestionBase = require(Shared:WaitForChild("GestionBase"))
local Nombres = require(Shared:WaitForChild("Nombres"))
local Revenus = require(Shared:WaitForChild("Revenus"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))
local Apercu = require(script.Parent:WaitForChild("Apercu"))

local InterfaceBase = {}

local VERT = Color3.fromRGB(90, 200, 110)
local HAUTEUR_LIGNE = 64
local DELAI_CONFIRMATION = 3 -- secondes pour confirmer une vente

function InterfaceBase.demarrer()
	local joueur = Players.LocalPlayer
	local vendre = ReplicatedStorage:WaitForChild("VendreCreature") :: RemoteEvent
	local trier = ReplicatedStorage:WaitForChild("TrierBase") :: RemoteEvent

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceBase"
	ecran.ResetOnSpawn = false
	ecran.DisplayOrder = 6

	local bouton =
		Habillage.bouton(ecran, "BoutonBase", { texte = "Base", couleur = VERT, rond = true })
	bouton.AnchorPoint = Vector2.new(1, 0.5)
	bouton.Position = UDim2.new(1, -12, 0.42, 2 * (Style.TailleBoutonMin + 12))

	local panneau = Instance.new("Frame")
	panneau.Name = "Panneau"
	panneau.AnchorPoint = Vector2.new(0.5, 0.5)
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	panneau.Size = UDim2.new(0.92, 0, 0.84, 0)
	panneau.BackgroundColor3 = Habillage.nommee("Fond")
	panneau.BackgroundTransparency = 0.08
	panneau.Visible = false
	panneau.Parent = ecran
	Habillage.arrondi(panneau, 0.04)
	Habillage.contour(panneau, Style.Contour.Moyen, Enum.ApplyStrokeMode.Border)
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(620, 620)
	limite.Parent = panneau

	local titre =
		Habillage.texte(panneau, "Titre", { couleur = VERT, contour = Style.Contour.Moyen })
	titre.Position = UDim2.fromOffset(14, 8)
	titre.Size = UDim2.new(1, -80, 0, 40)
	titre.TextXAlignment = Enum.TextXAlignment.Left
	local fermer = Habillage.bouton(panneau, "Fermer", {
		texte = "X",
		couleur = Habillage.nommee("Rouge"),
		taille = Vector2.new(44, 44),
	})
	fermer.AnchorPoint = Vector2.new(1, 0)
	fermer.Position = UDim2.new(1, -10, 0, 8)

	local boutonTrier = Habillage.bouton(panneau, "Trier", {
		texte = "Ranger par valeur",
		couleur = Habillage.nommee("Bleu"),
		taille = Vector2.new(220, 44),
	})
	boutonTrier.Position = UDim2.fromOffset(12, 56)

	local liste = Instance.new("ScrollingFrame")
	liste.Name = "Liste"
	liste.Position = UDim2.fromOffset(10, 108)
	liste.Size = UDim2.new(1, -20, 1, -118)
	liste.BackgroundTransparency = 1
	liste.BorderSizePixel = 0
	liste.ScrollBarThickness = 6
	liste.AutomaticCanvasSize = Enum.AutomaticSize.Y
	liste.CanvasSize = UDim2.new()
	liste.Parent = panneau
	local pile = Instance.new("UIListLayout")
	pile.SortOrder = Enum.SortOrder.LayoutOrder
	pile.Padding = UDim.new(0, 6)
	pile.Parent = liste

	local confirmation: number? = nil -- numéro en attente de confirmation
	local confirmationA = 0

	local function ligne(numero: number, fiche: string)
		local lue = Fiche.lire(fiche)
		if lue == nil then
			return
		end
		local infos = lue :: Fiche.Infos
		local couleur = Habillage.couleur(Style.couleurRarete(infos.Rarete))
		local cadre = Instance.new("Frame")
		cadre.Name = "Ligne" .. numero
		cadre.LayoutOrder = numero
		cadre.Size = UDim2.new(1, -8, 0, HAUTEUR_LIGNE)
		cadre.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		cadre.Parent = liste
		Habillage.arrondi(cadre, 0.15)
		local trait = Habillage.contour(cadre, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)
		trait.Color = couleur

		local vue = Instance.new("ViewportFrame")
		vue.Size = UDim2.fromOffset(HAUTEUR_LIGNE - 8, HAUTEUR_LIGNE - 8)
		vue.Position = UDim2.fromOffset(4, 4)
		vue.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
		vue.Ambient = Color3.fromRGB(200, 200, 210)
		vue.LightDirection = Vector3.new(-0.4, -1, 0.6)
		vue.Parent = cadre
		Habillage.arrondi(vue, 0.15)
		local espece = Bestiaire.especeCreature(infos.Rarete, infos.Espece)
		Apercu.montrer(vue, Apercu.modele(espece, false, couleur))

		local etage = math.floor((numero - 1) / Config.Creatures.MaxCreaturesBase) + 1
		local nom = Habillage.texte(cadre, "Nom", { contour = Style.Contour.Petit })
		nom.Position = UDim2.fromOffset(HAUTEUR_LIGNE + 4, 4)
		nom.Size = UDim2.new(1, -HAUTEUR_LIGNE - 140, 0, 28)
		nom.TextXAlignment = Enum.TextXAlignment.Left
		nom.TextScaled = true
		nom.Text = `{espece.Nom} · {Fiche.texte(infos.Rarete, infos.Taille)}`
		local detail =
			Habillage.texte(cadre, "Detail", { couleur = couleur, contour = Style.Contour.Petit })
		detail.Position = UDim2.fromOffset(HAUTEUR_LIGNE + 4, 34)
		detail.Size = UDim2.new(1, -HAUTEUR_LIGNE - 140, 0, 24)
		detail.TextXAlignment = Enum.TextXAlignment.Left
		detail.TextScaled = true
		detail.Text = `+{Nombres.abreger(Revenus.parSeconde(fiche))}/s · étage {etage}`

		local prix = GestionBase.prixVente(fiche)
		local enAttente = confirmation == numero and os.clock() - confirmationA < DELAI_CONFIRMATION
		local boutonVente, texteVente = Habillage.bouton(cadre, "Vendre", {
			texte = if enAttente then "Sûr ?" else `Vendre\n{Nombres.abreger(prix)}`,
			couleur = if enAttente then Habillage.nommee("Rouge") else Habillage.nommee("Orange"),
			taille = Vector2.new(120, HAUTEUR_LIGNE - 12),
		})
		boutonVente.AnchorPoint = Vector2.new(1, 0.5)
		boutonVente.Position = UDim2.new(1, -6, 0.5, 0)
		texteVente.TextScaled = true
		boutonVente.Activated:Connect(function()
			if confirmation == numero and os.clock() - confirmationA < DELAI_CONFIRMATION then
				confirmation = nil
				vendre:FireServer(numero)
			else
				confirmation = numero
				confirmationA = os.clock()
				texteVente.Text = "Sûr ?"
				boutonVente.BackgroundColor3 = Habillage.nommee("Rouge")
			end
		end)
	end

	local function afficher()
		for _, enfant in liste:GetChildren() do
			if enfant:IsA("Frame") then
				enfant:Destroy()
			end
		end
		local creatures = GestionBase.decoder(joueur:GetAttribute("CreaturesBase"))
		local etages = joueur:GetAttribute("Etages")
		local capacite = Config.Creatures.MaxCreaturesBase
			* (if type(etages) == "number" then etages else 1)
		titre.Text = `Ma base · {#creatures}/{capacite}`
		for numero, fiche in creatures do
			ligne(numero, fiche)
		end
		if #creatures == 0 then
			local vide = Habillage.texte(liste, "Vide", { contour = Style.Contour.Petit })
			vide.Size = UDim2.new(1, 0, 0, 40)
			vide.Text = "Ta base est vide : lance une graine !"
			local cadre = Instance.new("Frame")
			cadre.BackgroundTransparency = 1
			cadre.Size = UDim2.new(1, 0, 0, 40)
			cadre.Parent = liste
			vide.Parent = cadre
		end
	end

	bouton.Activated:Connect(function()
		panneau.Visible = not panneau.Visible
		if panneau.Visible then
			Habillage.apparaitre(panneau)
			afficher()
		end
	end)
	fermer.Activated:Connect(function()
		panneau.Visible = false
	end)
	boutonTrier.Activated:Connect(function()
		trier:FireServer()
	end)
	joueur:GetAttributeChangedSignal("CreaturesBase"):Connect(function()
		if panneau.Visible then
			afficher()
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceBase
