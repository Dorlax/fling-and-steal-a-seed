--!strict
-- Animations locales (affichage seulement) des créatures et des monstres en
-- blocs : tout le modèle sautille ou se dandine, et chaque pièce marquée par
-- le serveur (attributs Anim, Joint, Phase, Cote) tourne autour de son
-- articulation : pattes qui marchent, ailes qui battent, queue qui remue,
-- bras et mâchoire qui frappent (attribut FrappeA du monstre).
-- Le serveur reste maître des positions : dès qu'il déplace un modèle,
-- l'animation repart de la nouvelle position. Une créature portée (pièces
-- non ancrées) n'est pas animée.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Anime = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Anime"))

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
}

local suivis: { [Model]: Suivi } = {}
local demarre = false

local function sorteDe(objet: Instance): string?
	if not objet:IsA("Model") then
		return nil
	end
	if objet:GetAttribute("Monstre") == true then
		return "Monstre"
	end
	if objet:GetAttribute("Rarete") ~= nil or string.sub(objet.Name, 1, 8) == "Creature" then
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

local function suivre(objet: Instance)
	local sorte = sorteDe(objet)
	if sorte == nil or suivis[objet :: Model] ~= nil then
		return
	end
	local modele = objet :: Model
	if modele.PrimaryPart == nil then
		return
	end
	local base = modele:GetPivot()
	suivis[modele] = {
		base = base,
		pose = nil,
		phase = math.random() * math.pi * 2,
		monstre = sorte == "Monstre",
		pieces = releverPieces(modele, base),
		bougeA = 0,
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

local function poser(s: Suivi, pose: CFrame, t: number, marche: boolean, frappe: number)
	for _, p in s.pieces do
		local cadre: CFrame
		if p.role then
			local r = Anime.piece(p.role :: string, t, s.phase + p.phase, p.cote, marche, frappe)
			local rotation = CFrame.Angles(r.X, r.Y, r.Z)
			cadre = pose * CFrame.new(p.joint) * rotation * CFrame.new(-p.joint) * p.repos
		else
			cadre = pose * p.repos
		end
		table.insert(parts, p.part)
		table.insert(cadres, cadre)
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
	table.clear(parts)
	table.clear(cadres)
	for modele, s in suivis do
		local corps = modele.PrimaryPart
		if corps == nil or modele.Parent == nil then
			suivis[modele] = nil
			continue
		end
		if not (corps :: BasePart).Anchored then
			-- Portée : c'est la soudure du serveur qui la place.
			s.pose = nil
			continue
		end
		local actuel = modele:GetPivot()
		local pose = s.pose
		if pose == nil or not identiques(actuel, pose) then
			-- Le serveur a déplacé le modèle : nouvelle position de repos.
			if (actuel.Position - s.base.Position).Magnitude > 0.05 then
				s.bougeA = t
			end
			s.base = actuel
		end
		local loin = (s.base.Position - oeil).Magnitude > Anime.DistanceMax
		if loin then
			if pose ~= nil then
				poser(s, s.base, t, false, 0)
				s.pose = s.base
			end
			continue
		end
		local marche = s.monstre and t - s.bougeA < Anime.DureeMarche
		local frappeA = modele:GetAttribute("FrappeA")
		local frappe = 0
		if type(frappeA) == "number" and serveur - frappeA < Anime.DureeFrappe then
			frappe = (serveur - frappeA) / Anime.DureeFrappe
		end
		local d = if s.monstre then Anime.monstre(t, s.phase) else Anime.creature(t, s.phase)
		local nouvelle = s.base * CFrame.new(0, d.Hauteur, 0) * CFrame.Angles(0, d.Lacet, d.Roulis)
		poser(s, nouvelle, t, marche, frappe)
		s.pose = nouvelle
	end
	if #parts > 0 then
		Workspace:BulkMoveTo(parts, cadres, Enum.BulkMoveMode.FireCFrameChanged)
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
