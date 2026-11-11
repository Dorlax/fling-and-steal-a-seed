-- Remplace à l'affichage (sur ce client seulement) les blocs d'une espèce
-- sculptée en voxels par ses MeshParts (Shared.ConstructeurVoxels). Le
-- serveur garde ses blocs et reste maître des positions ; ici on retire les
-- blocs locaux et on pose les membres voxels au même endroit, avec les
-- attributs d'animation lus par Animations.
-- Si EditableMesh est indisponible, rien ne change (anciens blocs).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local ConstructeurVoxels =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ConstructeurVoxels"))

local HabillageVoxels = {}

local ARC = {
	Color3.fromRGB(255, 90, 90),
	Color3.fromRGB(255, 180, 60),
	Color3.fromRGB(255, 240, 80),
	Color3.fromRGB(90, 220, 120),
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(190, 110, 255),
}

-- Vrai si ce modèle peut être habillé en voxels.
function HabillageVoxels.concerne(modele: Model): boolean
	local espece = modele:GetAttribute("Espece")
	return type(espece) == "string"
		and type(modele:GetAttribute("EchelleBlocs")) == "number"
		and ConstructeurVoxels.existe(espece)
end

-- Vrai si le modèle voxel de l'espèce est prêt (habiller() ne bloquera pas).
function HabillageVoxels.pret(modele: Model): boolean
	return ConstructeurVoxels.pret(modele:GetAttribute("Espece") :: string)
end

-- Prépare le modèle de l'espèce en arrière-plan, puis appelle `fini`.
function HabillageVoxels.preparer(modele: Model, fini: () -> ())
	task.spawn(function()
		ConstructeurVoxels.modele(modele:GetAttribute("Espece") :: string)
		fini()
	end)
end

-- Teinte de mutation (comme Modeleur.muter côté serveur).
local function muter(parts: { MeshPart }, mutation: any)
	local infos = if type(mutation) == "string"
		then (Config.Mutations.Liste :: any)[mutation]
		else nil
	if infos == nil then
		return
	end
	local teinte = Color3.fromRGB(infos.Couleur[1], infos.Couleur[2], infos.Couleur[3])
	local melange = infos.Melange or 0.5
	local matiere = if infos.Matiere then (Enum.Material :: any)[infos.Matiere] else nil
	for i, p in parts do
		local cible = if infos.Arc then ARC[(i % #ARC) + 1] else teinte
		p.Color = Color3.new(1, 1, 1):Lerp(cible, melange)
		if matiere then
			p.Material = matiere
		end
		if infos.Transparence then
			p.Transparency = infos.Transparence
		end
	end
end

-- Remplace les blocs du modèle par les membres voxels, posés autour de
-- `base` (repère du modèle). Renvoie vrai si c'est fait.
function HabillageVoxels.habiller(modele: Model, base: CFrame): boolean
	if modele:GetAttribute("HabilleVoxels") == true then
		return true
	end
	local corps = modele.PrimaryPart
	local echelle = modele:GetAttribute("EchelleBlocs")
	if corps == nil or type(echelle) ~= "number" then
		return false
	end
	local gabarit = ConstructeurVoxels.modele(modele:GetAttribute("Espece") :: string)
	if gabarit == nil or modele.Parent == nil then
		return false
	end
	local taille = echelle * modele:GetScale()
	-- Retire (localement) les blocs ; le Corps invisible reste la racine.
	for _, objet in modele:GetChildren() do
		if objet:IsA("BasePart") and objet ~= corps then
			objet:Destroy()
		end
	end
	local nouvelles: { MeshPart } = {}
	for _, source in gabarit:GetChildren() do
		local p = source:Clone() :: MeshPart
		p.Size = source.Size * taille
		local cf = source.CFrame
		p.CFrame = base * (CFrame.new(cf.Position * taille) * cf.Rotation)
		local joint = source:GetAttribute("Joint")
		if typeof(joint) == "Vector3" then
			p:SetAttribute("Joint", joint * taille)
		end
		p.CastShadow = true
		p.Parent = modele
		table.insert(nouvelles, p)
	end
	muter(nouvelles, modele:GetAttribute("Mutation"))
	modele:SetAttribute("HabilleVoxels", true)
	return true
end

return HabillageVoxels
