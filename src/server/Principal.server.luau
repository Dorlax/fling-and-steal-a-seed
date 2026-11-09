--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Nombres = require(ReplicatedStorage.Shared.Nombres)
local Bases = require(script.Parent.Bases)
local Classements = require(script.Parent.Classements)
local CycleJourNuit = require(script.Parent.CycleJourNuit)
local Decor = require(script.Parent.Decor)
local Entrainement = require(script.Parent.Entrainement)
local Evenements = require(script.Parent.Evenements)
local Lancers = require(script.Parent.Lancers)
local Monstres = require(script.Parent.Monstres)
local PassesRobux = require(script.Parent.PassesRobux)
local Pieges = require(script.Parent.Pieges)
local Plaquages = require(script.Parent.Plaquages)
local Progression = require(script.Parent.Progression)
local Portage = require(script.Parent.Portage)
local Raids = require(script.Parent.Raids)
local Sauvegarde = require(script.Parent.Sauvegarde)
local TerresSauvages = require(script.Parent.TerresSauvages)

-- Les RemoteEvents sont déclarés dans default.project.json (présents dès le
-- chargement) ; on les crée seulement s'ils manquent.
local function remote(nom: string): RemoteEvent
	local existant = ReplicatedStorage:FindFirstChild(nom)
	if existant and existant:IsA("RemoteEvent") then
		return existant
	end
	local nouveau = Instance.new("RemoteEvent")
	nouveau.Name = nom
	nouveau.Parent = ReplicatedStorage
	return nouveau
end

-- Le client n'envoie qu'un nom de mode ; le serveur le valide.
remote("ChoisirModeForge").OnServerEvent:Connect(function(joueur: Player, valeur: any)
	if Sauvegarde.estCharge(joueur) then
		Entrainement.traiterChoixMode(joueur, valeur)
	end
end)

-- Achat du niveau de Forge suivant : aucun argument ; le serveur vérifie tout.
remote("AmeliorerForge").OnServerEvent:Connect(function(joueur: Player)
	if Sauvegarde.estCharge(joueur) then
		Entrainement.ameliorer(joueur)
	end
end)

-- Achat de l'agrandissement de base suivant : aucun argument.
remote("AgrandirBase").OnServerEvent:Connect(function(joueur: Player)
	if Sauvegarde.estCharge(joueur) and Bases.agrandir(joueur) then
		Bases.afficherCreatures(joueur, Sauvegarde.creaturesDe(joueur))
	end
end)

-- Achat de l'étage de base suivant : aucun argument ; le serveur vérifie tout.
remote("AcheterEtage").OnServerEvent:Connect(function(joueur: Player)
	if Sauvegarde.estCharge(joueur) and Bases.acheterEtage(joueur) then
		Bases.afficherCreatures(joueur, Sauvegarde.creaturesDe(joueur))
	end
end)

-- Gestion de la base : vendre la créature n° N, ranger par valeur. Le client
-- n'envoie qu'un numéro ; tout est vérifié par Sauvegarde. Anti-spam simple.
local derniereGestion: { [Player]: number } = {}
local function gestionPermise(joueur: Player): boolean
	local maintenant = os.clock()
	if not Sauvegarde.estCharge(joueur) or maintenant - (derniereGestion[joueur] or 0) < 0.25 then
		return false
	end
	derniereGestion[joueur] = maintenant
	return true
end
remote("VendreCreature").OnServerEvent:Connect(function(joueur: Player, numero: any)
	if gestionPermise(joueur) then
		local prix = Sauvegarde.vendre(joueur, numero)
		if prix > 0 then
			Bases.afficherCreatures(joueur, Sauvegarde.creaturesDe(joueur))
			remote("MessageJeu"):FireClient(
				joueur,
				`Créature vendue : +{Nombres.abreger(prix)} pièces`
			)
		end
	end
end)
remote("TrierBase").OnServerEvent:Connect(function(joueur: Player)
	if gestionPermise(joueur) and Sauvegarde.trier(joueur) then
		Bases.afficherCreatures(joueur, Sauvegarde.creaturesDe(joueur))
	end
end)

