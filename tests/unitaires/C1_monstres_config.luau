local Config = require("../../src/shared/Config")

local ZONES = { "Proche", "Moyenne", "Lointaine" }

return {
	["C1 Config.Monstres.Zones contient exactement Proche, Moyenne, Lointaine"] = function()
		local n = 0
		for nom in Config.Monstres.Zones do
			n += 1
			assert(table.find(ZONES, nom) ~= nil, "zone inattendue : " .. tostring(nom))
		end
		assert(n == 3, "3 zones attendues, trouvées " .. n)
		for _, nom in ZONES do
			assert(Config.Monstres.Zones[nom] ~= nil, "zone manquante : " .. nom)
		end
	end,

	["C1 Vitesse, Degats, PorteeDetection, NombreJour, NombreNuit strictement croissants"] = function()
		local z = Config.Monstres.Zones
		for _, champ in { "Vitesse", "Degats", "PorteeDetection", "NombreJour", "NombreNuit" } do
			assert(z.Proche[champ] < z.Moyenne[champ], champ .. " : Proche < Moyenne attendu")
			assert(z.Moyenne[champ] < z.Lointaine[champ], champ .. " : Moyenne < Lointaine attendu")
		end
	end,

	["C1 Recharge strictement décroissante"] = function()
		local z = Config.Monstres.Zones
		assert(z.Proche.Recharge > z.Moyenne.Recharge, "Recharge Proche > Moyenne attendu")
		assert(z.Moyenne.Recharge > z.Lointaine.Recharge, "Recharge Moyenne > Lointaine attendu")
	end,

	["C2 NombreNuit > NombreJour dans chaque zone"] = function()
		for _, nom in ZONES do
			local zone = Config.Monstres.Zones[nom]
			assert(zone.NombreNuit > zone.NombreJour, nom .. " : NombreNuit > NombreJour attendu")
		end
	end,

	["C2 Vitesse < Forge.WalkSpeedMax dans chaque zone"] = function()
		for _, nom in ZONES do
			assert(
				Config.Monstres.Zones[nom].Vitesse < Config.Forge.WalkSpeedMax,
				nom .. " : un joueur entraîné doit pouvoir fuir"
			)
		end
	end,
}
