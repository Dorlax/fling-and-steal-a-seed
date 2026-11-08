local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)
local Revenus = require(ReplicatedStorage.Shared.Revenus)

-- API serveur supposée d'après la maquette issue-5 (à ajuster avec le Bâtisseur si les noms diffèrent) :
--   Portage.recolter(joueur, creature) -> boolean ; Portage.verifierDepot(joueur)
--   Portage.tickRevenus(joueur) : un tick de la boucle de revenus (hypothèse de nom)
--   Bases.creer/liberer, Bases.solDe(joueur) -> BasePart
--   Sauvegarde.creaturesDe(joueur) -> { string } ; Sauvegarde.ajouterCreature(joueur, rarete) -> boolean
--   Sauvegarde.collecter(joueur) -> données (doit être exposée)
--   Entrainement.appliquerVitesse(joueur)
local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local prochainId = -500

-- Faux joueur avec un vrai personnage (Humanoid + HumanoidRootPart).
local function fauxJoueur(vitesse: number?): any
	prochainId -= 1
	local attributs: { [string]: any } =
		{ Force = 0, Vitesse = vitesse or 0, ModeForge = "Force", SurForge = false, Pieces = 0 }
	local perso = Instance.new("Model")
	perso.Name = "FauxPerso" .. prochainId
	local racine = Instance.new("Part")
	racine.Name = "HumanoidRootPart"
	racine.Size = Vector3.new(2, 2, 1)
	racine.Anchored = true
	racine.Parent = perso
	local humanoide = Instance.new("Humanoid")
	humanoide.WalkSpeed = Forge.walkSpeedPour(vitesse or 0)
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

-- Crée une créature au sol appartenant à `joueur` via un vrai lancer.
local function creatureAuSol(joueur: any, position: Vector3?): Model
	local Lancers = module("Lancers")
	Lancers.demarrer(joueur, 0)
	assert(Lancers.lacher(joueur, 0.8, 0) ~= nil, "lancer attendu")
	task.wait(2)
	for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
		if c:GetAttribute("Proprietaire") == joueur.UserId then
			if position then
				(c :: Model):PivotTo(CFrame.new(position))
			end
			return c :: Model
		end
	end
	error("créature introuvable après le lancer")
end

local function nettoyer(joueur: any)
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

local function dansLeDossier(creature: Instance): boolean
	return creature.Parent == module("TerresSauvages").dossierCreatures()
end

local function milieuSol(joueur: any): Vector3
	local sol = module("Bases").solDe(joueur) :: BasePart
	return sol.Position + Vector3.new(0, 4, 0)
end

local function remplirBase(joueur: any, n: number)
	local Sauvegarde = module("Sauvegarde")
	for _ = 1, n do
		Sauvegarde.ajouterCreature(joueur, "Commune")
	end
end

local POSITION_SAUVAGE = Vector3.new(0, 10, 500)

