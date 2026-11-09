local Config = require("../../src/shared/Config")
local Monstre = require("../../src/shared/Monstre")
local Biomes = require("../../src/shared/Biomes")

return {
	["C3 coup de monstre : propulsion qui suit la vitesse du biome, plafonnée"] = function()
		for _, zone in { "Proche", "Moyenne", "Lointaine" } do
			local precedent = 0
			for biome = 1, Biomes.nombre() do
				local h, v, duree = Monstre.recul(zone, biome)
				assert(h > 0 and v > 0 and duree > 0, "propulsion attendue")
				assert(h >= precedent, zone .. " : plus loin dans les biomes lointains")
				assert(h <= Config.Monstres.ReculMax, "plafond ReculMax")
				precedent = h
			end
			local h1 = Monstre.recul(zone, 1)
			assert(
				math.abs(h1 - Monstre.vitesse(zone, 1) * Config.Monstres.Zones[zone].Recul) < 1e-6,
				"biome 1 : vitesse × Recul"
			)
		end
		assert(
			Monstre.recul("Lointaine", 50) == Config.Monstres.ReculMax,
			"plafond atteint au loin"
		)
	end,

	["C3 aucun champ Degats : les monstres ne blessent jamais"] = function()
		for nom, zone in Config.Monstres.Zones do
			assert(zone.Degats == nil, nom .. " ne doit pas avoir de Degats")
		end
	end,
}
