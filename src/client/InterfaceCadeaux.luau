--!strict
-- Bouton « Cadeaux » 🎁 (connexion sur 7 jours, défis du jour, codes promo)
-- et bouton « Réglages » ⚙️ (sons, musique). Affichage seulement : le client
-- envoie une demande, le serveur (Cadeaux) vérifie et donne tout. Les infos
-- viennent des attributs du joueur.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Cadeau = require(Shared:WaitForChild("Cadeaux"))
local Config = require(Shared:WaitForChild("Config"))
local Nombres = require(Shared:WaitForChild("Nombres"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))
local Sons = require(script.Parent:WaitForChild("Sons"))

local InterfaceCadeaux = {}

local ROSE = Color3.fromRGB(255, 110, 170)
local VERT = Color3.fromRGB(90, 200, 110)
local INACTIF = Color3.fromRGB(110, 110, 125)
local OR = Color3.fromRGB(255, 190, 60)

local function duree(secondes: number): string
	local s = math.max(0, math.floor(secondes))
	return string.format("%d h %02d min", s // 3600, (s % 3600) // 60)
end

function InterfaceCadeaux.demarrer()
	local joueur = Players.LocalPlayer
	local remotes = {
		quotidien = ReplicatedStorage:WaitForChild("ReclamerQuotidien") :: RemoteEvent,
		defi = ReplicatedStorage:WaitForChild("ReclamerDefi") :: RemoteEvent,
		code = ReplicatedStorage:WaitForChild("UtiliserCode") :: RemoteEvent,
		resultatCode = ReplicatedStorage:WaitForChild("ResultatCode") :: RemoteEvent,
		reglage = ReplicatedStorage:WaitForChild("ChangerReglage") :: RemoteEvent,
	}

	local function liste(nom: string): { string }
		local v = joueur:GetAttribute(nom)
		return if type(v) == "string" and v ~= "" then string.split(v, ",") else {}
	end
	local function revenu(): number
		local v = joueur:GetAttribute("RevenuParSeconde")
		return if type(v) == "number" and v == v then v else 0
	end
	local function aujourdhui(): number
		return Cadeau.jour(Workspace:GetServerTimeNow())
	end

	-- État calculé à partir des attributs (le serveur reste seul juge).
	local function etatQuotidien(): (boolean, number)
		return Cadeau.quotidien(
			joueur:GetAttribute("QuotidienSerie"),
			joueur:GetAttribute("QuotidienJour"),
			aujourdhui()
		)
	end
	local function etatDefis(): ({ string }, { number }, { string })
		local jour = joueur:GetAttribute("DefisJour")
		local ids =
			Cadeau.defisDu(if type(jour) == "number" then jour else aujourdhui(), joueur.UserId)
		local progres = {}
		for i, m in liste("DefisProgres") do
			progres[i] = tonumber(m) or 0
		end
		local faits = liste("DefisReclames")
		if jour ~= aujourdhui() then
			progres, faits = {}, {} -- le serveur remettra à zéro au prochain progrès
		end
		return ids, progres, faits
	end
	local function aReclamer(): number
		local n = if etatQuotidien() then 1 else 0
		local ids, progres, faits = etatDefis()
		for i, id in ids do
			local d = (Config.Defis.Liste :: any)[id]
			if (progres[i] or 0) >= d.Objectif and faits[i] ~= "1" then
				n += 1
			end
		end
		return n
	end

	local ecran = Instance.new("ScreenGui")
	ecran.Name = "InterfaceCadeaux"
	ecran.ResetOnSpawn = false
	ecran.DisplayOrder = 6

	-- Troisième rangée des boutons de droite (sous Top/Livre/Base/Shop).
	local yRangee = 1.5 * Style.TailleBoutonMin + 18
	local bouton = Habillage.bouton(ecran, "BoutonCadeaux", {
		texte = "Cadeaux",
		couleur = ROSE,
		rond = true,
		icone = "🎁",
	})
	bouton.AnchorPoint = Vector2.new(1, 0.5)
	bouton.Position = UDim2.new(1, -Style.TailleBoutonMin - 22, 0.42, yRangee)
	local boutonReglages = Habillage.bouton(ecran, "BoutonReglages", {
		texte = "Options",
		couleur = Color3.fromRGB(120, 140, 170),
		rond = true,
		icone = "⚙️",
	})
	boutonReglages.AnchorPoint = Vector2.new(1, 0.5)
	boutonReglages.Position = UDim2.new(1, -12, 0.42, yRangee)

	-- Pastille rouge : nombre de récompenses à réclamer.
	local pastille = Instance.new("TextLabel")
	pastille.Name = "Pastille"
	pastille.AnchorPoint = Vector2.new(0.5, 0.5)
	pastille.Position = UDim2.new(1, -4, 0, 4)
	pastille.Size = UDim2.fromOffset(26, 26)
	pastille.BackgroundColor3 = Color3.fromRGB(235, 50, 60)
	pastille.TextColor3 = Color3.new(1, 1, 1)
	pastille.Font = Habillage.Police
	pastille.TextScaled = true
	pastille.ZIndex = 20
	pastille.Visible = false
	pastille.Parent = bouton
	Habillage.arrondi(pastille, 0.5)
	Habillage.contour(pastille, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)

	---------------------------------------------------------------------------
	-- Panneau Cadeaux

	local panneau = Instance.new("Frame")
	panneau.Name = "Panneau"
	panneau.AnchorPoint = Vector2.new(0.5, 0.5)
	panneau.Position = UDim2.fromScale(0.5, 0.5)
	panneau.Size = UDim2.new(0.92, 0, 0.86, 0)
	panneau.BackgroundColor3 = Habillage.nommee("Fond")
	panneau.BackgroundTransparency = 0.08
	panneau.Visible = false
	panneau.Parent = ecran
	Habillage.panneau(panneau, ROSE)
	local limite = Instance.new("UISizeConstraint")
	limite.MaxSize = Vector2.new(640, 600)
	limite.Parent = panneau

	local titre =
		Habillage.texte(panneau, "Titre", { couleur = ROSE, contour = Style.Contour.Moyen })
	titre.Position = UDim2.fromOffset(14, 8)
	titre.Size = UDim2.new(1, -80, 0, 40)
	titre.TextXAlignment = Enum.TextXAlignment.Left
	titre.Text = "🎁 Cadeaux"
	local fermer = Habillage.bouton(panneau, "Fermer", {
		texte = "X",
		couleur = Habillage.nommee("Rouge"),
		taille = Vector2.new(44, 44),
	})
	fermer.AnchorPoint = Vector2.new(1, 0)
	fermer.Position = UDim2.new(1, -10, 0, 8)

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

	local onglet = "Connexion"
	local boutonsOnglets: { [string]: TextButton } = {}
	local afficher: () -> ()
	local ONGLETS = { "Connexion", "Défis", "Codes" }
	for ordre, nom in ONGLETS do
		local b = Habillage.bouton(
			barre,
			nom,
			{ texte = nom, couleur = INACTIF, taille = Vector2.new(140, 44) }
		)
		b.LayoutOrder = ordre
		b.Size = UDim2.new(1 / #ONGLETS, -4, 1, 0)
		b.Activated:Connect(function()
			onglet = nom
			afficher()
		end)
		boutonsOnglets[nom] = b
	end

	local function vider()
		for _, enfant in contenu:GetChildren() do
			if enfant:IsA("GuiObject") or enfant:IsA("UIListLayout") then
				enfant:Destroy()
			end
		end
	end

	local function carte(parent: Instance, ordre: number, teinte: Color3): Frame
		local cadre = Instance.new("Frame")
		cadre.LayoutOrder = ordre
		cadre.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		cadre.Parent = parent
		Habillage.arrondi(cadre, 0.12)
		local trait = Habillage.contour(cadre, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)
		trait.Color = teinte
		return cadre
	end

	-- Texte d'une récompense (pièces chiffrées selon le revenu actuel).
	local function texteRecompense(r: any): (string, string)
		if r.Type == "Pieces" then
			return "💰", Nombres.abreger(Cadeau.pieces(revenu(), r.Minutes))
		elseif r.Type == "Boost" then
			return "⚡", "Revenus ×2"
		elseif r.Type == "Roue" then
			return "🎡", "Roue gratuite"
		end
		return "💎", "Graine cristal"
	end

	-- Onglet Connexion : 7 cases (jour 1 à 7), la case du jour s'allume.
	local function connexionOnglet()
		local dispo, serie = etatQuotidien()
		local pile = Instance.new("UIListLayout")
		pile.SortOrder = Enum.SortOrder.LayoutOrder
		pile.Padding = UDim.new(0, 8)
		pile.Parent = contenu
		local cases = Instance.new("Frame")
		cases.Name = "Cases"
		cases.LayoutOrder = 1
		cases.Size = UDim2.new(1, 0, 0, 2 * 120 + 8)
		cases.BackgroundTransparency = 1
		cases.Parent = contenu
		local grille = Instance.new("UIGridLayout")
		grille.CellSize = UDim2.new(0.25, -8, 0, 120)
		grille.CellPadding = UDim2.fromOffset(8, 8)
		grille.SortOrder = Enum.SortOrder.LayoutOrder
		grille.HorizontalAlignment = Enum.HorizontalAlignment.Center
		grille.Parent = cases
		for jour, r in Config.Quotidien.Recompenses do
			local deja = jour < serie or (jour == serie and not dispo)
			local cible = jour == serie and dispo
			local teinte = if cible then OR elseif deja then VERT else INACTIF
			local cadre = carte(cases, jour, teinte)
			if cible then
				cadre.BackgroundColor3 = Color3.fromRGB(80, 60, 40)
			end
			local icone, valeur = texteRecompense(r)
			local t =
				Habillage.texte(cadre, "Jour", { couleur = teinte, contour = Style.Contour.Petit })
			t.Size = UDim2.new(1, -8, 0, 24)
			t.Position = UDim2.fromOffset(4, 4)
			t.TextScaled = true
			t.Text = if jour == 7 then "Jour 7 ⭐" else `Jour {jour}`
			local i = Habillage.texte(cadre, "Icone", {})
			i.Size = UDim2.new(1, 0, 0, 44)
			i.Position = UDim2.fromOffset(0, 28)
			i.TextScaled = true
			i.Text = if deja then "✅" else icone
			local v = Habillage.texte(cadre, "Valeur", { contour = Style.Contour.Petit })
			v.Size = UDim2.new(1, -8, 0, 34)
			v.Position = UDim2.fromOffset(4, 78)
			v.TextScaled = true
			v.Text = valeur
		end
		-- Le grand bouton « Récupérer » (ou le temps avant le prochain cadeau).
		local action = Instance.new("Frame")
		action.LayoutOrder = 2
		action.Size = UDim2.new(1, 0, 0, 64)
		action.BackgroundTransparency = 1
		action.Parent = contenu
		local b = Habillage.bouton(action, "Recuperer", {
			texte = if dispo
				then `Récupérer le jour {serie} !`
				else `Prochain cadeau dans {duree(
					(aujourdhui() + 1) * 86400 - Workspace:GetServerTimeNow()
				)}`,
			couleur = if dispo then VERT else INACTIF,
			taille = Vector2.new(300, 56),
		})
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.Position = UDim2.fromScale(0.5, 0.5)
		b.Size = UDim2.new(0.8, 0, 0, 56)
		if dispo then
			b.Activated:Connect(function()
				remotes.quotidien:FireServer()
				Sons.jingle("Palier")
			end)
		end
	end

	-- Onglet Défis : 3 lignes avec barre de progression.
	local function defisOnglet()
		local pile = Instance.new("UIListLayout")
		pile.SortOrder = Enum.SortOrder.LayoutOrder
		pile.Padding = UDim.new(0, 8)
		pile.Parent = contenu
		local ids, progres, faits = etatDefis()
		for i, id in ids do
			local d = (Config.Defis.Liste :: any)[id]
			local fait = math.min(progres[i] or 0, d.Objectif)
			local fini = fait >= d.Objectif
			local reclame = faits[i] == "1"
			local teinte = if reclame then VERT elseif fini then OR else ROSE
			local cadre = carte(contenu, i, teinte)
			cadre.Size = UDim2.new(1, -8, 0, 92)
			local t =
				Habillage.texte(cadre, "Titre", { couleur = teinte, contour = Style.Contour.Petit })
			t.Position = UDim2.fromOffset(14, 6)
			t.Size = UDim2.new(1, -170, 0, 30)
			t.TextXAlignment = Enum.TextXAlignment.Left
			t.TextScaled = true
			t.Text = Cadeau.texteDefi(id)
			local fond = Instance.new("Frame")
			fond.Position = UDim2.fromOffset(14, 44)
			fond.Size = UDim2.new(1, -170, 0, 18)
			fond.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
			fond.Parent = cadre
			Habillage.arrondi(fond, 0.5)
			local plein = Instance.new("Frame")
			plein.Size = UDim2.fromScale(fait / d.Objectif, 1)
			plein.BackgroundColor3 = teinte
			plein.Parent = fond
			Habillage.arrondi(plein, 0.5)
			local c = Habillage.texte(cadre, "Compte", { contour = Style.Contour.Petit })
			c.Position = UDim2.fromOffset(14, 64)
			c.Size = UDim2.new(1, -170, 0, 22)
			c.TextXAlignment = Enum.TextXAlignment.Left
			c.TextScaled = true
			c.Text = `{math.floor(fait)} / {d.Objectif}  ·  💰 {Nombres.abreger(
				Cadeau.pieces(revenu(), d.Minutes)
			)}`
			local b = Habillage.bouton(cadre, "Action", {
				texte = if reclame then "✅" elseif fini then "Réclamer" else "En cours",
				couleur = if fini and not reclame then VERT else INACTIF,
				taille = Vector2.new(140, 70),
			})
			b.AnchorPoint = Vector2.new(1, 0.5)
			b.Position = UDim2.new(1, -8, 0.5, 0)
			if fini and not reclame then
				b.Activated:Connect(function()
					remotes.defi:FireServer(i)
					Sons.jingle("Rare")
				end)
			end
		end
		local info = Habillage.texte(contenu, "Info", { contour = Style.Contour.Petit })
		info.LayoutOrder = 99
		info.Size = UDim2.new(1, -8, 0, 26)
		info.TextScaled = true
		info.Text = `Nouveaux défis dans {duree(
			(aujourdhui() + 1) * 86400 - Workspace:GetServerTimeNow()
		)}`
	end

	-- Onglet Codes : une zone de saisie et un bouton.
	local retourCode = ""
	local retourOk = false
	local function codesOnglet()
		local pile = Instance.new("UIListLayout")
		pile.SortOrder = Enum.SortOrder.LayoutOrder
		pile.Padding = UDim.new(0, 10)
		pile.HorizontalAlignment = Enum.HorizontalAlignment.Center
		pile.Parent = contenu
		local aide = Habillage.texte(contenu, "Aide", { contour = Style.Contour.Petit })
		aide.LayoutOrder = 1
		aide.Size = UDim2.new(1, -8, 0, 30)
		aide.TextScaled = true
		aide.Text = "Entre un code pour gagner un cadeau 🎟️"
		local saisie = Instance.new("TextBox")
		saisie.Name = "Saisie"
		saisie.LayoutOrder = 2
		saisie.Size = UDim2.new(0.8, 0, 0, 56)
		saisie.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
		saisie.TextColor3 = Color3.new(1, 1, 1)
		saisie.PlaceholderText = "CODE"
		saisie.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
		saisie.Font = Habillage.Police
		saisie.TextScaled = true
		saisie.ClearTextOnFocus = false
		saisie.Text = ""
		saisie.Parent = contenu
		Habillage.arrondi(saisie, 0.25)
		Habillage.contour(saisie, Style.Contour.Petit, Enum.ApplyStrokeMode.Border).Color = ROSE
		local b = Habillage.bouton(
			contenu,
			"Valider",
			{ texte = "Valider", couleur = VERT, taille = Vector2.new(220, 56) }
		)
		b.LayoutOrder = 3
		b.Activated:Connect(function()
			if saisie.Text ~= "" then
				remotes.code:FireServer(saisie.Text)
			end
		end)
		local retour = Habillage.texte(
			contenu,
			"Retour",
			{ couleur = if retourOk then VERT else ROSE, contour = Style.Contour.Petit }
		)
		retour.LayoutOrder = 4
		retour.Size = UDim2.new(1, -8, 0, 30)
		retour.TextScaled = true
		retour.Text = retourCode
	end

	function afficher()
		local n = aReclamer()
		pastille.Visible = n > 0
		pastille.Text = tostring(n)
		if not panneau.Visible then
			return
		end
		for nom, b in boutonsOnglets do
			b.BackgroundColor3 = if nom == onglet then ROSE else INACTIF
		end
		vider()
		if onglet == "Connexion" then
			connexionOnglet()
		elseif onglet == "Défis" then
			defisOnglet()
		else
			codesOnglet()
		end
	end

	remotes.resultatCode.OnClientEvent:Connect(function(ok: any, texte: any)
		retourOk = ok == true
		retourCode = if type(texte) == "string" then texte else ""
		if retourOk then
			Sons.jingle("Rare")
		end
		if panneau.Visible and onglet == "Codes" then
			afficher()
		end
	end)

	bouton.Activated:Connect(function()
		panneau.Visible = not panneau.Visible
		if panneau.Visible then
			-- S'il y a un cadeau de connexion, on ouvre directement dessus.
			if etatQuotidien() then
				onglet = "Connexion"
			end
			Habillage.apparaitre(panneau)
		end
		afficher()
	end)
	fermer.Activated:Connect(function()
		panneau.Visible = false
	end)
	for _, nom in
		{ "QuotidienSerie", "QuotidienJour", "DefisJour", "DefisProgres", "DefisReclames" }
	do
		joueur:GetAttributeChangedSignal(nom):Connect(function()
			-- Pas de reconstruction pendant la saisie d'un code.
			if onglet ~= "Codes" then
				afficher()
			end
		end)
	end
	-- Comptes à rebours et changement de jour.
	task.spawn(function()
		while true do
			task.wait(30)
			if onglet ~= "Codes" then
				afficher()
			end
		end
	end)

	---------------------------------------------------------------------------
	-- Panneau Réglages

	local reglages = Instance.new("Frame")
	reglages.Name = "Reglages"
	reglages.AnchorPoint = Vector2.new(0.5, 0.5)
	reglages.Position = UDim2.fromScale(0.5, 0.5)
	reglages.Size = UDim2.fromOffset(360, 250)
	reglages.BackgroundColor3 = Habillage.nommee("Fond")
	reglages.BackgroundTransparency = 0.08
	reglages.Visible = false
	reglages.Parent = ecran
	Habillage.panneau(reglages, Color3.fromRGB(120, 140, 170))
	local titreR = Habillage.texte(reglages, "Titre", { contour = Style.Contour.Moyen })
	titreR.Position = UDim2.fromOffset(14, 8)
	titreR.Size = UDim2.new(1, -80, 0, 40)
	titreR.TextXAlignment = Enum.TextXAlignment.Left
	titreR.Text = "⚙️ Options"
	local fermerR = Habillage.bouton(reglages, "Fermer", {
		texte = "X",
		couleur = Habillage.nommee("Rouge"),
		taille = Vector2.new(44, 44),
	})
	fermerR.AnchorPoint = Vector2.new(1, 0)
	fermerR.Position = UDim2.new(1, -10, 0, 8)

	local function interrupteur(y: number, nom: string, libelle: string)
		local t = Habillage.texte(reglages, "Libelle" .. nom, { contour = Style.Contour.Petit })
		t.Position = UDim2.fromOffset(20, y)
		t.Size = UDim2.new(1, -190, 0, 56)
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.TextScaled = true
		t.Text = libelle
		local plafond = Instance.new("UITextSizeConstraint")
		plafond.MaxTextSize = 30
		plafond.Parent = t
		local b = Habillage.bouton(
			reglages,
			"Bouton" .. nom,
			{ texte = "", couleur = VERT, taille = Vector2.new(140, 56) }
		)
		b.AnchorPoint = Vector2.new(1, 0)
		b.Position = UDim2.new(1, -20, 0, y)
		local function maj()
			local actif = joueur:GetAttribute("Reglage" .. nom) ~= false
			b.BackgroundColor3 = if actif then VERT else INACTIF
			local face = b:FindFirstChild("Face")
			local texte = face and face:FindFirstChild("Texte")
			if texte and texte:IsA("TextLabel") then
				texte.Text = if actif then "Oui" else "Non"
			end
		end
		b.Activated:Connect(function()
			remotes.reglage:FireServer(nom, joueur:GetAttribute("Reglage" .. nom) == false)
		end)
		joueur:GetAttributeChangedSignal("Reglage" .. nom):Connect(maj)
		maj()
	end
	interrupteur(70, "Son", "🔊 Sons")
	interrupteur(150, "Musique", "🎵 Musique")

	boutonReglages.Activated:Connect(function()
		reglages.Visible = not reglages.Visible
		if reglages.Visible then
			Habillage.apparaitre(reglages)
		end
	end)
	fermerR.Activated:Connect(function()
		reglages.Visible = false
	end)

	afficher()
	ecran.Parent = joueur:WaitForChild("PlayerGui")
end

return InterfaceCadeaux
