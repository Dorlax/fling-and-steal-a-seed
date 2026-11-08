local Anime = require("../../src/shared/Anime")

return {
	["C1 le sautillement des créatures reste entre 0 et Saut"] = function()
		for i = 0, 200 do
			local d = Anime.creature(i * 0.05, i % 7)
			assert(
				d.Hauteur >= 0 and d.Hauteur <= Anime.Creature.Saut + 1e-9,
				"hauteur hors limites"
			)
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

	["C1 les pièces bougent plus quand le monstre marche"] = function()
		local function ampleur(marche: boolean): number
			local m = 0
			for i = 0, 100 do
				local r = Anime.piece("Patte", i * 0.03, 0, 1, marche, 0)
				m = math.max(m, math.abs(r.X))
			end
			return m
		end
		assert(ampleur(true) > ampleur(false), "la marche doit agiter les pattes")
	end,

	["C1 un rôle inconnu ne bouge pas et un coup lève le bras"] = function()
		local r = Anime.piece("Inconnu", 1, 0, 0, true, 0.5)
		assert(r.X == 0 and r.Y == 0 and r.Z == 0, "rôle inconnu : aucune rotation")
		local sans = Anime.piece("Bras", 0, 0, 1, false, 0)
		local avec = Anime.piece("Bras", 0, 0, 1, false, 0.5)
		assert(avec.X > sans.X, "le coup doit lever le bras vers l'avant")
	end,
}
