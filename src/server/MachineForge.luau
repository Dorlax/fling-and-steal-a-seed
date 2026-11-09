--!strict
-- Machine de la Forge : décor cartoon autour de la plateforme « Forge »
-- (fourneau en briques, bouche de feu, cheminée fumante, soufflets, enclume
-- et grand marteau). Purement visuel : la zone d'entraînement reste la
-- plateforme. Les couleurs du mode et les coups de marteau sont animés par le
-- client (AnimationsForge) à partir des attributs du propriétaire.
local CollectionService = game:GetService("CollectionService")

local MachineForge = {}

MachineForge.Tag = "MachineForge"

local BRIQUE = Color3.fromRGB(196, 92, 62)
local BRIQUE_CLAIRE = Color3.fromRGB(226, 128, 88)
local PIERRE = Color3.fromRGB(92, 88, 104)
local PIERRE_CLAIRE = Color3.fromRGB(132, 128, 146)
local BOIS = Color3.fromRGB(150, 96, 52)
local CUIR = Color3.fromRGB(120, 70, 40)
local METAL = Color3.fromRGB(70, 74, 88)
local FEU = Color3.fromRGB(255, 120, 40)

local function bloc(
	parent: Instance,
	nom: string,
	taille: Vector3,
	cf: CFrame,
	couleur: Color3,
	matiere: Enum.Material,
	forme: Enum.PartType?
): Part
	local p = Instance.new("Part")
	p.Name = nom
	p.Anchored = true
	p.Size = taille
	p.CFrame = cf
	p.Color = couleur
	p.Material = matiere
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if forme then
		p.Shape = forme
	end
	p.CastShadow = math.max(taille.X, taille.Y, taille.Z) >= 4
	p.Parent = parent
	return p
end

