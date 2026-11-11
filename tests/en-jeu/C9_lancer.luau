local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

-- API serveur supposée d'après la maquette issue-3 :
--   Lancers.demarrer(joueur, maintenant?) ; Lancers.lacher(joueur, maintenant?, aleatoire?) -> resultat?
--   Bases.creer(joueur) -> Model de la base ; Bases.liberer(joueur)
--   Lancers.traiterLacher(joueur, ...) : gestionnaire du RemoteEvent LacherJauge (hypothèse de nom
--   à ajuster avec le Bâtisseur si différent) ; il doit ignorer tous les arguments.
local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local prochainId = -100

local function fauxJoueur(force: number, ping: number?): any
	prochainId -= 1
	local attributs: { [string]: any } =
		{ Force = force, Vitesse = 0, ModeForge = "Force", SurForge = false }
	return {
		Name = "FauxLanceur" .. prochainId,
		UserId = prochainId,
		Character = nil,
		GetAttribute = function(_, nom: string)
			return attributs[nom]
		end,
		SetAttribute = function(_, nom: string, valeur: any)
			attributs[nom] = valeur
		end,
		GetNetworkPing = function()
			return ping or 0
		end,
	}
end

local function creaturesDe(joueur: any): { Instance }
	local liste = {}
	local dossier = Workspace:FindFirstChild("Creatures")
	if dossier then
		for _, c in dossier:GetChildren() do
			if c:GetAttribute("Proprietaire") == joueur.UserId then
				table.insert(liste, c)
			end
		end
	end
	return liste
end

