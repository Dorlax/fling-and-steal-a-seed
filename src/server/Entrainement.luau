--!strict
-- Entraînement sur la Forge, côté serveur.
-- Les stats vivent dans les attributs du Player (Force, Vitesse, ModeForge,
-- SurForge), écrits uniquement ici et par la Sauvegarde.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Forge = require(ReplicatedStorage.Shared.Forge)
local Bonus = require(ReplicatedStorage.Shared.Bonus)
local Piege = require(ReplicatedStorage.Shared.Piege)
local Revenus = require(ReplicatedStorage.Shared.Revenus)
local Passes = require(ReplicatedStorage.Shared.Passes)
local Evenement = require(ReplicatedStorage.Shared.Evenement)
local Cadeaux = require(script.Parent.Cadeaux)

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

-- Reçu du client : seul un mode permis à ce niveau de Forge est accepté.
function Entrainement.traiterChoixMode(joueur: any, valeur: any)
	if not Forge.modePermis(valeur, joueur:GetAttribute("NiveauForge")) then
		return
	end
	joueur:SetAttribute("ModeForge", valeur)
end

-- Un tick d'entraînement : si le joueur est sur sa Forge (attribut SurForge,
-- calculé par le serveur), la stat du mode actif gagne le gain du niveau
-- (mode Double : les deux stats, chacune à Config.Forge.Double.Part),
-- × renaissances, × 2 avec le passe de la stat.
function Entrainement.tick(joueur: any)
	if joueur:GetAttribute("SurForge") ~= true then
		return
	end
	local mode = joueur:GetAttribute("ModeForge")
	local niveau = joueur:GetAttribute("NiveauForge")
	if not Forge.modePermis(mode, niveau) then
		return
	end
	local noms, part = Forge.statsDuMode(mode)
	-- Renaissances : le gain de la Forge grandit (+50 % par renaissance).
	local bonus = Bonus.forgeRenaissance(joueur:GetAttribute("Renaissances"))
	local plafond = Config.Forge.PlafondStat
	-- Frénésie de la Forge (événement) : gains multipliés.
	local frenesie = Evenement.multiplicateurForge(Workspace:GetAttribute("Evenement"))
	Cadeaux.progresser(joueur, "Forge", Config.Forge.IntervalleSecondes)
	for _, nom in noms do
		local avant = joueur:GetAttribute(nom)
		if type(avant) ~= "number" or avant ~= avant or avant < 0 then
			avant = 0
		end
		local passe = joueur:GetAttribute(Passes.attribut("X2" .. nom))
		local gain = math.max(
			1,
			math.floor(
				Forge.gainPour(niveau, Config.Forge)
						* part
						* bonus
						* Passes.multiplicateurStat(nom, passe)
						* frenesie
					+ 0.5
			)
		)
		local apres = math.min(avant + gain, plafond)
		if apres ~= avant then
			joueur:SetAttribute(nom, apres)
			if nom == "Vitesse" then
				Entrainement.appliquerVitesse(joueur)
			end
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
