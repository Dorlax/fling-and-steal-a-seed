--!strict
-- Lancer côté client (affichage seulement) :
-- * animation du personnage qui lance (élan, bras qui fouette, accompagnement),
--   jouée pour tous les joueurs quand leur attribut « Lancers » augmente ;
-- * pour le lanceur : la caméra suit sa graine en vol, la distance défile en
--   gros, puis à l'atterrissage la distance finale, la rareté et la créature
--   s'affichent avant que la caméra revienne au joueur.
-- Le vol est rejoué localement à partir du départ et de l'arrivée envoyés par
-- le serveur (la graine du serveur peut ne pas être chargée de si loin).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Fiche = require(Shared:WaitForChild("Fiche"))
local Style = require(Shared:WaitForChild("Style"))
local Habillage = require(script.Parent:WaitForChild("Habillage"))
local Sons = require(script.Parent:WaitForChild("Sons"))

local LancerVisuel = {}

local DUREE_GESTE = 0.7 -- secondes de l'animation du lancer
local HAUTEUR_VOL = 45 -- même arc que le serveur
local RECUL_CAMERA = Vector3.new(0, 16, -34) -- derrière et au-dessus de la graine
local PAUSE_ATTERRISSAGE = 1.8 -- secondes sur le point d'atterrissage

local joueurLocal = Players.LocalPlayer

-- ===== Geste du lancer =====

local gestes: { [Model]: number } = {} -- personnage -> début du geste (os.clock)

local function moteur(personnage: Model, partie: string, nom: string): Motor6D?
	local p = personnage:FindFirstChild(partie)
	local m = p and p:FindFirstChild(nom)
	return if m and m:IsA("Motor6D") then m else nil
end

local function lisse(a: number, b: number, t: number): number
	local u = math.clamp(t, 0, 1)
	u = u * u * (3 - 2 * u)
	return a + (b - a) * u
end

-- Angles du geste à l'instant t (0 -> 1) : élan arrière, fouetté, accompagnement.
local function geste(t: number): (number, number, number, number)
	-- epaule (> 0 : bras vers l'avant / le haut), coude, rotation du buste,
	-- penché du buste vers l'avant.
	if t < 0.35 then
		local u = t / 0.35
		return lisse(0, -1.5, u), lisse(0, 1.2, u), lisse(0, 0.55, u), lisse(0, -0.12, u)
	elseif t < 0.55 then
		local u = (t - 0.35) / 0.2
		local epaule, coude = lisse(-1.5, 2.7, u), lisse(1.2, 0.1, u)
		return epaule, coude, lisse(0.55, -0.45, u), lisse(-0.12, 0.3, u)
	end
	local u = (t - 0.55) / 0.45
	return lisse(2.7, 0, u), lisse(0.1, 0, u), lisse(-0.45, 0, u), lisse(0.3, 0, u)
end

local function animerGestes()
	local maintenant = os.clock()
	for personnage, debut in gestes do
		local t = (maintenant - debut) / DUREE_GESTE
		if t >= 1 or personnage.Parent == nil then
			gestes[personnage] = nil
			continue
		end
		local epaule, coude, buste, penche = geste(t)
		local humanoide = personnage:FindFirstChildOfClass("Humanoid")
		if humanoide and humanoide.RigType == Enum.HumanoidRigType.R15 then
			local e = moteur(personnage, "RightUpperArm", "RightShoulder")
			local c = moteur(personnage, "RightLowerArm", "RightElbow")
			local w = moteur(personnage, "UpperTorso", "Waist")
			if e then
				e.Transform = CFrame.Angles(epaule, 0, 0.25)
			end
			if c then
				c.Transform = CFrame.Angles(coude, 0, 0)
			end
			if w then
				w.Transform = CFrame.Angles(-penche, buste, 0)
			end
		else
			local e = moteur(personnage, "Torso", "Right Shoulder")
			if e then
				e.Transform = CFrame.Angles(0, 0, epaule)
			end
		end
	end
end

local function suivreLanceur(joueur: Player)
	local function lancer()
		local personnage = joueur.Character
		if personnage then
			gestes[personnage] = os.clock()
		end
	end
	joueur:GetAttributeChangedSignal("Lancers"):Connect(lancer)
end

-- ===== Caméra et affichage du lanceur =====

local ecran: ScreenGui? = nil
local compteur: TextLabel? = nil
local carte: TextLabel? = nil
local echelleCarte: UIScale? = nil
local volEnCours = 0

local function creerEcran()
	local e = Instance.new("ScreenGui")
	e.Name = "LancerVisuel"
	e.ResetOnSpawn = false
	e.IgnoreGuiInset = true
	local c = Habillage.texte(e, "Distance", { contour = Style.Contour.Gros })
	c.AnchorPoint = Vector2.new(0.5, 0)
	c.Position = UDim2.fromScale(0.5, 0.1)
	c.Size = UDim2.fromScale(0.5, 0.11)
	c.Visible = false
	local r = Habillage.texte(e, "Resultat", { contour = Style.Contour.Gros })
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Position = UDim2.fromScale(0.5, 0.3)
	r.Size = UDim2.fromScale(0.6, 0.14)
	r.Visible = false
	local s = Instance.new("UIScale")
	s.Parent = r
	e.Parent = joueurLocal:WaitForChild("PlayerGui")
	ecran, compteur, carte, echelleCarte = e, c, r, s
end

-- Point de l'arc à l'instant a (0 -> 1).
local function surArc(depart: Vector3, arrivee: Vector3, a: number): Vector3
	return depart:Lerp(arrivee, a) + Vector3.new(0, 4 * a * (1 - a) * HAUTEUR_VOL, 0)
end

local function graineLocale(position: Vector3): Part
	local g = Instance.new("Part")
	g.Name = "GraineSuivie"
	g.Shape = Enum.PartType.Ball
	g.Size = Vector3.one * 1.6
	g.Anchored = true
	g.CanCollide = false
	g.CanQuery = false
	g.CanTouch = false
	g.Material = Enum.Material.Neon
	g.Color = Color3.fromRGB(255, 240, 150)
	g.Position = position
	local trainee = Instance.new("Trail")
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 0.5, 0)
	a0.Parent = g
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -0.5, 0)
	a1.Parent = g
	trainee.Attachment0 = a0
	trainee.Attachment1 = a1
	trainee.Lifetime = 0.5
	trainee.Color = ColorSequence.new(Color3.fromRGB(255, 240, 150), Color3.fromRGB(255, 160, 60))
	trainee.Transparency = NumberSequence.new(0.2, 1)
	trainee.LightEmission = 1
	trainee.Parent = g
	g.Parent = Workspace.CurrentCamera
	return g