return {
	["C9 lacher sans demarrer renvoie nil"] = function()
		local Lancers = module("Lancers")
		local j = fauxJoueur(100)
		Lancers.lacher(j, 1, 0)
		local j2 = fauxJoueur(100)
		assert(Lancers.lacher(j2, 1, 0) == nil, "lacher sans demarrer doit renvoyer nil")
	end,

	["C9 un second demarrer pendant une jauge en cours est ignoré"] = function()
		local Lancers = module("Lancers")
		local Bases = module("Bases")
		local j = fauxJoueur(100)
		Bases.creer(j)
		Lancers.demarrer(j, 0)
		Lancers.demarrer(j, 0.5) -- doit être ignoré : le début reste à 0
		local resultat = Lancers.lacher(j, 0.8, 0)
		Bases.liberer(j)
		assert(resultat ~= nil, "le lâcher devrait réussir")
		assert(
			resultat.Couleur == "Rouge",
			"le début doit être resté à 0 (Rouge attendu à t=0,8)"
		)
	end,

	["C9 demarrer avant DelaiEntreLancers après un lâcher est refusé"] = function()
		local Lancers = module("Lancers")
		local Bases = module("Bases")
		local j = fauxJoueur(100)
		Bases.creer(j)
		Lancers.demarrer(j, 0)
		assert(Lancers.lacher(j, 0.8, 0) ~= nil, "premier lancer attendu")
		Lancers.demarrer(j, 0.8 + Config.Lancer.DelaiEntreLancers - 0.5)
		assert(
			Lancers.lacher(j, 0.8 + Config.Lancer.DelaiEntreLancers, 0) == nil,
			"demarrer trop tôt doit être refusé"
		)
		Lancers.demarrer(j, 0.8 + Config.Lancer.DelaiEntreLancers + 0.1)
		assert(
			Lancers.lacher(j, 0.8 + Config.Lancer.DelaiEntreLancers + 0.9, 0) ~= nil,
			"demarrer après le délai doit être accepté"
		)
		Bases.liberer(j)
	end,

	["C9 une jauge lâchée après DureeMaxJauge est annulée"] = function()
		local Lancers = module("Lancers")
		local Bases = module("Bases")
		local j = fauxJoueur(100)
		Bases.creer(j)
		Lancers.demarrer(j, 0)
		local resultat = Lancers.lacher(j, Config.Lancer.DureeMaxJauge + 1, 0)
		Bases.liberer(j)
		assert(resultat == nil, "jauge trop longue : lancer annulé")
	end,

	["C10 Force 100, ping 0, lâcher à 0,8 s : PERFECT, 130, Proche, Commune"] = function()
		local Lancers = module("Lancers")
		local Bases = module("Bases")
		local j = fauxJoueur(100, 0)
		Bases.creer(j)
		Lancers.demarrer(j, 0)
		local r = Lancers.lacher(j, 0.8, 0)
		Bases.liberer(j)
		assert(r ~= nil, "résultat attendu")
		assert(r.Couleur == "Rouge", "Couleur : " .. tostring(r.Couleur))
		assert(r.Message == "PERFECT !", "Message : " .. tostring(r.Message))
		assert(r.Distance == 130, "Distance : " .. tostring(r.Distance))
		assert(r.Zone == "Proche", "Zone : " .. tostring(r.Zone))
		assert(r.Rarete == "Commune", "Rarete : " .. tostring(r.Rarete))
	end,

	["C10 la compensation du ping est plafonnée à CompensationPingMax"] = function()
		local Lancers = module("Lancers")
		local Bases = module("Bases")
		local max = Config.Lancer.CompensationPingMax
		-- Ping énorme (5 s) : seul `max` est retiré. t = 0,8 + max - max = 0,8 -> Rouge.
		local j = fauxJoueur(100, 5)
		Bases.creer(j)
		Lancers.demarrer(j, 0)
		local r = Lancers.lacher(j, 0.8 + max, 0)
		Bases.liberer(j)
		assert(r ~= nil, "résultat attendu")
		assert(
			r.Couleur == "Rouge",
			"ping plafonné : Rouge attendu, obtenu " .. tostring(r.Couleur)
		)
		-- Sans plafond, t serait négatif -> position 0 -> Vert.
		local j2 = fauxJoueur(100, 5)
		Bases.creer(j2)
		Lancers.demarrer(j2, 0)
		local r2 = Lancers.lacher(j2, 0.8, 0)
		Bases.liberer(j2)
		assert(r2 ~= nil, "résultat attendu")
		assert(r2.Couleur ~= "Rouge", "le ping ne doit pas être compensé au-delà du plafond")
	end,

	["C11 une créature apparaît avec les bons attributs et au bon endroit"] = function()
		local Lancers = module("Lancers")
		local Bases = module("Bases")
		local j = fauxJoueur(100, 0)
		local base = Bases.creer(j)
		Lancers.demarrer(j, 0)
		local r = Lancers.lacher(j, 0.8, 0)
		assert(r ~= nil, "résultat attendu")
		task.wait(Config.Lancer.DureeVolGraine + 1)
		local liste = creaturesDe(j)
		assert(#liste == 1, "une créature attendue, trouvée " .. #liste)
		local c = liste[1]
		assert(c.Name == "Creature" and c:IsA("Model"), "Model nommé Creature attendu")
		assert(c:GetAttribute("Rarete") == r.Rarete, "Rarete incohérente")
		assert(c:GetAttribute("Zone") == r.Zone, "Zone incohérente")
		assert(c:GetAttribute("Distance") == r.Distance, "Distance incohérente")
		assert(c:GetAttribute("Proprietaire") == j.UserId, "Proprietaire incohérent")
		assert(base ~= nil, "base attendue")
		-- Les distances partent de la ligne de la zone sûre.
		local attenduZ = Config.Monstres.BordBases + r.Distance
		local pos = (c :: Model):GetPivot().Position
		assert(math.abs(pos.Z - attenduZ) <= 2, "Z attendu " .. attenduZ .. ", obtenu " .. pos.Z)
		assert(pos.Y >= 0, "la créature doit être au-dessus du sol (Y >= 0), Y = " .. pos.Y)
		for _, creature in creaturesDe(j) do
			creature:Destroy()
		end
		Bases.liberer(j)
	end,

	["C11 au-delà de MaxCreaturesAuSol la plus ancienne disparaît"] = function()
		local Lancers = module("Lancers")
		local Bases = module("Bases")
		local j = fauxJoueur(100, 0)
		Bases.creer(j)
		local max = Config.Lancer.MaxCreaturesAuSol
		local t = 0
		for _ = 1, max + 1 do
			Lancers.demarrer(j, t)
			assert(Lancers.lacher(j, t + 0.8, 0) ~= nil, "lancer attendu")
			t += 0.8 + Config.Lancer.DelaiEntreLancers + 0.1
		end
		task.wait(Config.Lancer.DureeVolGraine + 1)
		local n = #creaturesDe(j)
		for _, creature in creaturesDe(j) do
			creature:Destroy()
		end
		Bases.liberer(j)
		assert(n == max, "attendu " .. max .. " créatures, trouvé " .. n)
	end,

	["C12 TerresSauvages, Creatures et RemoteEvents existent"] = function()
		local terres = Workspace:WaitForChild("TerresSauvages", 5)
		assert(terres and terres:IsA("BasePart"), "Workspace.TerresSauvages (Part) introuvable")
		assert((terres :: BasePart).Anchored, "TerresSauvages doit être ancrée")
		local creatures = Workspace:WaitForChild("Creatures", 5)
		assert(creatures and creatures:IsA("Folder"), "Workspace.Creatures (Folder) introuvable")
		for _, nom in { "DemarrerJauge", "LacherJauge", "ResultatLancer" } do
			local remote = ReplicatedStorage:WaitForChild(nom, 5)
			assert(remote and remote:IsA("RemoteEvent"), nom .. " doit être un RemoteEvent")
		end
	end,

	["C13 le serveur ignore les arguments envoyés par le client"] = function()
		local Lancers = module("Lancers")
		local Bases = module("Bases")
		assert(
			type(Lancers.traiterLacher) == "function",
			"Lancers.traiterLacher manquant (gestionnaire de LacherJauge)"
		)
		local function lancer(avecArguments: boolean): any
			local j = fauxJoueur(100, 0)
			Bases.creer(j)
			Lancers.demarrer(j, os.clock() - 0.8)
			local r
			if avecArguments then
				r = Lancers.traiterLacher(j, 9999, "Mythique", { Distance = 999 })
			else
				r = Lancers.traiterLacher(j)
			end
			Bases.liberer(j)
			for _, creature in creaturesDe(j) do
				creature:Destroy()
			end
			return r
		end
		local sans = lancer(false)
		local avec = lancer(true)
		assert(sans ~= nil and avec ~= nil, "résultats attendus")
		assert(avec.Distance < 999, "la distance du client ne doit pas être utilisée")
		assert(avec.Distance <= Config.Lancer.DistanceMax, "Distance hors plafond")
		assert(avec.Zone == sans.Zone or avec.Zone == "Proche", "la zone doit venir du serveur")
		assert(
			avec.Rarete ~= "Mythique" or sans.Rarete == "Mythique",
			"la rareté du client ne doit pas être utilisée"
		)
	end,
}
