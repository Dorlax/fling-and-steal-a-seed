--!strict
-- Anime les créatures 3D à squelette (modèles importés de Blender, os nommés
-- comme dans Shared.AnimeOs). Affichage seulement : le serveur reste maître
-- des positions.
-- Un modèle est animé s'il porte l'attribut Squelette = "Quadrupede".
-- Clip : attribut EtatAnim (Joie, Etourdi, Porte) s'il est posé, sinon
-- Idle / Marche / Course selon la vitesse réelle du modèle.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local AnimeOs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AnimeOs"))

local AnimationsOs = {}

-- Passage du repère Blender au repère des os Roblox après import FBX.
-- À calibrer une fois dans Studio si un mouvement part dans le mauvais sens :
-- chaque axe Roblox reprend un axe Blender, avec un signe.
AnimationsOs.Axes = {
	X = { axe = "X", signe = 1 },
	Y = { axe = "Y", signe = 1 },
	Z = { axe = "Z", signe = 1 },
}

local DISTANCE_MAX = 160 -- studs : au-delà, pas d'animation

type Suivi = {
	os: { [string]: Bone },
	temps: number,
	dernierePos: Vector3?,
	vitesse: number,
}

local suivis: { [Model]: Suivi } = {}

local function composante(o: AnimeOs.Os, axe: string, rotation: boolean): number
	if rotation then
		return if axe == "X" then o.X elseif axe == "Y" then o.Y else o.Z
	end
	return if axe == "X" then o.PX elseif axe == "Y" then o.PY else o.PZ
end

local function transformation(o: AnimeOs.Os): CFrame
	local a = AnimationsOs.Axes
	local rx = composante(o, a.X.axe, true) * a.X.signe
	local ry = composante(o, a.Y.axe, true) * a.Y.signe
	local rz = composante(o, a.Z.axe, true) * a.Z.signe
	local px = composante(o, a.X.axe, false) * a.X.signe
	local py = composante(o, a.Y.axe, false) * a.Y.signe
	local pz = composante(o, a.Z.axe, false) * a.Z.signe
	return CFrame.new(px, py, pz) * CFrame.fromEulerAnglesXYZ(rx, ry, rz)
end

local function suivre(modele: Model)
	if suivis[modele] then
		return
	end
	local liste: { [string]: Bone } = {}
	for _, d in modele:GetDescendants() do
		if d:IsA("Bone") then
			liste[d.Name] = d
		end
	end
	if next(liste) == nil then
		return
	end
	suivis[modele] = { os = liste, temps = math.random() * 10, vitesse = 0 }
end

local function estAnime(i: Instance): boolean
	return i:IsA("Model") and i:GetAttribute("Squelette") == "Quadrupede"
end

function AnimationsOs.demarrer()
	for _, d in Workspace:GetDescendants() do
		if estAnime(d) then
			suivre(d :: Model)
		end
	end
	Workspace.DescendantAdded:Connect(function(d)
		if estAnime(d) then
			-- Les os arrivent parfois après le modèle (streaming).
			task.defer(suivre, d :: Model)
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		local camera = Workspace.CurrentCamera
		local oeil = if camera then camera.CFrame.Position else Vector3.zero
		for modele, s in suivis do
			if not modele.Parent then
				suivis[modele] = nil
				continue
			end
			local pivot = modele:GetPivot().Position
			if (pivot - oeil).Magnitude > DISTANCE_MAX then
				continue
			end
			-- Vitesse horizontale lissée, ramenée à l'échelle 1 du modèle.
			local echelle = math.max(modele:GetScale(), 1e-3)
			if s.dernierePos and dt > 0 then
				local d = pivot - s.dernierePos
				local v = Vector3.new(d.X, 0, d.Z).Magnitude / dt / echelle
				s.vitesse += (v - s.vitesse) * math.min(1, dt * 8)
			end
			s.dernierePos = pivot

			local etat = modele:GetAttribute("EtatAnim")
			local etatTexte = if typeof(etat) == "string" then etat else nil
			local clip, cadence = AnimeOs.choisir(etatTexte, s.vitesse)
			s.temps += dt * cadence
			local pose = AnimeOs.pose(clip, s.temps)
			for nom, bone in s.os do
				local o = pose[nom]
				bone.Transform = if o then transformation(o) else CFrame.identity
			end
		end
	end)
end

return AnimationsOs
