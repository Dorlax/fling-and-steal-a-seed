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

local prochainId = -700

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
	task.wait(2)
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

return {
	["C11 RemoteEvent Plaquer et module Plaquages exposés"] = function()
		local remote = ReplicatedStorage:WaitForChild("Plaquer", 5)
		assert(remote and remote:IsA("RemoteEvent"), "RemoteEvent Plaquer attendu dans ReplicatedStorage")
		local P = module("Plaquages")
		assert(type(P.plaquer) == "function", "Plaquages.plaquer manquant")
		assert(type(P.traiterRequete) == "function", "Plaquages.traiterRequete manquant")
		assert(type(P.nettoyer) == "function", "Plaquages.nettoyer manquant")
	end,

	["C12 plaquage réussi : la créature est lâchée, libre et posée à DistanceChute"] = function()
		local P = module("Plaquages")
		local a, b, c = scenario()
		local t = Workspace:GetServerTimeNow()
		local cible = P.plaquer(a, { b }, t)
		local porte = b:GetAttribute("Porte")
		local dans = dansLeDossier(c)
		local libre = c:GetAttribute("Libre")
		local prompt = c:FindFirstChildWhichIsA("ProximityPrompt", true)
		local actif = prompt ~= nil and prompt.Enabled
		local distance = (c:GetPivot().Position - b.Character.HumanoidRootPart.Position)
		local horizontale = Vector3.new(distance.X, 0, distance.Z).Magnitude
		nettoyer(a, b)
		assert(cible == b, "plaquer doit renvoyer B")
		assert(porte == nil, "Porte de B doit être nil")
		assert(dans, "la créature doit être dans le dossier des créatures")
		assert(libre == true, "Libre = true attendu")
		assert(actif, "ProximityPrompt doit être activé")
		assert(
			math.abs(horizontale - PLAQUE.DistanceChute) <= 1.5,
			"créature à " .. horizontale .. " studs, attendu ~" .. PLAQUE.DistanceChute
		)
	end,

	["C13 la créature lâchée est récoltable par le plaqueur"] = function()
		local P, Portage = module("Plaquages"), module("Portage")
		local a, b, c = scenario()
		assert(P.plaquer(a, { b }, Workspace:GetServerTimeNow()) == b, "plaquage attendu")
		placer(a, c:GetPivot().Position)
		local ok = Portage.recolter(a, c)
		local proprio = c:GetAttribute("Proprietaire")
		local libre = c:GetAttribute("Libre")
		nettoyer(a, b)
		assert(ok == true, "A doit pouvoir récolter")
		assert(proprio == a.UserId, "Proprietaire doit devenir A")
		assert(libre == nil, "Libre doit être effacé")
	end,

	["C13 la créature lâchée est récoltable par un troisième joueur"] = function()
		local P, Portage = module("Plaquages"), module("Portage")
		local a, b, c = scenario()
		local tiers = fauxJoueur()
		module("Bases").creer(tiers)
		assert(P.plaquer(a, { b }, Workspace:GetServerTimeNow()) == b, "plaquage attendu")
		placer(tiers, c:GetPivot().Position)
		local ok = Portage.recolter(tiers, c)
		local proprio = c:GetAttribute("Proprietaire")
		nettoyer(a, b, tiers)
		assert(ok == true, "un tiers doit pouvoir récolter")
		assert(proprio == tiers.UserId, "Proprietaire doit devenir le tiers")
	end,

	["C13 une créature non libre reste réservée à son propriétaire"] = function()
		local Portage = module("Portage")
		local a, b = fauxJoueur(), fauxJoueur()
		module("Bases").creer(a)
		module("Bases").creer(b)
		local c = creatureAuSol(b, POSITION)
		placer(a, POSITION + Vector3.new(0, 0, 2))
		local ok = Portage.recolter(a, c)
		local porte = a:GetAttribute("Porte")
		nettoyer(a, b)
		assert(ok == false and porte == nil, "A ne doit pas récolter la créature de B")
	end,

	["C14 la cible est au sol puis se relève après DureeAuSol"] = function()
		local P = module("Plaquages")
		local a, b = scenario()
		assert(P.plaquer(a, { b }, Workspace:GetServerTimeNow()) == b, "plaquage attendu")
		local auSol = b:GetAttribute("AuSol")
		local stand = b.Character.Humanoid.PlatformStand
		task.wait(PLAQUE.DureeAuSol + 0.5)
		local auSolApres = b:GetAttribute("AuSol")
		local standApres = b.Character.Humanoid.PlatformStand
		nettoyer(a, b)
		assert(auSol == true and stand == true, "B doit être au sol juste après")
		assert(not auSolApres, "AuSol doit être effacé / false")
		assert(standApres == false, "PlatformStand doit revenir à false")
	end,

	["C15 protection : pas de replaquage avant DureeProtection"] = function()
		local P, Portage = module("Plaquages"), module("Portage")
		local a, b, c = scenario()
		local t = Workspace:GetServerTimeNow()
		assert(P.plaquer(a, { b }, t) == b, "plaquage attendu")
		-- B ramasse de nouveau la créature lâchée.
		placer(b, c:GetPivot().Position)
		assert(Portage.recolter(b, c) == true, "B doit pouvoir la reprendre")
		local autre = fauxJoueur()
		module("Bases").creer(autre)
		placer(autre, b.Character.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
		local pendant = P.plaquer(autre, { b }, t + 1)
		local protege = b:GetAttribute("ProtegeJusqua")
		local apres = P.plaquer(autre, { b }, t + PLAQUE.DureeProtection + 0.1)
		nettoyer(a, b, autre)
		assert(pendant == nil, "B doit être protégé à t + 1")
		assert(
			type(protege) == "number" and math.abs(protege - (t + PLAQUE.DureeProtection)) < 0.01,
			"ProtegeJusqua attendu t + DureeProtection"
		)
		assert(apres == b, "B doit pouvoir être replaqué après la protection")
	end,

	["C16 délai de récupération du plaqueur"] = function()
		local P, Portage = module("Plaquages"), module("Portage")
		local a, b, c = scenario()
		local t = Workspace:GetServerTimeNow()
		assert(P.plaquer(a, { b }, t) == b, "plaquage attendu")
		local pret = a:GetAttribute("PlaquagePretA")
		-- Autre cible valide, proche de A.
		local d = fauxJoueur()
		module("Bases").creer(d)
		local c2 = creatureAuSol(d, POSITION + Vector3.new(50, 0, 0))
		placer(d, POSITION + Vector3.new(50, 0, 0))
		assert(Portage.recolter(d, c2) == true, "récolte de D attendue")
		placer(a, POSITION + Vector3.new(50, 0, 4))
		local tot = P.plaquer(a, { d }, t + PLAQUE.DelaiRecuperation - 0.1)
		local tard = P.plaquer(a, { d }, t + PLAQUE.DelaiRecuperation)
		nettoyer(a, b, d)
		assert(c ~= nil)
		assert(
			type(pret) == "number" and math.abs(pret - (t + PLAQUE.DelaiRecuperation)) < 0.01,
			"PlaquagePretA attendu t + DelaiRecuperation"
		)
		assert(tot == nil, "trop tôt : nil attendu")
		assert(tard == d, "au bout du délai : D attendu")
	end,

	["C17 hors de portée, sans porteur : rien ne change et pas de délai"] = function()
		local P = module("Plaquages")
		local a, b, c = scenario()
		local t = Workspace:GetServerTimeNow()
		placer(b, POSITION + Vector3.new(0, 0, PLAQUE.Portee + 1 + 5))
		placer(a, POSITION + Vector3.new(0, 0, 5))
		local loin = P.plaquer(a, { b }, t)
		local porteLoin = b:GetAttribute("Porte")
		local pretLoin = a:GetAttribute("PlaquagePretA")
		-- B proche mais ne portant rien.
		placer(b, POSITION + Vector3.new(0, 0, 8))
		b:SetAttribute("Porte", nil)
		local vide = P.plaquer(a, { b }, t + 1)
		local pretVide = a:GetAttribute("PlaquagePretA")
		nettoyer(a, b)
		assert(c ~= nil)
		assert(loin == nil and porteLoin ~= nil, "hors de portée : rien ne doit changer")
		assert(pretLoin == nil, "un échec ne pose pas de délai")
		assert(vide == nil, "cible sans créature : nil attendu")
		assert(pretVide == pretLoin, "PlaquagePretA inchangé")
	end,

	["C18 pas de plaquage depuis sa propre base"] = function()
		local P = module("Plaquages")
		local a, b = scenario()
		local sol = module("Bases").solDe(a) :: BasePart
		placer(a, sol.Position + Vector3.new(0, 4, 0))
		placer(b, sol.Position + Vector3.new(0, 4, 3))
		local r = P.plaquer(a, { b }, Workspace:GetServerTimeNow())
		local porte = b:GetAttribute("Porte")
		nettoyer(a, b)
		assert(r == nil and porte ~= nil, "A dans sa base ne doit pas plaquer")
	end,

	["C18 pas de plaquage d'une cible dans sa propre base"] = function()
		local P = module("Plaquages")
		local a, b = scenario()
		local sol = module("Bases").solDe(b) :: BasePart
		placer(b, sol.Position + Vector3.new(0, 4, 0))
		placer(a, sol.Position + Vector3.new(0, 4, 3))
		local r = P.plaquer(a, { b }, Workspace:GetServerTimeNow())
		local porte = b:GetAttribute("Porte")
		nettoyer(a, b)
		assert(r == nil, "B dans sa base ne doit pas être plaqué")
		assert(porte ~= nil, "B doit garder sa créature")
	end,

	["C19 effet BOUM et étoiles, détruit après DureeAuSol"] = function()
		local P = module("Plaquages")
		local a, b = scenario()
		assert(P.plaquer(a, { b }, Workspace:GetServerTimeNow()) == b, "plaquage attendu")
		local effet = b.Character:FindFirstChild("EffetPlaquage", true)
		assert(effet and effet:IsA("BillboardGui"), "BillboardGui EffetPlaquage attendu")
		local boum, etoiles = false, 0
		for _, d in effet:GetDescendants() do
			if d:IsA("TextLabel") or d:IsA("TextButton") then
				local texte = (d :: TextLabel).Text
				if string.find(texte, "BOUM !", 1, true) then
					boum = true
				end
				local _, n = string.gsub(texte, "★", "")
				etoiles += n
			end
		end
		task.wait(PLAQUE.DureeAuSol + 0.5)
		local reste = b.Character:FindFirstChild("EffetPlaquage", true)
		nettoyer(a, b)
		assert(boum, "texte « BOUM ! » attendu")
		assert(etoiles >= 3, "au moins 3 étoiles attendues, trouvées " .. etoiles)
		assert(reste == nil, "l'effet doit disparaître après DureeAuSol")
	end,

	["C20 les arguments du client sont ignorés"] = function()
		local P = module("Plaquages")
		local a, b = scenario()
		placer(b, POSITION + Vector3.new(0, 0, PLAQUE.Portee + 20))
		P.traiterRequete(a, b)
		local porte = b:GetAttribute("Porte")
		local pret = a:GetAttribute("PlaquagePretA")
		nettoyer(a, b)
		assert(porte ~= nil, "B hors de portée doit garder sa créature")
		assert(pret == nil, "aucun plaquage ne doit avoir eu lieu")
	end,

	["C21 une créature libre non récoltée est programmée pour disparaître"] = function()
		local P = module("Plaquages")
		local a, b, c = scenario()
		local t = Workspace:GetServerTimeNow()
		assert(P.plaquer(a, { b }, t) == b, "plaquage attendu")
		local disparait = c:GetAttribute("DisparaitA")
		nettoyer(a, b)
		assert(type(disparait) == "number", "attribut DisparaitA attendu")
		assert(
			math.abs(disparait - (t + PLAQUE.DureeVieLachee)) < 5,
			"DisparaitA doit valoir environ maintenant + DureeVieLachee"
		)
	end,

	["C22 la mort d'un porteur fait retomber la créature non libre, réservée à son propriétaire"] = function()
		local Portage = module("Portage")
		local b = fauxJoueur()
		module("Bases").creer(b)
		local c = creatureAuSol(b, POSITION)
		placer(b, POSITION)
		assert(Portage.recolter(b, c) == true, "récolte attendue")
		b.Character.Humanoid.Health = 0
		task.wait(0.5)
		local porte = b:GetAttribute("Porte")
		local auSol = dansLeDossier(c)
		local libre = c:GetAttribute("Libre")
		local autre = fauxJoueur()
		module("Bases").creer(autre)
		placer(autre, c:GetPivot().Position)
		local refuse = Portage.recolter(autre, c)
		nettoyer(b, autre)
		assert(porte == nil, "Porte doit être effacé")
		assert(auSol, "la créature doit retomber dans le dossier")
		assert(libre ~= true, "la créature ne doit pas être libre")
		assert(refuse == false, "un autre joueur ne doit pas pouvoir la récolter")
	end,
}
