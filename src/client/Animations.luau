--!strict
-- Animations locales (affichage seulement) des créatures et des monstres en
-- blocs : tout le modèle sautille ou se dandine, et chaque pièce marquée par
-- le serveur (attributs Anim, Joint, Phase, Cote) tourne autour de son
-- articulation : pattes qui marchent, ailes qui battent, queue qui remue,
-- bras et mâchoire qui frappent (attribut FrappeA du monstre).
-- Le serveur reste maître des positions : dès qu'il déplace un modèle,
-- l'animation repart de la nouvelle position. Un monstre qui court (poursuite)
-- penche en avant et rebondit ; une créature portée en voxels gigote (ses
-- pattes pédalent) ; une créature portée en blocs (pièces soudées) ne bouge pas.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Anime = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Anime"))
local HabillageVoxels = require(script.Parent:WaitForChild("HabillageVoxels"))
local Promenade = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Promenade"))

local Animations = {}

type Piece = {
	part: BasePart,
	repos: CFrame, -- position de la pièce dans le repère du modèle
	role: string?,
	joint: Vector3,
	phase: number,
	cote: number,
}

type Suivi = {
	base: CFrame,
	pose: CFrame?,
	phase: number,
	monstre: boolean,
	pieces: { Piece },
	bougeA: number, -- dernier déplacement par le serveur (os.clock)
	majA: number, -- dernière nouvelle position reçue (os.clock)
	vitesse: number, -- studs/s estimée d'après les déplacements du serveur
	-- Créature de base qui se promène (Shared.Promenade), sinon nil.
	centre: Vector3?,
	voxels: boolean, -- habillée en voxels (pièces locales, ancrées)
	graine: number,
	rayon: number,
}

local suivis: { [Model]: Suivi } = {}
local demarre = false

-- Niveau de détail : de près, chaque image ; plus loin, une image sur 2 ou 3
-- (chaque modèle à son tour, pour lisser la charge).
local PRES = 50 -- studs
local MOYEN = 100 -- studs
local image = 0

-- Contours cartoon (Highlight) sur les modèles les plus proches : Roblox
-- n'en affiche qu'une trentaine à la fois, on en garde au plus CONTOURS_MAX.
local CONTOURS_MAX = 20
local CONTOURS_DISTANCE = 90
local contours: { [Model]: Highlight? } = {}
local prochainTri = 0

