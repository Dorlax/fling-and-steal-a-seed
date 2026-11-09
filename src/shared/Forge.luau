--!strict
-- Logique pure de la Forge : modes, gain, plafond, conversion Vitesse -> WalkSpeed.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local Forge = {}

local function estNombreValide(valeur: any): boolean
	return type(valeur) == "number" and valeur == valeur
end

-- Vrai seulement pour un nom de mode connu ("Force" ou "Vitesse").
function Forge.estModeValide(mode: any): boolean
	if type(mode) ~= "string" then
		return false
	end
	for _, nom in Config.Forge.Modes do
		if nom == mode then
			return true
		end
	end
	return false
end

-- Niveau de Forge valide (entier >= 1).
local function niveauValide(niveau: any): number
	if type(niveau) ~= "number" or niveau ~= niveau or niveau < 1 or niveau == math.huge then
		return 1
	end
	return math.floor(niveau)
end

-- Gain par tick au niveau n : suite 1, 2, 5, 10, 20, 50, 100… × GainParTick.
local SUITE = { 1, 2, 5 }
function Forge.gainPour(niveau: any, config: any?): number
	local cfg = config or Config.Forge
	local n = niveauValide(niveau) - 1
	return cfg.GainParTick * SUITE[n % 3 + 1] * 10 ^ (n // 3)
end

-- Coût en pièces pour passer du niveau n au niveau n + 1.
function Forge.coutNiveau(niveau: any): number
	local n = Config.Forge.Niveaux
	return math.floor(n.CoutBase * n.CroissanceCout ^ (niveauValide(niveau) - 1) + 0.5)
end

-- Ajoute le gain du niveau (GainParTick au niveau 1) à la stat du mode, sans
-- dépasser PlafondStat. Modifie `stats` et la renvoie ; un mode invalide ne
-- change rien.
function Forge.appliquerGain(
	stats: { [string]: any },
	mode: any,
	config: any?,
	niveau: any?
): { [string]: any }
	local cfg = config or Config.Forge
	if not Forge.estModeValide(mode) then
		return stats
	end
	local actuelle = stats[mode]
	if not estNombreValide(actuelle) or actuelle < 0 then
		actuelle = 0
	end
	if actuelle >= cfg.PlafondStat then
		return stats
	end
	stats[mode] = math.min(actuelle + Forge.gainPour(niveau, cfg), cfg.PlafondStat)
	return stats
end

-- Vitesse de course correspondant à une stat de Vitesse.
function Forge.walkSpeedPour(vitesse: any): number
	local cfg = Config.Forge
	if not estNombreValide(vitesse) or vitesse <= 0 then
		return cfg.WalkSpeedBase
	end
	local lineaire = math.min(vitesse, cfg.StatLineaire)
	local resultat = cfg.WalkSpeedBase + lineaire * cfg.WalkSpeedParPointVitesse
	if vitesse > cfg.StatLineaire and vitesse < math.huge then
		-- Chaque doublement au-delà ajoute un palier de vitesse (sans limite).
		resultat += math.log(vitesse / cfg.StatLineaire, 2) * cfg.WalkSpeedParDoublement
	end
	return math.clamp(resultat, cfg.WalkSpeedBase, cfg.WalkSpeedMax)
end

-- Mode accepté pour ce niveau : Force, Vitesse, ou Double à partir du niveau
-- Config.Forge.Double.NiveauMin.
function Forge.modePermis(mode: any, niveau: any): boolean
	if Forge.estModeValide(mode) then
		return true
	end
	return mode == "Double" and niveauValide(niveau) >= Config.Forge.Double.NiveauMin
end

-- Stats entraînées par un mode et part du gain de chacune.
function Forge.statsDuMode(mode: any): ({ string }, number)
	if mode == "Double" then
		return { "Force", "Vitesse" }, Config.Forge.Double.Part
	end
	if Forge.estModeValide(mode) then
		return { mode :: string }, 1
	end
	return {}, 0
end

-- Palier de la Forge (1 = Rustique…) pour un niveau.
function Forge.palier(niveau: any): number
	local n = niveauValide(niveau)
	local trouve = 1
	for i, palier in Config.Forge.Paliers do
		if n >= palier.Niveau then
			trouve = i
		end
	end
	return trouve
end

-- Nom de l'agrès d'un mode à ce niveau (« Roue en bois », « Haltères »…).
function Forge.agres(mode: any, niveau: any): string
	local palier: any = Config.Forge.Paliers[Forge.palier(niveau)]
	return if type(mode) == "string" and palier[mode] then palier[mode] else palier.Vitesse
end

return Forge