end

local function cacherGrainesServeur()
	for _, enfant in Workspace:GetChildren() do
		local mienne = enfant:GetAttribute("Lanceur") == joueurLocal.UserId
		if enfant.Name == "Graine" and enfant:IsA("BasePart") and mienne then
			enfant.LocalTransparencyModifier = 1
			for _, l in enfant:GetDescendants() do
				if l:IsA("Light") then
					l.Enabled = false
				end
			end
		end
	end
end

local function afficherCarte(texte: string, couleur: Color3, taille: number)
	if carte == nil or echelleCarte == nil then
		return
	end
	local c = carte :: TextLabel
	local s = echelleCarte :: UIScale
	c.Text = texte
	c.TextColor3 = couleur
	c.Visible = true
	s.Scale = 0.3
	TweenService:Create(
		s,
		TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = taille }
	):Play()
end

-- Vol de la graine du joueur local, suivi par la caméra, puis révélation.
function LancerVisuel.suivre(resultat: any)
	local depart, arrivee = resultat.Depart, resultat.Arrivee
	if typeof(depart) ~= "Vector3" or typeof(arrivee) ~= "Vector3" then
		return
	end
	if ecran == nil then
		creerEcran()
	end
	volEnCours += 1
	local numero = volEnCours
	local camera = Workspace.CurrentCamera
	local duree = Config.Lancer.DureeVolGraine
	local ligne = Config.Monstres.BordBases
	task.spawn(function()
		-- Le geste d'élan d'abord, puis la graine part.
		task.wait(DUREE_GESTE * 0.45)
		if numero ~= volEnCours then
			return
		end
		cacherGrainesServeur()
		pcall(function()
			joueurLocal:RequestStreamAroundAsync(arrivee, 2)
		end)
		local graine = graineLocale(depart)
		local c = compteur :: TextLabel
		c.Visible = true
		c.TextColor3 = Color3.new(1, 1, 1)
		camera.CameraType = Enum.CameraType.Scriptable
		local debut = os.clock()
		local connexion = RunService.RenderStepped:Connect(function()
			local a = math.min((os.clock() - debut) / duree, 1)
			local p = surArc(depart, arrivee, a)
			graine.Position = p
			c.Text = `{math.max(0, math.floor(p.Z - ligne))} m`
			local vise = CFrame.lookAt(p + RECUL_CAMERA, p)
			camera.CFrame = camera.CFrame:Lerp(vise, 0.18)
		end)
		task.wait(duree)
		connexion:Disconnect()
		graine:Destroy()
		if numero ~= volEnCours then
			camera.CameraType = Enum.CameraType.Custom
			return
		end
		-- Atterrissage : distance finale, rareté et créature.
		local distance = math.floor(resultat.Distance)
		c.Text = `{distance} m`
		local rarete = if type(resultat.Rarete) == "string" then resultat.Rarete else "Commune"
		local taille = if type(resultat.Taille) == "string" then resultat.Taille else "Normale"
		local rang = table.find(Config.Raretes.Ordre, rarete) or 1
		Sons.jouer("Plouf")
		if rang >= 5 then
			Sons.jingle("Mythique")
		elseif rang >= 3 then
			Sons.jingle("Rare")
		end
		afficherCarte(
			Fiche.texte(rarete, taille),
			Habillage.couleur(Style.couleurRarete(rarete)),
			if rang >= 3 then 1.4 else 1.1
		)
		local fin = os.clock() + PAUSE_ATTERRISSAGE
		local regard = RunService.RenderStepped:Connect(function()
			local vise = CFrame.lookAt(arrivee + RECUL_CAMERA * 0.6, arrivee)
			camera.CFrame = camera.CFrame:Lerp(vise, 0.1)
		end)
		while os.clock() < fin and numero == volEnCours do
			task.wait()
		end
		regard:Disconnect()
		if numero == volEnCours then
			c.Visible = false
			if carte then
				(carte :: TextLabel).Visible = false
			end
			camera.CameraType = Enum.CameraType.Custom
		end
	end)
end

function LancerVisuel.demarrer()
	for _, joueur in Players:GetPlayers() do
		suivreLanceur(joueur)
	end
	Players.PlayerAdded:Connect(suivreLanceur)
	-- Après l'Animator, comme les poses de la Forge.
	RunService.PreSimulation:Connect(animerGestes)
end

return LancerVisuel
