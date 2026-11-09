--!strict
-- Bouton « Bestiaire » (à droite, sous « Top ») et album des espèces :
-- une page par biome, une carte par créature (aperçu 3D qui tourne), en
-- silhouette noire tant qu'elle n'a pas été récoltée ; les 3 monstres du
-- biome sont toujours visibles. Affichage seulement : la liste des espèces
-- découvertes vient de l'attribut « Decouvertes » écrit par le serveur.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Bestiaire = require(Shared:WaitForChild("Bestiaire"))
local Biomes = require(Shared:WaitForChild("Biomes"))
local Collection = require(Shared:WaitForChild("Collection"))
local Config = require(Shared:WaitForChild("Config"))
local Revenus = require(Shared:WaitForChild("Revenus"))
local Nombres = require(Shared:WaitForChild("Nombres"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfaceBestiaire = {}

local VIOLET = Color3.fromRGB(150, 100, 255)
local SILHOUETTE = Color3.fromRGB(25, 25, 35)
local COULEUR_MONSTRE = Color3.fromRGB(255, 90, 90)
local VITESSE_ROTATION = 0.6 -- radians par seconde

local FORMES: { [string]: Enum.PartType } = {
	Ball = Enum.PartType.Ball,
	Cylinder = Enum.PartType.Cylinder,
}
local MATERIAUX: { [string]: Enum.Material } = {
	Neon = Enum.Material.Neon,
	Glass = Enum.Material.Glass,
	Foil = Enum.Material.Foil,
	Metal = Enum.Material.Metal,
}

-- Modèle d'aperçu (1 unité = 1 stud), sans physique ni texture.
local function apercu(espece: any, silhouette: boolean, couleurRarete: Color3): Model
	local modele = Instance.new("Model")
	modele.Name = espece.Nom
	for _, b in espece.Blocs do
		local p: BasePart
		if b.f == "Wedge" then
			p = Instance.new("WedgePart")
		else
			local part = Instance.new("Part")
			part.Shape = FORMES[b.f or ""] or Enum.PartType.Block
			p = part
		end
		p.Size = Vector3.new(b.t[1], b.t[2], b.t[3])
		local rotation = CFrame.new()
		if b.r then
			rotation = CFrame.Angles(math.rad(b.r[1]), math.rad(b.r[2]), math.rad(b.r[3]))
		end
		p.CFrame = CFrame.new(b.p[1], b.p[2], b.p[3]) * rotation
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		if silhouette then
			p.Color = SILHOUETTE
			p.Material = Enum.Material.SmoothPlastic
			p.Transparency = if b.tr and b.tr > 0.5 then 1 else 0
		else
			p.Color = if type(b.c) == "string"
				then couleurRarete
				else Color3.fromRGB(b.c[1], b.c[2], b.c[3])
			p.Material = MATERIAUX[b.m or ""] or Enum.Material.SmoothPlastic
			p.Transparency = b.tr or 0
		end
		p.Parent = modele
	end
	return modele
end

type Carte = { cadre: Frame, monde: Model?, pivot: CFrame }

function InterfaceBestiaire.demarrer()
	local joueur = Players.LocalPlayer

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceBestiaire"
	ecran.ResetOnSpawn = false
	ecran.DisplayOrder = 6

	local bouton = Habillage.bouton(ecran, "BoutonBestiaire", {
		texte = "Livre",
		couleur = VIOLET,
		rond = true,
	})
	bouton.AnchorPoint = Vector2.new(1, 0.5)
	bouton.Position = UDim2.new(1, -12, 0.42, Style.TailleBoutonMin + 12)

	local panneau = Instance.new("Frame")
	panneau.Name = "Panneau"
	panneau.AnchorPoint = Vector2.new(0.5, 0.5)
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	panneau.Size = UDim2.new(0.94, 0, 0.86, 0)
	panneau.BackgroundColor3 = Habillage.nommee("Fond")
	panneau.BackgroundTransparency = 0.08
	panneau.Visible = false
	panneau.Parent = ecran
	Habillage.arrondi(panneau, 0.04)
	Habillage.contour(panneau, Style.Contour.Moyen, Enum.ApplyStrokeMode.Border)
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(720, 640)
	limite.Parent = panneau

	-- En-tête : titre, total, fermeture.
	local titre =
		Habillage.texte(panneau, "Titre", { couleur = VIOLET, contour = Style.Contour.Moyen })
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

	-- Choix du biome : ◀ nom ▶.
	local precedent = Habillage.bouton(panneau, "Precedent", {
		texte = "<",
		couleur = Habillage.nommee("Bleu"),
		taille = Vector2.new(52, 44),
	})
	precedent.Position = UDim2.fromOffset(12, 56)
	local suivant = Habillage.bouton(panneau, "Suivant", {
		texte = ">",
		couleur = Habillage.nommee("Bleu"),
		taille = Vector2.new(52, 44),
	})
	suivant.AnchorPoint = Vector2.new(1, 0)
	suivant.Position = UDim2.new(1, -12, 0, 56)
	local nomBiome = Habillage.texte(panneau, "Biome", { contour = Style.Contour.Petit })
	nomBiome.Position = UDim2.fromOffset(72, 56)
	nomBiome.Size = UDim2.new(1, -144, 0, 44)

	-- Grille des cartes.
	local grille = Instance.new("ScrollingFrame")
	grille.Name = "Grille"
	grille.Position = UDim2.fromOffset(10, 108)
	grille.Size = UDim2.new(1, -20, 1, -118)
	grille.BackgroundTransparency = 1
	grille.BorderSizePixel = 0
	grille.ScrollBarThickness = 6
	grille.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grille.CanvasSize = UDim2.new()
	grille.Parent = panneau
	local disposition = Instance.new("UIGridLayout")
	disposition.CellSize = UDim2.fromOffset(122, 150)
	disposition.CellPadding = UDim2.fromOffset(8, 8)
	disposition.HorizontalAlignment = Enum.HorizontalAlignment.Center
	disposition.SortOrder = Enum.SortOrder.LayoutOrder
	disposition.Parent = grille

	local page = 1
	local cartes: { Carte } = {}

	local function vider()
		for _, carte in cartes do
			carte.cadre:Destroy()
		end
		table.clear(cartes)
	end

	local function carte(
		ordre: number,
		espece: any,
		nom: string,
		sousTitre: string,
		couleur: Color3,
		silhouette: boolean
	)
		local cadre = Instance.new("Frame")
		cadre.Name = "Carte" .. ordre
		cadre.LayoutOrder = ordre
		cadre.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		cadre.Parent = grille
		Habillage.arrondi(cadre, 0.08)
		local trait = Habillage.contour(cadre, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)
		trait.Color = couleur

		local vue = Instance.new("ViewportFrame")
		vue.Name = "Vue"
		vue.Size = UDim2.new(1, -8, 1, -46)
		vue.Position = UDim2.fromOffset(4, 4)
		vue.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
		vue.Ambient = Color3.fromRGB(200, 200, 210)
		vue.LightColor = Color3.new(1, 1, 1)
		vue.LightDirection = Vector3.new(-0.4, -1, 0.6)
		vue.Parent = cadre
		Habillage.arrondi(vue, 0.08)
		local monde = Instance.new("WorldModel")
		monde.Parent = vue
		local modele = apercu(espece, silhouette, couleur)
		modele.Parent = monde
		local camera = Instance.new("Camera")
		camera.FieldOfView = 34
		camera.CFrame = CFrame.lookAt(Vector3.new(1.3, 0.55, -2.3), Vector3.new(0, -0.02, 0))
		camera.Parent = vue
		vue.CurrentCamera = camera

		local etiquette = Habillage.texte(cadre, "Nom", { contour = Style.Contour.Petit })
		etiquette.Position = UDim2.new(0, 4, 1, -42)
		etiquette.Size = UDim2.new(1, -8, 0, 22)
		etiquette.TextScaled = true
		etiquette.Text = nom
		local detail =
			Habillage.texte(cadre, "Detail", { couleur = couleur, contour = Style.Contour.Petit })
		detail.Position = UDim2.new(0, 4, 1, -20)
		detail.Size = UDim2.new(1, -8, 0, 16)
		detail.TextScaled = true
		detail.Text = sousTitre

		table.insert(cartes, { cadre = cadre, monde = modele, pivot = modele:GetPivot() })
	end

	local function afficher()
		vider()
		local decouvertes = Collection.decoder(joueur:GetAttribute("Decouvertes"))
		titre.Text = `Bestiaire · {#decouvertes}/{Collection.total()}`
		local biome = Biomes.Liste[page]
		local trouvees, total = Collection.progression(decouvertes, page)
		nomBiome.Text = `{page}. {biome.Nom} · {trouvees}/{total}`
		local ordre = 0
		for _, rarete in Config.Raretes.Ordre do
			for _, nom in (biome.Creatures :: any)[rarete] or {} do
				ordre += 1
				local espece = Bestiaire.Especes[nom]
				local connue = table.find(decouvertes, nom) ~= nil
				local couleur = Habillage.couleur(Style.couleurRarete(rarete))
				local nomRarete = (Config.Raretes.Noms :: any)[rarete] or rarete
				local revenu = Revenus.parSeconde(`{rarete}:Normale:{nom}`)
				if espece then
					carte(
						ordre,
						espece,
						if connue then nom else "???",
						if connue then `{nomRarete} · {Nombres.abreger(revenu)}/s` else nomRarete,
						couleur,
						not connue
					)
				end
			end
		end
		for _, zone in { "Proche", "Moyenne", "Lointaine" } do
			for _, nom in (biome.Monstres :: any)[zone] or {} do
				ordre += 1
				local espece = Bestiaire.Especes[nom]
				if espece then
					carte(ordre, espece, nom, `Monstre · {zone}`, COULEUR_MONSTRE, false)
				end
			end
		end
	end

	local function changer(delta: number)
		page = (page - 1 + delta) % Biomes.nombre() + 1
		afficher()
	end

	precedent.Activated:Connect(function()
		changer(-1)
	end)
	suivant.Activated:Connect(function()
		changer(1)
	end)
	bouton.Activated:Connect(function()
		panneau.Visible = not panneau.Visible
		if panneau.Visible then
			-- Ouvre sur le biome où se trouve le joueur.
			local personnage = joueur.Character
			local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
			if racine and racine:IsA("BasePart") then
				local distance = racine.Position.Z - Config.Monstres.BordBases
				page = if distance < 0 then 1 else Biomes.index(distance)
			end
			Habillage.apparaitre(panneau)
			afficher()
		else
			vider()
		end
	end)
	fermer.Activated:Connect(function()
		panneau.Visible = false
		vider()
	end)
	joueur:GetAttributeChangedSignal("Decouvertes"):Connect(function()
		if panneau.Visible then
			afficher()
		end
	end)

	-- Les aperçus tournent doucement sur eux-mêmes.
	RunService.RenderStepped:Connect(function()
		if not panneau.Visible then
			return
		end
		local angle = os.clock() * VITESSE_ROTATION
		for _, c in cartes do
			if c.monde then
				c.monde:PivotTo(c.pivot * CFrame.Angles(0, math.sin(angle) * 0.6, 0))
			end
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceBestiaire
