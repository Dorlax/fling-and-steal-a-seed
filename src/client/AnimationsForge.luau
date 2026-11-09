--!strict
-- Animation des machines de Forge (affichage seulement) : couleur du mode du
-- propriétaire (Force rouge, Vitesse bleu, Double violet), soufflets qui
-- pompent pendant l'entraînement, coup de marteau et étincelles à chaque gain
-- de stat. Tout est lu dans les attributs répliqués du propriétaire.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local AnimationsForge = {}

local TAG = "MachineForge"
local DISTANCE = 160
local REPOS = math.rad(40) -- marteau levé
local DUREE_DESCENTE = 0.12
local DUREE_REMONTEE = 0.4
local COULEURS: { [string]: Color3 } = {
	Force = Color3.fromRGB(255, 96, 50),
	Vitesse = Color3.fromRGB(70, 165, 255),
	Double = Color3.fromRGB(185, 95, 255),
}

type Machine = {
	modele: Model,
	mode: string?,
	frappe: number, -- instant du dernier coup (os.clock), -math.huge sinon
	stats: { [string]: number },
	connexions: { RBXScriptConnection },
	etincelles: ParticleEmitter?,
	impact: number, -- coup dont les étincelles sont déjà parties
}

local machines: { [Model]: Machine } = {}

local function proprietaireDe(modele: Model): Player?
	local id = modele:GetAttribute("Proprietaire")
	return if type(id) == "number" then Players:GetPlayerByUserId(id) else nil
end

local function colorer(machine: Machine, mode: string)
	local couleur = COULEURS[mode] or COULEURS.Force
	machine.mode = mode
	for _, p in machine.modele:GetDescendants() do
		local teinte = (
			p:IsA("BasePart") and (p.Name == "Anneau" or p.Name == "Foyer" or p.Name == "Bande")
		) or (p:IsA("PointLight") and p.Name == "Lueur")
		if teinte then
			(p :: any).Color = couleur
		elseif p:IsA("ParticleEmitter") and p.Name == "Flammes" then
			p.Color = ColorSequence.new(couleur, Color3.fromRGB(255, 230, 140))
		end
	end
	if machine.etincelles then
		machine.etincelles.Color = ColorSequence.new(Color3.new(1, 1, 1), couleur)
	end
end

local function etincelles(modele: Model): ParticleEmitter?
	local point = modele:FindFirstChild("PointFrappe", true)
	if point == nil or not point:IsA("Attachment") then
		return nil
	end
	local e = Instance.new("ParticleEmitter")
	e.Name = "Etincelles"
	e.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	e.LightEmission = 1
	e.Size = NumberSequence.new(0.5, 0)
	e.Lifetime = NumberRange.new(0.3, 0.7)
	e.Speed = NumberRange.new(8, 16)
	e.SpreadAngle = Vector2.new(70, 70)
	e.Acceleration = Vector3.new(0, -30, 0)
	e.EmissionDirection = Enum.NormalId.Top
	e.Rate = 0
	e.Parent = point
	return e
end

local function ajouter(instance: Instance)
	if not instance:IsA("Model") or machines[instance :: Model] then
		return
	end
	local modele = instance :: Model
	local machine: Machine = {
		modele = modele,
		mode = nil,
		frappe = -math.huge,
		stats = {},
		connexions = {},
		etincelles = etincelles(modele),
		impact = -math.huge,
	}
	machines[modele] = machine
	local joueur = proprietaireDe(modele)
	if joueur then
		for _, nom in { "Force", "Vitesse" } do
			local v = joueur:GetAttribute(nom)
			machine.stats[nom] = if type(v) == "number" then v else 0
			table.insert(
				machine.connexions,
				joueur:GetAttributeChangedSignal(nom):Connect(function()
					local nouveau = joueur:GetAttribute(nom)
					local avant = machine.stats[nom]
					if type(nouveau) == "number" then
						machine.stats[nom] = nouveau
						if
							nouveau > avant
							and os.clock() - machine.frappe > DUREE_DESCENTE + 0.2
						then
							machine.frappe = os.clock()
						end
					end
				end)
			)
		end
	end
