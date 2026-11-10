--!strict
-- Bouton « Top » (à droite) et panneau Classement : meilleurs revenus / s et
-- biomes les plus lointains, pour ce serveur ou le monde entier.
-- Affichage seulement :
--  * ce serveur : attributs des joueurs (RevenuParSeconde, RecordBiome) ;
--  * monde : attribut « ClassementMonde » de ReplicatedStorage (JSON du serveur).
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Biomes = require(Shared:WaitForChild("Biomes"))
local Classement = require(Shared:WaitForChild("Classement"))
local Nombres = require(Shared:WaitForChild("Nombres"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfaceClassement = {}

local OR = Color3.fromRGB(255, 200, 50)
local MOI = Color3.fromRGB(255, 240, 120)
local MEDAILLES = {
	Color3.fromRGB(255, 210, 60),
	Color3.fromRGB(210, 220, 235),
	Color3.fromRGB(230, 150, 90),
}
local HAUTEUR_LIGNE = Style.TailleTexteMin + 8

type Colonne = {
	titre: TextLabel,
	lignes: { TextLabel },
}

local function nombre(joueur: Player, nom: string): number
	local v = joueur:GetAttribute(nom)
	return if type(v) == "number" and v == v then v else 0
end

local function colonne(parent: Instance, nom: string, titre: string, ordre: number): Colonne
	local cadre = Instance.new("Frame")
	cadre.Name = nom
	cadre.LayoutOrder = ordre
	cadre.Size = UDim2.new(0.5, -6, 1, 0)
	cadre.BackgroundTransparency = 1
	cadre.Parent = parent
	local liste = Instance.new("UIListLayout")
	liste.SortOrder = Enum.SortOrder.LayoutOrder
	liste.Padding = UDim.new(0, 2)
	liste.Parent = cadre

	local entete = Habillage.texte(cadre, "Titre", { couleur = OR, contour = Style.Contour.Petit })
	entete.LayoutOrder = 0
	entete.Size = UDim2.new(1, 0, 0, HAUTEUR_LIGNE + 4)
	entete.Text = titre

	local lignes = {}
	for i = 1, 10 do
		local ligne = Habillage.texte(cadre, "Ligne" .. i, { contour = Style.Contour.Petit })
		ligne.LayoutOrder = i
		ligne.Size = UDim2.new(1, 0, 0, HAUTEUR_LIGNE)
		ligne.TextXAlignment = Enum.TextXAlignment.Left
		ligne.TextScaled = true
		ligne.Text = ""
		table.insert(lignes, ligne)
	end
	return { titre = entete, lignes = lignes }
end

-- Remplit une colonne ; `texte` met en forme la valeur.
local function remplir(
	c: Colonne,
	entrees: { Classement.Entree },
	texte: (number) -> string,
	vide: string
)
	local moi = Players.LocalPlayer.Name
	for i, ligne in c.lignes do
		local e = entrees[i]
		if e then
			ligne.Text = `{i}. {e.Nom} · {texte(e.Valeur)}`
			ligne.TextColor3 = if e.Nom == moi then MOI else (MEDAILLES[i] or Color3.new(1, 1, 1))
		elseif i == 1 then
			ligne.Text = vide
			ligne.TextColor3 = Color3.fromRGB(200, 200, 210)
		else
			ligne.Text = ""
		end
	end
end

local function texteRevenu(v: number): string
	return Nombres.abreger(v) .. " / s"
end

local function texteBiome(v: number): string
	local n = math.max(1, math.floor(v))
	return `{n} ({Biomes.biome(n).Nom})`
end

function InterfaceClassement.demarrer()
	local joueur = Players.LocalPlayer

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceClassement"
	ecran.ResetOnSpawn = false
	ecran.DisplayOrder = 6

	local bouton = Habillage.bouton(ecran, "BoutonClassement", {
		texte = "Top",
		couleur = OR,
		rond = true,
		icone = "🏆",
	})
	bouton.AnchorPoint = Vector2.new(1, 0.5)
	bouton.Position =
		UDim2.new(1, -Style.TailleBoutonMin - 22, 0.42, -(Style.TailleBoutonMin / 2 + 6))

	local panneau = Instance.new("Frame")
	panneau.Name = "Panneau"
	panneau.AnchorPoint = Vector2.new(0.5, 0.5)
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	panneau.Size = UDim2.new(0.9, 0, 0, 0)
	panneau.AutomaticSize = Enum.AutomaticSize.Y
	panneau.BackgroundColor3 = Habillage.nommee("Fond")
	panneau.BackgroundTransparency = 0.1
	panneau.Visible = false
	panneau.Parent = ecran
	Habillage.panneau(panneau, Habillage.nommee("Jaune"))
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(620, math.huge)
	limite.Parent = panneau
	local marge = Instance.new("UIPadding")
	for _, cote in { "PaddingTop", "PaddingBottom", "PaddingLeft", "PaddingRight" } do
		(marge :: any)[cote] = UDim.new(0, 12)
	end
	marge.Parent = panneau
	local pile = Instance.new("UIListLayout")
	pile.SortOrder = Enum.SortOrder.LayoutOrder
	pile.Padding = UDim.new(0, 8)
	pile.Parent = panneau

	-- Titre et bouton de fermeture.
	local entete = Instance.new("Frame")
	entete.Name = "Entete"
	entete.LayoutOrder = 1
	entete.Size = UDim2.new(1, 0, 0, 44)
	entete.BackgroundTransparency = 1
	entete.Parent = panneau
	local titre = Habillage.texte(entete, "Titre", { couleur = OR, contour = Style.Contour.Moyen })
	titre.Size = UDim2.new(1, -60, 1, 0)
	titre.TextXAlignment = Enum.TextXAlignment.Left
	titre.Text = "Classement"
	local fermer = Habillage.bouton(entete, "Fermer", {
		texte = "X",
		couleur = Habillage.nommee("Rouge"),
		taille = Vector2.new(44, 44),
	})
	fermer.AnchorPoint = Vector2.new(1, 0)
	fermer.Position = UDim2.fromScale(1, 0)

	-- Onglets.
	local onglets = Instance.new("Frame")
	onglets.Name = "Onglets"
	onglets.LayoutOrder = 2
	onglets.Size = UDim2.new(1, 0, 0, 48)
	onglets.BackgroundTransparency = 1
	onglets.Parent = panneau
	local rangee = Instance.new("UIListLayout")
	rangee.FillDirection = Enum.FillDirection.Horizontal
	rangee.SortOrder = Enum.SortOrder.LayoutOrder
	rangee.Padding = UDim.new(0, 8)
	rangee.Parent = onglets
	local ongletServeur, texteServeur = Habillage.bouton(onglets, "Serveur", {
		texte = "Ce serveur",
		couleur = Habillage.nommee("Bleu"),
	})
	ongletServeur.LayoutOrder = 1
	ongletServeur.Size = UDim2.new(0.5, -4, 1, 0)
	local ongletMonde, texteMonde = Habillage.bouton(onglets, "Monde", {
		texte = "Monde",
		couleur = Habillage.nommee("Gris"),
	})
	ongletMonde.LayoutOrder = 2
	ongletMonde.Size = UDim2.new(0.5, -4, 1, 0)

	-- Deux colonnes : revenus et biomes.
	local corps = Instance.new("Frame")
	corps.Name = "Corps"
	corps.LayoutOrder = 3
	corps.Size = UDim2.new(1, 0, 0, (HAUTEUR_LIGNE + 2) * 11 + 6)
	corps.BackgroundTransparency = 1
	corps.Parent = panneau
	local cotes = Instance.new("UIListLayout")
	cotes.FillDirection = Enum.FillDirection.Horizontal
	cotes.SortOrder = Enum.SortOrder.LayoutOrder
	cotes.Padding = UDim.new(0, 12)
	cotes.Parent = corps
	local colRevenus = colonne(corps, "Revenus", "Revenus / s", 1)
	local colBiomes = colonne(corps, "Biomes", "Biome le plus loin", 2)

	local mode = "Serveur"

	local function majServeur()
		local revenus, biomes = {}, {}
		for _, autre in Players:GetPlayers() do
			table.insert(revenus, { Nom = autre.Name, Valeur = nombre(autre, "RevenuParSeconde") })
			table.insert(
				biomes,
				{ Nom = autre.Name, Valeur = math.max(1, nombre(autre, "RecordBiome")) }
			)
		end
		remplir(colRevenus, Classement.trier(revenus), texteRevenu, "")
		remplir(colBiomes, Classement.trier(biomes), texteBiome, "")
	end

	local function majMonde()
		local brut = ReplicatedStorage:GetAttribute("ClassementMonde")
		local donnees: any = nil
		if type(brut) == "string" then
			local ok, resultat = pcall(function()
				return HttpService:JSONDecode(brut)
			end)
			donnees = if ok then resultat else nil
		end
		local vide = "Bientôt disponible…"
		local revenus = if type(donnees) == "table" then Classement.trier(donnees.Revenus) else {}
		local biomes = if type(donnees) == "table" then Classement.trier(donnees.Biomes) else {}
		remplir(colRevenus, revenus, texteRevenu, vide)
		remplir(colBiomes, biomes, texteBiome, vide)
	end

	local function maj()
		if not panneau.Visible then
			return
		end
		if mode == "Serveur" then
			majServeur()
		else
			majMonde()
		end
	end

	local function choisir(nouveau: string)
		mode = nouveau
		ongletServeur.BackgroundColor3 =
			Habillage.nommee(if mode == "Serveur" then "Bleu" else "Gris")
		ongletMonde.BackgroundColor3 = Habillage.nommee(if mode == "Monde" then "Bleu" else "Gris")
		texteServeur.Text = "Ce serveur"
		texteMonde.Text = "Monde"
		maj()
	end

	ongletServeur.Activated:Connect(function()
		choisir("Serveur")
	end)
	ongletMonde.Activated:Connect(function()
		choisir("Monde")
	end)
	bouton.Activated:Connect(function()
		panneau.Visible = not panneau.Visible
		if panneau.Visible then
			Habillage.apparaitre(panneau)
			maj()
		end
	end)
	fermer.Activated:Connect(function()
		panneau.Visible = false
	end)
	ReplicatedStorage:GetAttributeChangedSignal("ClassementMonde"):Connect(maj)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
	task.spawn(function()
		while true do
			task.wait(2)
			maj()
		end
	end)
end

return InterfaceClassement
