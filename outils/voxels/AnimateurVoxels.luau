--!strict
-- Anime une créature voxel (MeshParts avec attributs Role / Joint / Cote /
-- Phase / Parent, créés par ConstructeurVoxels). Mêmes poses que
-- outils/voxels/animations.py : repos, marche, course, plaquage, drole.
--
-- local anim = AnimateurVoxels.nouveau(modele, taille)
-- anim:jouer("marche")            -- boucle
-- anim:etape(dt)                  -- à appeler chaque image (Heartbeat)
-- Le pivot du modèle (WorldPivot) doit être le centre du cube de sculpture.

local AnimateurVoxels = {}
AnimateurVoxels.__index = AnimateurVoxels

local TAU = 2 * math.pi
local DUREES = { repos = 1.6, marche = 1.0, course = 1.0, plaquage = 1.6, drole = 1.6 }

local function s(t: number, f: number?, ph: number?): number
	return math.sin(TAU * ((f or 1) * t + (ph or 0)))
end

local function doux(e: number): number
	e = math.clamp(e, 0, 1)
	return e * e * (3 - 2 * e)
end

-- Rotation (degrés), même ordre que sculpteur._rot : x puis y puis z.
local function rot(x: number, y: number, z: number): CFrame
	return CFrame.Angles(0, 0, math.rad(z)) * CFrame.Angles(0, math.rad(y), 0) * CFrame.Angles(math.rad(x), 0, 0)
end

type Pose = { [string]: { r: Vector3, t: Vector3 } }

local function base(m: any, t: number, ampl: number, freq: number, pose: Pose)
	for _, p in m do
		local ph = p.phase
		if p.role == "Patte" then
			pose[p.nom] = { r = Vector3.new(28 * ampl * s(t, freq, ph), 0, 0), t = Vector3.new(0, 0.012 * ampl * math.max(0, s(t, freq, ph + 0.25)), 0) }
		elseif p.role == "Bras" then
			pose[p.nom] = { r = Vector3.new(-25 * ampl * s(t, freq, ph), 0, 0), t = Vector3.zero }
		elseif p.role == "Queue" then
			pose[p.nom] = { r = Vector3.new(0, 18 * ampl * s(t, freq), 6 * s(t, freq * 2)), t = Vector3.zero }
		elseif p.role == "Oreille" then
			pose[p.nom] = { r = Vector3.new(0, 0, p.cote * 6 * ampl * s(t, freq * 2)), t = Vector3.zero }
		elseif p.role == "Aile" then
			pose[p.nom] = { r = Vector3.new(0, 0, p.cote * 14 * ampl * s(t, freq * 2)), t = Vector3.zero }
		elseif p.role == "Tete" then
			pose[p.nom] = { r = Vector3.new(4 * ampl * s(t, freq * 2), 3 * s(t, freq), 0), t = Vector3.zero }
		end
	end
end

local POSES = {}

function POSES.marche(self: any, t: number): (Pose, Vector3, Vector3)
	local pose = {}
	base(self.membres, t, 1, 1, pose)
	if self.sansPattes then
		return pose, Vector3.new(-6 * s(t, 2, 0.25), 0, 4 * s(t)), Vector3.new(0, 0.07 * math.abs(s(t, 2)), 0)
	end
	return pose, Vector3.new(0, 0, 2 * s(t)), Vector3.new(0, 0.012 * math.abs(s(t, 2)), 0)
end

function POSES.course(self: any, t: number): (Pose, Vector3, Vector3)
	local pose = {}
	base(self.membres, t, 1.7, 2, pose)
	if self.sansPattes then
		return pose, Vector3.new(-12, 0, 5 * s(t, 2)), Vector3.new(0, 0.12 * math.abs(s(t, 3)), 0)
	end
	return pose, Vector3.new(-8, 0, 3 * s(t, 2)), Vector3.new(0, 0.035 * math.abs(s(t, 4)), 0)
end

function POSES.repos(self: any, t: number): (Pose, Vector3, Vector3)
	local pose = {}
	local tic = doux((t - 0.62) / 0.05) * (1 - doux((t - 0.72) / 0.05))
	for _, p in self.membres do
		if p.role == "Tete" then
			pose[p.nom] = { r = Vector3.new(3 * s(t, 2), 20 * s(t), 4 * s(t, 1, 0.25)), t = Vector3.zero }
		elseif p.role == "Oreille" then
			pose[p.nom] = { r = Vector3.new(0, 0, p.cote * 18 * tic), t = Vector3.zero }
		elseif p.role == "Queue" then
			pose[p.nom] = { r = Vector3.new(0, 12 * s(t, 2), 0), t = Vector3.zero }
		elseif p.role == "Aile" then
			pose[p.nom] = { r = Vector3.new(0, 0, p.cote * 6 * s(t, 2)), t = Vector3.zero }
		elseif p.role == "Bras" then
			pose[p.nom] = { r = Vector3.new(4 * s(t, 2), 0, p.cote * 3 * s(t, 2)), t = Vector3.zero }
		end
	end
	return pose, Vector3.zero, Vector3.new(0, 0.006 * (1 + s(t, 2)), 0)
end

