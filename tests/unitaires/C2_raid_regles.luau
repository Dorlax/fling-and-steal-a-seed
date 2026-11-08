local Config = require("../../src/shared/Config")
local Raid = require("../../src/shared/Raid")

local R = (Config :: any).Raid

local function vol(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		memeJoueur = false,
		voleurVivant = true,
		voleurPorte = false,
		voleurDansBaseCible = true,
		baseVerrouillee = false,
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

local function verrou(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		estProprietaire = true,
		vivant = true,
		distance = 3,
		pieces = R.PrixVerrou,
		maintenant = 100,
		verrouJusqua = nil,
		pretA = nil,
	}
	for k, v in modif or {} do
		c[k] = v
	end
	return c
end

local function refusVerrou(modif: { [string]: any }, raison: string)
	local ok, pourquoi = Raid.verifierVerrou(verrou(modif))
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
		refusVol({ baseVerrouillee = true }, "verrouillee")
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
			baseVerrouillee = true,
			emplacementValide = false,
			distance = math.huge,
		}
		local ordre = {
			{ "memeJoueur", true, "soi-même" },
			{ "voleurVivant", false, "indisponible" },
			{ "voleurPorte", true, "porte" },
			{ "voleurDansBaseCible", false, "base" },
			{ "baseVerrouillee", true, "verrouillee" },
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

	["C4 verifierVerrou accepte un propriétaire vivant, à portée, avec le prix"] = function()
		local ok, pourquoi = Raid.verifierVerrou(verrou())
		assert(ok == true and pourquoi == nil, "contexte valide attendu")
	end,

	["C4 verifierVerrou : chaque raison de refus"] = function()
		refusVerrou({ estProprietaire = false }, "proprietaire")
		refusVerrou({ vivant = false }, "indisponible")
		refusVerrou({ distance = R.DistanceVerrou + 0.1 }, "portee")
		refusVerrou({ distance = 0 / 0 }, "portee")
		refusVerrou({ verrouJusqua = 150 }, "verrouillee")
		refusVerrou({ verrouJusqua = 90, pretA = 150 }, "recharge")
		refusVerrou({ pieces = R.PrixVerrou - 1 }, "pieces")
		refusVerrou({ pieces = 0 / 0 }, "pieces")
		-- Une clé à nil n'existe pas dans une table : on construit le contexte à la main.
		local sansPieces = verrou()
		sansPieces.pieces = nil
		local ok, pourquoi = Raid.verifierVerrou(sansPieces)
		assert(ok == false and pourquoi == "pieces", "refus pieces attendu si pieces est nil")
	end,

	["C4 verifierVerrou : ordre de priorité et bornes"] = function()
		refusVerrou(
			{ estProprietaire = false, vivant = false, distance = 99, pieces = 0 },
			"proprietaire"
		)
		refusVerrou({ vivant = false, distance = 99, pieces = 0 }, "indisponible")
		refusVerrou({ distance = 99, verrouJusqua = 150, pieces = 0 }, "portee")
		refusVerrou({ verrouJusqua = 150, pretA = 200, pieces = 0 }, "verrouillee")
		refusVerrou({ verrouJusqua = 90, pretA = 150, pieces = 0 }, "recharge")
		-- Bornes : verrou fini et recharge finie à maintenant exactement.
		local ok = Raid.verifierVerrou(verrou({ verrouJusqua = 100, pretA = 100 }))
		assert(ok == true, "verrou et recharge terminés à maintenant")
	end,

	["C5 acheterVerrou(100) renvoie (160, 220)"] = function()
		local jusqua, pret = Raid.acheterVerrou(100)
		assert(jusqua == 100 + R.DureeVerrou, "verrouJusqua attendu 160")
		assert(pret == 100 + R.DureeVerrou + R.Recharge, "pretA attendu 220")
		assert(jusqua == 160 and pret == 220, "valeurs par défaut 160 / 220")
	end,

	["C5 estVerrouillee"] = function()
		assert(Raid.estVerrouillee(159.9, 160) == true, "159.9 < 160 : verrouillée")
		assert(Raid.estVerrouillee(160, 160) == false, "160 == 160 : libre")
		assert(Raid.estVerrouillee(1000, nil) == false, "nil : libre")
		assert(Raid.estVerrouillee(0, nil) == false, "nil : libre")
		assert(Raid.estVerrouillee(10, 0 / 0) == false, "NaN : libre")
		assert(Raid.estVerrouillee(10, math.huge) == false, "non fini : libre")
	end,

	["C6 doitExpulser n'est vrai que pour (false, true, true)"] = function()
		for _, proprio in { false, true } do
			for _, dans in { false, true } do
				for _, verrouillee in { false, true } do
					local attendu = (not proprio) and dans and verrouillee
					local r = Raid.doitExpulser(proprio, dans, verrouillee)
					assert(
						r == attendu,
						string.format(
							"(%s, %s, %s) : attendu %s",
							tostring(proprio),
							tostring(dans),
							tostring(verrouillee),
							tostring(attendu)
						)
					)
				end
			end
		end
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

	["C8 texteVerrou"] = function()
		assert(Raid.texteVerrou(100, 160, 220) == "VERROUILLÉ 60 s", "verrou 60 s")
		assert(Raid.texteVerrou(159.2, 160, 220) == "VERROUILLÉ 1 s", "arrondi au supérieur")
		assert(Raid.texteVerrou(170, 160, 220) == "Prêt dans 50 s", "recharge")
		assert(Raid.texteVerrou(220, 160, 220) == "Verrouiller : 100 pièces", "prêt")
		assert(Raid.texteVerrou(0, nil, nil) == "Verrouiller : 100 pièces", "jamais acheté")
	end,
}
