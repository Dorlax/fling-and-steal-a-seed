--!strict
-- Fabrique d'éléments d'interface au style cartoon (textes, boutons, jauges,
-- animations). Toutes les valeurs viennent de Shared.Style ; ce module ne
-- fait que les convertir en instances Roblox. Affichage seulement.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Style = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Style"))
local Sons = require(script.Parent:WaitForChild("Sons"))

local Habillage = {}

Habillage.Police = (Enum.Font :: any)[Style.Police] :: Enum.Font

function Habillage.couleur(rgb: { number }): Color3
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

-- Couleur nommée de Style.Couleurs (« Vert », « Rouge »…).
function Habillage.nommee(nom: string): Color3
	local rgb = (Style.Couleurs :: any)[nom]
	if type(rgb) ~= "table" then
		return Color3.new(1, 1, 1)
	end
	return Habillage.couleur(rgb)
end

-- Contour noir (épaisseur toujours >= Style.Contour.Petit).
function Habillage.contour(
	element: GuiObject,
	epaisseur: number?,
	mode: Enum.ApplyStrokeMode?
): UIStroke
	local trait = Instance.new("UIStroke")
	trait.Thickness = math.max(epaisseur or Style.Contour.Moyen, Style.Contour.Petit)
	trait.Color = Color3.new(0, 0, 0)
	trait.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Contextual
	trait.Parent = element
	return trait
end

function Habillage.arrondi(element: GuiObject, echelle: number?): UICorner
	local coin = Instance.new("UICorner")
	coin.CornerRadius = UDim.new(echelle or Style.ArrondiBouton, 0)
	coin.Parent = element
	return coin
end

-- UIScale de l'élément (créé au besoin).
function Habillage.echelle(element: GuiObject): UIScale
	local existante = element:FindFirstChildOfClass("UIScale")
	if existante then
		return existante
	end
	local echelle = Instance.new("UIScale")
	echelle.Parent = element
	return echelle
end

-- Applique police, contour et taille minimale à un texte existant.
function Habillage.styliserTexte(
	label: any, -- TextLabel ou TextButton
	epaisseur: number?,
	tailleMin: number?
)
	label.Font = Habillage.Police
	label.TextScaled = true
	label.TextStrokeTransparency = 1
	Habillage.contour(label, epaisseur or Style.Contour.Moyen, Enum.ApplyStrokeMode.Contextual)
	local contrainte = Instance.new("UITextSizeConstraint")
	contrainte.MinTextSize = tailleMin or Style.TailleTexteMin
	contrainte.MaxTextSize = 100
	contrainte.Parent = label
end

export type OptionsTexte = {
	couleur: Color3?,
	contour: number?,
	tailleMin: number?,
}

-- Texte transparent, police ronde, contour noir, taille lisible.
function Habillage.texte(parent: Instance, nom: string, options: OptionsTexte?): TextLabel
	local o: OptionsTexte = options or {}
	local label = Instance.new("TextLabel")
	label.Name = nom
	label.BackgroundTransparency = 1
	label.TextColor3 = o.couleur or Color3.new(1, 1, 1)
	label.Text = ""
	Habillage.styliserTexte(label, o.contour, o.tailleMin)
	label.Parent = parent
	return label
end

