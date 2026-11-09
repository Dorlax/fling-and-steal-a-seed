--!strict
-- Construit en blocs une espèce du Bestiaire autour d'une pièce « Corps ».
-- Le Corps reste la racine du modèle (PrimaryPart, panneau, bouton, lumière)
-- mais devient invisible : ce sont les blocs qui donnent la forme.
-- Les pièces animées portent les attributs Anim, Joint, Phase et Cote, lus
-- par le client (Animations) ; elles sont purement visuelles.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bestiaire = require(ReplicatedStorage.Shared.Bestiaire)
local Config = require(ReplicatedStorage.Shared.Config)

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
	Metal = Enum.Material.Metal,
}

local function vecteur(v: { number }, echelle: number): Vector3
	return Vector3.new(v[1], v[2], v[3]) * echelle
end

local FACES = {
	Enum.NormalId.Top,
	Enum.NormalId.Front,
	Enum.NormalId.Back,
	Enum.NormalId.Left,
	Enum.NormalId.Right,
}

-- Habille de pixel-art les faces visibles d'un gros bloc (teinté par sa
-- couleur). Les petits détails (yeux, dents, griffes) restent unis.
local function texturer(p: BasePart, b: Bestiaire.Bloc, image: string, taille: number)
	if b.f ~= nil or b.m == "Neon" or b.m == "Foil" or b.m == "Metal" then
		return
	end
	if math.min(b.t[1], b.t[3]) < 0.1 or string.sub(b.n, 1, 4) == "Oeil" then
		return
	end
	for _, face in FACES do
		local tex = Instance.new("Texture")
		tex.Name = "Motif"
		tex.Face = face
		tex.Texture = image
		tex.Color3 = p.Color
		tex.Transparency = p.Transparency
		tex.StudsPerTileU = taille * 0.8
		tex.StudsPerTileV = taille * 0.8
		tex.Parent = p
	end
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
	local image = Bestiaire.Textures[espece.Texture] or Bestiaire.Textures.Pelage
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
		p.Material = if b.m
			then MATERIAUX[b.m] or Enum.Material.SmoothPlastic
			else Enum.Material.SmoothPlastic
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
		texturer(p, b, image, taille)
		p.Parent = modele
	end
	modele:SetAttribute("Espece", espece.Nom)
	-- Le client reçoit le modèle en entier (pour relever toutes ses pièces).
	modele.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	return #espece.Blocs
end

-- Mutation (Dorée, Cristal, Arc-en-ciel) : les blocs changent de teinte et
-- de matière, et de petites étincelles de la couleur de la mutation
-- l'entourent. Sans mutation : rien ne change.
local ARC = {
	Color3.fromRGB(255, 90, 90),
	Color3.fromRGB(255, 180, 60),
	Color3.fromRGB(255, 240, 80),
	Color3.fromRGB(90, 220, 120),
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(190, 110, 255),
}
function Modeleur.muter(modele: Model, corps: BasePart, mutation: string?)
	if mutation == nil then
		return
	end
	local infos = (Config.Mutations.Liste :: any)[mutation]
	if infos == nil then
		return
	end
	local teinte = Color3.fromRGB(infos.Couleur[1], infos.Couleur[2], infos.Couleur[3])
	local i = 0
	for _, p in modele:GetChildren() do
		if p:IsA("BasePart") and p ~= corps and string.sub(p.Name, 1, 4) ~= "Oeil" then
			i += 1
			if mutation == "Doree" then
				p.Color = p.Color:Lerp(teinte, 0.6)
				p.Material = Enum.Material.Foil
			elseif mutation == "Cristal" then
				p.Color = p.Color:Lerp(teinte, 0.55)
				p.Material = Enum.Material.Glass
				p.Transparency = math.max(p.Transparency, 0.15)
			else
				p.Color = p.Color:Lerp(ARC[(i % #ARC) + 1], 0.65)
			end
			for _, motif in p:GetChildren() do
				if motif:IsA("Texture") then
					motif.Color3 = p.Color
				end
			end
		end
	end
	local e = Instance.new("ParticleEmitter")
	e.Name = "Mutation"
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.Color = if mutation == "Arcenciel"
		then ColorSequence.new({
			ColorSequenceKeypoint.new(0, ARC[1]),
			ColorSequenceKeypoint.new(0.5, ARC[4]),
			ColorSequenceKeypoint.new(1, ARC[6]),
		})
		else ColorSequence.new(teinte)
	e.LightEmission = 1
	e.Size = NumberSequence.new(0.4, 0)
	e.Lifetime = NumberRange.new(0.8, 1.4)
	e.Speed = NumberRange.new(0.6, 1.4)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Rate = 10
	e.Parent = corps
	modele:SetAttribute("Mutation", mutation)
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

-- Croissance : la créature sort de terre, petite, et grandit jusqu'à sa
-- taille (visuel seulement). Son bouton « Récolter » attend la fin.
-- Attribut EnCroissance = true pendant ce temps (le client n'anime pas).
local DUREE_POUSSE = 0.7
local ETAPES_POUSSE = 14

local function rebond(a: number): number
	-- Dépasse un peu sa taille puis revient (effet « pop »).
	return 1 - (1 - a) ^ 3 + math.sin(a * math.pi) * 0.15
end

function Modeleur.pousser(modele: Model)
	local corpsOuNil = modele.PrimaryPart
	if corpsOuNil == nil then
		return
	end
	local corps = corpsOuNil :: BasePart
	local sol = modele:GetPivot().Position - Vector3.new(0, corps.Size.Y / 2, 0)
	local prompt = corps:FindFirstChildWhichIsA("ProximityPrompt")
	if prompt then
		prompt.Enabled = false
	end
	modele:SetAttribute("EnCroissance", true)
	local function placer(echelle: number)
		modele:ScaleTo(math.max(echelle, 0.05))
		local demi = corps.Size.Y / 2
		modele:PivotTo(CFrame.new(sol + Vector3.new(0, demi, 0)))
	end
	placer(0.1)
	task.spawn(function()
		for i = 1, ETAPES_POUSSE do
			task.wait(DUREE_POUSSE / ETAPES_POUSSE)
			if modele.Parent == nil or not corps.Anchored then
				break
			end
			placer(0.1 + 0.9 * rebond(i / ETAPES_POUSSE))
		end
		if modele.Parent ~= nil and corps.Anchored then
			placer(1)
		end
		modele:SetAttribute("EnCroissance", nil)
		if prompt and modele.Parent ~= nil and corps.Anchored then
			prompt.Enabled = true
		end
	end)
end

return Modeleur
