--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Bases = require(script.Parent.Bases)
local Entrainement = require(script.Parent.Entrainement)
local Lancers = require(script.Parent.Lancers)
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

TerresSauvages.creer()

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
	Sauvegarde.charger(joueur)
	if Sauvegarde.estCharge(joueur) then
		Entrainement.appliquerVitesse(joueur)
	end
end

Players.PlayerAdded:Connect(surArrivee)
for _, joueur in Players:GetPlayers() do
	task.spawn(surArrivee, joueur)
end

Players.PlayerRemoving:Connect(function(joueur)
	Lancers.nettoyer(joueur)
	Bases.liberer(joueur)
	Sauvegarde.terminer(joueur)
end)

Sauvegarde.demarrer()

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

print(`{Config.NomDuJeu} {Config.Version} : serveur démarré`)
