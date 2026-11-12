--!strict
-- Forge côté client (affichage seulement, rien n'est envoyé au serveur) :
-- * n'affiche que l'agrès du mode du propriétaire (tapis, barre, corde) ;
-- * anime le personnage de tout joueur qui s'entraîne sur sa Forge
--   (course, soulevé, corde à sauter), plus vite quand l'agrès est moderne ;
-- * fait tourner la roue / défiler le tapis, affiche le gain sur l'écran,
--   met l'objet soulevé (rocher, haltères, barre, météorite) dans les mains
--   et fait tourner la corde ;
-- * « +N » au-dessus de la tête et fête du nouvel agrès pour le joueur local.
-- Les poses (Shared.PosesForge) remplacent l'animation par défaut en écrivant
-- Motor6D.Transform à chaque PreSimulation, après l'Animator.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Forge = require(Shared:WaitForChild("Forge"))
local Nombres = require(Shared:WaitForChild("Nombres"))
local PosesForge = require(Shared:WaitForChild("PosesForge"))
local Sons = require(script.Parent:WaitForChild("Sons"))

local AnimationsForge = {}

local TAG = "MachineForge"
local DISTANCE = 160
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
	palier: number?,
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

-- Intensité de l'animation : 0 pour l'agrès rustique, 1 pour le dernier.
local function intensiteDe(joueur: Player): number
	local paliers = #Config.Forge.Paliers
	return (Forge.palier(joueur:GetAttribute("NiveauForge")) - 1) / math.max(1, paliers - 1)
end

local function posteDe(machine: Machine, mode: string): Model?
	local m = machine.modele:FindFirstChild("Poste" .. mode)
	return if m and m:IsA("Model") then m else nil
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
	local force = posteDe(machine, "Force")
	local objet = force and force:FindFirstChild("Objet")
	if objet then
		for _, p in objet:GetDescendants() do
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
		palier = nil,
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

	if machine.palier ~= machine.modele:GetAttribute("Palier") then
		-- Machine reconstruite (nouveau palier) : tout réafficher.
		local palier = machine.modele:GetAttribute("Palier")
		machine.palier = if type(palier) == "number" then palier else nil
		machine.transparences = {}
		machine.barreCachee = false
		afficherMode(machine, mode :: string)
	end
	local vitesse = if mode == "Vitesse" then posteDe(machine, "Vitesse") else nil
	if vitesse then
		local niveau = if joueur then joueur:GetAttribute("NiveauForge") else 1
		local allure = 6 + 14 * intensite
		if actif then
			machine.defilement += dt * allure
		end
		local roue = vitesse:FindFirstChild("Roue")
		local axe = roue and roue:GetAttribute("Axe")
		local rayon = roue and roue:GetAttribute("Rayon")
		if roue and typeof(axe) == "CFrame" and type(rayon) == "number" then
			local rotation = (axe :: CFrame) * CFrame.Angles(-machine.defilement / rayon, 0, 0)
			for _, p in roue:GetChildren() do
				local decalage = p:GetAttribute("Decalage")
				if p:IsA("BasePart") and typeof(decalage) == "CFrame" then
					p.CFrame = rotation * decalage
				end
			end
		end
		for _, bande in vitesse:GetChildren() do
			local indice = bande:GetAttribute("Indice")
			if bande:IsA("BasePart") and type(indice) == "number" and machine.plateforme then
				local z = -3 + ((indice * 0.85 + machine.defilement) % 6.8)
				local centre = (machine.plateforme :: BasePart).Position
				bande.CFrame = CFrame.new(bande.Position.X, bande.Position.Y, centre.Z + z)
			end
		end
		local texte = vitesse:FindFirstChild("Texte", true)
		if texte and texte:IsA("TextLabel") then
			texte.Text = if actif then `+{Nombres.abreger(Forge.gainPour(niveau))}/s` else "GO !"
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

-- L'apparence de l'avatar remplace les membres (et leurs Motor6D) après
-- l'apparition : un moteur gardé en cache peut ne plus être dans le
-- personnage. On les recherche alors.
local function moteursValides(moteurs: Moteurs, personnage: Model): boolean
	for _, m in { moteurs.racine, moteurs.epauleD, moteurs.hancheG } do
		if m == nil or not (m :: Motor6D):IsDescendantOf(personnage) then
			return false
		end
	end
	return true
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

-- Objet soulevé selon l'agrès : X = décalage le long de l'axe des mains,
-- Y = au-dessus des mains (petit : l'objet reste dans les mains pendant tout
-- l'épaulé-jeté), Main = "G"/"D" pour un objet par main.
local function creerObjet(genre: string, force: number): Folder
	local f = Instance.new("Folder")
	f.Name = "Objet"
	local d = 1.3 + 0.22 * math.min(10, math.log10(math.max(force, 0) + 1))
	if genre == "Rocher" then
		for _, b in
			{
				{ 0, 0.1, 0, 1.6 },
				{ 0.55, 0.25, 0.2, 1.1 },
				{ -0.55, 0.2, -0.2, 1.1 },
				{ 0, 0.75, 0, 0.9 },
			}
		do
			local roc = partie(
				f,
				Vector3.new(b[4], b[4], b[4]),
				Color3.fromRGB(128, 124, 136),
				Enum.PartType.Ball
			)
			roc.Material = Enum.Material.Slate
			roc:SetAttribute("X", b[1])
			roc:SetAttribute("Y", b[2])
			roc:SetAttribute("Z", b[3])
		end
	elseif genre == "Halteres" then
		for _, main in { "G", "D" } do
			local poignee = partie(f, Vector3.new(1, 0.2, 0.2), ACIER, Enum.PartType.Cylinder)
			poignee:SetAttribute("Main", main)
			for _, cote in { -1, 1 } do
				local poids = partie(
					f,
					Vector3.new(0.3, 0.75, 0.75),
					if main == "G" then COULEURS.Vitesse else COULEURS.Force,
					Enum.PartType.Cylinder
				)
				poids:SetAttribute("Main", main)
				poids:SetAttribute("X", cote * 0.55)
			end
		end
	elseif genre == "Meteorite" then
		local roc =
			partie(f, Vector3.new(2.6, 2.6, 2.6), Color3.fromRGB(90, 50, 40), Enum.PartType.Ball)
		roc.Material = Enum.Material.CrackedLava
		roc:SetAttribute("Y", 0.5) -- tenue entre les mains
		local feu = Instance.new("ParticleEmitter")
		feu.Texture = "rbxasset://textures/particles/fire_main.dds"
		feu.Color = ColorSequence.new(Color3.fromRGB(255, 120, 40), Color3.fromRGB(255, 120, 210))
		feu.LightEmission = 1
		feu.Size = NumberSequence.new(1, 0)
		feu.Lifetime = NumberRange.new(0.3, 0.6)
		feu.Rate = 18
		feu.Parent = roc
	else
		local plasma = genre == "Plasma"
		local tige = partie(f, Vector3.new(6.6, 0.24, 0.24), ACIER, Enum.PartType.Cylinder)
		tige.Material = Enum.Material.Metal
		for _, cote in { -1, 1 } do
			if plasma then
				local disque = partie(
					f,
					Vector3.new(0.4, d, d),
					Color3.fromRGB(60, 240, 255),
					Enum.PartType.Cylinder
				)
				disque.Material = Enum.Material.Neon
				disque.Transparency = 0.3
				disque:SetAttribute("X", cote * 2.4)
			else
				local grand =
					partie(f, Vector3.new(0.35, d, d), COULEURS.Force, Enum.PartType.Cylinder)
				grand:SetAttribute("X", cote * 2.3)
				local petit =
					partie(f, Vector3.new(0.3, d * 0.72, d * 0.72), JAUNE, Enum.PartType.Cylinder)
				petit:SetAttribute("X", cote * 2.65)
			end
		end
	end
	f.Parent = dossier()
	return f
end

local COULEURS_CORDE: { [string]: Color3 } = {
	Lumineuse = JAUNE,
	Laser = Color3.fromRGB(60, 240, 255),
}

local function creerCorde(genre: string): Folder
	local f = Instance.new("Folder")
	f.Name = "Corde"
	for i = 1, 18 do
		local couleur = COULEURS_CORDE[genre] or Color3.fromHSV(i / 18, 0.7, 1)
		local brin = partie(f, Vector3.new(0.13, 0.13, 1), couleur)
		brin.Name = "Brin"
		brin.Material = Enum.Material.Neon
		brin:SetAttribute("Indice", i)
	end
	f.Parent = dossier()
	return f
end

local function attributStation(joueur: Player, mode: string, nom: string): any
	local machine = machineDe(joueur)
	local station = if machine then posteDe(machine, mode) else nil
	return if station then station:GetAttribute(nom) else nil
end

local function nombreOu(valeur: any, defaut: number): number
	return if type(valeur) == "number" then valeur else defaut
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
			local genre = attributStation(joueur, "Force", "Objet")
			sportif.accessoires = creerObjet(
				if type(genre) == "string" then genre else "Barre",
				nombreOu(joueur:GetAttribute("Force"), 0)
			)
		end
		local repere = repereEntre(g :: Vector3, d :: Vector3)
		for _, p in (sportif.accessoires :: Folder):GetChildren() do
			if p:IsA("BasePart") then
				local main = p:GetAttribute("Main")
				local base = if main == "G"
					then repere - repere.Position + (g :: Vector3)
					elseif main == "D" then repere - repere.Position + (d :: Vector3)
					else repere
				p.CFrame = base
					* CFrame.new(
						nombreOu(p:GetAttribute("X"), 0),
						nombreOu(p:GetAttribute("Y"), 0),
						nombreOu(p:GetAttribute("Z"), 0)
					)
			end
		end
	elseif mode == "Double" then
		if sportif.accessoires == nil then
			local genre = attributStation(joueur, "Double", "Corde")
			sportif.accessoires = creerCorde(if type(genre) == "string" then genre else "Lumineuse")
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
				if not moteursValides(sportif.moteurs, personnage) then
					sportif.moteurs = moteursDe(personnage)
				end
				if pose then
					local machine = machineDe(joueur)
					local station = if machine then posteDe(machine, mode :: string) else nil
					local hauteur = if station then station:GetAttribute("Hauteur") else nil
					appliquer(
						sportif.moteurs,
						pose,
						if type(hauteur) == "number" then hauteur else 0
					)
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

-- « +N » qui jaillissent autour de la tête du joueur local à chaque gain
-- (plusieurs par seconde) : icône, gros chiffres contourés, rebond, envol.
local ICONES: { [string]: string } = { Force = "💪", Vitesse = "👟" }
local MAX_JAILLISSEMENTS = 14
local jaillissements = 0

local function surgir(joueur: Player, texte: string, couleur: Color3)
	local personnage = joueur.Character
	local tete = personnage and personnage:FindFirstChild("Head")
	if tete == nil or not tete:IsA("BasePart") or jaillissements >= MAX_JAILLISSEMENTS then
		return
	end
	jaillissements += 1
	local panneau = Instance.new("BillboardGui")
	panneau.Size = UDim2.fromOffset(220, 64)
	local depart = Vector3.new(math.random(-18, 18) / 10, 1.4 + math.random(0, 14) / 10, 0)
	panneau.StudsOffset = depart
	panneau.AlwaysOnTop = true
	panneau.LightInfluence = 0
	panneau.Adornee = tete :: BasePart
	local etiquette = Instance.new("TextLabel")
	etiquette.Size = UDim2.fromScale(1, 1)
	etiquette.BackgroundTransparency = 1
	etiquette.Font = Enum.Font.FredokaOne
	etiquette.TextScaled = true
	etiquette.TextColor3 = Color3.new(1, 1, 1)
	etiquette.Text = texte
	etiquette.Parent = panneau
	-- Dégradé clair -> couleur de la stat, contour épais foncé.
	local degrade = Instance.new("UIGradient")
	degrade.Color = ColorSequence.new(Color3.new(1, 1, 1):Lerp(couleur, 0.35), couleur)
	degrade.Rotation = 90
	degrade.Parent = etiquette
	local contour = Instance.new("UIStroke")
	contour.Thickness = 3
	contour.Color = couleur:Lerp(Color3.new(0, 0, 0), 0.7)
	contour.Parent = etiquette
	local echelle = Instance.new("UIScale")
	echelle.Scale = 0.3
	echelle.Parent = etiquette
	panneau.Parent = dossier()
	TweenService:Create(
		echelle,
		TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()
	local envol = TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(panneau, envol, { StudsOffset = depart + Vector3.new(0, 2.6, 0) }):Play()
	task.delay(0.45, function()
		local fondu = TweenInfo.new(0.4)
		TweenService:Create(etiquette, fondu, { TextTransparency = 1 }):Play()
		TweenService:Create(contour, fondu, { Transparency = 1 }):Play()
	end)
	task.delay(0.9, function()
		jaillissements -= 1
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
				surgir(joueur, `{ICONES[nom]} +{Nombres.abreger(valeur - avant)}`, COULEURS[nom])
				Sons.jouer("Gain", if nom == "Force" then 1.2 else 1.6)
			end
			avant = valeur
		end)
	end
end

-- Fête du nouvel agrès quand le niveau de Forge passe un palier.
local function suivrePaliers()
	local joueur = Players.LocalPlayer
	local avant = Forge.palier(joueur:GetAttribute("NiveauForge"))
	joueur:GetAttributeChangedSignal("NiveauForge"):Connect(function()
		local niveau = joueur:GetAttribute("NiveauForge")
		local palier = Forge.palier(niveau)
		if palier > avant then
			local ecran = Instance.new("ScreenGui")
			ecran.Name = "NouvelAgres"
			ecran.ResetOnSpawn = false
			local etiquette = Instance.new("TextLabel")
			etiquette.AnchorPoint = Vector2.new(0.5, 0.5)
			etiquette.Position = UDim2.fromScale(0.5, 0.32)
			etiquette.Size = UDim2.fromScale(0.7, 0.12)
			etiquette.BackgroundTransparency = 1
			etiquette.Font = Enum.Font.FredokaOne
			etiquette.TextScaled = true
			etiquette.TextColor3 = JAUNE
			etiquette.TextStrokeTransparency = 0
			local mode = joueur:GetAttribute("ModeForge")
			etiquette.Text =
				`✨ Forge {Config.Forge.Paliers[palier].Nom} : {Forge.agres(mode, niveau)} !`
			etiquette.Parent = ecran
			local echelle = Instance.new("UIScale")
			echelle.Scale = 0.2
			echelle.Parent = etiquette
			ecran.Parent = joueur:WaitForChild("PlayerGui")
			Sons.jingle("Palier")
			TweenService:Create(echelle, TweenInfo.new(0.5, Enum.EasingStyle.Back), { Scale = 1 })
				:Play()
			task.delay(2.5, function()
				TweenService:Create(
					etiquette,
					TweenInfo.new(0.5),
					{ TextTransparency = 1, TextStrokeTransparency = 1 }
				):Play()
				task.wait(0.6)
				ecran:Destroy()
			end)
		end
		avant = palier
	end)
end

function AnimationsForge.demarrer()
	CollectionService:GetInstanceAddedSignal(TAG):Connect(ajouterMachine)
	for _, modele in CollectionService:GetTagged(TAG) do
		ajouterMachine(modele)
	end
	RunService.PreSimulation:Connect(pas)
	RunService.PreRender:Connect(rendu)
	suivreGains()
	suivrePaliers()
end

return AnimationsForge