function POSES.plaquage(self: any, t: number): (Pose, Vector3, Vector3)
	local incl, z, y, j, bond
	if t < 0.35 then
		local e = doux(t / 0.35)
		incl, z, y, j, bond = 12 * e, 0.07 * e, -0.03 * e, -25 * e, 0
	elseif t < 0.55 then
		local e = doux((t - 0.35) / 0.2)
		incl = 12 - 40 * e
		z = 0.07 - 0.3 * e
		y = -0.03 + 0.03 * e + 0.12 * math.sin(math.pi * e)
		j = -25 + 65 * e
		bond = e
	else
		local e = 1 - doux((t - 0.55) / 0.45)
		incl, z, y, j, bond = -28 * e, -0.23 * e, 0, 40 * e, e
	end
	local pose = {}
	for _, p in self.membres do
		if p.role == "Patte" then
			local sens = if string.find(p.nom, "Av") then 1 elseif string.find(p.nom, "Ar") then -1 else -p.cote
			pose[p.nom] = { r = Vector3.new(sens * j, 0, 0), t = Vector3.zero }
		elseif p.role == "Bras" then
			pose[p.nom] = { r = Vector3.new(95 * bond, 0, p.cote * -10 * bond), t = Vector3.zero }
		elseif p.role == "Tete" then
			pose[p.nom] = { r = Vector3.new(-12 * bond, 0, 0), t = Vector3.zero }
		elseif p.role == "Queue" or p.role == "Oreille" then
			pose[p.nom] = { r = Vector3.new(25 * bond, 0, 0), t = Vector3.zero }
		elseif p.role == "Aile" then
			pose[p.nom] = { r = Vector3.new(0, 0, p.cote * 35 * bond), t = Vector3.zero }
		end
	end
	return pose, Vector3.new(incl, 0, 0), Vector3.new(0, y, z)
end

function POSES.drole(self: any, t: number): (Pose, Vector3, Vector3)
	local saut = math.sin(math.pi * t)
	local pose = {}
	for _, p in self.membres do
		if p.role == "Patte" then
			local sens = if string.find(p.nom, "Av") then 1 else -1
			pose[p.nom] = { r = Vector3.new(35 * saut * sens, 0, 0), t = Vector3.new(0, 0.03 * saut, 0) }
		elseif p.role == "Bras" then
			pose[p.nom] = { r = Vector3.new(0, 0, p.cote * 130 * saut), t = Vector3.zero }
		elseif p.role == "Oreille" then
			pose[p.nom] = { r = Vector3.new(0, 0, p.cote * 30 * saut), t = Vector3.zero }
		elseif p.role == "Aile" then
			pose[p.nom] = { r = Vector3.new(0, 0, p.cote * 45 * s(t, 3)), t = Vector3.zero }
		elseif p.role == "Queue" then
			pose[p.nom] = { r = Vector3.new(0, 30 * s(t, 2), 0), t = Vector3.zero }
		elseif p.role == "Tete" then
			pose[p.nom] = { r = Vector3.new(-10 * saut, 0, 10 * s(t, 2)), t = Vector3.zero }
		end
	end
	return pose, Vector3.new(0, 360 * doux(t), 0), Vector3.new(0, 0.26 * saut, 0)
end

function AnimateurVoxels.nouveau(modele: Model, taille: number)
	local self = setmetatable({}, AnimateurVoxels)
	self.modele = modele
	self.taille = taille
	self.membres = {}
	self.parNom = {}
	self.sansPattes = true
	local pivot = modele:GetPivot()
	for _, part in modele:GetChildren() do
		if part:IsA("BasePart") then
			local m = {
				part = part,
				nom = part.Name,
				role = part:GetAttribute("Role"),
				cote = part:GetAttribute("Cote") or 0,
				phase = part:GetAttribute("Phase") or 0,
				parent = part:GetAttribute("Parent"),
				joint = part:GetAttribute("Joint") or Vector3.zero,
				repos = pivot:ToObjectSpace(part.CFrame),
			}
			if m.role == "Patte" or m.role == "Bras" then
				self.sansPattes = false
			end
			table.insert(self.membres, m)
			self.parNom[m.nom] = m
		end
	end
	self.anim = "repos"
	self.t = 0
	return self
end

function AnimateurVoxels:jouer(nom: string)
	if self.anim ~= nom then
		self.anim = nom
		self.t = 0
	end
end

-- Transformation locale d'un membre : rotation autour de son articulation.
local function local_(m: any, pose: Pose, taille: number): CFrame
	local p = pose[m.nom]
	if not p then
		return CFrame.identity
	end
	local j = m.joint
	return CFrame.new(j + p.t * taille) * rot(p.r.X, p.r.Y, p.r.Z) * CFrame.new(-j)
end

function AnimateurVoxels:etape(dt: number)
	local duree = DUREES[self.anim] or 1
	self.t = (self.t + dt / duree) % 1
	local pose, racineRot, racineTr = POSES[self.anim](self, self.t)
	local T = self.taille
	local pied = Vector3.new(0, -0.5 * T, 0)
	local racine = CFrame.new(racineTr * T) * CFrame.new(pied) * rot(racineRot.X, racineRot.Y, racineRot.Z) * CFrame.new(-pied)
	local pivot = self.modele:GetPivot()
	local parts, cfs = {}, {}
	for _, m in self.membres do
		local cf = local_(m, pose, T)
		local parent = m.parent and self.parNom[m.parent]
		while parent do
			cf = local_(parent, pose, T) * cf
			parent = parent.parent and self.parNom[parent.parent]
		end
		table.insert(parts, m.part)
		table.insert(cfs, pivot * racine * cf * m.repos)
	end
	workspace:BulkMoveTo(parts, cfs, Enum.BulkMoveMode.FireCFrameChanged)
end

return AnimateurVoxels