end

local function retirer(modele: Instance)
	local machine = machines[modele :: Model]
	if machine then
		for _, c in machine.connexions do
			c:Disconnect()
		end
		machines[modele :: Model] = nil
	end
end

-- Angle du marteau (0 = tête sur l'enclume) selon le temps depuis le coup.
local function angleMarteau(depuis: number): number
	if depuis < DUREE_DESCENTE then
		local a = depuis / DUREE_DESCENTE
		return REPOS * (1 - a * a)
	end
	local r = math.clamp((depuis - DUREE_DESCENTE) / DUREE_REMONTEE, 0, 1)
	-- Petit rebond au départ de la remontée.
	return REPOS * (1 - (1 - r) ^ 3)
end

local function animer(machine: Machine, t: number)
	local modele = machine.modele
	local joueur = proprietaireDe(modele)
	local mode = if joueur then joueur:GetAttribute("ModeForge") else nil
	if type(mode) == "string" and mode ~= machine.mode then
		colorer(machine, mode)
	end
	local actif = joueur ~= nil and joueur:GetAttribute("SurForge") == true

	-- Marteau.
	local marteau = modele:FindFirstChild("Marteau")
	local pivot = if marteau then marteau:GetAttribute("Pivot") else nil
	if marteau and typeof(pivot) == "CFrame" then
		local depuis = os.clock() - machine.frappe
		local angle = angleMarteau(depuis)
		if not actif and depuis > 1 then
			angle = REPOS + math.rad(3) * math.sin(t * 1.2)
		end
		local rotation = (pivot :: CFrame) * CFrame.Angles(0, 0, angle)
		for _, p in marteau:GetChildren() do
			local decalage = p:GetAttribute("Decalage")
			if p:IsA("BasePart") and typeof(decalage) == "CFrame" then
				p.CFrame = rotation * decalage
			end
		end
		-- Étincelles une seule fois, au moment de l'impact.
		local gerbe = machine.etincelles
		if gerbe and depuis >= DUREE_DESCENTE and machine.impact ~= machine.frappe then
			machine.impact = machine.frappe
			gerbe:Emit(if mode == "Double" then 28 else 18)
		end
	end

	-- Soufflets : pompent vite pendant l'entraînement, respirent sinon.
	local ouverture = if actif
		then math.rad(9) * (1 + math.sin(t * 7))
		else math.rad(2) * (1 + math.sin(t * 1.5))
	for _, soufflet in modele:GetChildren() do
		local planche = if soufflet:IsA("Model") then soufflet:FindFirstChild("Planche") else nil
		if planche and planche:IsA("BasePart") then
			local charniere = planche:GetAttribute("Charniere")
			local repos = planche:GetAttribute("Repos")
			if typeof(charniere) == "CFrame" and typeof(repos) == "CFrame" then
				local c = charniere :: CFrame
				planche.CFrame = c
					* CFrame.Angles(-ouverture, 0, 0)
					* c:ToObjectSpace(repos :: CFrame)
			end
		end
	end

	-- Le feu ronfle pendant l'entraînement.
	local foyer = modele:FindFirstChild("Foyer")
	local flammes = foyer and foyer:FindFirstChild("Flammes")
	if flammes and flammes:IsA("ParticleEmitter") then
		flammes.Rate = if actif then 32 else 12
	end
end

function AnimationsForge.demarrer()
	CollectionService:GetInstanceAddedSignal(TAG):Connect(ajouter)
	CollectionService:GetInstanceRemovedSignal(TAG):Connect(retirer)
	for _, modele in CollectionService:GetTagged(TAG) do
		ajouter(modele)
	end
	RunService.RenderStepped:Connect(function()
		local camera = Workspace.CurrentCamera
		if camera == nil then
			return
		end
		local oeil = camera.CFrame.Position
		local t = os.clock()
		for modele, machine in machines do
			if modele.Parent == nil then
				retirer(modele)
			elseif (modele:GetPivot().Position - oeil).Magnitude < DISTANCE then
				animer(machine, t)
			end
		end
	end)
end

return AnimationsForge
