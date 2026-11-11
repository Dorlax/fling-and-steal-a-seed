local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)

-- API serveur selon la maquette issue-7 :
--   Plaquages.plaquer(plaqueur, candidats?, maintenant?) -> Player? ; Plaquages.traiterRequete(joueur, ...)
--   Plaquages.nettoyer(joueur) ; Portage.recolter(joueur, creature) -> boolean
--   Attributs : Libre, DisparaitA (créature) ; AuSol, ProtegeJusqua, PlaquagePretA (joueur)
local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local prochainId = -2200

-- Faux joueur avec un vrai personnage (Humanoid + HumanoidRootPart).
local function fauxJoueur(): any
	prochainId -= 1
	local attributs: { [string]: any } =
		{ Force = 0, Vitesse = 0, ModeForge = "Force", SurForge = false, Pieces = 0 }
	local perso = Instance.new("Model")
	perso.Name = "FauxPerso" .. prochainId
	local racine = Instance.new("Part")
	racine.Name = "HumanoidRootPart"
	racine.Size = Vector3.new(2, 2, 1)
	racine.Anchored = true
	racine.Parent = perso
	local tete = Instance.new("Part")
	tete.Name = "Head"
	tete.Size = Vector3.new(2, 1, 1)
	tete.Anchored = true
	tete.Position = racine.Position + Vector3.new(0, 1.5, 0)
	tete.Parent = perso
	local humanoide = Instance.new("Humanoid")
	humanoide.WalkSpeed = Forge.walkSpeedPour(0)
	humanoide.Parent = perso
	perso.PrimaryPart = racine
	perso.Parent = Workspace
	return {
		Name = perso.Name,
		UserId = prochainId,
		Character = perso,
		GetAttribute = function(_, nom: string)
			return attributs[nom]
		end,
		SetAttribute = function(_, nom: string, valeur: any)
			attributs[nom] = valeur
		end,
		GetNetworkPing = function()
			return 0
		end,
	}
end

local function placer(joueur: any, position: Vector3)
	joueur.Character.HumanoidRootPart.CFrame = CFrame.new(position)
end

local function creatureAuSol(joueur: any, position: Vector3): Model
	local Lancers = module("Lancers")
	Lancers.demarrer(joueur, 0)
	assert(Lancers.lacher(joueur, 0.8, 0) ~= nil, "lancer attendu")
	task.wait(Config.Lancer.DureeVolGraine + 1)
	for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
		if c:GetAttribute("Proprietaire") == joueur.UserId then
			(c :: Model):PivotTo(CFrame.new(position))
			return c :: Model
		end
	end
	error("créature introuvable après le lancer")
end

local function nettoyer(...: any)
	for _, joueur in { ... } do
		module("Plaquages").nettoyer(joueur)
		for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
			if c:GetAttribute("Proprietaire") == joueur.UserId then
				c:Destroy()
			end
		end
		module("Bases").liberer(joueur)
		if joueur.Character then
			joueur.Character:Destroy()
		end
	end
	for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
		if c:GetAttribute("Libre") == true then
			c:Destroy()
		end
	end
end

local function dansLeDossier(creature: Instance): boolean
	return creature.Parent == module("TerresSauvages").dossierCreatures()
end

local POSITION = Vector3.new(0, 10, 500)
local PLAQUE = Config.Plaquage

-- Crée A (plaqueur) à 5 studs de B (porteur d'une créature).
local function scenario(): (any, any, Model)
	local Portage = module("Portage")
	local a, b = fauxJoueur(), fauxJoueur()
	module("Bases").creer(a)
	module("Bases").creer(b)
	local c = creatureAuSol(b, POSITION)
	placer(b, POSITION)
	assert(Portage.recolter(b, c) == true, "récolte de B attendue")
	placer(a, POSITION + Vector3.new(0, 0, 5))
	return a, b, c
end

local SURE = Vector3.new(300, 4, Config.Monstres.BordBases - 20) -- zone sûre, hors des bases

local function premierMonstre(): Model
	-- Le serveur de test peut ne pas encore avoir peuplé les biomes.
	local Monstres = module("Monstres")
	Monstres.completer(0)
	for _, m in Monstres.dossier():GetChildren() do
		if m:GetAttribute("Zone") == "Proche" then
			return m :: Model
		end
	end
	error("monstre de la zone Proche introuvable")
end

return {
	["C22 un monstre ne frappe pas un porteur dans la zone sûre"] = function()
		local Monstres = module("Monstres")
		local a, b = scenario()
		placer(b, SURE)
		local trouve, monstre = pcall(premierMonstre)
		local ok, raison, porte = false, "monstre introuvable", nil
		if trouve then
			monstre:PivotTo(CFrame.new(SURE + Vector3.new(0, 0, 2)))
			ok, raison = Monstres.frapper(monstre, b, Workspace:GetServerTimeNow() + 2000)
			porte = b:GetAttribute("Porte")
		end
		Monstres.nettoyer(b)
		nettoyer(a, b)
		assert(ok == false and raison == "zonesure", "refus zonesure attendu : " .. tostring(raison))
		assert(porte ~= nil, "B garde sa créature")
	end,

	["C22 un monstre ne frappe pas un joueur qui ne porte rien"] = function()
		local Monstres = module("Monstres")
		local a = fauxJoueur()
		module("Bases").creer(a)
		placer(a, POSITION)
		local trouve, monstre = pcall(premierMonstre)
		local ok, raison = false, "monstre introuvable"
		if trouve then
			monstre:PivotTo(CFrame.new(POSITION + Vector3.new(0, 0, 2)))
			ok, raison = Monstres.frapper(monstre, a, Workspace:GetServerTimeNow() + 3000)
		end
		Monstres.nettoyer(a)
		nettoyer(a)
		assert(ok == false and raison == "sansgraine", "refus sansgraine : " .. tostring(raison))
	end,

	["C22 pas de plaquage d'un porteur dans la zone sûre"] = function()
		local P = module("Plaquages")
		local a, b = scenario()
		placer(b, SURE)
		placer(a, SURE + Vector3.new(0, 0, 3))
		local r = P.plaquer(a, { b }, Workspace:GetServerTimeNow())
		local porte = b:GetAttribute("Porte")
		nettoyer(a, b)
		assert(r == nil, "B en zone sûre ne doit pas être plaqué")
		assert(porte ~= nil, "B garde sa créature")
	end,

	["C22 la ligne de la zone sûre et son sol existent"] = function()
		module("TerresSauvages").creer()
		local zone = Workspace:FindFirstChild("ZoneSure")
		assert(zone, "modèle ZoneSure attendu")
		local sol = zone:FindFirstChild("Sol")
		assert(sol and sol:IsA("BasePart") and sol.CanCollide, "sol de la zone sûre attendu")
		local rideau = zone:FindFirstChild("Rideau")
		assert(rideau and rideau:IsA("BasePart"), "rideau de la ligne attendu")
		assert(rideau.CanCollide == false, "la ligne ne bloque personne")
		assert(
			math.abs(rideau.Position.Z - Config.Monstres.BordBases) < 0.01,
			"rideau sur la ligne"
		)
	end,
}
