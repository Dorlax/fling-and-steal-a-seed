local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)

-- Hypothèses sur l'API serveur (la maquette ne nomme que Monstres.nettoyer et le paramètre `maintenant`) :
--   Monstres.completer(maintenant?)            : complète chaque zone jusqu'au nombre voulu (jour/nuit selon la phase)
--   Monstres.pas(maintenant?)                  : un pas de la boucle d'IA
--   Monstres.frapper(monstre, joueur, maintenant?) -> boolean, string? : tente un coup (peutFrapper puis effets)
--   Monstres.nettoyer(joueur)
--   CycleJourNuit.appliquer(maintenant?)       : applique la phase de `maintenant` (Lighting, attribut Nuit)
-- Attributs : Workspace.Nuit ; monstre : Zone, Monstre ; joueur : ProtegeMonstreJusqua.
local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local M = Config.Monstres
local C = Config.Cycle
local ZONES = { "Proche", "Moyenne", "Lointaine" }
local DUREE_CYCLE = C.DureeJour + C.DureeNuit
local POSITION = Vector3.new(0, 10, M.BordBases + 100)

local prochainId = -900

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

local function dossierMonstres(): Folder
	local d = Workspace:WaitForChild("Monstres", 5)
	assert(d, "Workspace.Monstres introuvable")
	return d :: Folder
end

local function compter(zone: string): number
	local n = 0
	for _, m in dossierMonstres():GetChildren() do
		if m:GetAttribute("Zone") == zone then
			n += 1
		end
	end
	return n
end

local function premierMonstre(zone: string): Model
	for _, m in dossierMonstres():GetChildren() do
		if m:GetAttribute("Zone") == zone then
			return m :: Model
		end
	end
	error("aucun monstre en zone " .. zone)
end

local function nettoyer(...: any)
	for _, joueur in { ... } do
		module("Monstres").nettoyer(joueur)
		module("Portage").nettoyer(joueur)
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

-- Joueur porteur d'une créature, dans les Terres Sauvages, à portée de coup d'un monstre de Proche.
local function scenario(): (any, Model, Model)
	local Lancers, Portage = module("Lancers"), module("Portage")
	local joueur = fauxJoueur()
	module("Bases").creer(joueur)
	Lancers.demarrer(joueur, 0)
	assert(Lancers.lacher(joueur, 0.8, 0) ~= nil, "lancer attendu")
	task.wait(2)
	local creature: Model? = nil
	for _, c in module("TerresSauvages").dossierCreatures():GetChildren() do
		if c:GetAttribute("Proprietaire") == joueur.UserId then
			creature = c :: Model
		end
	end
	assert(creature, "créature introuvable après le lancer")
	creature:PivotTo(CFrame.new(POSITION))
	placer(joueur, POSITION)
	assert(Portage.recolter(joueur, creature) == true, "récolte attendue")
	local monstre = premierMonstre("Proche")
	monstre:PivotTo(CFrame.new(POSITION + Vector3.new(0, 0, 2)))
	return joueur, monstre, creature
end

local function revenirAuJour()
	module("CycleJourNuit").appliquer(0)
	module("Monstres").completer(0)
end

