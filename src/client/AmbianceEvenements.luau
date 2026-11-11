--!strict
-- Ambiance des événements (client, visuel seulement) : bandeau animé à
-- l'annonce, teinte de la lumière, effets dans le ciel autour du joueur :
--   Heure dorée : lumière chaude et paillettes dorées qui flottent
--   Vent porteur : traits de vent et feuilles qui filent
--   Graines géantes : graines lumineuses géantes qui dérivent dans le ciel
--   Nuit des étoiles filantes : ciel bleu nuit, étoiles, étoiles filantes
--   Arc-en-ciel de chance : immense arc-en-ciel et confettis
--   Frénésie de la Forge : lumière ardente et braises qui montent
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Evenement = require(Shared:WaitForChild("Evenement"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))
local Sons = require(script.Parent:WaitForChild("Sons"))

local AmbianceEvenements = {}

local TEINTES: { [string]: { teinte: Color3, lumiere: number, saturation: number } } = {
	PluieDoree = { teinte = Color3.fromRGB(255, 236, 196), lumiere = 0.05, saturation = 0.15 },
	VentPorteur = { teinte = Color3.fromRGB(228, 244, 255), lumiere = 0.03, saturation = 0.05 },
	GrainesGeantes = { teinte = Color3.fromRGB(236, 222, 255), lumiere = 0.02, saturation = 0.1 },
	NuitEtoilee = { teinte = Color3.fromRGB(150, 165, 255), lumiere = -0.12, saturation = 0.05 },
	ArcEnCiel = { teinte = Color3.fromRGB(255, 236, 250), lumiere = 0.05, saturation = 0.25 },
	Frenesie = { teinte = Color3.fromRGB(255, 214, 196), lumiere = 0.03, saturation = 0.2 },
}

local TEXTURE_ETINCELLE = "rbxasset://textures/particles/sparkles_main.dds"
local TEXTURE_FUMEE = "rbxasset://textures/particles/smoke_main.dds"
local TEXTURE_FEU = "rbxasset://textures/particles/fire_main.dds"

local correction: ColorCorrectionEffect? = nil
local ciel: Part? = nil -- support invisible des particules, suit la caméra
local dossier: Folder? = nil -- objets propres à l'événement en cours
local connexions: { RBXScriptConnection } = {}

local function correctionLocale(): ColorCorrectionEffect
	if correction == nil or correction.Parent == nil then
		local c = Instance.new("ColorCorrectionEffect")
		c.Name = "AmbianceEvenement"
		c.Parent = Lighting
		correction = c
	end
	return correction :: ColorCorrectionEffect
end

local function partie(
	parent: Instance,
	taille: Vector3,
	couleur: Color3,
	forme: Enum.PartType?
): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = taille
	p.Color = couleur
	p.Material = Enum.Material.Neon
	if forme then
		p.Shape = forme
	end
	p.Parent = parent
	return p
end

local function emetteur(
	parent: Instance,
	texture: string,
	couleurs: ColorSequence,
	options: { [string]: any }
): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Texture = texture
	e.Color = couleurs
	e.LightEmission = options.lumiere or 1
	e.Size = options.taille or NumberSequence.new(0.6, 0)
	e.Transparency = options.transparence or NumberSequence.new(0.1, 1)
	e.Lifetime = options.duree or NumberRange.new(3, 5)
	e.Speed = options.vitesse or NumberRange.new(1, 3)
	e.SpreadAngle = options.dispersion or Vector2.new(30, 30)
	e.Acceleration = options.acceleration or Vector3.zero
	e.EmissionDirection = options.direction or Enum.NormalId.Bottom
	e.Rate = options.debit or 20
	e.Rotation = NumberRange.new(0, 360)
	e.RotSpeed = NumberRange.new(-60, 60)
	e.Parent = parent
	return e
end

local function nettoyer()
	for _, c in connexions do
		c:Disconnect()
	end
	connexions = {}
	if dossier then
		dossier:Destroy()
		dossier = nil
	end
	if ciel then
		ciel:Destroy()
		ciel = nil
	end
	local c = correctionLocale()
	TweenService:Create(c, TweenInfo.new(1.5), {
		TintColor = Color3.new(1, 1, 1),
		Brightness = 0,
		Saturation = 0,
	}):Play()
end

