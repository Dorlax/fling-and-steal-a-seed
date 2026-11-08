-- Hypothèses sur l'API de src/shared/Monstre.luau (la maquette ne fixe pas les noms de champs) :
--   zoneDe({X,Y,Z}) -> string ; limiter({X,Y,Z}) -> {X,Y,Z} ; nombreVoulu(zone, nuit) -> number
--   peutFrapper({ zone, cibleVivante, cibleDansSaBase, distance, maintenant, pretA?, protegeeJusqua? }) -> boolean, string?
--   choisirCible(candidats {distance, valide}, portee?) -> number? ; phase(t) -> "Jour"|"Nuit", restant
local Config = require("../../src/shared/Config")
local Monstre = require("../../src/shared/Monstre")

local M = Config.Monstres
local ZONES = { "Proche", "Moyenne", "Lointaine" }

local function contexte(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		zone = "Proche",
		cibleVivante = true,
		cibleDansSaBase = false,
		distance = 3,
		maintenant = 100,
		pretA = nil,
		protegeeJusqua = nil,
	}
	for k, v in modif or {} do
		c[k] = v
	end
	return c
end

local function refus(modif: { [string]: any }, raison: string)
	local ok, pourquoi = Monstre.peutFrapper(contexte(modif))
	assert(ok == false, "refus attendu")
	assert(pourquoi == raison, "raison attendue " .. raison .. ", obtenue " .. tostring(pourquoi))
end

return {
	["C3 zoneDe : Proche, Moyenne, Lointaine selon Z"] = function()
		assert(Monstre.zoneDe({ X = 0, Y = 0, Z = M.BordBases + 10 }) == "Proche", "Proche attendu")
		assert(
			Monstre.zoneDe({ X = 0, Y = 0, Z = M.BordBases + 200 }) == "Moyenne",
			"Moyenne attendu"
		)
		assert(
			Monstre.zoneDe({ X = 0, Y = 0, Z = M.BordBases + 400 }) == "Lointaine",
			"Lointaine attendu"
		)
	end,

	["C4 limiter : Z toujours fini et >= BordBases + MargeBases"] = function()
		local minimum = M.BordBases + M.MargeBases
		for _, z in { -500, -1, 0, M.BordBases, M.BordBases + 1, 1e9, 0 / 0, math.huge, -math.huge } do
			local p = Monstre.limiter({ X = 0, Y = 5, Z = z })
			assert(
				p.Z == p.Z and p.Z > -math.huge and p.Z < math.huge,
				"Z fini attendu pour " .. tostring(z)
			)
			assert(
				p.Z >= minimum,
				"Z >= " .. minimum .. " attendu pour " .. tostring(z) .. ", obtenu " .. p.Z
			)
		end
	end,

	["C4 limiter : une position déjà valide est inchangée"] = function()
		local p = Monstre.limiter({ X = 12, Y = 5, Z = M.BordBases + 100 })
		assert(p.X == 12 and p.Y == 5 and p.Z == M.BordBases + 100, "position valide modifiée")
	end,

	["C5 peutFrapper : true si tout est valide"] = function()
		local ok, raison = Monstre.peutFrapper(contexte())
		assert(ok == true and raison == nil, "coup attendu, raison " .. tostring(raison))
	end,

	["C5 peutFrapper : cible morte -> indisponible"] = function()
		refus({ cibleVivante = false }, "indisponible")
	end,

	["C5 peutFrapper : cible dans sa base -> base"] = function()
		refus({ cibleDansSaBase = true }, "base")
	end,

	["C5 peutFrapper : cible protégée -> protegee"] = function()
		refus({ protegeeJusqua = 105 }, "protegee")
	end,

	["C5 peutFrapper : monstre en recharge -> recharge"] = function()
		refus({ pretA = 101 }, "recharge")
	end,

	["C5 peutFrapper : hors de portée ou NaN -> portee"] = function()
		for _, nom in ZONES do
			refus({ zone = nom, distance = M.Zones[nom].PorteeCoup + 0.5 }, "portee")
		end
		refus({ distance = 0 / 0 }, "portee")
	end,

	["C5 peutFrapper : protection et recharge écoulées -> true"] = function()
		local ok = Monstre.peutFrapper(contexte({ protegeeJusqua = 100, pretA = 100 }))
		assert(ok == true, "coup attendu quand protection et recharge sont écoulées")
	end,

	["C6 choisirCible : le valide le plus proche dans la portée de détection"] = function()
		local portee = M.Zones.Proche.PorteeDetection
		local i = Monstre.choisirCible({
			{ distance = portee - 1, valide = true },
			{ distance = 2, valide = false },
			{ distance = 8, valide = true },
		}, portee)
		assert(i == 3, "indice 3 attendu, obtenu " .. tostring(i))
	end,

	["C6 choisirCible : nil si aucun valide ou tous hors de portée"] = function()
		local portee = M.Zones.Proche.PorteeDetection
		assert(Monstre.choisirCible({}, portee) == nil, "liste vide -> nil")
		assert(
			Monstre.choisirCible({ { distance = 1, valide = false } }, portee) == nil,
			"invalide -> nil"
		)
		assert(
			Monstre.choisirCible({ { distance = portee + 5, valide = true } }, portee) == nil,
			"trop loin -> nil"
		)
	end,

	["C7 nombreVoulu : NombreJour le jour, NombreNuit la nuit"] = function()
		for _, nom in ZONES do
			assert(Monstre.nombreVoulu(nom, false) == M.Zones[nom].NombreJour, nom .. " jour")
			assert(Monstre.nombreVoulu(nom, true) == M.Zones[nom].NombreNuit, nom .. " nuit")
		end
	end,

	["C8 phase : Jour puis Nuit puis cycle"] = function()
		local C = Config.Cycle
		assert((Monstre.phase(0)) == "Jour", "t = 0 -> Jour")
		assert((Monstre.phase(C.DureeJour - 1)) == "Jour", "DureeJour - 1 -> Jour")
		assert((Monstre.phase(C.DureeJour)) == "Nuit", "DureeJour -> Nuit")
		assert((Monstre.phase(C.DureeJour + C.DureeNuit)) == "Jour", "fin de cycle -> Jour")
		assert(
			(Monstre.phase(C.DureeJour + C.DureeNuit + C.DureeJour)) == "Nuit",
			"2e cycle -> Nuit"
		)
	end,

	["C8 phase : temps restant dans la phase"] = function()
		local C = Config.Cycle
		local _, restant = Monstre.phase(C.DureeJour - 1)
		assert(restant == 1, "1 s restante attendue, obtenue " .. tostring(restant))
	end,
}
