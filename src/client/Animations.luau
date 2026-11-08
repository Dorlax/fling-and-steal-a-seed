--!strict
-- Animations locales (affichage seulement) : les créatures posées sautillent
-- et regardent autour d'elles, les monstres se dandinent.
-- Le serveur reste maître des positions : dès qu'il déplace un modèle,
-- l'animation repart de la nouvelle position. Une créature portée (pièces
-- non ancrées) n'est pas animée.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Anime = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Anime"))

local Animations = {}

type Suivi = { base: CFrame, pose: CFrame?, phase: number, monstre: boolean }

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

local function suivre(objet: Instance)
	local sorte = sorteDe(objet)
	if sorte == nil or suivis[objet :: Model] ~= nil then
		return
	end
	local modele = objet :: Model
	suivis[modele] = {
		base = modele:GetPivot(),
		pose = nil,
		phase = math.random() * math.pi * 2,
		monstre = sorte == "Monstre",
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

local function pas()
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return
	end
	local oeil = camera.CFrame.Position
	local t = os.clock()
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
			s.base = actuel
		end
		if (s.base.Position - oeil).Magnitude > Anime.DistanceMax then
			if pose ~= nil then
				modele:PivotTo(s.base)
				s.pose = s.base
			end
			continue
		end
		local d = if s.monstre then Anime.monstre(t, s.phase) else Anime.creature(t, s.phase)
		local nouvelle = s.base * CFrame.new(0, d.Hauteur, 0) * CFrame.Angles(0, d.Lacet, d.Roulis)
		modele:PivotTo(nouvelle)
		s.pose = nouvelle
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
		-- Les attributs peuvent arriver juste après l'objet.
		task.defer(suivre, objet)
	end)
	RunService.RenderStepped:Connect(pas)
end

return Animations