local function majContours(oeil: Vector3)
	local proches: { { modele: Model, distance: number } } = {}
	for modele, s in suivis do
		local distance = (s.base.Position - oeil).Magnitude
		if distance <= CONTOURS_DISTANCE and modele.PrimaryPart and modele.PrimaryPart.Anchored then
			table.insert(proches, { modele = modele, distance = distance })
		end
	end
	table.sort(proches, function(a, b)
		return a.distance < b.distance
	end)
	local gardes: { [Model]: boolean } = {}
	for i = 1, math.min(#proches, CONTOURS_MAX) do
		local modele = proches[i].modele
		gardes[modele] = true
		if contours[modele] == nil then
			local h = Instance.new("Highlight")
			h.Name = "Contour"
			h.FillTransparency = 1
			h.OutlineColor = Color3.fromRGB(30, 20, 40)
			h.OutlineTransparency = 0.15
			h.DepthMode = Enum.HighlightDepthMode.Occluded
			h.Adornee = modele
			h.Parent = modele
			contours[modele] = h
		end
	end
	for modele, h in contours do
		if h and (not gardes[modele] or modele.Parent == nil) then
			h:Destroy()
			contours[modele] = nil
		end
	end
end

local function sorteDe(objet: Instance): string?
	if not objet:IsA("Model") then
		return nil
	end
	if objet:GetAttribute("Monstre") == true then
		return "Monstre"
	end
	if
		objet:GetAttribute("Rarete") ~= nil
		or objet:GetAttribute("Mascotte") == true
		or string.sub(objet.Name, 1, 8) == "Creature"
	then
		return "Creature"
	end
	return nil
end

-- Relève la position de repos de chaque pièce dans le repère du modèle.
local function releverPieces(modele: Model, base: CFrame): { Piece }
	local pieces: { Piece } = {}
	for _, objet in modele:GetDescendants() do
		if objet:IsA("BasePart") then
			local role = objet:GetAttribute("Anim")
			local joint = objet:GetAttribute("Joint")
			local phase = objet:GetAttribute("Phase")
			local cote = objet:GetAttribute("Cote")
			table.insert(pieces, {
				part = objet,
				repos = base:ToObjectSpace(objet.CFrame),
				role = if type(role) == "string" then role else nil,
				joint = if typeof(joint) == "Vector3" then joint else Vector3.zero,
				phase = if type(phase) == "number" then phase else 0,
				cote = if type(cote) == "number" then cote else 0,
			})
		end
	end
	return pieces
end

local suivre: (objet: Instance) -> ()
function suivre(objet: Instance)
	local sorte = sorteDe(objet)
	if sorte == nil or suivis[objet :: Model] ~= nil then
		return
	end
	local modele = objet :: Model
	if modele.PrimaryPart == nil then
		return
	end
	if modele:GetAttribute("EnCroissance") == true then
		-- Elle sort de terre (le serveur la fait grandir) : on attend la fin
		-- pour relever ses pièces à leur vraie taille.
		local connexion: RBXScriptConnection
		connexion = modele:GetAttributeChangedSignal("EnCroissance"):Connect(function()
			if modele:GetAttribute("EnCroissance") ~= true then
				connexion:Disconnect()
				suivre(modele)
			end
		end)
		return
	end
	local base = modele:GetPivot()
	-- Espèce sculptée en voxels : on remplace ses blocs avant de relever les
	-- pièces. Si son modèle n'est pas encore construit, on garde les blocs et
	-- on recommence dès qu'il est prêt.
	local voxels = false
	if HabillageVoxels.concerne(modele) then
		if HabillageVoxels.pret(modele) then
			voxels = HabillageVoxels.habiller(modele, base)
		else
			HabillageVoxels.preparer(modele, function()
				local s = suivis[modele]
				if s and modele.Parent ~= nil and HabillageVoxels.habiller(modele, s.base) then
					s.voxels = true
					s.pieces = releverPieces(modele, s.base)
				end
			end)
		end
	end
	local centre = modele:GetAttribute("PromenadeCentre")
	local graine = modele:GetAttribute("Graine")
	local rayon = modele:GetAttribute("PromenadeRayon")
	suivis[modele] = {
		centre = if typeof(centre) == "Vector3" and type(graine) == "number" then centre else nil,
		graine = if type(graine) == "number" then graine else 0,
		rayon = if type(rayon) == "number" then rayon else Promenade.Rayon,
		base = base,
		pose = nil,
		phase = math.random() * math.pi * 2,
		monstre = sorte == "Monstre",
		pieces = releverPieces(modele, base),
		bougeA = 0,
		majA = 0,
		vitesse = 0,
		voxels = voxels,
	}
	modele.Destroying:Connect(function()
		suivis[modele] = nil
	end)
end

-- Vrai si deux CFrame sont (presque) égales : position et orientation.
local function identiques(a: CFrame, b: CFrame): boolean
	return (a.Position - b.Position).Magnitude < 1e-3
		and a.LookVector:Dot(b.LookVector) > 0.99999
		and a.UpVector:Dot(b.UpVector) > 0.99999
end

local parts: { BasePart } = {}
local cadres: { CFrame } = {}

-- Cadre d'une pièce : tournée autour de son articulation selon son rôle.
local function cadrePiece(
	s: Suivi,
	p: Piece,
	pose: CFrame,
	t: number,
	marche: boolean,
	frappe: number
): CFrame
	if p.role == nil then
		return pose * p.repos
	end
	local r = Anime.piece(p.role :: string, t, s.phase + p.phase, p.cote, marche, frappe)
	local rotation = CFrame.Angles(r.X, r.Y, r.Z)
	return pose * CFrame.new(p.joint) * rotation * CFrame.new(-p.joint) * p.repos
end

local function poser(s: Suivi, pose: CFrame, t: number, marche: boolean, frappe: number)
	for _, p in s.pieces do
		table.insert(parts, p.part)
		table.insert(cadres, cadrePiece(s, p, pose, t, marche, frappe))
	end
end

local function pas()
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return
	end
	local oeil = camera.CFrame.Position
	local t = os.clock()
	local serveur = Workspace:GetServerTimeNow()
	image += 1
	table.clear(parts)
	table.clear(cadres)
	for modele, s in suivis do
		local corps = modele.PrimaryPart
		if corps == nil or modele.Parent == nil then
			suivis[modele] = nil
			continue
		end
		if not (corps :: BasePart).Anchored then
			-- Portée : c'est la soudure du serveur qui la place. Les membres
			-- voxels (locaux, ancrés) suivent le Corps à la main.
			-- Elles gigotent : pattes qui pédalent, queue qui remue.
			s.pose = nil
			if s.voxels then
				local actuel = modele:GetPivot()
				local tPortee = t * Anime.Portee.Cadence
				for _, p in s.pieces do
					if p.part ~= corps and p.part.Anchored then
						table.insert(parts, p.part)
						table.insert(cadres, cadrePiece(s, p, actuel, tPortee, true, 0))
					end
				end
			end
			continue
		end
		local actuel = modele:GetPivot()
		local pose = s.pose
		local promenade: Promenade.Etat? = nil
		if s.centre then
			-- Promenade dans la base : position calculée depuis l'heure du serveur.
			local etat = Promenade.etat(s.graine, serveur, s.rayon)
			promenade = etat
			s.base = CFrame.new((s.centre :: Vector3) + Vector3.new(etat.X, etat.Saut, etat.Z))
				* CFrame.Angles(0, etat.Cap + etat.Tour, 0)
		elseif pose == nil or not identiques(actuel, pose) then
			-- Le serveur a déplacé le modèle : nouvelle position de repos.
			local ecart = actuel.Position - s.base.Position
			local deplacement = Vector3.new(ecart.X, 0, ecart.Z).Magnitude
			if deplacement > 0.05 then
				s.bougeA = t
				local dt = t - s.majA
				if dt > 0 and dt < 1 then
					-- Vitesse lissée (le serveur avance par pas de 0,1 s).
					s.vitesse = s.vitesse * 0.6 + (deplacement / dt) * 0.4
				end
			end
			s.majA = t
			s.base = actuel
		end
		local distance = (s.base.Position - oeil).Magnitude
		local loin = distance > Anime.DistanceMax
		if not loin and distance > PRES then
			local pasImages = if distance > MOYEN then 3 else 2
			if (image + math.floor(s.phase * 10)) % pasImages ~= 0 then
				continue
			end
		end
		if loin then
			if pose ~= nil then
				poser(s, s.base, t, false, 0)
				s.pose = s.base
			end
			continue
		end
		local marche = (s.monstre and t - s.bougeA < Anime.DureeMarche)
			or (promenade ~= nil and (promenade :: Promenade.Etat).Marche)
		local frappeA = modele:GetAttribute("FrappeA")
		local frappe = 0
		if type(frappeA) == "number" and serveur - frappeA < Anime.DureeFrappe then
			frappe = (serveur - frappeA) / Anime.DureeFrappe
		end
		-- Immobile depuis un moment : plus de course.
		if t - s.bougeA > 0.4 then
			s.vitesse = 0
		end
		local court = s.monstre and Anime.court(s.vitesse)
		local d = if s.monstre
			then Anime.monstre(t, s.phase, s.vitesse)
			else Anime.creature(t, s.phase)
		local penche = CFrame.Angles(0, d.Lacet, d.Roulis) * CFrame.Angles(d.Tangage, 0, 0)
		local nouvelle = s.base * CFrame.new(0, d.Hauteur, 0) * penche
		local tPieces = if court then t * Anime.Monstre.Course.Cadence else t
		poser(s, nouvelle, tPieces, marche, frappe)
		s.pose = nouvelle
	end
	if #parts > 0 then
		Workspace:BulkMoveTo(parts, cadres, Enum.BulkMoveMode.FireCFrameChanged)
	end
	if t >= prochainTri then
		prochainTri = t + 0.5
		majContours(oeil)
	end
end

function Animations.demarrer()
	if demarre then
		return
	end
	demarre = true
	for _, objet in Workspace:GetDescendants() do
		suivre(objet)
	end
	Workspace.DescendantAdded:Connect(function(objet)
		-- Les attributs et les pièces arrivent juste après l'objet.
		task.delay(0.2, suivre, objet)
	end)
	RunService.RenderStepped:Connect(pas)
end

return Animations