return {
	["C9 au démarrage (jour), NombreJour monstres par zone, bien placés"] = function()
		revenirAuJour()
		for _, zone in ZONES do
			assert(
				compter(zone) == M.Zones[zone].NombreJour,
				zone .. " : " .. compter(zone) .. " monstres, attendu " .. M.Zones[zone].NombreJour
			)
		end
		local Monstre = require(ReplicatedStorage.Shared.Monstre)
		for _, m in dossierMonstres():GetChildren() do
			local zone = m:GetAttribute("Zone")
			assert(m:GetAttribute("Monstre") == true, "attribut Monstre = true attendu")
			local z = (m :: Model):GetPivot().Position.Z
			assert(Monstre.zoneDe({ X = 0, Y = 0, Z = z }) == zone, "pivot hors de la bande de " .. tostring(zone))
		end
	end,

	["C10 coup de monstre : créature lâchée, libre, à DistanceChute, vie réduite"] = function()
		local Portage, Monstres = module("Portage"), module("Monstres")
		local joueur, monstre, creature = scenario()
		local humanoide = joueur.Character.Humanoid :: Humanoid
		local avant = humanoide.Health
		local t = Workspace:GetServerTimeNow()
		local ok = Monstres.frapper(monstre, joueur, t)
		local porte = Portage.porte(joueur)
		local libre = creature:GetAttribute("Libre")
		local dans = creature.Parent == module("TerresSauvages").dossierCreatures()
		local delta = creature:GetPivot().Position - joueur.Character.HumanoidRootPart.Position
		local horizontale = Vector3.new(delta.X, 0, delta.Z).Magnitude
		local vie = humanoide.Health
		nettoyer(joueur)
		assert(ok == true, "le coup doit réussir")
		assert(porte == false, "le joueur ne doit plus rien porter")
		assert(dans and libre == true, "créature libre dans Workspace.Creatures attendue")
		assert(
			math.abs(horizontale - Config.Plaquage.DistanceChute) <= 1.5,
			"créature à " .. horizontale .. " studs, attendu ~" .. Config.Plaquage.DistanceChute
		)
		assert(math.abs((avant - vie) - M.Zones.Proche.Degats) < 0.01, "vie perdue : " .. (avant - vie))
	end,

	["C11 protection après un coup : refus 'protegee', puis succès après DureeProtection"] = function()
		local Monstres = module("Monstres")
		local joueur, monstre = scenario()
		joueur.Character.Humanoid.MaxHealth = 1000
		joueur.Character.Humanoid.Health = 1000
		local t = Workspace:GetServerTimeNow()
		assert(Monstres.frapper(monstre, joueur, t) == true, "premier coup attendu")
		local protege = joueur:GetAttribute("ProtegeMonstreJusqua")
		-- Monstre sans recharge : on avance au-delà de la recharge mais pas de la protection.
		local pendant, raison = Monstres.frapper(monstre, joueur, t + 1)
		local apres = Monstres.frapper(monstre, joueur, t + M.DureeProtection + 0.1)
		nettoyer(joueur)
		assert(
			type(protege) == "number" and math.abs(protege - (t + M.DureeProtection)) < 0.01,
			"ProtegeMonstreJusqua attendu t + DureeProtection"
		)
		assert(pendant == false and raison == "protegee", "refus 'protegee' attendu, obtenu " .. tostring(raison))
		assert(apres == true, "le coup doit réussir après la protection")
	end,

	["C12 un monstre ne pénètre jamais dans une base et ne frappe pas à l'intérieur"] = function()
		local Monstres = module("Monstres")
		local joueur = fauxJoueur()
		module("Bases").creer(joueur)
		local sol = module("Bases").solDe(joueur) :: BasePart
		placer(joueur, sol.Position + Vector3.new(0, 4, 0))
		local monstre = premierMonstre("Proche")
		monstre:PivotTo(CFrame.new(0, 10, M.BordBases + M.MargeBases + 3))
		local zMin = math.huge
		local t = Workspace:GetServerTimeNow()
		for i = 1, 200 do
			Monstres.pas(t + i * M.IntervalleIA)
			zMin = math.min(zMin, monstre:GetPivot().Position.Z)
		end
		local ok, raison = Monstres.frapper(monstre, joueur, t + 1000)
		nettoyer(joueur)
		assert(zMin >= M.BordBases + M.MargeBases - 0.01, "monstre entré dans une base : Z min " .. zMin)
		assert(ok == false and raison == "base", "refus 'base' attendu, obtenu " .. tostring(raison))
	end,

	["C13 nuit forcée : attribut Nuit, ClockTime, vague puis retour au jour"] = function()
		local Monstres, Cycle = module("Monstres"), module("CycleJourNuit")
		local tNuit = C.DureeJour + 1
		Cycle.appliquer(tNuit)
		Monstres.completer(tNuit)
		local nuit, heure = Workspace:GetAttribute("Nuit"), Lighting.ClockTime
		local nombres = {}
		for _, zone in ZONES do
			nombres[zone] = compter(zone)
		end
		local tJour = DUREE_CYCLE + 1
		Cycle.appliquer(tJour)
		Monstres.completer(tJour)
		local jour, heureJour = Workspace:GetAttribute("Nuit"), Lighting.ClockTime
		local apres = {}
		for _, zone in ZONES do
			apres[zone] = compter(zone)
		end
		assert(nuit == true and heure == C.HeureNuit, "nuit attendue (Nuit = true, ClockTime = HeureNuit)")
		assert(jour == false and heureJour == C.HeureJour, "jour attendu au retour")
		for _, zone in ZONES do
			assert(nombres[zone] == M.Zones[zone].NombreNuit, zone .. " nuit : " .. nombres[zone])
			assert(apres[zone] == M.Zones[zone].NombreJour, zone .. " jour : " .. apres[zone])
		end
	end,

	["C14 aucun nouveau RemoteEvent pour les monstres"] = function()
		for _, enfant in ReplicatedStorage:GetChildren() do
			if enfant:IsA("RemoteEvent") then
				local nom = string.lower(enfant.Name)
				assert(
					not string.find(nom, "monstre", 1, true) and not string.find(nom, "cycle", 1, true),
					"RemoteEvent interdit : " .. enfant.Name
				)
			end
		end
		local avant = 0
		for _, d in ReplicatedStorage:GetDescendants() do
			if d:IsA("RemoteEvent") then
				avant += 1
			end
		end
		module("Monstres").completer(0)
		local apres = 0
		for _, d in ReplicatedStorage:GetDescendants() do
			if d:IsA("RemoteEvent") then
				apres += 1
			end
		end
		assert(avant == apres, "le module Monstres ne doit créer aucun RemoteEvent")
	end,
}
