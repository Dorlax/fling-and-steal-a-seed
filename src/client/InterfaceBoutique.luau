--!strict
-- Bouton « Shop » et boutique en 4 onglets : Graines (achat, équipement),
-- Renaissance, Roue gratuite et Traînées. Le client n'envoie que des
-- identifiants ; le serveur (Progression) vérifie tout. Les infos viennent
-- des attributs du joueur.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Bonus = require(Shared:WaitForChild("Bonus"))
local Config = require(Shared:WaitForChild("Config"))
local Lancer = require(Shared:WaitForChild("Lancer"))
local Nombres = require(Shared:WaitForChild("Nombres"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfaceBoutique = {}

local OR = Color3.fromRGB(255, 190, 60)
local INACTIF = Color3.fromRGB(110, 110, 125)
local HAUTEUR_LIGNE = 70

local function couleur(rgb: { number }): Color3
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

local function duree(secondes: number): string
	local s = math.max(0, math.floor(secondes))
	return string.format("%d h %02d min", s // 3600, (s % 3600) // 60)
end

function InterfaceBoutique.demarrer()
	local joueur = Players.LocalPlayer
	local remotes = {
		renaitre = ReplicatedStorage:WaitForChild("Renaitre") :: RemoteEvent,
		acheter = ReplicatedStorage:WaitForChild("AcheterGraine") :: RemoteEvent,
		equiperGraine = ReplicatedStorage:WaitForChild("EquiperGraine") :: RemoteEvent,
		roue = ReplicatedStorage:WaitForChild("TournerRoue") :: RemoteEvent,
		resultatRoue = ReplicatedStorage:WaitForChild("ResultatRoue") :: RemoteEvent,
		equiperTrainee = ReplicatedStorage:WaitForChild("EquiperTrainee") :: RemoteEvent,
	}

	local function nombre(nom: string): number
		local v = joueur:GetAttribute(nom)
		return if type(v) == "number" and v == v then v else 0
	end
	local function liste(nom: string): { string }
		local v = joueur:GetAttribute(nom)
		return if type(v) == "string" and v ~= "" then string.split(v, ",") else {}
	end

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceBoutique"
	ecran.ResetOnSpawn = false
	ecran.DisplayOrder = 6

	local bouton =
		Habillage.bouton(ecran, "BoutonBoutique", { texte = "Shop", couleur = OR, rond = true })
	bouton.AnchorPoint = Vector2.new(1, 0.5)
	bouton.Position = UDim2.new(1, -12, 0.42, Style.TailleBoutonMin / 2 + 6)

	local panneau = Instance.new("Frame")
	panneau.Name = "Panneau"
	panneau.AnchorPoint = Vector2.new(0.5, 0.5)
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	panneau.Size = UDim2.new(0.92, 0, 0.86, 0)
	panneau.BackgroundColor3 = Habillage.nommee("Fond")
	panneau.BackgroundTransparency = 0.08
	panneau.Visible = false
	panneau.Parent = ecran
	Habillage.arrondi(panneau, 0.04)
	Habillage.contour(panneau, Style.Contour.Moyen, Enum.ApplyStrokeMode.Border)
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(640, 640)
	limite.Parent = panneau

	local titre = Habillage.texte(panneau, "Titre", { couleur = OR, contour = Style.Contour.Moyen })
	titre.Position = UDim2.fromOffset(14, 8)
	titre.Size = UDim2.new(1, -80, 0, 40)
	titre.TextXAlignment = Enum.TextXAlignment.Left
	titre.Text = "Boutique"
	local fermer = Habillage.bouton(panneau, "Fermer", {
		texte = "X",
		couleur = Habillage.nommee("Rouge"),
		taille = Vector2.new(44, 44),
	})
	fermer.AnchorPoint = Vector2.new(1, 0)
	fermer.Position = UDim2.new(1, -10, 0, 8)

	-- Onglets.
	local barre = Instance.new("Frame")
	barre.Name = "Onglets"
	barre.Position = UDim2.fromOffset(10, 56)
	barre.Size = UDim2.new(1, -20, 0, 44)
	barre.BackgroundTransparency = 1
	barre.Parent = panneau
	local rangee = Instance.new("UIListLayout")
	rangee.FillDirection = Enum.FillDirection.Horizontal
	rangee.Padding = UDim.new(0, 6)
	rangee.SortOrder = Enum.SortOrder.LayoutOrder
	rangee.Parent = barre

	local contenu = Instance.new("ScrollingFrame")
	contenu.Name = "Contenu"
	contenu.Position = UDim2.fromOffset(10, 108)
	contenu.Size = UDim2.new(1, -20, 1, -118)
	contenu.BackgroundTransparency = 1
	contenu.BorderSizePixel = 0
	contenu.ScrollBarThickness = 6
	contenu.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contenu.CanvasSize = UDim2.new()
	contenu.Parent = panneau
	local pile = Instance.new("UIListLayout")
	pile.SortOrder = Enum.SortOrder.LayoutOrder
	pile.Padding = UDim.new(0, 6)
	pile.Parent = contenu

	local onglet = "Graines"
	local boutonsOnglets: { [string]: TextButton } = {}
	local afficher: () -> ()

	for ordre, nom in { "Graines", "Renaissance", "Roue", "Traînées" } do
		local b = Habillage.bouton(barre, nom, {
			texte = nom,
			couleur = INACTIF,
			taille = Vector2.new(140, 44),
		})
		b.LayoutOrder = ordre
		b.Size = UDim2.new(0.25, -5, 1, 0)
		b.Activated:Connect(function()
			onglet = nom
			afficher()
		end)
		boutonsOnglets[nom] = b
	end

	local function vider()
		for _, enfant in contenu:GetChildren() do
			if enfant:IsA("GuiObject") then
				enfant:Destroy()
			end
		end
	end

	-- Une ligne : titre, détail et bouton d'action à droite.
	local function ligne(
		ordre: number,
		titreLigne: string,
		detail: string,
		teinte: Color3,
		action: string?,
		actif: boolean,
		quandAppui: (() -> ())?
	)
		local cadre = Instance.new("Frame")
		cadre.LayoutOrder = ordre
		cadre.Size = UDim2.new(1, -8, 0, HAUTEUR_LIGNE)
		cadre.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		cadre.Parent = contenu
		Habillage.arrondi(cadre, 0.15)
		local trait = Habillage.contour(cadre, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)
		trait.Color = teinte
		local pastille = Instance.new("Frame")
		pastille.Size = UDim2.fromOffset(14, HAUTEUR_LIGNE - 16)
		pastille.Position = UDim2.fromOffset(8, 8)
		pastille.BackgroundColor3 = teinte
		pastille.Parent = cadre
		Habillage.arrondi(pastille, 0.5)
		local t =
			Habillage.texte(cadre, "Titre", { couleur = teinte, contour = Style.Contour.Petit })
		t.Position = UDim2.fromOffset(30, 4)
		t.Size = UDim2.new(1, -170, 0, 30)
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextScaled = true
		t.Text = titreLigne
		local d = Habillage.texte(cadre, "Detail", { contour = Style.Contour.Petit })
		d.Position = UDim2.fromOffset(30, 36)
		d.Size = UDim2.new(1, -170, 0, 28)
		d.TextXAlignment = Enum.TextXAlignment.Left
		d.TextScaled = true
		d.Text = detail
		if action then
			local b = Habillage.bouton(cadre, "Action", {
				texte = action,
				couleur = if actif then Color3.fromRGB(90, 200, 110) else INACTIF,
				taille = Vector2.new(130, HAUTEUR_LIGNE - 14),
			})
			b.AnchorPoint = Vector2.new(1, 0.5)
			b.Position = UDim2.new(1, -6, 0.5, 0)
			if quandAppui then
				b.Activated:Connect(quandAppui)
			end
		end
	end

	local function grainesOnglet()
		local possedees = liste("Graines")
		local equipee = joueur:GetAttribute("Graine")
		for ordre, id in Config.Graines.Ordre do
			local g = (Config.Graines.Liste :: any)[id]
			local taux = Lancer.tauxAvecChance("Lointaine", g.Chance)
			local mythique = math.floor(taux.Mythique * 100 + 0.5) / 100
			local detail =
				`Mythique (Lointaine) {mythique} % · tailles +{g.Tailles} · mutations ×{g.Mutation}`
			local possede = table.find(possedees, id) ~= nil
			if possede then
				local estEquipee = equipee == id
				ligne(
					ordre,
					g.Nom,
					detail,
					couleur(g.Couleur),
					if estEquipee then "Équipée" else "Équiper",
					not estEquipee,
					function()
						remotes.equiperGraine:FireServer(id)
					end
				)
			else
				local prix = g.Prix
				ligne(
					ordre,
					g.Nom,
					detail,
					couleur(g.Couleur),
					`{Nombres.abreger(prix)} 🪙`,
					nombre("Pieces") >= prix,
					function()
						remotes.acheter:FireServer(id)
					end
				)
			end
		end
	end

	local confirmation = 0
	local function renaissanceOnglet()
		local n = nombre("Renaissances")
		local prix = Bonus.prixRenaissance(n)
		ligne(
			1,
			`Renaissances : {n}`,
			`Revenus × {Nombres.abreger(Bonus.revenusRenaissance(n))} · Forge × {Bonus.forgeRenaissance(
				n
			)}`,
			OR,
			nil,
			false,
			nil
		)
		local sur = os.clock() - confirmation < 3
		ligne(
			2,
			`Renaître (n° {n + 1})`,
			`Pièces remises à 0 · créatures et Forge gardées · revenus × {Nombres.abreger(
				Bonus.revenusRenaissance(n + 1)
			)}`,
			Color3.fromRGB(255, 120, 200),
			if sur then "Sûr ?" else `{Nombres.abreger(prix)} 🪙`,
			nombre("Pieces") >= prix,
			function()
				if os.clock() - confirmation < 3 then
					confirmation = 0
					remotes.renaitre:FireServer()
				else
					confirmation = os.clock()
					afficher()
				end
			end
		)
		local pages = nombre("PagesCompletes")
		ligne(
			3,
			`Bestiaire : {pages} page(s) complète(s)`,
			`Revenus + {math.floor(Config.Renaissance.BonusPage * 100 * pages + 0.5)} % pour toujours`,
			Color3.fromRGB(150, 100, 255),
			nil,
			false,
			nil
		)
	end

	local function roueOnglet()
		local reste = nombre("ProchaineRoue") - os.time()
		local prete = reste <= 0
		ligne(
			1,
			"Roue gratuite",
			if prete then "Un tour t'attend !" else `Prochain tour dans {duree(reste)}`,
			OR,
			if prete then "Tourner !" else "Bientôt",
			prete,
			function()
				remotes.roue:FireServer()
			end
		)
		local total = 0
		for _, lot in Config.Roue.Lots do
			total += lot.Poids
		end
		for i, lot in Config.Roue.Lots do
			ligne(
				i + 1,
				lot.Nom,
				`Chance : {math.floor(lot.Poids / total * 1000 + 0.5) / 10} %`,
				Color3.fromRGB(120, 200, 255),
				nil,
				false,
				nil
			)
		end
	end

	local function traineesOnglet()
		local possedees = liste("Trainees")
		local equipee = joueur:GetAttribute("Trainee")
		ligne(
			1,
			"Aucune traînée",
			"Retirer la traînée",
			INACTIF,
			if equipee == "" then "Choisie" else "Choisir",
			equipee ~= "",
			function()
				remotes.equiperTrainee:FireServer("")
			end
		)
		for i, id in Config.Trainees.Ordre do
			local t = (Config.Trainees.Liste :: any)[id]
			local condition = if t.Renaissances
				then `Renaissance {t.Renaissances}`
				elseif t.Pages then `{t.Pages} pages du Bestiaire`
				else "Roue gratuite"
			local possede = table.find(possedees, id) ~= nil
			local teinte = couleur(t.Couleurs[1])
			if possede then
				ligne(
					i + 1,
					t.Nom,
					"Débloquée",
					teinte,
					if equipee == id then "Équipée" else "Équiper",
					equipee ~= id,
					function()
						remotes.equiperTrainee:FireServer(id)
					end
				)
			else
				ligne(
					i + 1,
					t.Nom,
					`À débloquer : {condition}`,
					INACTIF,
					"Verrouillée",
					false,
					nil
				)
			end
		end
	end

	function afficher()
		if not panneau.Visible then
			return
		end
		for nom, b in boutonsOnglets do
			b.BackgroundColor3 = if nom == onglet then OR else INACTIF
		end
		vider()
		if onglet == "Graines" then
			grainesOnglet()
		elseif onglet == "Renaissance" then
			renaissanceOnglet()
		elseif onglet == "Roue" then
			roueOnglet()
		else
			traineesOnglet()
		end
	end

	-- Petite célébration du lot gagné à la roue.
	remotes.resultatRoue.OnClientEvent:Connect(function(numero: any)
		local trouve = if type(numero) == "number" then Config.Roue.Lots[numero] else nil
		if trouve == nil then
			return
		end
		local lot: any = trouve
		local etiquette =
			Habillage.texte(ecran, "Lot", { couleur = OR, contour = Style.Contour.Gros })
		etiquette.AnchorPoint = Vector2.new(0.5, 0.5)
		etiquette.Position = UDim2.fromScale(0.5, 0.3)
		etiquette.Size = UDim2.fromOffset(520, 70)
		etiquette.Text = `🎉 {lot.Nom} !`
		Habillage.apparaitre(etiquette)
		TweenService:Create(
			etiquette,
			TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 2),
			{ TextTransparency = 1 }
		):Play()
		task.delay(2.8, function()
			etiquette:Destroy()
		end)
	end)

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
	for _, nom in
		{
			"Pieces",
			"Graines",
			"Graine",
			"Renaissances",
			"ProchaineRoue",
			"Trainees",
			"Trainee",
			"PagesCompletes",
		}
	do
		joueur:GetAttributeChangedSignal(nom):Connect(function()
			if nom ~= "Pieces" or onglet ~= "Roue" then
				afficher()
			end
		end)
	end
	-- Compte à rebours de la roue.
	task.spawn(function()
		while true do
			task.wait(30)
			if panneau.Visible and onglet == "Roue" then
				afficher()
			end
		end
	end)

	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceBoutique
