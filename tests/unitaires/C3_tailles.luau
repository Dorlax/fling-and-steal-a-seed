local Config = require("../../src/shared/Config")
local Fiche = require("../../src/shared/Fiche")
local Revenus = require("../../src/shared/Revenus")
local Donnees = require("../../src/shared/Donnees")

local T = Config.Tailles

return {
	["C3 les taux de taille font 100 % et plus c'est gros, plus ça rapporte"] = function()
		local somme = 0
		local echelle, multiplicateur = 0, 0
		for _, taille in T.Ordre do
			somme += T.Taux[taille]
			assert(T.Echelle[taille] > echelle, "échelle croissante : " .. taille)
			assert(
				T.Multiplicateur[taille] > multiplicateur,
				"multiplicateur croissant : " .. taille
			)
			echelle, multiplicateur = T.Echelle[taille], T.Multiplicateur[taille]
		end
		assert(math.abs(somme - 100) < 1e-9, "les taux doivent faire 100 %")
		assert(T.Multiplicateur.Normale == 1, "Normale = revenu de la rareté")
	end,

	["C3 tirerTaille suit les taux (bornes comprises)"] = function()
		assert(Fiche.tirerTaille(0) == "Normale", "0 -> Normale")
		assert(Fiche.tirerTaille(0.5999) == "Normale", "0.5999 -> Normale")
		assert(Fiche.tirerTaille(0.6) == "Grande", "0.6 -> Grande")
		assert(Fiche.tirerTaille(0.9999) == "Titan", "0.9999 -> Titan")
		assert(Fiche.tirerTaille(5) == "Titan", "hors bornes -> borné")
		assert(Fiche.tirerTaille(-1) == "Normale", "négatif -> borné")
	end,

	["C3 une fiche se relit à l'identique, les anciennes sauvegardes restent valides"] = function()
		local ancienne = Fiche.lire("Rare")
		assert(
			ancienne and ancienne.Rarete == "Rare" and ancienne.Taille == "Normale",
			"ancien format"
		)
		assert(Fiche.ecrire("Rare", "Normale") == "Rare", "Normale sans espèce : format court")
		local texte = Fiche.ecrire("Epique", "Geante", "Hibouflor")
		local infos = Fiche.lire(texte)
		assert(infos and infos.Rarete == "Epique" and infos.Taille == "Geante", "aller-retour")
		assert(infos.Espece == "Hibouflor", "espèce conservée")
	end,

	["C3 une fiche invalide est refusée"] = function()
		for _, mauvaise in
			{ "Rare:Enorme", "Inconnue", "Rare:Grande:x:y", 12, {}, string.rep("a", 80) }
		do
			assert(Fiche.lire(mauvaise) == nil, "doit être refusée : " .. tostring(mauvaise))
		end
		local permises = { Rare = { "Lapinou" } }
		assert(Fiche.lire("Rare:Grande:Lapinou", permises) ~= nil, "espèce permise")
		assert(Fiche.lire("Rare:Grande:Dragonnet", permises) == nil, "espèce d'une autre rareté")
	end,

	["C3 revenu = revenu de la rareté × multiplicateur de taille"] = function()
		assert(Revenus.parSeconde("Epique") == 10, "Épique normale")
		assert(Revenus.parSeconde("Epique:Titan") == 10 * T.Multiplicateur.Titan, "Épique Titan")
		assert(
			Revenus.parSeconde("Rare:Grande:Lapinou") == 3 * T.Multiplicateur.Grande,
			"Rare Grande"
		)
		assert(Revenus.parSeconde("Rare:Enorme") == 0, "taille inconnue : 0")
		assert(
			Revenus.total({ "Commune", "Commune:Geante" }) == 1 + T.Multiplicateur.Geante,
			"total"
		)
	end,

	["C3 la sauvegarde garde les fiches valides et jette les autres"] = function()
		local d = Donnees.nettoyer({
			CreaturesBase = { "Rare", "Mythique:Colossale:Phenigraine", "Rare:Enorme" },
		})
		assert(#d.CreaturesBase == 2, "2 fiches valides attendues")
		assert(d.CreaturesBase[2] == "Mythique:Colossale:Phenigraine", "fiche complète conservée")
	end,
}
