--!strict
-- Entraînement sur la Forge, côté serveur.
-- Les stats vivent dans les attributs du Player (Force, Vitesse, ModeForge,
-- SurForge), écrits uniquement ici et par la Sauvegarde.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)
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
	Forge.appliquerGain(stats, mode, Config.Forge)
	if stats[mode] ~= avant then
		joueur:SetAttribute(mode, stats[mode])
		if mode == "Vitesse" then
			Entrainement.appliquerVitesse(joueur)
		end
	end
end

return Entrainement
