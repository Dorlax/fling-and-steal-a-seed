local Config = require("../../src/shared/Config")
local Raid = require("../../src/shared/Raid")

local R = (Config :: any).Raid

local function vol(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		memeJoueur = false,
		voleurVivant = true,
		voleurPorte = false,
		voleurDansBaseCible = true,
		emplacementValide = true,
		distance = R.DistanceVol,
	}
	for k, v in modif or {} do
		c[k] = v
	end
	return c
end

local function refusVol(modif: { [string]: any }, raison: string)
	local ok, pourquoi = Raid.verifierVol(vol(modif))
	assert(ok == false, "refus attendu")
	assert(pourquoi == raison, "raison attendue " .. raison .. ", obtenue " .. tostring(pourquoi))
end

return {
	["C2 verifierVol accepte un contexte valide (distance = DistanceVol)"] = function()
		local ok, pourquoi = Raid.verifierVol(vol())
		assert(ok == true and pourquoi == nil, "contexte valide attendu")
	end,

	["C2 verifierVol : chaque raison de refus"] = function()
		refusVol({ memeJoueur = true }, "soi-même")
		refusVol({ voleurVivant = false }, "indisponible")
		refusVol({ voleurPorte = true }, "porte")
		refusVol({ voleurDansBaseCible = false }, "base")
		refusVol({ emplacementValide = false }, "creature")
		refusVol({ distance = R.DistanceVol + 0.1 }, "portee")
		refusVol({ distance = 0 / 0 }, "portee")
		refusVol({ distance = math.huge }, "portee")
	end,

	["C2 verifierVol : ordre de priorité des raisons"] = function()
		local tout = {
			memeJoueur = true,
			voleurVivant = false,
			voleurPorte = true,
			voleurDansBaseCible = false,
			emplacementValide = false,
			distance = math.huge,
		}
		local ordre = {
			{ "memeJoueur", true, "soi-même" },
			{ "voleurVivant", false, "indisponible" },
			{ "voleurPorte", true, "porte" },
			{ "voleurDansBaseCible", false, "base" },
			{ "emplacementValide", false, "creature" },
		}
		local c = table.clone(tout)
		for _, etape in ordre do
			local _, pourquoi = Raid.verifierVol(c)
			assert(
				pourquoi == etape[3],
				"attendu " .. etape[3] .. ", obtenu " .. tostring(pourquoi)
			)
			c[etape[1]] = not etape[2]
		end
		local _, dernier = Raid.verifierVol(c)
		assert(dernier == "portee", "attendu portee, obtenu " .. tostring(dernier))
	end,

	["C3 verifierVol refuse 'porte' un voleur qui porte déjà une créature"] = function()
		refusVol({ voleurPorte = true }, "porte")
	end,

	["C7 retirerEmplacement retire l'élément sans modifier l'entrée"] = function()
		local liste = { "Commune", "Rare", "Epique" }
		local nouvelle, rarete = Raid.retirerEmplacement(liste, 2)
		assert(rarete == "Rare", "rareté retirée attendue : Rare")
		assert(
			#nouvelle == 2 and nouvelle[1] == "Commune" and nouvelle[2] == "Epique",
			"les suivants remontent"
		)
		assert(#liste == 3 and liste[2] == "Rare", "l'entrée ne doit pas être modifiée")
		assert(nouvelle ~= liste, "doit renvoyer une copie")
	end,

	["C7 retirerEmplacement : numéros invalides → liste identique et nil"] = function()
		local liste = { "Commune", "Rare", "Epique" }
		for _, numero in { 0, 4, 1.5, -1, "2", 0 / 0 } do
			local nouvelle, rarete = Raid.retirerEmplacement(liste, numero :: any)
			assert(rarete == nil, "rareté nil attendue pour " .. tostring(numero))
			assert(
				#nouvelle == 3
					and nouvelle[1] == "Commune"
					and nouvelle[2] == "Rare"
					and nouvelle[3] == "Epique",
				"liste identique pour " .. tostring(numero)
			)
			assert(nouvelle ~= liste, "doit renvoyer une copie")
		end
		local nouvelle, rarete = Raid.retirerEmplacement(liste, nil :: any)
		assert(rarete == nil and #nouvelle == 3, "nil : liste identique et nil")
		assert(#liste == 3, "entrée inchangée")
	end,

	["C7 retirerEmplacement : élément non string → inchangé et nil"] = function()
		local liste: { any } = { "Commune", 5, "Epique" }
		local nouvelle, rarete = Raid.retirerEmplacement(liste, 2)
		assert(rarete == nil and #nouvelle == 3, "élément non string refusé")
	end,


}
