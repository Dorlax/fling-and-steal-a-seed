local Config = require("../../src/shared/Config")
local Plaquage = require("../../src/shared/Plaquage")

local function contexte(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		memeJoueur = false,
		plaqueurVivant = true,
		plaqueurAuSol = false,
		plaqueurDansSaBase = false,
		cibleVivante = true,
		ciblePorte = true,
		cibleDansSaBase = false,
		distance = 5,
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
	local ok, pourquoi = Plaquage.verifier(contexte(modif))
	assert(ok == false, "refus attendu")
	assert(pourquoi == raison, "raison attendue " .. raison .. ", obtenue " .. tostring(pourquoi))
end

return {
	["C3 verifier accepte un contexte valide"] = function()
		local ok = Plaquage.verifier(contexte())
		assert(ok == true, "contexte valide refusé")
	end,

	["C3 refus « cible » si la cible ne porte rien"] = function()
		refus({ ciblePorte = false }, "cible")
	end,

	["C3 refus « cible » si la cible est morte"] = function()
		refus({ cibleVivante = false }, "cible")
	end,

	["C4 refus « portee » au-delà de Portee"] = function()
		refus({ distance = Config.Plaquage.Portee + 0.1 }, "portee")
	end,

	["C4 refus « portee » pour NaN et l'infini"] = function()
		refus({ distance = 0 / 0 }, "portee")
		refus({ distance = math.huge }, "portee")
	end,

	["C4 accepté à exactement Portee"] = function()
		local ok = Plaquage.verifier(contexte({ distance = Config.Plaquage.Portee }))
		assert(ok == true, "distance = Portee doit être acceptée")
	end,

	["C5 refus « recuperation » tant que maintenant < pretA"] = function()
		refus({ maintenant = 100, pretA = 100.5 }, "recuperation")
	end,

	["C5 accepté quand maintenant >= pretA"] = function()
		assert(
			Plaquage.verifier(contexte({ maintenant = 100, pretA = 100 })) == true,
			"égalité acceptée"
		)
		assert(
			Plaquage.verifier(contexte({ maintenant = 101, pretA = 100 })) == true,
			"après pretA accepté"
		)
	end,

	["C6 refus « protegee » tant que maintenant < protegeeJusqua"] = function()
		refus({ maintenant = 100, protegeeJusqua = 100.5 }, "protegee")
	end,

	["C6 accepté une fois la protection terminée"] = function()
		assert(
			Plaquage.verifier(contexte({ maintenant = 100, protegeeJusqua = 100 })) == true,
			"égalité acceptée"
		)
		assert(
			Plaquage.verifier(contexte({ maintenant = 105, protegeeJusqua = 100 })) == true,
			"après acceptée"
		)
	end,

	["C7 refus « base » si le plaqueur est dans sa base"] = function()
		refus({ plaqueurDansSaBase = true }, "base")
	end,

	["C7 refus « base » si la cible est dans sa base"] = function()
		refus({ cibleDansSaBase = true }, "base")
	end,

	["C8 refus « soi-même »"] = function()
		refus({ memeJoueur = true }, "soi-même")
	end,

	["C8 refus « indisponible » si le plaqueur est mort ou au sol"] = function()
		refus({ plaqueurVivant = false }, "indisponible")
		refus({ plaqueurAuSol = true }, "indisponible")
	end,

	["C8 ordre des refus"] = function()
		refus({ memeJoueur = true, plaqueurVivant = false, distance = 999 }, "soi-même")
		refus({ plaqueurAuSol = true, maintenant = 1, pretA = 50 }, "indisponible")
		refus({ maintenant = 1, pretA = 50, plaqueurDansSaBase = true }, "recuperation")
		refus({ plaqueurDansSaBase = true, ciblePorte = false }, "base")
		refus({ ciblePorte = false, distance = 999 }, "cible")
		refus({ cibleDansSaBase = true, maintenant = 1, protegeeJusqua = 50 }, "base")
		refus({ maintenant = 1, protegeeJusqua = 50, distance = 999 }, "protegee")
	end,
}
