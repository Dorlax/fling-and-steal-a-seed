--!strict
-- Construit en blocs une espèce du Bestiaire autour d'une pièce « Corps ».
-- Le Corps reste la racine du modèle (PrimaryPart, panneau, bouton, lumière)
-- mais devient invisible : ce sont les blocs qui donnent la forme.
-- Les pièces animées portent les attributs Anim, Joint, Phase et Cote, lus
-- par le client (Animations) ; elles sont purement visuelles.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bestiaire = require(ReplicatedStorage.Shared.Bestiaire)

local Modeleur = {}

local FORMES: { [string]: Enum.PartType } = {
	Block = Enum.PartType.Block,
	Ball = Enum.PartType.Ball,
	Cylinder = Enum.PartType.Cylinder,
	Wedge = Enum.PartType.Wedge,
}

local MATERIAUX: { [string]: Enum.Material } = {
	Neon = Enum.Material.Neon,
	Glass = Enum.Material.Glass,
	Foil = Enum.Material.Foil,
}

local function vecteur(v: { number }, echelle: number): Vector3
	return Vector3.new(v[1], v[2], v[3]) * echelle
end

local function couleurDe(c: Bestiaire.Couleur, rarete: Color3): Color3
	if type(c) == "string" then
		return rarete
	end
	local rgb = c :: { number }
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

-- Ajoute les blocs de `espece` au modèle, à l'échelle `taille` (studs pour
-- une unité), autour du CFrame actuel de `corps`. Renvoie le nombre de blocs.
function Modeleur.construire(
	modele: Model,
	corps: BasePart,
	espece: Bestiaire.Espece,
	taille: number,
	couleurRarete: Color3
): number
	corps.Transparency = 1
	corps.CastShadow = false
	local origine = corps.CFrame
	for _, b in espece.Blocs do
		local p: Part
		if b.f == "Wedge" then
			p = Instance.new("WedgePart") :: any
		else
			p = Instance.new("Part")
			p.Shape = FORMES[b.f or "Block"] or Enum.PartType.Block
		end
		p.Name = b.n
		p.Size = vecteur(b.t, taille)
		local rotation = CFrame.new()
		if b.r then
			local r = b.r :: { number }
			rotation = CFrame.Angles(math.rad(r[1]), math.rad(r[2]), math.rad(r[3]))
		end
		p.CFrame = origine * CFrame.new(vecteur(b.p, taille)) * rotation
		p.Color = couleurDe(b.c, couleurRarete)
		p.Material = if b.m then MATERIAUX[b.m] or Enum.Material.SmoothPlastic else Enum.Material.SmoothPlastic
		p.Transparency = b.tr or 0
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = b.tr == nil and b.t[2] * taille > 0.4
		if b.a then
			p:SetAttribute("Anim", b.a)
			p:SetAttribute("Joint", vecteur(b.j or b.p, taille))
			p:SetAttribute("Phase", b.ph or 0)
			p:SetAttribute("Cote", b.cote or 0)
		end
		p.Parent = modele
	end
	modele:SetAttribute("Espece", espece.Nom)
	-- Le client reçoit le modèle en entier (pour relever toutes ses pièces).
	modele.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	return #espece.Blocs
end

-- Aura de rareté : étincelles dès Épique, plus nombreuses ensuite ;
-- les Mythiques ont en plus un halo arc-en-ciel.
function Modeleur.aura(corps: BasePart, couleur: Color3, rang: number)
	if rang < 3 then
		return
	end
	local e = Instance.new("ParticleEmitter")
	e.Name = "Etincelles"
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = ColorSequence.new(couleur, Color3.new(1, 1, 1))
	e.LightEmission = 1
	e.Size = NumberSequence.new(0.3, 0)
	e.Lifetime = NumberRange.new(0.6, 1.2)
	e.Speed = NumberRange.new(0.5, 1.5)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Rate = 4 * (rang - 2)
	e.Parent = corps
	if rang >= 5 then
		local halo = Instance.new("ParticleEmitter")
		halo.Name = "Aura"
		halo.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 120)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 220, 60)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 220, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 90, 255)),
		})
		halo.LightEmission = 1
		halo.Transparency = NumberSequence.new(0.5, 1)
		halo.Size = NumberSequence.new(0.6, 1.4)
		halo.Lifetime = NumberRange.new(1, 1.5)
		halo.Speed = NumberRange.new(0.3, 0.6)
		halo.SpreadAngle = Vector2.new(180, 180)
		halo.Rate = 6
		halo.Parent = corps
	end
end

return Modeleur
