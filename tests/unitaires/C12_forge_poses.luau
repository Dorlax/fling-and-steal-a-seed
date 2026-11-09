local Config = require("../../src/shared/Config")
local Forge = require("../../src/shared/Forge")
local PosesForge = require("../../src/shared/PosesForge")

local CHAMPS = {
	"dy",
	"penche",
	"tete",
	"hancheG",
	"hancheD",
	"genouG",
	"genouD",
	"epauleG",
	"epauleD",
	"ecartG",
	"ecartD",
	"coudeG",
	"coudeD",
}

return {
	["C1 gains de la Forge : +1, +2, +5, +10, +20, +50…"] = function()
		local attendus = { 1, 2, 5, 10, 20, 50, 100, 200, 500 }
		for niveau, gain in attendus do
			assert(Forge.gainPour(niveau) == gain * Config.Forge.GainParTick, `niveau {niveau}`)
		end
		assert(Forge.gainPour(0 / 0) == Forge.gainPour(1), "niveau invalide = 1")
	end,

	["C5 paliers : l'agrès se modernise avec le niveau"] = function()
		assert(Forge.palier(1) == 1 and Forge.palier(nil) == 1, "rustique au départ")
		local precedent = 0
		for i, palier in Config.Forge.Paliers do
			assert(palier.Niveau > precedent, "niveaux croissants")
			precedent = palier.Niveau
			assert(Forge.palier(palier.Niveau) == i, palier.Nom)
			for _, mode in { "Vitesse", "Force", "Double" } do
				assert(type(palier[mode]) == "string", `{palier.Nom} {mode}`)
			end
		end
		assert(Forge.agres("Vitesse", 1) == "Roue en bois", "roue au début")
		assert(Forge.agres("Force", 999) == "Météorite", "dernier palier")
		assert(Forge.palier(Config.Forge.Double.NiveauMin) >= 4, "Double = agrès moderne")
	end,

	["C2 poses : chaque mode donne une pose complète et finie"] = function()
		for _, mode in { "Vitesse", "Force", "Double" } do
			for _, phase in { 0, 0.25, 0.5, 1, 2, 3 } do
				for _, i in { 0, 0.5, 1, 5, -1 } do
					local pose = PosesForge.pose(mode, phase, i)
					assert(pose, mode)
					for _, champ in CHAMPS do
						local v = (pose :: any)[champ]
						assert(
							type(v) == "number" and v == v and math.abs(v) < 10,
							`{mode}.{champ}`
						)
					end
				end
			end
		end
		assert(PosesForge.pose("Triche", 0, 0) == nil, "mode inconnu")
	end,

	["C3 de plus en plus vite : le tempo monte avec la série"] = function()
		for _, mode in { "Vitesse", "Force", "Double" } do
			assert(PosesForge.tempo(mode, 1) > PosesForge.tempo(mode, 0), mode)
		end
	end,

	["C4 course : les jambes alternent ; soulevé : la barre monte au-dessus de la tête"] = function()
		local course = PosesForge.course(math.pi / 2, 0)
		assert(course.hancheG > 0 and course.hancheD < 0, "jambes opposées")
		assert(course.epauleG < 0 and course.epauleD > 0, "bras opposés aux jambes")
		assert(
			PosesForge.hauteurBarre(0) == 0 and math.abs(PosesForge.hauteurBarre(0.5) - 1) < 1e-9
		)
		local haut = PosesForge.souleve(0.5, 0)
		local bas = PosesForge.souleve(0, 0)
		assert(haut.epauleG > 2.5 and bas.epauleG < 1, "bras levés en haut")
		assert(haut.coudeG < bas.coudeG, "bras tendus en haut")
		assert(
			PosesForge.corde(math.pi, 0).dy > PosesForge.corde(0, 0).dy,
			"saut quand la corde passe"
		)
	end,
}