-- Progression : renaissance, graines, roue, traînées. Le client n'envoie
-- qu'un identifiant ; Progression vérifie tout (pièces, possession, délai).
remote("Renaitre").OnServerEvent:Connect(function(joueur: Player)
	if gestionPermise(joueur) then
		Progression.renaitre(joueur)
	end
end)
remote("AcheterGraine").OnServerEvent:Connect(function(joueur: Player, id: any)
	if gestionPermise(joueur) then
		Progression.acheterGraine(joueur, id)
	end
end)
remote("EquiperGraine").OnServerEvent:Connect(function(joueur: Player, id: any)
	if gestionPermise(joueur) then
		Progression.equiperGraine(joueur, id)
	end
end)
local resultatRoue = remote("ResultatRoue")
remote("TournerRoue").OnServerEvent:Connect(function(joueur: Player)
	if gestionPermise(joueur) then
		local numero = Progression.tournerRoue(joueur)
		if numero then
			resultatRoue:FireClient(joueur, numero)
		end
	end
end)
remote("EquiperTrainee").OnServerEvent:Connect(function(joueur: Player, id: any)
	if gestionPermise(joueur) then
		Progression.equiperTrainee(joueur, id)
	end
end)

-- Lancer : le client signale seulement « début » et « lâcher » ; ses arguments
-- éventuels sont ignorés, tout est calculé par le serveur.
remote("ResultatLancer")
remote("DemarrerJauge").OnServerEvent:Connect(function(joueur: Player)
	if Sauvegarde.estCharge(joueur) then
		Lancers.traiterDemarrer(joueur)
	end
end)
remote("LacherJauge").OnServerEvent:Connect(function(joueur: Player)
	Lancers.traiterLacher(joueur)
end)

-- Messages courts serveur -> client (« Base pleine ! », « Créature déposée ! »).
remote("MessageJeu")

-- Récolte : bouton « Récolter » (ProximityPrompt.Triggered), validé par Portage.
-- Aucun RemoteEvent client -> serveur pour la récolte ni le dépôt.
Lancers.surRecolte(function(joueur: Player, creature: Model)
	if Sauvegarde.estCharge(joueur) then
		Portage.recolter(joueur, creature)
	end
end)

-- Plaquage : le client signale seulement « Plaquer » ; ses arguments sont
-- ignorés, la cible et toutes les vérifications sont décidées par le serveur.
remote("Plaquer").OnServerEvent:Connect(function(joueur: Player)
	if Sauvegarde.estCharge(joueur) then
		Plaquages.traiterRequete(joueur)
	end
end)

-- Pièges : le client n'envoie que le nom du type ; tout autre argument est
-- ignoré, la position et toutes les vérifications sont décidées par le serveur.
remote("PoserPiege").OnServerEvent:Connect(function(joueur: Player, typePiege: any)
	if Sauvegarde.estCharge(joueur) then
		Pieges.traiterRequete(joueur, typePiege)
	end
end)

-- Raids : alertes serveur -> client uniquement (aucun OnServerEvent).
-- « Voler » et « Verrouiller » passent par les ProximityPrompts des bases ;
-- le serveur ne se fie qu'au joueur fourni par Triggered.
remote("AlerteVol")
Bases.surVol(function(declencheur: Player, proprietaire: any, numero: number)
	if Sauvegarde.estCharge(declencheur) and Sauvegarde.estCharge(proprietaire) then
		Raids.voler(declencheur, proprietaire, numero)
	end
end)
Bases.surVerrou(function(declencheur: Player, proprietaire: any)
	if Sauvegarde.estCharge(declencheur) and Sauvegarde.estCharge(proprietaire) then
		Raids.verrouiller(proprietaire, declencheur)
	end
end)

TerresSauvages.creer()
-- Décor cartoon et éclairage : avant le cycle jour/nuit, qui mémorise l'éclairage de jour.
Decor.eclairer()
Decor.creer()
Decor.suivreBases()

