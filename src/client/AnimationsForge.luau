--!strict
-- Forge côté client (affichage seulement, rien n'est envoyé au serveur) :
-- * n'affiche que l'agrès du mode du propriétaire (tapis, barre, corde) ;
-- * anime le personnage de tout joueur qui s'entraîne sur sa Forge
--   (course, soulevé de barre, corde à sauter), de plus en plus vite pendant
--   la série (attribut SerieDebut écrit par le serveur) ;
-- * fait défiler le tapis, affiche la vitesse sur l'écran, fait apparaître
--   la barre dans les mains et la corde qui tourne ;
-- * « +N » au-dessus de la tête du joueur local à chaque gain.
-- Les poses (Shared.PosesForge) remplacent l'animation par défaut en écrivant
-- Motor6D.Transform à chaque PreSimulation, après l'Animator.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Forge = require(Shared:WaitForChild("Forge"))
local Nombres = require(Shared:WaitForChild("Nombres"))
local PosesForge = require(Shared:WaitForChild("PosesForge"))

local AnimationsForge = {}

local TAG = "MachineForge"
local DISTANCE = 160
local HAUTEUR_TAPIS = 0.45
local COULEURS: { [string]: Color3 } = {
	Force = Color3.fromRGB(235, 70, 60),
	Vitesse = Color3.fromRGB(70, 165, 255),
	Double = Color3.fromRGB(175, 95, 255),
}
local JAUNE = Color3.fromRGB(255, 205, 50)
local ACIER = Color3.fromRGB(196, 202, 214)

type Machine = {
	modele: Model,
	plateforme: BasePart?,
	mode: string?,
	transparences: { [BasePart]: number },
	defilement: number,
	barreCachee: boolean,
}

type Moteurs = {
	r15: boolean,
	racine: Motor6D?,
	cou: Motor6D?,
	hancheG: Motor6D?,
	hancheD: Motor6D?,
	genouG: Motor6D?,
	genouD: Motor6D?,
	epauleG: Motor6D?,
	epauleD: Motor6D?,
	coudeG: Motor6D?,
	coudeD: Motor6D?,
}

type Sportif = {
	personnage: Model,
	moteurs: Moteurs,
	phase: number,
	actif: boolean,
	mode: string?,
	aligne: boolean,
	accessoires: Folder?,
}

local machines: { [Model]: Machine } = {}
local sportifs: { [Player]: Sportif } = {}
local dossierLocal: Folder? = nil

local function dossier(): Folder
	if dossierLocal == nil or dossierLocal.Parent == nil then
		local d = Instance.new("Folder")
		d.Name = "AccessoiresForge"
		d.Parent = Workspace
		dossierLocal = d
	end
	return dossierLocal :: Folder
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
	p.Material = Enum.Material.SmoothPlastic
	if forme then
		p.Shape = forme
	end
	p.Parent = parent
	return p
end

-- ===== Machines =====

local function proprietaireDe(modele: Model): Player?
	local id = modele:GetAttribute("Proprietaire")
	return if type(id) == "number" then Players:GetPlayerByUserId(id) else nil
end

local function machineDe(joueur: Player): Machine?
	for _, machine in machines do
		if machine.modele:GetAttribute("Proprietaire") == joueur.UserId then
			return machine
		end
	end
	return nil
end

local function intensiteDe(joueur: Player): number
	local debut = joueur:GetAttribute("SerieDebut")
	if type(debut) ~= "number" then
		return 0
	end
	return Forge.intensiteSerie(Workspace:GetServerTimeNow() - debut)
end

-- Montre l'agrès du mode et cache les autres (transparence locale).
local function afficherMode(machine: Machine, mode: string)
	machine.mode = mode
	local couleur = COULEURS[mode] or COULEURS.Force
	for _, enfant in machine.modele:GetChildren() do
		if enfant:IsA("BasePart") and enfant.Name == "Anneau" then
			enfant.Color = couleur
		elseif enfant:IsA("Model") and enfant:GetAttribute("Mode") ~= nil then
			local visible = enfant:GetAttribute("Mode") == mode
			for _, p in enfant:GetDescendants() do
				if p:IsA("BasePart") then
					if machine.transparences[p] == nil then
						machine.transparences[p] = p.Transparency
					end
					p.Transparency = if visible then machine.transparences[p] else 1
				elseif p:IsA("SurfaceGui") then
					p.Enabled = visible
				end
			end
		end
	end
	machine.barreCachee = false
end

local function cacherBarre(machine: Machine, cachee: boolean)
	if machine.barreCachee == cachee then
		return
	end
	machine.barreCachee = cachee
	local barre = machine.modele:FindFirstChild("Barre", true)
	if barre then
		for _, p in barre:GetDescendants() do
			if p:IsA("BasePart") then
				p.LocalTransparencyModifier = if cachee then 1 else 0
			end
		end
	end
end

local function ajouterMachine(instance: Instance)
	if not instance:IsA("Model") or machines[instance :: Model] then
		return
	end
	local modele = instance :: Model
	local plateforme = modele.Parent and modele.Parent:FindFirstChild("Forge")
	machines[modele] = {
		modele = modele,
		plateforme = if plateforme and plateforme:IsA("BasePart") then plateforme else nil,
		mode = nil,
		transparences = {},
		defilement = 0,
		barreCachee = false,
	}
end

local function majMachine(machine: Machine, dt: number)
	local joueur = proprietaireDe(machine.modele)
	local mode = if joueur then joueur:GetAttribute("ModeForge") else "Vitesse"
	if type(mode) ~= "string" then
		mode = "Vitesse"
	end
	if mode ~= machine.mode then
		afficherMode(machine, mode :: string)
	end
	local sportif = if joueur then sportifs[joueur] else nil
	local actif = sportif ~= nil and sportif.actif
	local intensite = if joueur and actif then intensiteDe(joueur) else 0
	cacherBarre(machine, actif and mode == "Force")

	if mode == "Vitesse" and machine.plateforme then
		local plateforme = machine.plateforme :: BasePart
		local origine = plateforme.Position + Vector3.new(0, plateforme.Size.Y / 2, 0)
		if actif then
			machine.defilement += dt * (6 + 14 * intensite)
		end
		for _, bande in machine.modele:GetDescendants() do
			local indice = bande:GetAttribute("Indice")
			if bande:IsA("BasePart") and bande.Name == "Bande" and type(indice) == "number" then
				local z = -3 + ((indice * 0.85 + machine.defilement) % 6.8)
				bande.CFrame = CFrame.new(origine + Vector3.new(0, 0.44, z))
			end
		end
		local texte = machine.modele:FindFirstChild("Texte", true)
		if texte and texte:IsA("TextLabel") then
			local multiplicateur = string.gsub(string.format("%.1f", 1 + intensite), "%.", ",")
			texte.Text = if actif then `× {multiplicateur}` else "VITESSE"
		end
	end
end

-- ===== Personnages =====

local function moteur(personnage: Model, partieNom: string, nom: string): Motor6D?
	local p = personnage:FindFirstChild(partieNom)
	local m = p and p:FindFirstChild(nom)
	return if m and m:IsA("Motor6D") then m else nil
end

local function moteursDe(personnage: Model): Moteurs
	local humanoide = personnage:FindFirstChildOfClass("Humanoid")
	if humanoide and humanoide.RigType == Enum.HumanoidRigType.R15 then
		return {
			r15 = true,
			racine = moteur(personnage, "LowerTorso", "Root"),
			cou = moteur(personnage, "Head", "Neck"),
			hancheG = moteur(personnage, "LeftUpperLeg", "LeftHip"),
			hancheD = moteur(personnage, "RightUpperLeg", "RightHip"),
			genouG = moteur(personnage, "LeftLowerLeg", "LeftKnee"),
			genouD = moteur(personnage, "RightLowerLeg", "RightKnee"),
			epauleG = moteur(personnage, "LeftUpperArm", "LeftShoulder"),
			epauleD = moteur(personnage, "RightUpperArm", "RightShoulder"),
			coudeG = moteur(personnage, "LeftLowerArm", "LeftElbow"),
			coudeD = moteur(personnage, "RightLowerArm", "RightElbow"),
		}
	end
	return {
		r15 = false,
		racine = moteur(personnage, "HumanoidRootPart", "RootJoint"),
		cou = moteur(personnage, "Torso", "Neck"),
		hancheG = moteur(personnage, "Torso", "Left Hip"),
		hancheD = moteur(personnage, "Torso", "Right Hip"),
		epauleG = moteur(personnage, "Torso", "Left Shoulder"),
		epauleD = moteur(personnage, "Torso", "Right Shoulder"),
	}
end

local function poser(m: Motor6D?, cf: CFrame)
	if m then
		m.Transform = cf
	end
end

local function appliquer(moteurs: Moteurs, pose: PosesForge.Pose, dy: number)
	if moteurs.r15 then
		poser(moteurs.racine, CFrame.new(0, pose.dy + dy, 0) * CFrame.Angles(-pose.penche, 0, 0))
		poser(moteurs.cou, CFrame.Angles(pose.tete, 0, 0))
		poser(moteurs.hancheG, CFrame.Angles(pose.hancheG, 0, 0))
		poser(moteurs.hancheD, CFrame.Angles(pose.hancheD, 0, 0))
		poser(moteurs.genouG, CFrame.Angles(-pose.genouG, 0, 0))
		poser(moteurs.genouD, CFrame.Angles(-pose.genouD, 0, 0))
		poser(moteurs.epauleG, CFrame.Angles(pose.epauleG, 0, -pose.ecartG))
		poser(moteurs.epauleD, CFrame.Angles(pose.epauleD, 0, pose.ecartD))
		poser(moteurs.coudeG, CFrame.Angles(pose.coudeG, 0, 0))
		poser(moteurs.coudeD, CFrame.Angles(pose.coudeD, 0, 0))
	else
		-- R6 : articulations tournées sur Z (droite + = avant, gauche - = avant).
		poser(moteurs.racine, CFrame.new(0, 0, pose.dy + dy))
		poser(moteurs.hancheG, CFrame.Angles(0, 0, -pose.hancheG))
		poser(moteurs.hancheD, CFrame.Angles(0, 0, pose.hancheD))
		poser(moteurs.epauleG, CFrame.Angles(0, 0, -pose.epauleG))
		poser(moteurs.epauleD, CFrame.Angles(0, 0, pose.epauleD))
	end
end

local function mains(personnage: Model): (Vector3?, Vector3?)
	local g = personnage:FindFirstChild("LeftHand") or personnage:FindFirstChild("Left Arm")
	local d = personnage:FindFirstChild("RightHand") or personnage:FindFirstChild("Right Arm")
	if g == nil or d == nil or not g:IsA("BasePart") or not d:IsA("BasePart") then
		return nil, nil
	end
	local bas = if (g :: BasePart).Name == "Left Arm" then Vector3.new(0, -0.9, 0) else Vector3.zero
	return (g :: BasePart).CFrame:PointToWorldSpace(bas),
		(d :: BasePart).CFrame:PointToWorldSpace(bas)
end

-- Repère dont l'axe X va d'une main à l'autre.
local function repereEntre(g: Vector3, d: Vector3): CFrame
	local x = (d - g)
	x = if x.Magnitude > 1e-3 then x.Unit else Vector3.xAxis
	local y = Vector3.yAxis
	if math.abs(x:Dot(y)) > 0.95 then
		y = Vector3.zAxis
	end
	local z = x:Cross(y).Unit
	y = z:Cross(x).Unit
	return CFrame.fromMatrix((g + d) / 2, x, y, z)
end

local function retirerAccessoires(sportif: Sportif)
	if sportif.accessoires then
		sportif.accessoires:Destroy()
		sportif.accessoires = nil
	end
end

-- Barre tenue à deux mains ; les disques grossissent avec la Force.
local function creerBarre(force: number): Folder
	local f = Instance.new("Folder")
	f.Name = "Barre"
	local tige = partie(f, Vector3.new(6.6, 0.24, 0.24), ACIER, Enum.PartType.Cylinder)
	tige.Name = "Tige"
	tige.Material = Enum.Material.Metal
	local d = 1.3 + 0.22 * math.min(10, math.log10(math.max(force, 0) + 1))
	for _, cote in { -1, 1 } do
		local grand = partie(f, Vector3.new(0.35, d, d), COULEURS.Force, Enum.PartType.Cylinder)
		grand.Name = "Disque"
		grand:SetAttribute("X", cote * 2.3)
		local petit = partie(f, Vector3.new(0.3, d * 0.72, d * 0.72), JAUNE, Enum.PartType.Cylinder)
		petit.Name = "Disque"
		petit:SetAttribute("X", cote * 2.65)
	end
	f.Parent = dossier()
	return f
end

local function creerCorde(): Folder
	local f = Instance.new("Folder")
	f.Name = "Corde"
	for i = 1, 18 do
		local brin = partie(f, Vector3.new(0.13, 0.13, 1), JAUNE)
		brin.Name = "Brin"
		brin.Material = Enum.Material.Neon
		brin:SetAttribute("Indice", i)
	end
	f.Parent = dossier()
	return f
end

local function placerAccessoires(sportif: Sportif, joueur: Player, sol: number?)
	local personnage = sportif.personnage
	local g, d = mains(personnage)
	if g == nil or d == nil then
		return
	end
	local mode = sportif.mode
	if mode == "Force" then
		if sportif.accessoires == nil then
			local force = joueur:GetAttribute("Force")
			sportif.accessoires = creerBarre(if type(force) == "number" then force else 0)
		end
		local repere = repereEntre(g :: Vector3, d :: Vector3)
		for _, p in (sportif.accessoires :: Folder):GetChildren() do
			if p:IsA("BasePart") then
				local x = p:GetAttribute("X")
				p.CFrame = repere * CFrame.new(if type(x) == "number" then x else 0, 0, 0)
			end
		end
	elseif mode == "Double" then
		if sportif.accessoires == nil then
			sportif.accessoires = creerCorde()
		end
		local axe = (d :: Vector3) - (g :: Vector3)
		local largeur = axe.Magnitude / 2
		local unite = if largeur > 1e-3 then axe.Unit else Vector3.xAxis
		local centre = ((g :: Vector3) + (d :: Vector3)) / 2
		-- Bas (perpendiculaire à l'axe des mains) et avant.
		local bas = (-Vector3.yAxis - unite * (-Vector3.yAxis):Dot(unite)).Unit
		local avant = unite:Cross(bas)
		local direction = bas * -math.cos(sportif.phase) + avant * math.sin(sportif.phase)
		local rayon = math.max(2.5, centre.Y - (sol or centre.Y - 3) + 0.15)
		local points = {}
		local n = 18
		for i = 0, n do
			local s = i / n * math.pi
			points[i] = centre - unite * (largeur * math.cos(s)) + direction * (rayon * math.sin(s))
		end
		for _, brin in (sportif.accessoires :: Folder):GetChildren() do
			local i = brin:GetAttribute("Indice")
			if brin:IsA("BasePart") and type(i) == "number" then
				local a, b = points[i - 1], points[i]
				brin.Size = Vector3.new(0.13, 0.13, (b - a).Magnitude + 0.05)
				brin.CFrame = CFrame.lookAt((a + b) / 2, b)
			end
		end
	end
end

-- Vrai si le joueur s'entraîne et reste immobile sur sa Forge.
local function estActif(joueur: Player, personnage: Model): boolean
	if joueur:GetAttribute("SurForge") ~= true then
		return false
	end
	local humanoide = personnage:FindFirstChildOfClass("Humanoid")
	local racine = personnage:FindFirstChild("HumanoidRootPart")
	if humanoide == nil or humanoide.Health <= 0 or racine == nil or not racine:IsA("BasePart") then
		return false
	end
	if joueur == Players.LocalPlayer then
		return (humanoide :: Humanoid).MoveDirection.Magnitude < 0.1
	end
	local v = (racine :: BasePart).AssemblyLinearVelocity
	return Vector3.new(v.X, 0, v.Z).Magnitude < 2
end

-- Place le joueur local au poste, face à l'agrès (une fois par série).
local function aligner(joueur: Player, personnage: Model)
	local machine = machineDe(joueur)
	local plateforme = machine and machine.plateforme
	local poste = plateforme and plateforme:FindFirstChild("Poste")
	local racine = personnage:FindFirstChild("HumanoidRootPart")
	if poste and poste:IsA("Attachment") and racine and racine:IsA("BasePart") then
		local p = poste.WorldPosition
		local position = Vector3.new(p.X, racine.Position.Y, p.Z)
		racine.CFrame = CFrame.lookAt(position, position - Vector3.zAxis)
	end
end

local function sportifDe(joueur: Player): Sportif?
	local trouve = joueur.Character
	if trouve == nil then
		return nil
	end
	local personnage = trouve :: Model
	local sportif = sportifs[joueur]
	if sportif == nil or sportif.personnage ~= personnage then
		if sportif then
			retirerAccessoires(sportif)
		end
		sportif = {
			personnage = personnage,
			moteurs = moteursDe(personnage),
			phase = 0,
			actif = false,
			mode = nil,
			aligne = false,
			accessoires = nil,
		}
		sportifs[joueur] = sportif
	end
	return sportif
end

local function pas(dt: number)
	local camera = Workspace.CurrentCamera
	local oeil = if camera then camera.CFrame.Position else Vector3.zero
	for _, joueur in Players:GetPlayers() do
		local sportif = sportifDe(joueur)
		local personnage = joueur.Character
		local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
		if sportif and personnage and racine and racine:IsA("BasePart") then
			local proche = (racine.Position - oeil).Magnitude < DISTANCE
			local mode = joueur:GetAttribute("ModeForge")
			local actif = proche and estActif(joueur, personnage) and type(mode) == "string"
			if mode ~= sportif.mode then
				retirerAccessoires(sportif)
				sportif.mode = if type(mode) == "string" then mode else nil
				sportif.aligne = false
			end
			if not actif then
				if sportif.actif then
					retirerAccessoires(sportif)
				end
				sportif.actif = false
				sportif.aligne = false
				sportif.phase = 0
			else
				sportif.actif = true
				if joueur == Players.LocalPlayer and not sportif.aligne then
					sportif.aligne = true
					aligner(joueur, personnage)
				end
				local intensite = intensiteDe(joueur)
				sportif.phase += dt * PosesForge.tempo(mode :: string, intensite)
				if mode == "Force" then
					sportif.phase %= 1
				else
					sportif.phase %= 2 * math.pi
				end
				local pose = PosesForge.pose(mode, sportif.phase, intensite)
				if pose then
					appliquer(sportif.moteurs, pose, if mode == "Vitesse" then HAUTEUR_TAPIS else 0)
				end
			end
		end
	end
	for joueur, sportif in sportifs do
		if joueur.Parent == nil then
			retirerAccessoires(sportif)
			sportifs[joueur] = nil
		end
	end
end

local function rendu(dt: number)
	for modele, machine in machines do
		if modele.Parent == nil then
			machines[modele] = nil
		else
			local proche = true
			local camera = Workspace.CurrentCamera
			if camera then
				proche = (modele:GetPivot().Position - camera.CFrame.Position).Magnitude < DISTANCE
			end
			if proche then
				majMachine(machine, dt)
			end
		end
	end
	for joueur, sportif in sportifs do
		if sportif.actif then
			local machine = machineDe(joueur)
			local plateforme = machine and machine.plateforme
			local sol = if plateforme then plateforme.Position.Y + plateforme.Size.Y / 2 else nil
			placerAccessoires(sportif, joueur, sol)
		end
	end
end

-- « +N » qui monte au-dessus de la tête du joueur local.
local function surgir(joueur: Player, texte: string, couleur: Color3)
	local personnage = joueur.Character
	local tete = personnage and personnage:FindFirstChild("Head")
	if tete == nil or not tete:IsA("BasePart") then
		return
	end
	local panneau = Instance.new("BillboardGui")
	panneau.Size = UDim2.fromOffset(140, 40)
	panneau.StudsOffset = Vector3.new(math.random(-10, 10) / 10, 2.2, 0)
	panneau.AlwaysOnTop = true
	panneau.Adornee = tete :: BasePart
	local etiquette = Instance.new("TextLabel")
	etiquette.Size = UDim2.fromScale(1, 1)
	etiquette.BackgroundTransparency = 1
	etiquette.Font = Enum.Font.FredokaOne
	etiquette.TextScaled = true
	etiquette.TextColor3 = couleur
	etiquette.TextStrokeTransparency = 0
	etiquette.Text = texte
	etiquette.Parent = panneau
	panneau.Parent = dossier()
	local info = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService
		:Create(panneau, info, { StudsOffset = panneau.StudsOffset + Vector3.new(0, 2.2, 0) })
		:Play()
	TweenService:Create(etiquette, info, { TextTransparency = 1, TextStrokeTransparency = 1 })
		:Play()
	task.delay(1, function()
		panneau:Destroy()
	end)
end

local function suivreGains()
	local joueur = Players.LocalPlayer
	for _, nom in { "Force", "Vitesse" } do
		local avant = joueur:GetAttribute(nom)
		joueur:GetAttributeChangedSignal(nom):Connect(function()
			local valeur = joueur:GetAttribute(nom)
			if
				type(valeur) == "number"
				and type(avant) == "number"
				and valeur > avant
				and joueur:GetAttribute("SurForge") == true
			then
				surgir(joueur, `+{Nombres.abreger(valeur - avant)}`, COULEURS[nom])
			end
			avant = valeur
		end)
	end
end

function AnimationsForge.demarrer()
	CollectionService:GetInstanceAddedSignal(TAG):Connect(ajouterMachine)
	for _, modele in CollectionService:GetTagged(TAG) do
		ajouterMachine(modele)
	end
	RunService.PreSimulation:Connect(pas)
	RunService.PreRender:Connect(rendu)
	suivreGains()
end

return AnimationsForge
