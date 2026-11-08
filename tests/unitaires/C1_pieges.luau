local Config = require("../../src/shared/Config")
local Piege = require("../../src/shared/Piege")

local PIEGES = Config.Pieges
local NAN = 0 / 0

local function contexteHors(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		typePiege = "Filet",
		vivant = true,
		immobilise = false,
		pieces = PIEGES.Types.Filet.Prix + 1000,
		actifs = 0,
		maintenant = 100,
		pretA = nil,
		position = { X = 0, Y = 0, Z = Config.Monstres.BordBases + Config.Monstres.MargeBases + 50 },
		dansUneBase = false,
		distancePlusProche = nil,
	}
	for k, v in modif or {} do
		c[k] = v
	end
	return c
end

local function refusPose(modif: { [string]: any }, raison: string)
	local ok, pourquoi = Piege.verifierPose(contexteHors(modif))
	assert(ok == false, "refus attendu (" .. raison .. ")")
	assert(pourquoi == raison, "raison attendue " .. raison .. ", obtenue " .. tostring(pourquoi))
end

local function contexteAffecter(modif: { [string]: any }?): any
	local c: { [string]: any } = {
		memePoseur = false,
		vivante = true,
		maintenant = 100,
		protegeeJusqua = nil,
		immobileJusqua = nil,
	}
	for k, v in modif or {} do
		c[k] = v
	end
	return c
end