-- Cycle jour/nuit puis monstres : tout est décidé par le serveur, aucun
-- RemoteEvent (le client n'envoie rien pour les monstres).
CycleJourNuit.demarrer()
Monstres.demarrer()
Pieges.demarrer()
-- Multijoueur : événements pour tout le serveur et classements.
Evenements.demarrer()
Classements.demarrer()

local function placerDansSaBase(joueur: Player, personnage: Model)
	local racine = personnage:WaitForChild("HumanoidRootPart", 5)
	local apparition = Bases.apparitionDe(joueur)
	if racine and apparition and personnage.Parent then
		personnage:PivotTo(apparition)
	end
end

local function surPersonnage(joueur: Player, personnage: Model)
	placerDansSaBase(joueur, personnage)
	local humanoide = personnage:WaitForChild("Humanoid", 5)
	if humanoide and Sauvegarde.estCharge(joueur) then
		Entrainement.appliquerVitesse(joueur)
	end
end

local function surArrivee(joueur: Player)
	Bases.creer(joueur)
	joueur.CharacterAdded:Connect(function(personnage)
		surPersonnage(joueur, personnage)
	end)
	local personnageActuel = joueur.Character
	if personnageActuel then
		task.spawn(surPersonnage, joueur, personnageActuel)
	end
	task.spawn(PassesRobux.verifier, joueur)
	Sauvegarde.charger(joueur)
	if Sauvegarde.estCharge(joueur) then
		Classements.suivre(joueur)
		Progression.suivre(joueur)
		local gain = Sauvegarde.prendreGainHorsLigne(joueur)
		if gain > 0 then
			task.delay(5, function()
				if joueur.Parent then
					remote("MessageJeu"):FireClient(
						joueur,
						`Pendant ton absence, tes créatures ont gagné {Nombres.abreger(gain)} pièces !`
					)
				end
			end)
		end
		Entrainement.appliquerVitesse(joueur)
		Bases.afficherCreatures(joueur, Sauvegarde.creaturesDe(joueur))
	end
end

Players.PlayerAdded:Connect(surArrivee)
for _, joueur in Players:GetPlayers() do
	task.spawn(surArrivee, joueur)
end

Players.PlayerRemoving:Connect(function(joueur)
	derniereGestion[joueur] = nil
	Portage.nettoyer(joueur)
	Plaquages.nettoyer(joueur)
	Pieges.nettoyer(joueur)
	Monstres.nettoyer(joueur)
	Lancers.nettoyer(joueur)
	Raids.nettoyer(joueur)
	Bases.liberer(joueur)
	Sauvegarde.terminer(joueur)
end)

Sauvegarde.demarrer()
PassesRobux.demarrer()

-- Boucle d'entraînement : AFK compris, aucune action du joueur nécessaire.
task.spawn(function()
	while true do
		task.wait(Config.Forge.IntervalleSecondes)
		for _, joueur in Players:GetPlayers() do
			if Sauvegarde.estCharge(joueur) then
				joueur:SetAttribute("SurForge", Bases.estSurSaForge(joueur))
				Entrainement.tick(joueur)
			end
		end
	end
end)

-- Dépôt automatique : vérifié souvent pour réagir dès l'entrée dans la base.
task.spawn(function()
	while true do
		task.wait(0.2)
		for _, joueur in Players:GetPlayers() do
			if Sauvegarde.estCharge(joueur) then
				Portage.verifierDepot(joueur)
			end
		end
		Raids.pas()
	end
end)

-- Filet de sécurité : un joueur tombé sous la carte revient dans sa base.
task.spawn(function()
	while true do
		task.wait(1)
		for _, joueur in Players:GetPlayers() do
			local personnage = joueur.Character
			local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
			if
				racine
				and racine:IsA("BasePart")
				and racine.Position.Y < Config.Limites.HauteurChute
			then
				local apparition = Bases.apparitionDe(joueur)
				if apparition and personnage then
					racine.AssemblyLinearVelocity = Vector3.zero
					personnage:PivotTo(apparition)
				end
			end
		end
	end
end)

-- Revenus : chaque créature de la base rapporte des pièces, AFK compris.
task.spawn(function()
	while true do
		task.wait(Config.Creatures.IntervalleRevenus)
		for _, joueur in Players:GetPlayers() do
			if Sauvegarde.estCharge(joueur) then
				Portage.tickRevenus(joueur)
			end
		end
	end
end)

print(`{Config.NomDuJeu} {Config.Version} : serveur démarré`)
