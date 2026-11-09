--!strict
-- Interface du lancer : bouton LANCER, jauge de timing, message de résultat
-- et panneau des taux de rareté (toujours visible).
-- Le client ne calcule ni distance ni rareté : il affiche ce que le serveur renvoie.
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config")) :: any
local Jauge = require(Shared:WaitForChild("Jauge")) :: any
local Lancer = require(Shared:WaitForChild("Lancer")) :: any
local Fiche = require(Shared:WaitForChild("Fiche"))
local Biomes = require(Shared:WaitForChild("Biomes"))
local Evenement = require(Shared:WaitForChild("Evenement"))
local Bonus = require(Shared:WaitForChild("Bonus"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))

local InterfaceLancer = {}

local COULEUR_FOND = Habillage.nommee("Fond")
local COULEUR_BOUTON = Habillage.nommee("Vert")
local COULEUR_BOUTON_ATTENTE = Habillage.nommee("Gris")
local COULEURS_PALIERS: { [string]: Color3 } = {
	Vert = Habillage.nommee("Vert"),
	Jaune = Habillage.nommee("Jaune"),
	Orange = Habillage.nommee("Orange"),
	Rouge = Habillage.nommee("Rouge"),
}

local function couleurRarete(rarete: string): Color3
	return Habillage.couleur(Style.couleurRarete(rarete))
end

local function creerPanneauTaux(ecran: ScreenGui)
	local cadre = Instance.new("Frame")
	cadre.Name = "TauxRarete"
	cadre.AnchorPoint = Vector2.new(0.5, 0)
	cadre.Position = UDim2.new(0.5, 0, 0, 8)
	cadre.Size = UDim2.new(0.6, 0, 0, 0)
	cadre.AutomaticSize = Enum.AutomaticSize.Y
	cadre.BackgroundColor3 = COULEUR_FOND
	cadre.BackgroundTransparency = 0.25
	cadre.Parent = ecran
	Habillage.arrondi(cadre, 0.15)
	Habillage.contour(cadre, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)

	local contrainte = Instance.new("UISizeConstraint")
	contrainte.MinSize = Vector2.new(300, 0)
	contrainte.MaxSize = Vector2.new(640, math.huge)
	contrainte.Parent = cadre

	local marge = Instance.new("UIPadding")
	marge.PaddingTop = UDim.new(0, 6)
	marge.PaddingBottom = UDim.new(0, 6)
	marge.PaddingLeft = UDim.new(0, 10)
	marge.PaddingRight = UDim.new(0, 10)
	marge.Parent = cadre

	local liste = Instance.new("UIListLayout")
	liste.SortOrder = Enum.SortOrder.LayoutOrder
	liste.Padding = UDim.new(0, 2)
	liste.Parent = cadre

	local titre = Instance.new("TextButton")
	titre.Name = "Titre"
	titre.LayoutOrder = 0
	titre.Size = UDim2.new(1, 0, 0, 26)
	titre.BackgroundTransparency = 1
	titre.TextColor3 = Color3.new(1, 1, 1)
	titre.Text = "Taux de rareté ▲"
	titre.Selectable = true
	Habillage.styliserTexte(titre, Style.Contour.Petit)
	titre.Parent = cadre

	local lignes: { TextLabel } = {}
	local lignesZones: { [string]: TextLabel } = {}
	for i, zone in Config.Lancer.Zones do
		local ligne = Habillage.texte(cadre, "Taux" .. zone.Nom, {
			couleur = Habillage.couleur(Style.couleurZone(zone.Nom)),
			contour = Style.Contour.Petit,
		})
		ligne.LayoutOrder = i
		ligne.Size = UDim2.new(1, 0, 0, Style.TailleTexteMin + 2)
		ligne.Text = Lancer.texteTaux(zone.Nom)
		table.insert(lignes, ligne)
		lignesZones[zone.Nom] = ligne
	end

	-- Taux de taille du biome que le lancer atteint avec la Force actuelle :
	-- plus on va loin, plus les grosses tailles sortent souvent.
	local ligneTailles = Habillage.texte(cadre, "TauxTailles", {
		couleur = Color3.fromRGB(255, 240, 200),
		contour = Style.Contour.Petit,
	})
	ligneTailles.LayoutOrder = #Config.Lancer.Zones + 1
	ligneTailles.Size = UDim2.new(1, 0, 0, Style.TailleTexteMin + 2)
	table.insert(lignes, ligneTailles)
	local joueur = Players.LocalPlayer
	local ouvert = true
	local function majTailles()
		local force = joueur:GetAttribute("Force")
		local evenement = Workspace:GetAttribute("Evenement")
		local biome = Biomes.index(
			Lancer.distance(if type(force) == "number" then force else 0, 0)
				+ Evenement.bonusDistance(evenement)
		)
		-- Graines géantes et graine équipée : taux de biomes plus loin (affichés tels quels).
		local graine = Bonus.graine(joueur:GetAttribute("Graine"))
		local taux = Fiche.tauxTailles(biome + Evenement.bonusTailles(evenement) + graine.Tailles)
		-- Taux de rareté avec la graine équipée (ceux du Plan avec la graine simple).
		for nom, ligneZone in lignesZones do
			ligneZone.Text = Lancer.texteTaux(nom, graine.Chance)
		end
		titre.Text = if ouvert
			then `Taux de rareté · {graine.Nom} ▲`
			else `Taux de rareté · {graine.Nom} ▼`
		local morceaux = {}
		for _, taille in Config.Tailles.Ordre do
			local nom = (Config.Tailles.Noms :: any)[taille]
			local mult = (Config.Tailles.Multiplicateur :: any)[taille]
			local pourcent = math.floor(taux[taille] * 10 + 0.5) / 10
			local texte = string.gsub(tostring(pourcent), "%.", ",")
			table.insert(morceaux, `{nom} {texte} % (×{mult})`)
		end
		ligneTailles.Text = `Tailles (biome {biome}) : ` .. table.concat(morceaux, " · ")
	end
	majTailles()
	joueur:GetAttributeChangedSignal("Force"):Connect(majTailles)
	joueur:GetAttributeChangedSignal("Graine"):Connect(majTailles)
	Workspace:GetAttributeChangedSignal("Evenement"):Connect(majTailles)

	titre.Activated:Connect(function()
		ouvert = not ouvert
		majTailles()
		for _, ligne in lignes do
			ligne.Visible = ouvert
		end
	end)
