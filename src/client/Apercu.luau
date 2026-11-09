--!strict
-- Modèle d'aperçu d'une espèce du Bestiaire pour un ViewportFrame
-- (1 unité = 1 stud, sans physique ni texture), en couleurs ou en silhouette.
local Apercu = {}

local SILHOUETTE = Color3.fromRGB(25, 25, 35)

local FORMES: { [string]: Enum.PartType } = {
	Ball = Enum.PartType.Ball,
	Cylinder = Enum.PartType.Cylinder,
}
local MATERIAUX: { [string]: Enum.Material } = {
	Neon = Enum.Material.Neon,
	Glass = Enum.Material.Glass,
	Foil = Enum.Material.Foil,
	Metal = Enum.Material.Metal,
}

-- Modèle d'aperçu (1 unité = 1 stud), sans physique ni texture.
function Apercu.modele(espece: any, silhouette: boolean, couleurRarete: Color3): Model
	local modele = Instance.new("Model")
	modele.Name = espece.Nom
	for _, b in espece.Blocs do
		local p: BasePart
		if b.f == "Wedge" then
			p = Instance.new("WedgePart")
		else
			local part = Instance.new("Part")
			part.Shape = FORMES[b.f or ""] or Enum.PartType.Block
			p = part
		end
		p.Size = Vector3.new(b.t[1], b.t[2], b.t[3])
		local rotation = CFrame.new()
		if b.r then
			rotation = CFrame.Angles(math.rad(b.r[1]), math.rad(b.r[2]), math.rad(b.r[3]))
		end
		p.CFrame = CFrame.new(b.p[1], b.p[2], b.p[3]) * rotation
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		if silhouette then
			p.Color = SILHOUETTE
			p.Material = Enum.Material.SmoothPlastic
			p.Transparency = if b.tr and b.tr > 0.5 then 1 else 0
		else
			p.Color = if type(b.c) == "string"
				then couleurRarete
				else Color3.fromRGB(b.c[1], b.c[2], b.c[3])
			p.Material = MATERIAUX[b.m or ""] or Enum.Material.SmoothPlastic
			p.Transparency = b.tr or 0
		end
		p.Parent = modele
	end
	return modele
end

-- Place `modele` dans `vue` (WorldModel + caméra de face, un peu de biais).
function Apercu.montrer(vue: ViewportFrame, modele: Model, zoom: number?)
	local monde = Instance.new("WorldModel")
	monde.Parent = vue
	modele.Parent = monde
	local camera = Instance.new("Camera")
	camera.FieldOfView = 34
	local recul = zoom or 1
	camera.CFrame = CFrame.lookAt(Vector3.new(1.3, 0.55, -2.3) * recul, Vector3.new(0, -0.02, 0))
	camera.Parent = vue
	vue.CurrentCamera = camera
end

return Apercu