-- Construit la machine autour de `plateforme` (la Part « Forge », posée sur
-- le sol dont le dessus est à `sol` en Y). Renvoie le modèle.
function MachineForge.construire(plateforme: BasePart, sol: number, proprietaire: any): Model
	local modele = Instance.new("Model")
	modele.Name = "MachineForge"
	modele:SetAttribute("Proprietaire", proprietaire)

	local centre = plateforme.Position
	local demi = plateforme.Size.Z / 2

	-- Plateforme : dalle de pierre et anneau lumineux à la couleur du mode.
	plateforme.Material = Enum.Material.Slate
	plateforme.Color = PIERRE_CLAIRE
	local haut = centre.Y + plateforme.Size.Y / 2
	local largeur = plateforme.Size.X
	for i, cote in { Vector3.new(0, 0, 1), Vector3.new(0, 0, -1) } do
		bloc(
			modele,
			"Anneau",
			Vector3.new(largeur, 0.12, 0.5),
			CFrame.new(centre.X, haut + 0.06, centre.Z + cote.Z * (demi - 0.25)),
			FEU,
			Enum.Material.Neon
		).CanCollide =
			false
		bloc(
			modele,
			"Anneau",
			Vector3.new(0.5, 0.12, largeur - 1),
			CFrame.new(centre.X + (if i == 1 then 1 else -1) * (demi - 0.25), haut + 0.06, centre.Z),
			FEU,
			Enum.Material.Neon
		).CanCollide =
			false
	end
	local rune = bloc(
		modele,
		"Anneau",
		Vector3.new(0.1, 3.4, 3.4),
		CFrame.new(centre.X, haut + 0.05, centre.Z) * CFrame.Angles(0, 0, math.rad(90)),
		FEU,
		Enum.Material.Neon,
		Enum.PartType.Cylinder
	)
	rune.CanCollide = false
	rune.Transparency = 0.35

	-- Fourneau, derrière la plateforme (côté apparition).
	local zF = centre.Z - demi - 2
	local x0 = centre.X
	local function cf(x: number, y: number, z: number): CFrame
		return CFrame.new(x0 + x, sol + y, zF + z)
	end
	bloc(modele, "Socle", Vector3.new(8.4, 0.8, 4), cf(0, 0.4, 0), PIERRE, Enum.Material.Slate)
	bloc(modele, "Fourneau", Vector3.new(7, 4.8, 3.2), cf(0, 3.2, 0), BRIQUE, Enum.Material.Brick)
	for _, x in { -3.3, 3.3 } do
		bloc(
			modele,
			"Pilier",
			Vector3.new(1, 5, 3.6),
			cf(x, 3.3, 0),
			BRIQUE_CLAIRE,
			Enum.Material.Brick
		)
	end
	bloc(modele, "Corniche", Vector3.new(8, 0.9, 4), cf(0, 6, 0), PIERRE, Enum.Material.Slate)

	-- Bouche de feu, tournée vers la plateforme.
	local zBouche = 1.6
	bloc(
		modele,
		"Arche",
		Vector3.new(4, 0.7, 0.6),
		cf(0, 4.3, zBouche + 0.1),
		PIERRE_CLAIRE,
		Enum.Material.Slate
	)
	bloc(
		modele,
		"Bouche",
		Vector3.new(3.2, 2.4, 0.3),
		cf(0, 2.6, zBouche),
		Color3.fromRGB(35, 20, 25),
		Enum.Material.SmoothPlastic
	)
	local foyer = bloc(
		modele,
		"Foyer",
		Vector3.new(2.6, 1.6, 0.3),
		cf(0, 2.2, zBouche + 0.05),
		FEU,
		Enum.Material.Neon
	)
	foyer.CanCollide = false
	local flammes = Instance.new("ParticleEmitter")
	flammes.Name = "Flammes"
	flammes.Texture = "rbxasset://textures/particles/fire_main.dds"
	flammes.Color = ColorSequence.new(FEU)
	flammes.LightEmission = 1
	flammes.Size =
		NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 0) })
	flammes.Lifetime = NumberRange.new(0.4, 0.8)
	flammes.Speed = NumberRange.new(1, 2.5)
	flammes.SpreadAngle = Vector2.new(25, 10)
	flammes.Acceleration = Vector3.new(0, 4, 0)
	flammes.Rate = 14
	flammes.EmissionDirection = Enum.NormalId.Front
	flammes.Parent = foyer
	local lueur = Instance.new("PointLight")
	lueur.Name = "Lueur"
	lueur.Color = FEU
	lueur.Range = 14
	lueur.Brightness = 2
	lueur.Parent = foyer

	-- Cheminée fumante.
	bloc(
		modele,
		"Cheminee",
		Vector3.new(3.4, 1.8, 1.8),
		cf(2.4, 8.1, -0.6) * CFrame.Angles(0, 0, math.rad(90)),
		BRIQUE_CLAIRE,
		Enum.Material.Brick,
		Enum.PartType.Cylinder
	)
	local chapeau = bloc(
		modele,
		"ChapeauCheminee",
		Vector3.new(0.6, 2.4, 2.4),
		cf(2.4, 9.9, -0.6) * CFrame.Angles(0, 0, math.rad(90)),
		PIERRE,
		Enum.Material.Slate,
		Enum.PartType.Cylinder
	)
	local fumee = Instance.new("ParticleEmitter")
	fumee.Name = "Fumee"
	fumee.Texture = "rbxasset://textures/particles/smoke_main.dds"
	fumee.Color = ColorSequence.new(Color3.fromRGB(230, 225, 235))
	fumee.Transparency = NumberSequence.new(0.3, 1)
	fumee.Size = NumberSequence.new(1.2, 3.5)
	fumee.Lifetime = NumberRange.new(2, 3)
	fumee.Speed = NumberRange.new(2, 3)
	fumee.SpreadAngle = Vector2.new(12, 12)
	fumee.Rate = 3
	fumee.EmissionDirection = Enum.NormalId.Right -- axe du cylindre = vers le haut
	fumee.Parent = chapeau

	-- Soufflets de chaque côté : la planche du haut pivote sur sa charnière.
	for i, x in { -4.9, 4.9 } do
		local soufflet = Instance.new("Model")
		soufflet.Name = "Soufflet" .. i
		soufflet.Parent = modele
		bloc(
			soufflet,
			"Bas",
			Vector3.new(1.6, 0.3, 2.6),
			cf(x, 1.15, 0.4),
			BOIS,
			Enum.Material.Wood
		)
		bloc(
			soufflet,
			"Cuir",
			Vector3.new(1.3, 0.7, 2.2),
			cf(x, 1.6, 0.3),
			CUIR,
			Enum.Material.Fabric
		)
		local planche = bloc(
			soufflet,
			"Planche",
			Vector3.new(1.6, 0.3, 2.6),
			cf(x, 2.05, 0.4),
			BOIS,
			Enum.Material.Wood
		)
		bloc(
			soufflet,
			"Bec",
			Vector3.new(0.4, 0.4, 1),
			cf(x, 1.6, -1.2),
			METAL,
			Enum.Material.Metal
		)
		-- Charnière : bord arrière (côté bec) de la planche.
		planche:SetAttribute("Charniere", planche.CFrame * CFrame.new(0, 0, -1.3))
		planche:SetAttribute("Repos", planche.CFrame)
	end

	-- Enclume sur la corniche et grand marteau sur son poteau.
	local yCorniche = 6.45
	bloc(
		modele,
		"PiedEnclume",
		Vector3.new(1, 0.8, 1),
		cf(0, yCorniche + 0.4, 0),
		METAL,
		Enum.Material.Metal
	)
	local enclume = bloc(
		modele,
		"Enclume",
		Vector3.new(2.6, 0.7, 1.4),
		cf(0, yCorniche + 1.15, 0),
		METAL,
		Enum.Material.Metal
	)
	bloc(
		modele,
		"BecEnclume",
		Vector3.new(0.9, 0.5, 0.9),
		cf(1.6, yCorniche + 1.2, 0) * CFrame.Angles(0, 0, math.rad(-20)),
		METAL,
		Enum.Material.Metal
	)
	local etincelles = Instance.new("Attachment")
	etincelles.Name = "PointFrappe"
	etincelles.Position = Vector3.new(0, 0.4, 0)
	etincelles.Parent = enclume

	local hautEnclume = yCorniche + 1.5
	local yPivot = hautEnclume + 0.9 -- marteau à l'horizontale = tête posée
	bloc(
		modele,
		"Poteau",
		Vector3.new(0.6, yPivot - yCorniche, 0.6),
		cf(-3.2, (yCorniche + yPivot) / 2, 0),
		BOIS,
		Enum.Material.Wood
	)
	local marteau = Instance.new("Model")
	marteau.Name = "Marteau"
	marteau.Parent = modele
	local pivot = cf(-3.2, yPivot, 0)
	bloc(
		marteau,
		"Manche",
		Vector3.new(3.4, 0.45, 0.45),
		pivot * CFrame.new(1.7, 0, 0),
		BOIS,
		Enum.Material.Wood
	)
	local tete = bloc(
		marteau,
		"Tete",
		Vector3.new(1.4, 1.8, 1.8),
		pivot * CFrame.new(3.2, 0, 0),
		METAL,
		Enum.Material.Metal
	)
	bloc(
		marteau,
		"Bande",
		Vector3.new(1.5, 0.3, 1.9),
		pivot * CFrame.new(3.2, 0.5, 0),
		FEU,
		Enum.Material.Neon
	).CanCollide =
		false
	marteau.PrimaryPart = tete
	marteau:SetAttribute("Pivot", pivot)
	for _, p in marteau:GetChildren() do
		if p:IsA("BasePart") then
			p.CanCollide = false
			p:SetAttribute("Decalage", pivot:ToObjectSpace(p.CFrame))
		end
	end

	-- Petit panneau en bois sur le devant de la corniche.
	local panneau = bloc(
		modele,
		"Enseigne",
		Vector3.new(3.6, 1, 0.3),
		cf(0, 5.25, 2.1),
		BOIS,
		Enum.Material.Wood
	)
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.PixelsPerStud = 40
	surface.Parent = panneau
	local texte = Instance.new("TextLabel")
	texte.Size = UDim2.fromScale(1, 1)
	texte.BackgroundTransparency = 1
	texte.Font = Enum.Font.FredokaOne
	texte.TextScaled = true
	texte.TextColor3 = Color3.fromRGB(255, 230, 150)
	texte.TextStrokeTransparency = 0
	texte.Text = "FORGE"
	texte.Parent = surface

	modele.Parent = plateforme.Parent
	CollectionService:AddTag(modele, MachineForge.Tag)
	return modele
end

return MachineForge