-- Grand bandeau d'annonce : icône, nom, effet ; arrive en rebondissant.
local function bandeau(infos: Evenement.Infos)
	local joueur = Players.LocalPlayer
	local ecran = Instance.new("ScreenGui")
	ecran.Name = "BandeauEvenement"
	ecran.ResetOnSpawn = false
	ecran.DisplayOrder = 20
	local cadre = Instance.new("Frame")
	cadre.AnchorPoint = Vector2.new(0.5, 0.5)
	cadre.Position = UDim2.fromScale(0.5, 0.3)
	cadre.Size = UDim2.fromOffset(520, 130)
	cadre.BackgroundColor3 = Habillage.couleur(infos.Couleur)
	cadre.Parent = ecran
	Habillage.arrondi(cadre, 0.3)
	local degrade = Instance.new("UIGradient")
	degrade.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 190, 205))
	degrade.Rotation = 90
	degrade.Parent = cadre
	local bord = Instance.new("UIStroke")
	bord.Thickness = 5
	bord.Color = Habillage.assombrir(Habillage.couleur(infos.Couleur), 0.55)
	bord.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bord.Parent = cadre
	local icone = Instance.new("TextLabel")
	icone.BackgroundTransparency = 1
	icone.Position = UDim2.fromOffset(10, 10)
	icone.Size = UDim2.fromOffset(110, 110)
	icone.TextScaled = true
	icone.Text = infos.Icone or "⭐"
	icone.Parent = cadre
	local titre = Habillage.texte(cadre, "Titre", { contour = 4 })
	titre.Position = UDim2.fromOffset(125, 12)
	titre.Size = UDim2.new(1, -140, 0, 64)
	titre.TextXAlignment = Enum.TextXAlignment.Left
	titre.Text = infos.Nom
	local effet = Habillage.texte(cadre, "Effet", { contour = 3 })
	effet.Position = UDim2.fromOffset(125, 78)
	effet.Size = UDim2.new(1, -140, 0, 38)
	effet.TextXAlignment = Enum.TextXAlignment.Left
	effet.Text = infos.Texte
	ecran.Parent = joueur:WaitForChild("PlayerGui")
	local echelle = Habillage.echelle(cadre)
	echelle.Scale = 0
	TweenService:Create(echelle, TweenInfo.new(0.5, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	-- Petite oscillation de l'icône.
	TweenService:Create(
		icone,
		TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Rotation = 12 }
	):Play()
	task.delay(3.5, function()
		TweenService
			:Create(echelle, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Scale = 0,
			})
			:Play()
		task.wait(0.4)
		ecran:Destroy()
	end)
end

-- Plateforme invisible au-dessus du joueur qui porte les particules.
local function creerCiel(hauteur: number, taille: number): Part
	local p = Instance.new("Part")
	p.Name = "CielEvenement"
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = Vector3.new(taille, 1, taille)
	p.Parent = Workspace
	ciel = p
	table.insert(
		connexions,
		RunService.Heartbeat:Connect(function()
			local camera = Workspace.CurrentCamera
			if camera then
				local o = camera.CFrame.Position
				p.CFrame = CFrame.new(o.X, o.Y + hauteur, o.Z)
			end
		end)
	)
	return p
end

-- Étoiles filantes : un trait lumineux traverse le ciel régulièrement.
local function etoilesFilantes(parent: Instance)
	table.insert(
		connexions,
		RunService.Heartbeat:Connect(function()
			if math.random() > 0.025 then
				return
			end
			local camera = Workspace.CurrentCamera
			if camera == nil then
				return
			end
			local o = camera.CFrame.Position
			local depart = o
				+ Vector3.new(math.random(-150, 150), math.random(70, 120), math.random(-150, 150))
			local direction = Vector3.new(math.random(-10, 10), -4, math.random(-10, 10)).Unit
			local etoile = partie(
				parent,
				Vector3.new(1.2, 1.2, 1.2),
				Color3.fromRGB(255, 255, 230),
				Enum.PartType.Ball
			)
			etoile.CFrame = CFrame.new(depart)
			local a0 = Instance.new("Attachment")
			a0.Position = Vector3.new(0, 0.5, 0)
			a0.Parent = etoile
			local a1 = Instance.new("Attachment")
			a1.Position = Vector3.new(0, -0.5, 0)
			a1.Parent = etoile
			local trace = Instance.new("Trail")
			trace.Attachment0 = a0
			trace.Attachment1 = a1
			trace.Lifetime = 0.5
			trace.LightEmission = 1
			trace.Color =
				ColorSequence.new(Color3.fromRGB(255, 255, 230), Color3.fromRGB(140, 170, 255))
			trace.Transparency = NumberSequence.new(0, 1)
			trace.WidthScale = NumberSequence.new(1, 0)
			trace.Parent = etoile
			TweenService:Create(etoile, TweenInfo.new(1.1, Enum.EasingStyle.Linear), {
				CFrame = CFrame.new(depart + direction * 160),
			}):Play()
			task.delay(1.2, function()
				etoile:Destroy()
			end)
		end)
	)
end