-- Petit enfoncement puis retour (appui).
function Habillage.rebondir(element: GuiObject)
	local echelle = Habillage.echelle(element)
	echelle.Scale = Style.Rebond.Echelle
	TweenService:Create(
		echelle,
		TweenInfo.new(Style.Rebond.Duree, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
end

-- Apparition : échelle 0 -> 1.
function Habillage.apparaitre(element: GuiObject)
	local echelle = Habillage.echelle(element)
	echelle.Scale = 0
	TweenService:Create(
		echelle,
		TweenInfo.new(Style.Rebond.Duree, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
end

export type OptionsBouton = {
	texte: string?,
	couleur: Color3,
	taille: Vector2?,
	rond: boolean?,
	icone: string?, -- emoji affiché au-dessus du texte (gros boutons ronds)
}

local RELIEF = 5 -- hauteur de la tranche sous le bouton (px)

-- Couleur assombrie (0 = identique, 1 = noir).
function Habillage.assombrir(c: Color3, t: number): Color3
	return c:Lerp(Color3.new(0, 0, 0), t)
end

-- Gros bouton façon jeu « simulateur » : face colorée en relief sur une
-- tranche sombre, dégradé, reflet brillant, contour de la couleur assombrie.
-- S'enfonce à l'appui, grossit au survol. La couleur reste pilotée par
-- bouton.BackgroundColor3 (le bouton lui-même est transparent : la face et
-- la tranche suivent sa couleur). Renvoie le bouton et son texte.
function Habillage.bouton(
	parent: Instance,
	nom: string,
	options: OptionsBouton
): (TextButton, TextLabel)
	local taille = options.taille or Vector2.new(Style.TailleBoutonMin, Style.TailleBoutonMin)
	local arrondi = if options.rond then 0.5 else Style.ArrondiBouton
	local bouton = Instance.new("TextButton")
	bouton.Name = nom
	bouton.Size = UDim2.fromOffset(taille.X, taille.Y)
	bouton.BackgroundColor3 = options.couleur
	bouton.BackgroundTransparency = 1
	bouton.Font = Habillage.Police
	bouton.Text = ""
	bouton.Selectable = true -- manette
	bouton.AutoButtonColor = false

	local tranche = Instance.new("Frame")
	tranche.Name = "Tranche"
	tranche.Size = UDim2.new(1, 0, 1, 0)
	tranche.BorderSizePixel = 0
	Habillage.arrondi(tranche, arrondi)
	tranche.Parent = bouton

	local face = Instance.new("Frame")
	face.Name = "Face"
	face.Size = UDim2.new(1, 0, 1, -RELIEF)
	face.BorderSizePixel = 0
	Habillage.arrondi(face, arrondi)
	local degrade = Instance.new("UIGradient")
	degrade.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(205, 205, 215))
	degrade.Rotation = 90
	degrade.Parent = face
	local trait = Instance.new("UIStroke")
	trait.Thickness = Style.Contour.Petit
	trait.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	trait.Parent = face
	face.Parent = bouton

	-- Reflet : bande claire en haut de la face.
	local reflet = Instance.new("Frame")
	reflet.Name = "Reflet"
	reflet.AnchorPoint = Vector2.new(0.5, 0)
	reflet.Position = UDim2.new(0.5, 0, 0, 4)
	reflet.Size = UDim2.new(1, -14, 0.38, 0)
	reflet.BackgroundColor3 = Color3.new(1, 1, 1)
	reflet.BackgroundTransparency = 0.72
	reflet.BorderSizePixel = 0
	Habillage.arrondi(reflet, arrondi)
	reflet.Parent = face

	local libelle = Habillage.texte(face, "Texte", { contour = Style.Contour.Moyen })
	libelle.AnchorPoint = Vector2.new(0.5, 0.5)
	libelle.ZIndex = 2
	if options.icone then
		local icone = Instance.new("TextLabel")
		icone.Name = "Icone"
		icone.BackgroundTransparency = 1
		icone.AnchorPoint = Vector2.new(0.5, 0.5)
		icone.Position = UDim2.fromScale(0.5, 0.38)
		icone.Size = UDim2.fromScale(0.55, 0.45)
		icone.TextScaled = true
		icone.Font = Habillage.Police
		icone.Text = options.icone
		icone.ZIndex = 2
		icone.Parent = face
		libelle.Position = UDim2.fromScale(0.5, 0.76)
		libelle.Size = UDim2.new(0.86, 0, 0.26, 0)
	else
		libelle.Position = UDim2.fromScale(0.5, 0.5)
		libelle.Size = if options.rond then UDim2.new(1, -24, 0.5, 0) else UDim2.new(1, -16, 1, -12)
	end
	libelle.Text = options.texte or ""

	-- La couleur du bouton pilote face, tranche, contour et contour du texte.
	local function teindre()
		local c = bouton.BackgroundColor3
		face.BackgroundColor3 = c
		tranche.BackgroundColor3 = Habillage.assombrir(c, 0.45)
		trait.Color = Habillage.assombrir(c, 0.55)
		local contourTexte = libelle:FindFirstChildOfClass("UIStroke")
		if contourTexte then
			contourTexte.Color = Habillage.assombrir(c, 0.65)
		end
	end
	teindre()
	bouton:GetPropertyChangedSignal("BackgroundColor3"):Connect(teindre)

	-- Appui : la face descend sur sa tranche ; survol : léger grossissement.
	local function enfoncer(bas: boolean)
		TweenService:Create(face, TweenInfo.new(0.08), {
			Position = UDim2.fromOffset(0, if bas then RELIEF - 1 else 0),
		}):Play()
	end
	bouton.MouseButton1Down:Connect(function()
		enfoncer(true)
	end)
	bouton.MouseButton1Up:Connect(function()
		enfoncer(false)
	end)
	bouton.MouseLeave:Connect(function()
		enfoncer(false)
		TweenService:Create(Habillage.echelle(bouton), TweenInfo.new(0.12), { Scale = 1 }):Play()
	end)
	bouton.MouseEnter:Connect(function()
		TweenService:Create(Habillage.echelle(bouton), TweenInfo.new(0.12), { Scale = 1.05 }):Play()
	end)
	bouton.Activated:Connect(function()
		Habillage.rebondir(bouton)
		Sons.jouer("Clic")
	end)
	bouton.Parent = parent
	Habillage.apparaitre(bouton)
	return bouton, libelle
end

-- Habille un panneau existant : fond nuit dégradé, bordure de la couleur
-- d'accent, coins arrondis.
function Habillage.panneau(panneau: GuiObject, accent: Color3?)
	local couleur = accent or Habillage.nommee("Bleu")
	panneau.BackgroundColor3 = Color3.fromRGB(38, 44, 78)
	panneau.BackgroundTransparency = 0.04
	for _, ancien in panneau:GetChildren() do
		if ancien:IsA("UIStroke") or ancien:IsA("UICorner") or ancien:IsA("UIGradient") then
			ancien:Destroy()
		end
	end
	Habillage.arrondi(panneau, 0.06)
	local degrade = Instance.new("UIGradient")
	degrade.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(150, 150, 175))
	degrade.Rotation = 90
	degrade.Parent = panneau
	local bord = Instance.new("UIStroke")
	bord.Thickness = Style.Contour.Moyen
	bord.Color = couleur
	bord.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bord.Parent = panneau
end

-- ColorSequence continue construite depuis Style.Degrade.
function Habillage.degrade(): ColorSequence
	local points = {}
	for _, point in Style.Degrade do
		table.insert(points, ColorSequenceKeypoint.new(point[1], Habillage.couleur(point[2])))
	end
	return ColorSequence.new(points)
end

export type Jauge = {
	cadre: Frame,
	remplissage: Frame,
	maj: (ratio: number) -> (),
}

-- Barre horizontale : remplissage = ratio, couleur du dégradé, cachée à 0.
function Habillage.jauge(parent: Instance, nom: string, taille: UDim2): Jauge
	local cadre = Instance.new("Frame")
	cadre.Name = nom
	cadre.Size = taille
	cadre.BackgroundColor3 = Habillage.nommee("Fond")
	cadre.BackgroundTransparency = 0.2
	cadre.Visible = false
	cadre.ZIndex = 3
	Habillage.arrondi(cadre, 0.5)
	Habillage.contour(cadre, Style.Contour.Petit, Enum.ApplyStrokeMode.Border)
	cadre.Parent = parent

	local remplissage = Instance.new("Frame")
	remplissage.Name = "Remplissage"
	remplissage.Size = UDim2.fromScale(0, 1)
	remplissage.BorderSizePixel = 0
	remplissage.ZIndex = 4
	Habillage.arrondi(remplissage, 0.5)
	remplissage.Parent = cadre

	local function maj(ratio: number)
		local r = if type(ratio) == "number" and ratio == ratio then math.clamp(ratio, 0, 1) else 0
		cadre.Visible = r > 0
		remplissage.Size = UDim2.fromScale(r, 1)
		remplissage.BackgroundColor3 = Habillage.couleur(Style.couleurJauge(r))
	end
	maj(0)
	return { cadre = cadre, remplissage = remplissage, maj = maj }
end

-- Texte qui monte de Style.Flottant.Montee px et s'efface, puis disparaît.
function Habillage.flotter(
	parent: Instance,
	texte: string,
	couleur: Color3,
	position: UDim2,
	taille: UDim2
)
	local bulle =
		Habillage.texte(parent, "Flottant", { couleur = couleur, contour = Style.Contour.Petit })
	bulle.AnchorPoint = Vector2.new(0.5, 0)
	bulle.Position = position
	bulle.Size = taille
	bulle.Text = texte
	local trait = bulle:FindFirstChildOfClass("UIStroke")
	local info =
		TweenInfo.new(Style.Flottant.Duree, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(bulle, info, {
		Position = position - UDim2.fromOffset(0, Style.Flottant.Montee),
		TextTransparency = 1,
	}):Play()
	if trait then
		TweenService:Create(trait, info, { Transparency = 1 }):Play()
	end
	task.delay(Style.Flottant.Duree + 0.05, function()
		bulle:Destroy()
	end)
end

return Habillage
