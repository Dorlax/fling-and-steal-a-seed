local Projection = require("../../src/shared/Projection")

return {
	["C4 projection : chaque style est tirable et bien formé"] = function()
		local vus = {}
		for i = 0, 99 do
			vus[Projection.tirer(i / 100).Id] = true
		end
		for _, style in Projection.Liste do
			assert(vus[style.Id], "jamais tiré : " .. style.Id)
			assert(#style.Mots > 0 and style.Message ~= "", style.Id .. " : textes")
			assert(style.MultH > 0 and style.MultV > 0, style.Id .. " : poussée")
			assert(Projection.style(style.Id) == style, "recherche par Id")
			assert(table.find(style.Mots, Projection.mot(style, 0.5)), "mot du style")
		end
		assert(Projection.tirer(0 / 0) == Projection.Liste[1], "tirage invalide")
		assert(Projection.style("Inconnu") == nil, "style inconnu")
	end,

	["C4 projection : Fusée monte plus haut, Ballon étourdit plus longtemps"] = function()
		local fusee = Projection.style("Fusee") :: any
		local boing = Projection.style("Boing") :: any
		local ballon = Projection.style("Ballon") :: any
		local _, vFusee = Projection.poussee(fusee, 100, 30)
		local _, vBoing = Projection.poussee(boing, 100, 30)
		assert(vFusee > vBoing * 2, "la fusée monte bien plus haut")
		assert(Projection.duree(boing, 1) == 1, "durée de la zone")
		assert(Projection.duree(ballon, 1) > ballon.Ballon, "étourdi tant qu'il flotte")
	end,
}
