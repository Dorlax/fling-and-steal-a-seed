-- Épaulé-jeté et sprint de la Forge ; zone de départ des lancers.
local PosesForge = require("../../src/shared/PosesForge")
local Config = require("../../src/shared/Config")

return {
	["C1 épaulé-jeté : accroupi au départ, barre aux épaules, puis au-dessus"] = function()
		local bas = PosesForge.souleve(0, 1)
		local epaules = PosesForge.souleve(0.28, 1)
		local haut = PosesForge.souleve(0.5, 1)
		assert(bas.dy < -0.5 and bas.genouG > 1.2, "accroupi au départ")
		assert(epaules.coudeG > 2 and epaules.epauleG < 1, "barre aux épaules")
		assert(haut.epauleG > 2.5 and haut.coudeG < 0.3, "bras tendus au-dessus")
		local fin = PosesForge.souleve(0.999, 1)
		assert(math.abs(fin.dy - bas.dy) < 0.05, "la répétition boucle")
		for _, p in { 0 / 0, -3, 7.25 } do
			local pose = PosesForge.souleve(p, 0.5)
			for nom, v in pose :: any do
				assert(v == v, "valeur NaN : " .. nom)
			end
		end
	end,

	["C2 sprint : genou haut devant, bras pliés, buste penché"] = function()
		local maxHanche, maxGenou = 0, 0
		for k = 0, 40 do
			local p = PosesForge.course(k / 40 * 2 * math.pi, 1)
			maxHanche = math.max(maxHanche, p.hancheG)
			maxGenou = math.max(maxGenou, p.genouG)
			assert(p.coudeG > 1.2 and p.coudeD > 1.2, "bras pliés")
			assert(p.penche > 0.2, "buste penché")
		end
		assert(maxHanche > 0.9 and maxGenou > 1.5, "genou haut et talon qui remonte")
	end,

	["C3 la zone de départ des lancers est plus profonde"] = function()
		assert(Config.ZoneSure.Profondeur >= 100, "zone de départ agrandie")
		assert(Config.Lancer.DureeVolGraine >= 1 and Config.Lancer.DureeVolGraine <= 3, "vol suivi")
	end,
}
