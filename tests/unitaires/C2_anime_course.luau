-- Animations : un monstre qui poursuit court (penché, rebond, cadence) ;
-- au pas, rien ne change par rapport à avant.
local Anime = require("../../src/shared/Anime")

return {
	["C2 au pas ou à l'arrêt, le monstre se dandine seulement"] = function()
		for _, v in { nil, 0, 3, 0 / 0 } do
			local d = Anime.monstre(1.3, 0.5, v)
			assert(d.Hauteur == 0 and d.Lacet == 0 and d.Tangage == 0, "pas de course")
		end
		assert(Anime.court(nil) == false and Anime.court(0 / 0) == false, "nil / NaN : pas de course")
	end,

	["C2 en course, le monstre penche en avant et rebondit"] = function()
		local c = Anime.Monstre.Course
		assert(Anime.court(c.Seuil) == true, "au seuil : course")
		local maxH = 0
		for i = 0, 100 do
			local d = Anime.monstre(i * 0.03, 0, c.Seuil + 5)
			assert(d.Tangage < 0, "penché vers l'avant")
			assert(d.Hauteur >= 0 and d.Hauteur <= c.Saut + 1e-9, "rebond borné")
			maxH = math.max(maxH, d.Hauteur)
		end
		assert(maxH > c.Saut * 0.5, "il rebondit vraiment")
	end,

	["C2 créatures : pas de tangage, cadence de portée plus rapide"] = function()
		assert(Anime.creature(0.7, 1).Tangage == 0, "créature : tangage nul")
		assert(Anime.Portee.Cadence > 1 and Anime.Monstre.Course.Cadence > 1, "cadences > 1")
	end,
}
