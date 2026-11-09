local GestionBase = require("../../src/shared/GestionBase")
local Config = require("../../src/shared/Config")
local Revenus = require("../../src/shared/Revenus")
local Promenade = require("../../src/shared/Promenade")
local Donnees = require("../../src/shared/Donnees")

return {
	["C1 vente : prix = revenu × Secondes, rien pour une fiche invalide"] = function()
		local fiche = "Rare:Grande"
		assert(
			GestionBase.prixVente(fiche) == Revenus.parSeconde(fiche) * Config.Vente.Secondes,
			"prix"
		)
		assert(GestionBase.prixVente("Inconnue") == 0, "fiche invalide")
	end,

	["C2 tri : les plus rentables d'abord, encodage réversible"] = function()
		local liste = { "Commune", "Mythique", "Rare" }
		local triee = GestionBase.trier(liste)
		assert(triee[1] == "Mythique" and triee[3] == "Commune", "ordre décroissant")
		assert(liste[1] == "Commune", "la liste d'origine ne change pas")
		local retour = GestionBase.decoder(GestionBase.encoder(triee))
		assert(#retour == 3 and retour[1] == "Mythique", "encodage")
		assert(#GestionBase.decoder("Mythique,Bidon") == 1, "fiche invalide ignorée")
	end,

	["C3 hors ligne : moitié du revenu, plafond 12 h, rien sous 1 min"] = function()
		local r = Config.HorsLigne
		assert(GestionBase.gainHorsLigne(10, 30) == 0, "trop court")
		assert(GestionBase.gainHorsLigne(10, 3600) == math.floor(10 * 3600 * r.Taux), "une heure")
		assert(
			GestionBase.gainHorsLigne(10, 1e9) == math.floor(10 * r.MaxSecondes * r.Taux),
			"plafond"
		)
		assert(GestionBase.gainHorsLigne(0 / 0, 3600) == 0, "revenu invalide")
		assert(
			Donnees.nettoyer({ DerniereConnexion = 1700000000.5 }).DerniereConnexion == 1700000000,
			"date"
		)
		assert(Donnees.nettoyer({ DerniereConnexion = -1 }).DerniereConnexion == 0, "date invalide")
	end,

	["C4 promenade : reste dans son disque, marche puis s'arrête"] = function()
		local marche, pause = false, false
		for i = 0, 400 do
			local e = Promenade.etat(4.2, i * 0.1)
			assert(math.sqrt(e.X ^ 2 + e.Z ^ 2) <= Promenade.Rayon + 1e-6, "hors du disque")
			assert(e.Saut >= 0 and e.Saut <= 2, "saut raisonnable")
			if e.Marche then
				marche = true
			else
				pause = true
			end
		end
		assert(marche and pause, "elle marche et fait des pauses")
		local a = Promenade.etat(1.5, 12.3)
		local b = Promenade.etat(1.5, 12.3)
		assert(a.X == b.X and a.Z == b.Z, "déterministe : même résultat partout")
	end,
}
