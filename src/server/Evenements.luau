--!strict
-- Événements de serveur : un à la fois, tirés par le serveur, annoncés à tous.
-- L'événement en cours est publié dans les attributs de Workspace :
--   Evenement     identifiant (chaîne vide sans événement)
--   EvenementFin  heure de fin (Workspace:GetServerTimeNow())
-- Les effets (Shared.Evenement) sont appliqués par Portage et Lancers.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Evenement = require(ReplicatedStorage.Shared.Evenement)

local Evenements = {}

local reglages = Config.Evenements
local hasard = Random.new()
local actuel: string? = nil
local numero = 0 -- change à chaque lancement (une fin ancienne ne coupe pas la suivante)

local function annoncer(texte: string)
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireAllClients(texte)
	end
end

-- Identifiant de l'événement en cours, ou nil.
function Evenements.actuel(): string?
	return actuel
end

-- Termine l'événement en cours (s'il y en a un).
function Evenements.finir()
	local id = actuel
	if id == nil then
		return
	end
	actuel = nil
	Workspace:SetAttribute("Evenement", "")
	Workspace:SetAttribute("EvenementFin", 0)
	local infos = Evenement.infos(id)
	if infos then
		annoncer(`{infos.Nom} : terminé !`)
	end
end

-- Lance l'événement `id` pendant `duree` secondes (Config par défaut).
-- Renvoie false si l'événement est inconnu.
function Evenements.lancer(id: string, duree: number?): boolean
	local trouve = Evenement.infos(id)
	if trouve == nil then
		return false
	end
	local infos = trouve :: Evenement.Infos
	local longueur = duree or reglages.Duree
	numero += 1
	local moi = numero
	actuel = id
	Workspace:SetAttribute("Evenement", id)
	Workspace:SetAttribute("EvenementFin", Workspace:GetServerTimeNow() + longueur)
	annoncer(`Événement : {infos.Nom} ! {infos.Texte} pour tout le serveur`)
	task.delay(longueur, function()
		if numero == moi then
			Evenements.finir()
		end
	end)
	return true
end

-- Boucle : un premier événement après PremierApres, puis un toutes les
-- Intervalle secondes.
function Evenements.demarrer()
	Workspace:SetAttribute("Evenement", "")
	Workspace:SetAttribute("EvenementFin", 0)
	task.spawn(function()
		task.wait(reglages.PremierApres)
		local precedent: string? = nil
		while true do
			local id = Evenement.tirer(hasard:NextNumber(), precedent)
			precedent = id
			Evenements.lancer(id)
			task.wait(reglages.Intervalle)
		end
	end)
end

return Evenements
