--!strict
-- Cycle jour/nuit (serveur) : la phase dépend uniquement de l'horloge serveur.
-- Applique l'éclairage à Lighting (répliqué par Roblox), met l'attribut `Nuit`
-- sur Workspace et prévient les joueurs au changement de phase.
-- `maintenant` (optionnel) sert uniquement aux tests en jeu.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Monstre = require(ReplicatedStorage.Shared.Monstre)

local CycleJourNuit = {}

local cycle = Config.Cycle
local INTERVALLE = 1 -- secondes entre deux vérifications de la phase

-- Nuit cartoon : bleu-violet profond, terrain bien visible.
local NUIT = {
	Ambient = Color3.fromRGB(70, 60, 130),
	OutdoorAmbient = Color3.fromRGB(70, 60, 130),
	Brightness = 1,
}

local jour: { Ambient: Color3, OutdoorAmbient: Color3, Brightness: number }? = nil
local phaseActuelle: string? = nil
local demarre = false

local function estNombreFini(valeur: any): boolean
	return type(valeur) == "number"
		and valeur == valeur
		and valeur > -math.huge
		and valeur < math.huge
end

local function envoyerATous(texte: string)
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireAllClients(texte)
	end
end

-- Applique la phase de `maintenant` (horloge serveur par défaut).
-- Renvoie "Jour" ou "Nuit".
function CycleJourNuit.appliquer(maintenant: number?): string
	local instant = if estNombreFini(maintenant)
		then maintenant :: number
		else Workspace:GetServerTimeNow()
	if jour == nil then
		-- Éclairage actuel du jeu = éclairage de jour.
		jour = {
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
			Brightness = Lighting.Brightness,
		}
	end
	local phase = Monstre.phase(instant)
	local nuit = phase == "Nuit"
	local reglage = if nuit then NUIT else jour :: any
	Lighting.ClockTime = if nuit then cycle.HeureNuit else cycle.HeureJour
	Lighting.Ambient = reglage.Ambient
	Lighting.OutdoorAmbient = reglage.OutdoorAmbient
	Lighting.Brightness = reglage.Brightness
	Workspace:SetAttribute("Nuit", nuit)

	if phaseActuelle ~= nil and phaseActuelle ~= phase then
		if nuit then
			envoyerATous("La nuit tombe… les monstres arrivent en nombre !")
		else
			envoyerATous("Le jour se lève !")
		end
	end
	phaseActuelle = phase
	return phase
end

-- Applique la phase tout de suite, puis la vérifie chaque seconde.
function CycleJourNuit.demarrer()
	CycleJourNuit.appliquer()
	if demarre then
		return
	end
	demarre = true
	task.spawn(function()
		while true do
			task.wait(INTERVALLE)
			CycleJourNuit.appliquer()
		end
	end)
end

return CycleJourNuit