return {
	["C1 Config.Pieges contient les trois types avec un prix > 0"] = function()
		for _, nom in { "Filet", "Glu", "FausseGraine" } do
			local t = PIEGES.Types[nom]
			assert(t ~= nil, "type manquant : " .. nom)
			assert(type(t.Prix) == "number" and t.Prix > 0, "Prix > 0 attendu pour " .. nom)
		end
	end,

	["C1 réglages généraux strictement positifs"] = function()
		assert(PIEGES.MaxParJoueur > 0, "MaxParJoueur > 0")
		assert(PIEGES.DelaiPose > 0, "DelaiPose > 0")
		assert(PIEGES.DureeVie > 0, "DureeVie > 0")
		assert(PIEGES.DureeProtection > 0, "DureeProtection > 0")
	end,

	["C1 durées des effets et multiplicateur de glu"] = function()
		assert(PIEGES.Types.Filet.Duree > 0, "Filet.Duree > 0")
		assert(PIEGES.Types.FausseGraine.Duree > 0, "FausseGraine.Duree > 0")
		local m = PIEGES.Types.Glu.Multiplicateur
		assert(m > 0 and m < 1, "Glu.Multiplicateur strictement entre 0 et 1")
	end,

	["C2 estType accepte les trois noms"] = function()
		for _, nom in { "Filet", "Glu", "FausseGraine" } do
			assert(Piege.estType(nom) == true, nom .. " doit être accepté")
		end
	end,

	["C2 estType refuse nil, Bombe, 1 et {}"] = function()
		assert(Piege.estType(nil) == false, "nil refusé")
		assert(Piege.estType("Bombe") == false, "Bombe refusé")
		assert(Piege.estType(1) == false, "1 refusé")
		assert(Piege.estType({}) == false, "{} refusé")
	end,

	["C3 verifierPose accepte un contexte valide"] = function()
		local ok, raison = Piege.verifierPose(contexteHors())
		assert(ok == true and raison == nil, "contexte valide refusé : " .. tostring(raison))
	end,

	["C3 refus « type »"] = function()
		refusPose({ typePiege = "Bombe" }, "type")
		refusPose({ typePiege = 123 }, "type")
	end,

	["C3 refus « indisponible » si mort ou immobilisé"] = function()
		refusPose({ vivant = false }, "indisponible")
		refusPose({ immobilise = true }, "indisponible")
	end,

	["C3 refus « delai » tant que pretA n'est pas atteint"] = function()
		refusPose({ maintenant = 100, pretA = 101 }, "delai")
		local ok = Piege.verifierPose(contexteHors({ maintenant = 101, pretA = 101 }))
		assert(ok == true, "au moment de pretA la pose est permise")
	end,

	["C3 refus « limite » à MaxParJoueur pièges actifs"] = function()
		refusPose({ actifs = PIEGES.MaxParJoueur }, "limite")
		local ok = Piege.verifierPose(contexteHors({ actifs = PIEGES.MaxParJoueur - 1 }))
		assert(ok == true, "MaxParJoueur - 1 actifs : pose permise")
	end,

	["C3 refus « pieces » si pièces < prix ou NaN"] = function()
		refusPose({ pieces = PIEGES.Types.Filet.Prix - 1 }, "pieces")
		refusPose({ pieces = NAN }, "pieces")
		refusPose({ pieces = false }, "pieces")
		local ok = Piege.verifierPose(contexteHors({ pieces = PIEGES.Types.Filet.Prix }))
		assert(ok == true, "pièces = prix : pose permise")
	end,

	["C3 refus « zone » dans une base ou hors des Terres Sauvages"] = function()
		local seuil = Config.Monstres.BordBases + Config.Monstres.MargeBases
		refusPose({ dansUneBase = true }, "zone")
		refusPose({ position = { X = 0, Y = 0, Z = seuil - 1 } }, "zone")
		refusPose({ position = { X = 0, Y = 0, Z = Config.Monstres.BordBases + Config.Lancer.DistanceMax + 41 } }, "zone")
		refusPose({ position = { X = 401, Y = 0, Z = seuil + 10 } }, "zone")
		local ok = Piege.verifierPose(contexteHors({ position = { X = 0, Y = 0, Z = seuil } }))
		assert(ok == true, "Z = BordBases + MargeBases : pose permise")
	end,

	["C3 refus « ecart » trop près d'un autre piège"] = function()
		refusPose({ distancePlusProche = PIEGES.EcartMin - 0.1 }, "ecart")
		local ok = Piege.verifierPose(contexteHors({ distancePlusProche = PIEGES.EcartMin }))
		assert(ok == true, "distance = EcartMin : pose permise")
	end,

	["C3 ordre des raisons : type avant indisponible avant delai avant limite"] = function()
		refusPose({ typePiege = false, vivant = false }, "type")
		refusPose({ vivant = false, pretA = 1000, actifs = 99 }, "indisponible")
		refusPose({ pretA = 1000, actifs = 99, pieces = 0 }, "delai")
		refusPose({ actifs = 99, pieces = 0 }, "limite")
		refusPose({ pieces = 0, dansUneBase = true }, "pieces")
		refusPose({ dansUneBase = true, distancePlusProche = 0 }, "zone")
	end,

	["C4 peutAffecter accepte une victime normale"] = function()
		local ok, raison = Piege.peutAffecter(contexteAffecter())
		assert(ok == true and raison == nil, "victime normale refusée : " .. tostring(raison))
	end,

	["C4 peutAffecter refuse le poseur"] = function()
		local ok, raison = Piege.peutAffecter(contexteAffecter({ memePoseur = true }))
		assert(ok == false and raison == "poseur", "raison « poseur » attendue")
	end,

	["C4 peutAffecter refuse une joueuse morte"] = function()
		local ok, raison = Piege.peutAffecter(contexteAffecter({ vivante = false }))
		assert(ok == false and raison == "morte", "raison « morte » attendue")
	end,

	["C4 peutAffecter refuse pendant la protection puis accepte après"] = function()
		local ok, raison = Piege.peutAffecter(contexteAffecter({ maintenant = 100, protegeeJusqua = 104 }))
		assert(ok == false and raison == "protegee", "raison « protegee » attendue")
		local apres = Piege.peutAffecter(contexteAffecter({ maintenant = 104, protegeeJusqua = 104 }))
		assert(apres == true, "protection finie : affectable")
	end,

	["C4 peutAffecter refuse pendant une immobilisation"] = function()
		local ok, raison = Piege.peutAffecter(contexteAffecter({ maintenant = 100, immobileJusqua = 103 }))
		assert(ok == false and raison == "deja", "raison « deja » attendue")
		local apres = Piege.peutAffecter(contexteAffecter({ maintenant = 103, immobileJusqua = 103 }))
		assert(apres == true, "immobilisation finie : affectable")
	end,

	["C5 walkSpeed vaut 0 si immobilisé"] = function()
		assert(Piege.walkSpeed(16, true, false) == 0, "immobilisé : 0")
		assert(Piege.walkSpeed(16, true, true) == 0, "immobilisé et englué : 0")
	end,

	["C5 walkSpeed applique le multiplicateur de glu"] = function()
		local attendu = 16 * PIEGES.Types.Glu.Multiplicateur
		assert(math.abs(Piege.walkSpeed(16, false, true) - attendu) < 1e-6, "base × Multiplicateur attendu")
	end,

	["C5 walkSpeed renvoie la base sans effet"] = function()
		assert(Piege.walkSpeed(23, false, false) == 23, "base inchangée")
	end,

	["C5 walkSpeed jamais négatif ni NaN"] = function()
		local base = Config.Forge.WalkSpeedBase
		local mult = PIEGES.Types.Glu.Multiplicateur
		local invalides: { any } = { NAN, "x" }
		for i = 1, 3 do
			local invalide: any = invalides[i] -- le 3e est nil
			local libre = Piege.walkSpeed(invalide, false, false)
			assert(libre == libre and libre >= 0, "résultat valide attendu")
			assert(libre == base, "base invalide : Forge.WalkSpeedBase attendu")
			local englue = Piege.walkSpeed(invalide, false, true)
			assert(englue == englue and englue >= 0, "résultat valide attendu (glu)")
			assert(
				englue == base or math.abs(englue - base * mult) < 1e-6,
				"base invalide englué : WalkSpeedBase éventuellement multiplié"
			)
			assert(Piege.walkSpeed(invalide, true, false) == 0, "immobilisé : 0 même si base invalide")
		end
	end,

	["C6 estExpire est faux juste avant la fin de vie"] = function()
		assert(Piege.estExpire(100, 100 + PIEGES.DureeVie - 0.01) == false, "pas encore expiré")
		assert(Piege.estExpire(100, 100) == false, "juste posé")
	end,

	["C6 estExpire est vrai à partir de poseA + DureeVie"] = function()
		assert(Piege.estExpire(100, 100 + PIEGES.DureeVie) == true, "expiré pile")
		assert(Piege.estExpire(100, 100 + PIEGES.DureeVie + 50) == true, "expiré")
	end,

	["C6 estExpire est vrai pour des entrées invalides"] = function()
		assert(Piege.estExpire(NAN, 100) == true, "poseA NaN")
		assert(Piege.estExpire(100, NAN) == true, "maintenant NaN")
		assert(Piege.estExpire(nil :: any, 100) == true, "poseA nil")
		assert(Piege.estExpire(100, nil :: any) == true, "maintenant nil")
		assert(Piege.estExpire(math.huge, 100) == true, "poseA infini")
	end,

	["C7 texteBouton affiche nom et prix quand prêt"] = function()
		local attendu = PIEGES.Types.Filet.Nom .. " " .. PIEGES.Types.Filet.Prix
		assert(Piege.texteBouton("Filet", 100, nil, 0) == attendu, "« " .. attendu .. " » attendu")
		assert(Piege.texteBouton("Filet", 100, 100, 0) == attendu, "prêt pile à pretA")
		local glu = PIEGES.Types.Glu.Nom .. " " .. PIEGES.Types.Glu.Prix
		assert(Piege.texteBouton("Glu", 100, 50, 1) == glu, "délai passé : texte normal")
	end,

	["C7 texteBouton arrondit au supérieur les secondes restantes"] = function()
		assert(Piege.texteBouton("Filet", 100, 102.2, 0) == "3", "2,2 s -> « 3 »")
		assert(Piege.texteBouton("Glu", 100, 100.1, 0) == "1", "0,1 s -> « 1 »")
	end,

	["C7 texteBouton affiche MAX à la limite de pièges"] = function()
		assert(Piege.texteBouton("Filet", 100, nil, PIEGES.MaxParJoueur) == "MAX", "MAX attendu")
		assert(Piege.texteBouton("Filet", 100, nil, PIEGES.MaxParJoueur + 2) == "MAX", "MAX attendu (>)")
	end,
}
