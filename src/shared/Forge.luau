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

-- Ajoute GainParTick à la stat du mode, sans dépasser PlafondStat.
-- Modifie `stats` et la renvoie ; un mode invalide ne change rien.
function Forge.appliquerGain(stats: { [string]: any }, mode: any, config: any?): { [string]: any }
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
	stats[mode] = math.min(actuelle + cfg.GainParTick, cfg.PlafondStat)
	return stats
end

-- Vitesse de course correspondant à une stat de Vitesse.
function Forge.walkSpeedPour(vitesse: any): number
	local cfg = Config.Forge
	if not estNombreValide(vitesse) or vitesse <= 0 then
		return cfg.WalkSpeedBase
	end
	local resultat = cfg.WalkSpeedBase + vitesse * cfg.WalkSpeedParPointVitesse
	return math.clamp(resultat, cfg.WalkSpeedBase, cfg.WalkSpeedMax)
end

return Forge
