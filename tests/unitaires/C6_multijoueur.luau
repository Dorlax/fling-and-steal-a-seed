local Config = require("../../src/shared/Config")
local Evenement = require("../../src/shared/Evenement")
local Classement = require("../../src/shared/Classement")
local Donnees = require("../../src/shared/Donnees")

return {
	["C1 événements : tirage couvre toute la liste et ne répète jamais le précédent"] = function()
		local vus = {}
		for i = 0, 99 do
			local id = Evenement.tirer(i / 100)
			assert(Evenement.infos(id), "événement inconnu : " .. tostring(id))
			vus[id] = true
		end
		for _, id in Config.Evenements.Ordre do
			assert(vus[id], "jamais tiré : " .. id)
			for i = 0, 9 do
				assert(Evenement.tirer(i / 10, id) ~= id, "répétition de " .. id)
			end
		end
		assert(Evenement.infos(Evenement.tirer(0 / 0)), "tirage invalide -> premier")
		assert(Evenement.infos(Evenement.tirer(1)), "tirage 1 -> dernier")
	end,

	["C2 événements : effets, neutres sans événement"] = function()
		assert(Evenement.multiplicateurRevenus("PluieDoree") == 2, "Pluie dorée : × 2")
		assert(Evenement.bonusDistance("VentPorteur") == 300, "Vent porteur : + 300")
		assert(Evenement.bonusTailles("GrainesGeantes") == 3, "Graines géantes : + 3 biomes")
		for _, id in { nil, "", "Inconnu", 42 } :: { any } do
			assert(Evenement.multiplicateurRevenus(id) == 1, "revenus neutres")
			assert(Evenement.bonusDistance(id) == 0, "distance neutre")
			assert(Evenement.bonusTailles(id) == 0, "tailles neutres")
		end
		-- Un événement n'a qu'un seul effet.
		assert(
			Evenement.bonusDistance("PluieDoree") == 0 and Evenement.bonusTailles("PluieDoree") == 0
		)
	end,

	["C3 événements : temps restant et texte"] = function()
		assert(Evenement.restant(110, 100) == 10, "10 s")
		assert(Evenement.restant(99.2, 100) == 0, "jamais négatif")
		assert(Evenement.restant(nil, 100) == 0, "fin invalide")
		assert(Evenement.texteDuree(125) == "2:05", "2:05")
		assert(Evenement.texteDuree(-3) == "0:00", "0:00")
	end,

	["C4 classement : score des revenus croissant et réversible"] = function()
		assert(Classement.scoreRevenus(0) == 0 and Classement.scoreRevenus(-5) == 0, "0 ou moins")
		assert(Classement.scoreRevenus(0 / 0) == 0, "NaN")
		local precedent = -1
		for _, r in { 1, 9, 10, 1e3, 1e6, 1e15, 1e100, 1e300, math.huge } do
			local s = Classement.scoreRevenus(r)
			assert(s > precedent, "score croissant pour " .. tostring(r))
			assert(s == math.floor(s), "score entier")
			precedent = s
		end
		local r = Classement.revenusDeScore(Classement.scoreRevenus(123456))
		assert(math.abs(r - 123456) / 123456 < 0.01, "inverse à 1 % près")
	end,

	["C5 classement : tri décroissant, 10 lignes, entrées invalides ignorées"] = function()
		local entrees = {}
		for i = 1, 15 do
			table.insert(entrees, { Nom = "J" .. i, Valeur = i })
		end
		table.insert(entrees, { Nom = "Mauvais", Valeur = 0 / 0 })
		table.insert(entrees, { Valeur = 99 })
		table.insert(entrees, "texte")
		local top = Classement.trier(entrees)
		assert(#top == Config.Classement.Taille, "10 lignes")
		assert(top[1].Nom == "J15" and top[10].Nom == "J6", "ordre décroissant")
		assert(#Classement.trier(nil) == 0, "rien -> liste vide")
		local egal = Classement.trier({ { Nom = "B", Valeur = 1 }, { Nom = "A", Valeur = 1 } })
		assert(egal[1].Nom == "A", "égalité : ordre alphabétique")
	end,

	["C6 record de biome : ne fait que monter"] = function()
		local r, battu = Classement.record(3, 5)
		assert(r == 5 and battu, "5 bat 3")
		r, battu = Classement.record(5, 4)
		assert(r == 5 and not battu, "4 ne bat pas 5")
		r, battu = Classement.record(5, 5)
		assert(r == 5 and not battu, "égalité : pas de record")
		r, battu = Classement.record(nil, 1)
		assert(r == 1 and not battu, "défaut 1")
		r, battu = Classement.record(2, 0 / 0)
		assert(r == 2 and not battu, "biome invalide")
	end,

	["C7 données : RecordBiome sauvegardé et nettoyé"] = function()
		assert(Donnees.parDefaut().RecordBiome == 1, "défaut 1")
		assert(Donnees.nettoyer({ RecordBiome = 7.6 }).RecordBiome == 7, "entier")
		for _, mauvais in { 0, -2, 0 / 0, math.huge, "9" } :: { any } do
			assert(Donnees.nettoyer({ RecordBiome = mauvais }).RecordBiome == 1, "invalide -> 1")
		end
	end,
}
