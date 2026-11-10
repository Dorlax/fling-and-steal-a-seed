local Config = require("../../src/shared/Config")
local Cadeaux = require("../../src/shared/Cadeaux")
local Donnees = require("../../src/shared/Donnees")

return {
	["C1 série de connexion : +1 le lendemain, 1 après un jour raté, rien deux fois"] = function()
		local dispo, serie = Cadeaux.quotidien(0, -1, 100)
		assert(dispo and serie == 1, "premier cadeau : jour 1")
		dispo, serie = Cadeaux.quotidien(3, 99, 100)
		assert(dispo and serie == 4, "hier : jour suivant")
		dispo = Cadeaux.quotidien(3, 100, 100)
		assert(not dispo, "déjà pris aujourd'hui")
		dispo, serie = Cadeaux.quotidien(5, 97, 100)
		assert(dispo and serie == 1, "jour raté : on repart à 1")
		dispo, serie = Cadeaux.quotidien(7, 99, 100)
		assert(dispo and serie == 1, "après le jour 7 : nouvelle semaine")
		dispo, serie = Cadeaux.quotidien("x", 0 / 0, 100)
		assert(dispo and serie == 1, "valeurs invalides")
	end,

	["C2 7 récompenses, la dernière est la plus grosse en pièces"] = function()
		local r = Config.Quotidien.Recompenses
		assert(#r == 7, "7 jours")
		assert(r[7].Type == "Pieces" and r[7].Minutes >= r[1].Minutes, "jour 7")
		assert(Cadeaux.pieces(0, 5) == Config.Quotidien.Min, "minimum")
		assert(Cadeaux.pieces(10, 5) == 3000, "10/s × 5 min")
		assert(Cadeaux.pieces(0 / 0, 5) == Config.Quotidien.Min, "NaN")
	end,

	["C3 défis du jour : 3 différents, stables pour un jour, changent d'un jour à l'autre"] = function()
		local a = Cadeaux.defisDu(100, 42)
		assert(#a == Config.Defis.Nombre, "3 défis")
		assert(a[1] ~= a[2] and a[2] ~= a[3] and a[1] ~= a[3], "différents")
		local b = Cadeaux.defisDu(100, 42)
		assert(a[1] == b[1] and a[2] == b[2] and a[3] == b[3], "stables")
		local change = false
		for jour = 101, 110 do
			local c = Cadeaux.defisDu(jour, 42)
			if c[1] ~= a[1] or c[2] ~= a[2] or c[3] ~= a[3] then
				change = true
			end
		end
		assert(change, "changent selon le jour")
		for _, id in a do
			assert(Config.Defis.Liste[id], id)
			assert(not string.find(Cadeaux.texteDefi(id), "%%"), "texte rempli")
		end
	end,

	["C4 codes promo : majuscules, espaces ignorés, inconnus refusés"] = function()
		assert(Cadeaux.code(" bienvenue ") == "BIENVENUE", "normalisé")
		assert(Cadeaux.code("PASUNCODE") == nil, "inconnu")
		assert(Cadeaux.code(12) == nil, "pas un texte")
		assert(Cadeaux.code(string.rep("A", 100)) == nil, "trop long")
	end,

	["C5 sauvegarde : champs des cadeaux nettoyés, réglages par défaut activés"] = function()
		local d = Donnees.nettoyer({
			QuotidienSerie = 99,
			QuotidienJour = 123.7,
			DefisProgres = { 3, -2, "x" },
			DefisReclames = { true, "oui" },
			Codes = { "BIENVENUE", "FAUX", "BIENVENUE" },
			ReglageMusique = false,
		})
		assert(d.QuotidienSerie == 7, "série bornée")
		assert(d.QuotidienJour == 123, "jour entier")
		assert(
			d.DefisProgres[1] == 3 and d.DefisProgres[2] == 0 and d.DefisProgres[3] == 0,
			"progrès"
		)
		assert(d.DefisReclames[1] == true and d.DefisReclames[2] == false, "réclamés")
		assert(#d.Codes == 1 and d.Codes[1] == "BIENVENUE", "codes valides, sans doublon")
		assert(d.ReglageSon == true and d.ReglageMusique == false, "réglages")
		local v = Donnees.parDefaut()
		assert(v.ReglageSon and v.ReglageMusique and v.QuotidienJour == -1, "défauts")
	end,
}