local function demarrer(id: string, infos: Evenement.Infos)
	nettoyer()
	local d = Instance.new("Folder")
	d.Name = "AmbianceEvenement"
	d.Parent = Workspace
	dossier = d
	local t = TEINTES[id]
	if t then
		TweenService:Create(correctionLocale(), TweenInfo.new(2), {
			TintColor = t.teinte,
			Brightness = t.lumiere,
			Saturation = t.saturation,
		}):Play()
	end
	if id == "PluieDoree" then
		local p = creerCiel(18, 140)
		emetteur(
			p,
			TEXTURE_ETINCELLE,
			ColorSequence.new(Color3.fromRGB(255, 230, 120), Color3.fromRGB(255, 190, 40)),
			{
				taille = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.3, 0.7),
					NumberSequenceKeypoint.new(1, 0),
				}),
				vitesse = NumberRange.new(1, 2.5),
				duree = NumberRange.new(5, 8),
				acceleration = Vector3.new(0, -0.6, 0),
				debit = 60,
			}
		)
	elseif id == "VentPorteur" then
		local p = creerCiel(6, 160)
		emetteur(p, TEXTURE_FUMEE, ColorSequence.new(Color3.new(1, 1, 1)), {
			taille = NumberSequence.new(0.5, 0.2),
			transparence = NumberSequence.new(0.6, 1),
			vitesse = NumberRange.new(40, 60),
			duree = NumberRange.new(1.5, 2.5),
			acceleration = Vector3.new(0, 0, 35),
			dispersion = Vector2.new(5, 5),
			direction = Enum.NormalId.Back,
			debit = 40,
		})
		emetteur(
			p,
			TEXTURE_ETINCELLE,
			ColorSequence.new(Color3.fromRGB(140, 230, 90), Color3.fromRGB(230, 200, 80)),
			{
				taille = NumberSequence.new(0.6, 0.3),
				vitesse = NumberRange.new(15, 30),
				duree = NumberRange.new(3, 4),
				acceleration = Vector3.new(0, -2, 25),
				direction = Enum.NormalId.Back,
				debit = 25,
			}
		)
	elseif id == "GrainesGeantes" then
		-- Graines géantes retirées : elles bouchaient la vue.
		local p = creerCiel(20, 120)
		emetteur(
			p,
			TEXTURE_ETINCELLE,
			ColorSequence.new(Color3.fromRGB(200, 255, 170), Color3.fromRGB(220, 170, 255)),
			{
				vitesse = NumberRange.new(0.5, 1.5),
				duree = NumberRange.new(4, 6),
				debit = 25,
			}
		)
	elseif id == "NuitEtoilee" then
		local p = creerCiel(90, 400)
		emetteur(
			p,
			TEXTURE_ETINCELLE,
			ColorSequence.new(Color3.fromRGB(255, 255, 230), Color3.fromRGB(170, 190, 255)),
			{
				taille = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 2.2),
					NumberSequenceKeypoint.new(1, 0),
				}),
				transparence = NumberSequence.new(0, 0.6),
				vitesse = NumberRange.new(0, 0.2),
				duree = NumberRange.new(2, 4),
				debit = 50,
			}
		)
		etoilesFilantes(d)
	elseif id == "ArcEnCiel" then
		-- Arc-en-ciel géant retiré : ses piliers bouchaient la vue un peu partout.
		local p = creerCiel(16, 120)
		local confettis = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 90)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 230, 70)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(90, 220, 140)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 120, 255)),
		})
		emetteur(p, TEXTURE_ETINCELLE, confettis, {
			taille = NumberSequence.new(0.6, 0.4),
			vitesse = NumberRange.new(2, 5),
			duree = NumberRange.new(4, 6),
			acceleration = Vector3.new(0, -2, 0),
			debit = 50,
		})
	elseif id == "Frenesie" then
		local p = creerCiel(-4, 90)
		emetteur(
			p,
			TEXTURE_FEU,
			ColorSequence.new(Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 80, 30)),
			{
				taille = NumberSequence.new(0.5, 0),
				vitesse = NumberRange.new(2, 5),
				duree = NumberRange.new(2, 4),
				acceleration = Vector3.new(0, 4, 0),
				direction = Enum.NormalId.Top,
				debit = 45,
			}
		)
	end
	bandeau(infos)
	Sons.jingle("Evenement")
end

function AmbianceEvenements.demarrer()
	local actuel: string? = nil
	local function maj()
		local id = Workspace:GetAttribute("Evenement")
		local infos = Evenement.infos(id)
		if infos == nil then
			if actuel ~= nil then
				actuel = nil
				nettoyer()
			end
			return
		end
		if id ~= actuel then
			actuel = id :: string
			demarrer(id :: string, infos :: Evenement.Infos)
		end
	end
	Workspace:GetAttributeChangedSignal("Evenement"):Connect(maj)
	maj()
end

return AmbianceEvenements
