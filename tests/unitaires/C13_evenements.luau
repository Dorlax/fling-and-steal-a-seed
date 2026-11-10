local Config = require("../../src/shared/Config")
local Evenement = require("../../src/shared/Evenement")

return {
	["C1 six événements, chacun avec nom, texte, icône et un effet"] = function()
		assert(#Config.Evenements.Ordre == 6, "6 événements")
		for _, id in Config.Evenements.Ordre do
			local e = Evenement.infos(id)
			assert(e and e.Nom and e.Texte and e.Icone, id)
			assert(
				e.Revenus or e.Distance or e.BonusTailles or e.Mutations or e.Chance or e.Forge,
				`{id} : un effet`
			)
		end
	end,

	["C2 effets des nouveaux événements, neutres sans événement"] = function()
		assert(
			Evenement.multiplicateurMutation("NuitEtoilee") == 4,
			"étoiles filantes : mutations × 4"
		)
		assert(
			Evenement.multiplicateurMutation("PluieDoree") == Config.Mutations.BonusEvenement,
			"bonus de base"
		)
		assert(Evenement.multiplicateurMutation(nil) == 1, "sans événement")
		assert(
			Evenement.bonusChance("ArcEnCiel") == 1 and Evenement.bonusChance(nil) == 0,
			"chance"
		)
		assert(
			Evenement.multiplicateurForge("Frenesie") == 2
				and Evenement.multiplicateurForge("VentPorteur") == 1,
			"forge"
		)
	end,

	["C3 sons : effets et jingles bien formés"] = function()
		for nom, s in Config.Sons.Effets do
			assert(type(s.Id) == "string" and type(s.Volume) == "number", nom)
		end
		for nom, j in Config.Sons.Jingles do
			assert(Config.Sons.Effets[j.Son] and #j.Notes > 0 and j.Tempo > 0, nom)
		end
	end,
}
