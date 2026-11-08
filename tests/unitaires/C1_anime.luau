local Anime = require("../../src/shared/Anime")

return {
	["C1 le sautillement des créatures reste entre 0 et Saut"] = function()
		for i = 0, 200 do
			local d = Anime.creature(i * 0.05, i % 7)
			assert(d.Hauteur >= 0 and d.Hauteur <= Anime.Creature.Saut + 1e-9, "hauteur hors limites")
			assert(math.abs(d.Lacet) <= Anime.Creature.Lacet + 1e-9, "lacet hors limites")
			assert(math.abs(d.Roulis) <= Anime.Creature.Roulis + 1e-9, "roulis hors limites")
		end
	end,

	["C1 les monstres se dandinent sans bouger en hauteur"] = function()
		for i = 0, 200 do
			local d = Anime.monstre(i * 0.05, 1)
			assert(d.Hauteur == 0 and d.Lacet == 0, "seul le roulis doit varier")
			assert(math.abs(d.Roulis) <= Anime.Monstre.Roulis + 1e-9, "roulis hors limites")
		end
	end,
}
