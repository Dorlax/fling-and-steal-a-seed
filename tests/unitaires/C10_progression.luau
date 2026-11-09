local Bonus = require("../../src/shared/Bonus")
local Config = require("../../src/shared/Config")
local Lancer = require("../../src/shared/Lancer")
local Fiche = require("../../src/shared/Fiche")
local Revenus = require("../../src/shared/Revenus")
local Donnees = require("../../src/shared/Donnees")
local Collection = require("../../src/shared/Collection")
local Biomes = require("../../src/shared/Biomes")

return {
	["C1 renaissance : prix croissant, revenus × 2 et Forge + 50 % par renaissance"] = function()
		assert(Bonus.prixRenaissance(0) == Config.Renaissance.PrixBase, "prix de départ")
		assert(
			Bonus.prixRenaissance(2) == Config.Renaissance.PrixBase * 100,
			"× 10 par renaissance"
		)
		assert(Bonus.revenusRenaissance(3) == 8, "× 2 ^ 3")
		assert(Bonus.forgeRenaissance(2) == 2, "+ 50 % × 2")
		assert(Bonus.revenusRenaissance(0 / 0) == 1, "valeur invalide")
		assert(math.abs(Bonus.revenus(1, 2) - 2 * 1.2) < 1e-9, "renaissance × collection")
	end,

	["C2 graines : taux du Plan sans graine, raretés hautes plus fréquentes avec, total 100 %"] = function()
		for _, zone in Config.Lancer.Zones do
			local plan = Config.Raretes.Taux[zone.Nom]
			local sans = Lancer.tauxAvecChance(zone.Nom, 0)
			for rarete, valeur in plan do
				assert(math.abs(sans[rarete] - valeur) < 1e-9, "graine simple = taux du Plan")
			end
			for _, id in Config.Graines.Ordre do
				local taux = Lancer.tauxAvecChance(zone.Nom, Config.Graines.Liste[id].Chance)
				local total = 0
				for _, rarete in Config.Raretes.Ordre do
					assert(taux[rarete] > 0, "toutes les raretés restent possibles")
					total += taux[rarete]
				end
				assert(math.abs(total - 100) < 1e-6, "total 100 %")
			end
			local cosmique = Lancer.tauxAvecChance(zone.Nom, Config.Graines.Liste.Cosmique.Chance)
			assert(cosmique.Mythique > plan.Mythique, "plus de Mythiques")
		end
		assert(
			Lancer.tirerRareteChance("Proche", 0.1, 0) == Lancer.tirerRarete("Proche", 0.1),
			"même tirage"
		)
		assert(Bonus.meilleureGraine("Doree", "Cristal") == "Cristal", "meilleure graine")
		assert(Bonus.graine("Inconnue").Chance == 0, "graine inconnue = simple")
		local prix, chance = -1, -1
		for _, id in Config.Graines.Ordre do
			local g = Config.Graines.Liste[id]
			assert(g.Prix > prix and g.Chance > chance, "chaque graine meilleure et plus chère")
			prix, chance = g.Prix, g.Chance
		end
	end,

	["C3 mutations : fiche lue, revenus multipliés, chances respectées"] = function()
		local fiche = Fiche.ecrire("Rare", "Normale", "Hibouflor", "Doree")
		local infos = Fiche.lire(fiche)
		assert(infos and infos.Mutation == "Doree" and infos.Espece == "Hibouflor", "lecture")
		assert(Fiche.lire("Rare:Normale:Hibouflor:Bidon") == nil, "mutation inconnue refusée")
		assert(
			Revenus.parSeconde(fiche) == Revenus.parSeconde("Rare:Normale:Hibouflor") * 3,
			"Dorée : × 3"
		)
		assert(Fiche.tirerMutation(0.99) == nil, "le plus souvent rien")
		assert(Fiche.tirerMutation(0) == "Galactique", "tirage 0 : la plus rare")
		assert(Fiche.multiplicateurMutation("Galactique") == 30, "Galactique : × 30")
		local precedent = 0
		for _, nom in Config.Mutations.Ordre do
			local m = Config.Mutations.Liste[nom]
			assert(m.Mult > precedent, "plus rare = plus rentable")
			assert(m.Effet ~= nil and m.Melange ~= nil, "visuel défini")
			precedent = m.Mult
		end
		assert(Fiche.texte("Rare", "Grande", "Cristal") == "Cristal Grande Rare", "texte")
	end,

	["C4 données : renaissances, graines, traînées et roue nettoyées"] = function()
		local d = Donnees.nettoyer({
			Renaissances = 2.7,
			Graines = { "Doree", "Bidon", "Doree" },
			Graine = "Cristal",
			Trainees = { "Bulles", "X" },
			Trainee = "Bulles",
			ProchaineRoue = 123.4,
		})
		assert(d.Renaissances == 2, "renaissances")
		assert(#d.Graines == 2 and d.Graines[1] == "Simple" and d.Graines[2] == "Doree", "graines")
		assert(d.Graine == "Simple", "graine non possédée refusée")
		assert(#d.Trainees == 1 and d.Trainee == "Bulles", "traînées")
		assert(d.ProchaineRoue == 123, "roue")
	end,

	["C5 Bestiaire : une page complète compte"] = function()
		local liste = {}
		for _, rarete in Config.Raretes.Ordre do
			for _, nom in Biomes.Liste[1].Creatures[rarete] do
				table.insert(liste, nom)
			end
		end
		assert(Collection.pagesCompletes(liste) == 1, "page 1 complète")
		table.remove(liste)
		assert(Collection.pagesCompletes(liste) == 0, "incomplète")
	end,
}
