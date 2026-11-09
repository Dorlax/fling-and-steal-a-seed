--!strict
-- Entraînement sur la Forge, côté serveur.
-- Les stats vivent dans les attributs du Player (Force, Vitesse, ModeForge,
-- SurForge), écrits uniquement ici et par la Sauvegarde.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)
local Bonus = require(ReplicatedStorage.Shared.Bonus)
local Piege = require(ReplicatedStorage.Shared.Piege)
local Revenus = require(ReplicatedStorage.Shared.Revenus)

local Entrainement = {}

-- Applique au personnage le WalkSpeed correspondant à la Vitesse (ralenti
-- pendant le portage d'une créature, attribut Porte, puis effets de piège :
-- ImmobileJusqua et Englue, écrits par Pieges) ; le renvoie.
function Entrainement.appliquerVitesse(joueur: any): number
	local walkSpeed = Forge.walkSpeedPour(joueur:GetAttribute("Vitesse"))
	if joueur:GetAttribute("Porte") ~= nil then
		walkSpeed = Revenus.walkSpeedPortage(walkSpeed)
	end
	-- L'attribut ImmobileJusqua n'existe que pendant l'immobilisation.
	local immobile = type(joueur:GetAttribute("ImmobileJusqua")) == "number"
	walkSpeed = Piege.walkSpeed(walkSpeed, immobile, joueur:GetAttribute("Englue") == true)
	local personnage = joueur.Character
	if personnage then
		local humanoide = personnage:FindFirstChildOfClass("Humanoid")
		if humanoide then
			humanoide.WalkSpeed = walkSpeed
		end
	end
	return walkSpeed
end

-- Reçu du client : seul un nom de mode valide est accepté.
function Entrainement.traiterChoixMode(joueur: any, valeur: any)
	if not Forge.estModeValide(valeur) then
		return
	end
	joueur:SetAttribute("ModeForge", valeur)
end

-- Un tick d'entraînement : si le joueur est sur sa Forge (attribut SurForge,
-- calculé par le serveur), la stat du mode actif gagne GainParTick.
function Entrainement.tick(joueur: any)
	if joueur:GetAttribute("SurForge") ~= true then
		return
	end
	local mode = joueur:GetAttribute("ModeForge")
	if not Forge.estModeValide(mode) then
		return
	end
	local stats = {
		Force = joueur:GetAttribute("Force"),
		Vitesse = joueur:GetAttribute("Vitesse"),
	}
	local avant = stats[mode]
	Forge.appliquerGain(stats, mode, Config.Forge, joueur:GetAttribute("NiveauForge"))
	-- Renaissances : le gain de la Forge grandit (+50 % par renaissance).
	local bonus = Bonus.forgeRenaissance(joueur:GetAttribute("Renaissances"))
	if bonus > 1 and type(avant) == "number" and type(stats[mode]) == "number" then
		stats[mode] = math.min(avant + (stats[mode] - avant) * bonus, Config.Forge.PlafondStat)
	end
	if stats[mode] ~= avant then
		joueur:SetAttribute(mode, stats[mode])
		if mode == "Vitesse" then
			Entrainement.appliquerVitesse(joueur)
		end
	end
end

-- Achat du niveau de Forge suivant avec des pièces (tout vérifié ici).
-- Renvoie true si le niveau a été acheté.
function Entrainement.ameliorer(joueur: any): boolean
	local niveau = joueur:GetAttribute("NiveauForge")
	if type(niveau) ~= "number" or niveau ~= niveau or niveau < 1 then
		niveau = 1
	end
	local cout = Forge.coutNiveau(niveau)
	local pieces = joueur:GetAttribute("Pieces")
	if type(pieces) ~= "number" or pieces ~= pieces or pieces < cout then
		return false
	end
	joueur:SetAttribute("Pieces", pieces - cout)
	joueur:SetAttribute("NiveauForge", math.floor(niveau) + 1)
	return true
end

return Entrainement
