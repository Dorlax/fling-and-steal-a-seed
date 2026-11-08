local Config = require("../../src/shared/Config")
local Forge = require("../../src/shared/Forge")

local cfg = Config.Forge

-- appliquerGain peut modifier la table ou en renvoyer une nouvelle : on accepte les deux.
local function gain(stats: any, mode: any): any
	local resultat = (Forge :: any).appliquerGain(stats, mode, cfg)
	if type(resultat) == "table" then
		return resultat
	end
	return stats
end

return {
	["C1 estModeValide accepte Force et Vitesse"] = function()
		assert(Forge.estModeValide("Force") == true, "Force doit être valide")
		assert(Forge.estModeValide("Vitesse") == true, "Vitesse doit être valide")
	end,

	["C1 estModeValide refuse les autres valeurs"] = function()
		for _, v in { "Vol", "", 42, {} } do
			assert(Forge.estModeValide(v) == false, "doit refuser " .. tostring(v))
		end
		assert(Forge.estModeValide(nil) == false, "doit refuser nil")
	end,

	["C2 gain en mode Force"] = function()
		local r = gain({ Force = 10, Vitesse = 5 }, "Force")
		assert(r.Force == 10 + cfg.GainParTick, "Force doit gagner GainParTick")
		assert(r.Vitesse == 5, "Vitesse ne doit pas changer")
	end,

	["C2 gain en mode Vitesse"] = function()
		local r = gain({ Force = 10, Vitesse = 5 }, "Vitesse")
		assert(r.Vitesse == 5 + cfg.GainParTick, "Vitesse doit gagner GainParTick")
		assert(r.Force == 10, "Force ne doit pas changer")
	end,

	["C3 le gain ne dépasse pas le plafond"] = function()
		local r = gain({ Force = cfg.PlafondStat - 0.5, Vitesse = 0 }, "Force")
		assert(r.Force == cfg.PlafondStat, "doit s'arrêter exactement au plafond")
		local r2 = gain({ Force = 0, Vitesse = cfg.PlafondStat }, "Vitesse")
		assert(r2.Vitesse == cfg.PlafondStat, "inchangée au plafond")
	end,

	["C4 mode invalide : aucune stat modifiée"] = function()
		for _, mode in { "Triche", "", 42, {} } do
			local r = gain({ Force = 3, Vitesse = 4 }, mode)
			assert(r.Force == 3 and r.Vitesse == 4, "stats modifiées pour " .. tostring(mode))
		end
		local r = gain({ Force = 3, Vitesse = 4 }, nil)
		assert(r.Force == 3 and r.Vitesse == 4, "stats modifiées pour nil")
	end,

	["C5 walkSpeedPour(0) vaut la base"] = function()
		assert(Forge.walkSpeedPour(0) == cfg.WalkSpeedBase)
	end,

	["C5 walkSpeedPour est croissante"] = function()
		assert(Forge.walkSpeedPour(500) > Forge.walkSpeedPour(100))
	end,

	["C5 walkSpeedPour est bornée"] = function()
		assert(Forge.walkSpeedPour(math.huge) <= cfg.WalkSpeedMax, "math.huge dépasse le max")
		assert(Forge.walkSpeedPour(1e9) <= cfg.WalkSpeedMax, "1e9 dépasse le max")
	end,

	["C5 walkSpeedPour négatif ou NaN donne la base"] = function()
		assert(Forge.walkSpeedPour(-10) == cfg.WalkSpeedBase)
		assert(Forge.walkSpeedPour(0 / 0) == cfg.WalkSpeedBase)
	end,

	["C8 Config.Forge est complète"] = function()
		assert(type(cfg) == "table", "Config.Forge manquante")
		assert(type(cfg.Modes) == "table", "Modes manquant")
		assert(cfg.IntervalleSecondes > 0)
		assert(cfg.GainParTick > 0)
		assert(cfg.PlafondStat > 0)
		assert(type(cfg.WalkSpeedBase) == "number")
		assert(type(cfg.WalkSpeedMax) == "number")
		assert(cfg.WalkSpeedMax >= cfg.WalkSpeedBase)
	end,
}