return {
	["C7 récolte valide par le propriétaire à portée"] = function()
		local Portage = module("Portage")
		local j = fauxJoueur()
		module("Bases").creer(j)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE + Vector3.new(0, 0, Config.Creatures.DistanceRecolte - 3))
		local rarete = c:GetAttribute("Rarete")
		local ok = Portage.recolter(j, c)
		local porte = j:GetAttribute("Porte")
		local reste = dansLeDossier(c)
		nettoyer(j)
		assert(ok == true, "recolter doit renvoyer true")
		assert(porte == rarete, "attribut Porte attendu = " .. tostring(rarete))
		assert(not reste, "la créature ne doit plus être dans le dossier au sol")
	end,

	["C8 récolte refusée pour un autre joueur"] = function()
		local Portage = module("Portage")
		local j, autre = fauxJoueur(), fauxJoueur()
		module("Bases").creer(j)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(autre, POSITION_SAUVAGE + Vector3.new(0, 0, 2))
		local ok = Portage.recolter(autre, c)
		local porte = autre:GetAttribute("Porte")
		local reste = dansLeDossier(c)
		nettoyer(j)
		nettoyer(autre)
		assert(ok == false, "recolter doit renvoyer false")
		assert(porte == nil, "rien ne doit être porté")
		assert(reste, "la créature doit rester au sol")
	end,

	["C8 récolte refusée trop loin"] = function()
		local Portage = module("Portage")
		local j = fauxJoueur()
		module("Bases").creer(j)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE + Vector3.new(0, 0, Config.Creatures.DistanceRecolte + 30))
		local ok = Portage.recolter(j, c)
		local porte = j:GetAttribute("Porte")
		local reste = dansLeDossier(c)
		nettoyer(j)
		assert(ok == false and porte == nil and reste, "récolte trop loin doit être refusée sans effet")
	end,

	["C8 récolte refusée si le joueur porte déjà une créature"] = function()
		local Portage = module("Portage")
		local Lancers = module("Lancers")
		local j = fauxJoueur()
		module("Bases").creer(j)
		local c1 = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE)
		assert(Portage.recolter(j, c1) == true, "première récolte attendue")
		local avant = j:GetAttribute("Porte")
		Lancers.demarrer(j, 10)
		assert(Lancers.lacher(j, 10.8, 0) ~= nil, "second lancer attendu")
		task.wait(2)
		local c2: Instance? = nil
		for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
			if c:GetAttribute("Proprietaire") == j.UserId then
				c2 = c
			end
		end
		assert(c2, "seconde créature introuvable")
		(c2 :: Model):PivotTo(CFrame.new(POSITION_SAUVAGE + Vector3.new(0, 0, 2)))
		local ok = Portage.recolter(j, c2)
		local apres = j:GetAttribute("Porte")
		local reste = dansLeDossier(c2 :: Instance)
		nettoyer(j)
		assert(ok == false, "seconde récolte doit être refusée")
		assert(apres == avant, "Porte inchangé")
		assert(reste, "la seconde créature doit rester au sol")
	end,

	["C9 WalkSpeed ralenti pendant le portage puis rétabli après le dépôt"] = function()
		local Portage = module("Portage")
		local Entrainement = module("Entrainement")
		local j = fauxJoueur(250)
		module("Bases").creer(j)
		local normal = Forge.walkSpeedPour(250)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE)
		assert(Portage.recolter(j, c) == true, "récolte attendue")
		Entrainement.appliquerVitesse(j)
		local pendant = j.Character.Humanoid.WalkSpeed
		placer(j, milieuSol(j))
		Portage.verifierDepot(j)
		Entrainement.appliquerVitesse(j)
		local apres = j.Character.Humanoid.WalkSpeed
		nettoyer(j)
		assert(
			math.abs(pendant - normal * Config.Creatures.MultiplicateurPortage) < 1e-6,
			"WalkSpeed portage : " .. pendant
		)
		assert(math.abs(apres - normal) < 1e-6, "WalkSpeed après dépôt : " .. apres)
	end,

	["C10 dépôt dans sa base"] = function()
		local Portage = module("Portage")
		local Sauvegarde = module("Sauvegarde")
		local j = fauxJoueur()
		local base = module("Bases").creer(j)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE)
		assert(Portage.recolter(j, c) == true, "récolte attendue")
		local rarete = j:GetAttribute("Porte")
		local avant = #(base :: Instance):GetDescendants()
		placer(j, milieuSol(j))
		Portage.verifierDepot(j)
		local porte = j:GetAttribute("Porte")
		local liste = Sauvegarde.creaturesDe(j)
		local revenu = j:GetAttribute("RevenuParSeconde")
		local apres = #(base :: Instance):GetDescendants()
		nettoyer(j)
		assert(porte == nil, "Porte doit être effacé")
		assert(#liste == 1 and liste[1] == rarete, "CreaturesBase doit contenir la rareté")
		assert(revenu == Revenus.parSeconde(rarete), "RevenuParSeconde incorrect : " .. tostring(revenu))
		assert(apres > avant, "un modèle de créature doit apparaître dans la base")
	end,

	["C10 aucun dépôt hors de sa base ni dans celle d'un autre"] = function()
		local Portage = module("Portage")
		local Sauvegarde = module("Sauvegarde")
		local Bases = module("Bases")
		local j, autre = fauxJoueur(), fauxJoueur()
		Bases.creer(j)
		Bases.creer(autre)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE)
		assert(Portage.recolter(j, c) == true, "récolte attendue")
		Portage.verifierDepot(j)
		local horsBase = #Sauvegarde.creaturesDe(j)
		placer(j, milieuSol(autre))
		Portage.verifierDepot(j)
		local chezAutre = #Sauvegarde.creaturesDe(j)
		local porte = j:GetAttribute("Porte")
		nettoyer(j)
		nettoyer(autre)
		assert(horsBase == 0 and chezAutre == 0, "aucun dépôt attendu")
		assert(porte ~= nil, "la créature doit rester portée")
	end,

	["C11 base pleine : dépôt refusé, la créature reste portée"] = function()
		local Portage = module("Portage")
		local Sauvegarde = module("Sauvegarde")
		local j = fauxJoueur()
		module("Bases").creer(j)
		remplirBase(j, Config.Creatures.MaxCreaturesBase)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE)
		assert(Portage.recolter(j, c) == true, "récolte attendue")
		placer(j, milieuSol(j))
		Portage.verifierDepot(j)
		local n = #Sauvegarde.creaturesDe(j)
		local porte = j:GetAttribute("Porte")
		nettoyer(j)
		assert(n == Config.Creatures.MaxCreaturesBase, "la base ne doit pas dépasser le maximum")
		assert(porte ~= nil, "la créature doit rester portée")
	end,

	["C12 un tick de revenus ajoute exactement Revenus.total"] = function()
		local Portage = module("Portage")
		local Sauvegarde = module("Sauvegarde")
		local j = fauxJoueur()
		module("Bases").creer(j)
		assert(type(Portage.tickRevenus) == "function", "Portage.tickRevenus manquant")
		local avant = j:GetAttribute("Pieces")
		Portage.tickRevenus(j)
		assert(j:GetAttribute("Pieces") == avant, "sans créature, Pieces ne change pas")
		Sauvegarde.ajouterCreature(j, "Commune")
		Sauvegarde.ajouterCreature(j, "Mythique")
		local base = j:GetAttribute("Pieces")
		Portage.tickRevenus(j)
		local gain = j:GetAttribute("Pieces") - base
		nettoyer(j)
		assert(gain == Revenus.total({ "Commune", "Mythique" }), "gain attendu 101, obtenu " .. gain)
	end,

	["C13 une créature portée survit à MaxCreaturesAuSol"] = function()
		local Portage = module("Portage")
		local Lancers = module("Lancers")
		local j = fauxJoueur()
		module("Bases").creer(j)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE)
		assert(Portage.recolter(j, c) == true, "récolte attendue")
		local t = 10
		for _ = 1, Config.Lancer.MaxCreaturesAuSol + 2 do
			Lancers.demarrer(j, t)
			Lancers.lacher(j, t + 0.8, 0)
			t += 0.8 + Config.Lancer.DelaiEntreLancers + 0.1
		end
		task.wait(1.5)
		local vivante = c:IsDescendantOf(Workspace)
		local porte = j:GetAttribute("Porte")
		nettoyer(j)
		assert(vivante, "la créature portée ne doit pas être détruite")
		assert(porte ~= nil, "Porte doit rester défini")
	end,

	["C14 mort en portant : la créature retombe et reste récoltable"] = function()
		local Portage = module("Portage")
		local j = fauxJoueur()
		module("Bases").creer(j)
		local c = creatureAuSol(j, POSITION_SAUVAGE)
		placer(j, POSITION_SAUVAGE)
		assert(Portage.recolter(j, c) == true, "récolte attendue")
		j.Character.Humanoid.Health = 0
		task.wait(0.5)
		local porte = j:GetAttribute("Porte")
		local auSol = dansLeDossier(c)
		-- Un personnage « ressuscité » à portée peut la récolter à nouveau.
		j.Character.Humanoid.Health = j.Character.Humanoid.MaxHealth
		local ok = Portage.recolter(j, c)
		nettoyer(j)
		assert(porte == nil, "Porte doit être effacé")
		assert(auSol, "la créature doit être revenue dans le dossier au sol")
		assert(ok == true, "la créature doit être de nouveau récoltable")
	end,

	["C15 collecter contient Pieces et CreaturesBase à jour"] = function()
		local Sauvegarde = module("Sauvegarde")
		local j = fauxJoueur()
		module("Bases").creer(j)
		Sauvegarde.ajouterCreature(j, "Rare")
		j:SetAttribute("Pieces", 42)
		assert(type(Sauvegarde.collecter) == "function", "Sauvegarde.collecter doit être exposée")
		local d = Sauvegarde.collecter(j)
		nettoyer(j)
		assert(d.Pieces == 42, "Pieces attendu 42, obtenu " .. tostring(d.Pieces))
		assert(d.CreaturesBase and d.CreaturesBase[1] == "Rare", "CreaturesBase doit contenir Rare")
	end,

	["C16 aucun RemoteEvent de récolte ou de dépôt n'existe"] = function()
		for _, nom in { "Recolter", "Deposer", "RecolterCreature", "DeposerCreature", "Porter" } do
			assert(ReplicatedStorage:FindFirstChild(nom) == nil, "RemoteEvent interdit : " .. nom)
		end
		local message = ReplicatedStorage:WaitForChild("MessageJeu", 5)
		assert(message and message:IsA("RemoteEvent"), "MessageJeu (RemoteEvent) attendu")
	end,

	["C16 la récolte passe par un ProximityPrompt"] = function()
		local j = fauxJoueur()
		module("Bases").creer(j)
		local c = creatureAuSol(j)
		local prompt = c:FindFirstChildWhichIsA("ProximityPrompt", true)
		local ok = prompt ~= nil
			and prompt.HoldDuration == Config.Creatures.DureeRecolte
			and prompt.MaxActivationDistance == Config.Creatures.DistanceRecolte
		nettoyer(j)
		assert(ok, "ProximityPrompt « Récolter » mal configuré ou absent")
	end,

	["C17 InterfacePieces existe côté client et est démarrée"] = function()
		local client = game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("Client")
		assert(client, "dossier Client introuvable")
		local m = client:FindFirstChild("InterfacePieces")
		assert(m and m:IsA("ModuleScript"), "InterfacePieces manquant")
		local principal = client:FindFirstChild("Principal")
		assert(principal, "Principal.client introuvable")
		assert(
			string.find((principal :: any).Source, "InterfacePieces", 1, true),
			"Principal doit démarrer InterfacePieces"
		)
	end,
}