end

function InterfaceLancer.demarrer()
	local joueur = Players.LocalPlayer
	local demarrerJauge = ReplicatedStorage:WaitForChild("DemarrerJauge") :: RemoteEvent
	local lacherJauge = ReplicatedStorage:WaitForChild("LacherJauge") :: RemoteEvent
	local resultatLancer = ReplicatedStorage:WaitForChild("ResultatLancer") :: RemoteEvent

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceLancer"
	ecran.ResetOnSpawn = false

	-- Bouton LANCER (souris et toucher via Activated).
	local bouton, texteBouton = Habillage.bouton(ecran, "Lancer", {
		texte = "LANCER",
		couleur = COULEUR_BOUTON,
		taille = Vector2.new(170, Style.TailleBoutonMin),
	})
	bouton.AnchorPoint = Vector2.new(1, 1)
	bouton.Position = UDim2.new(1, -20, 1, -20)

	-- Jauge verticale, au-dessus du bouton : dégradé continu (vert en bas -> rouge en haut).
	local jauge = Instance.new("Frame")
	jauge.Name = "Jauge"
	jauge.AnchorPoint = Vector2.new(1, 1)
	jauge.Position = UDim2.new(1, -85, 1, -20 - Style.TailleBoutonMin - 25)
	jauge.Size = UDim2.fromOffset(44, 260)
	jauge.BackgroundColor3 = Color3.new(1, 1, 1)
	jauge.Visible = false
	jauge.Parent = ecran
	Habillage.arrondi(jauge, 0.3)
	Habillage.contour(jauge, Style.Contour.Moyen, Enum.ApplyStrokeMode.Border)
	local degrade = Instance.new("UIGradient")
	degrade.Color = Habillage.degrade()
	degrade.Rotation = -90 -- 0 en bas, 1 en haut
	degrade.Parent = jauge

	local curseur = Instance.new("Frame")
	curseur.Name = "Curseur"
	curseur.AnchorPoint = Vector2.new(0.5, 0.5)
	curseur.Position = UDim2.fromScale(0.5, 1)
	curseur.Size = UDim2.new(1, 16, 0, 8)
	curseur.BackgroundColor3 = Color3.new(1, 1, 1)
	curseur.ZIndex = 2
	curseur.Parent = jauge
	Habillage.arrondi(curseur, 0.5)
	Habillage.contour(curseur, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)

	-- Message de résultat (sous le bandeau des messages, sans le recouvrir).
	local message = Habillage.texte(ecran, "Message", { contour = Style.Contour.Gros })
	message.AnchorPoint = Vector2.new(0.5, 0)
	message.Position = UDim2.new(0.5, 0, 0, 276)
	message.Size = UDim2.fromOffset(520, 90)
	message.Visible = false
	local echelle = Habillage.echelle(message)

	creerPanneauTaux(ecran)

	-- État local (affichage seulement : le serveur valide tout).
	local enCours = false
	local debutLocal = 0
	local attenteJusqua = 0
	local animation: RBXScriptConnection? = nil
	local numeroMessage = 0

	local function cacherJauge()
		enCours = false
		jauge.Visible = false
		if animation then
			animation:Disconnect()
			animation = nil
		end
	end

	local function rafraichirBouton()
		local enAttente = os.clock() < attenteJusqua
		bouton.BackgroundColor3 = if enAttente then COULEUR_BOUTON_ATTENTE else COULEUR_BOUTON
		texteBouton.Text = if enCours then "LÂCHER !" else "LANCER"
	end

	local function actionner()
		Habillage.rebondir(bouton)
		if enCours then
			lacherJauge:FireServer()
			cacherJauge()
			attenteJusqua = os.clock() + Config.Lancer.DelaiEntreLancers
		else
			if os.clock() < attenteJusqua then
				return
			end
			demarrerJauge:FireServer()
			enCours = true
			debutLocal = os.clock()
			jauge.Visible = true
			animation = RunService.RenderStepped:Connect(function()
				local ecoule = os.clock() - debutLocal
				if ecoule > Config.Lancer.DureeMaxJauge then
					cacherJauge() -- annulée côté serveur aussi
					rafraichirBouton()
					return
				end
				curseur.Position = UDim2.fromScale(0.5, 1 - Jauge.position(ecoule))
			end)
		end
		rafraichirBouton()
		task.delay(Config.Lancer.DelaiEntreLancers, rafraichirBouton)
	end

	bouton.Activated:Connect(actionner)
	-- Manette (R2) et clavier (F) : même action que le bouton.
	ContextActionService:BindAction("LancerGraine", function(_, etat: Enum.UserInputState)
		if etat == Enum.UserInputState.Begin then
			actionner()
		end
		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.ButtonR2, Enum.KeyCode.F)

	local function afficher(texte: string, couleur: Color3, taille: number)
		message.Text = texte
		message.TextColor3 = couleur
		message.Visible = true
		echelle.Scale = 0.3
		TweenService:Create(
			echelle,
			TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = taille }
		):Play()
	end

	resultatLancer.OnClientEvent:Connect(function(resultat: any)
		if type(resultat) ~= "table" then
			return
		end
		local distance = resultat.Distance
		local rarete = resultat.Rarete
		if type(distance) ~= "number" or type(rarete) ~= "string" then
			return
		end
		numeroMessage += 1
		local numero = numeroMessage
		local couleurPalier = COULEURS_PALIERS[resultat.Couleur] or Color3.new(1, 1, 1)
		local rangRarete = table.find(Config.Raretes.Ordre, rarete) or 1
		local taille = if type(resultat.Taille) == "string" then resultat.Taille else "Normale"
		local rangTaille = table.find(Config.Tailles.Ordre, taille) or 1
		local genereux = rangRarete >= 3 or rangTaille >= 3 -- Épique ou Géante et au-dessus

		local tailleMessage = if resultat.Couleur == "Rouge" then 1.25 else 1
		afficher(tostring(resultat.Message or ""), couleurPalier, tailleMessage)
		task.wait(1)
		if numero ~= numeroMessage then
			return
		end
		local nom = Fiche.texte(rarete, taille)
		afficher(
			`+{math.floor(distance)} m · {nom}`,
			couleurRarete(rarete),
			if genereux then 1.4 else 1
		)
		if genereux then
			-- Effet plus généreux : pulsations de la taille.
			for _ = 1, 3 do
				task.wait(0.25)
				if numero ~= numeroMessage then
					return
				end
				TweenService:Create(echelle, TweenInfo.new(0.12), { Scale = 1.6 }):Play()
				task.wait(0.12)
				TweenService:Create(echelle, TweenInfo.new(0.12), { Scale = 1.4 }):Play()
			end
		end
		task.wait(if genereux then 2 else 1.5)
		if numero == numeroMessage then
			message.Visible = false
		end
	end)

	rafraichirBouton()
	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceLancer
