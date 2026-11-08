local Config = require("../../src/shared/Config")
local Plaquage = require("../../src/shared/Plaquage")

return {
	["C9 choisirCible renvoie le valide le plus proche"] = function()
		local i = Plaquage.choisirCible({
			{ distance = 6, valide = true },
			{ distance = 2, valide = true },
			{ distance = 4, valide = true },
		})
		assert(i == 2, "indice 2 attendu, obtenu " .. tostring(i))
	end,

	["C9 choisirCible ignore les invalides"] = function()
		local i = Plaquage.choisirCible({
			{ distance = 1, valide = false },
			{ distance = 5, valide = true },
			{ distance = 3, valide = false },
		})
		assert(i == 2, "indice 2 attendu, obtenu " .. tostring(i))
	end,

	["C9 choisirCible : égalité, le premier"] = function()
		local i = Plaquage.choisirCible({
			{ distance = 9, valide = true },
			{ distance = 3, valide = true },
			{ distance = 3, valide = true },
		})
		assert(i == 2, "le premier à égalité attendu, obtenu " .. tostring(i))
	end,

	["C9 choisirCible : nil pour liste vide ou sans valide"] = function()
		assert(Plaquage.choisirCible({}) == nil, "liste vide -> nil")
		assert(
			Plaquage.choisirCible({
				{ distance = 1, valide = false },
				{ distance = 2, valide = false },
			}) == nil,
			"aucun valide -> nil"
		)
	end,

	["C10 texteBouton : PLAQUER ! si prêt"] = function()
		assert(Plaquage.texteBouton(100, nil) == "PLAQUER !", "pretA nil")
		assert(Plaquage.texteBouton(100, 90) == "PLAQUER !", "pretA dépassé")
		assert(Plaquage.texteBouton(100, 100) == "PLAQUER !", "pretA atteint")
	end,

	["C10 texteBouton : secondes restantes arrondies au supérieur"] = function()
		assert(Plaquage.texteBouton(100, 102.1) == "3", "2,1 s -> 3")
		assert(Plaquage.texteBouton(100, 101) == "1", "1 s -> 1")
		local delai = Config.Plaquage.DelaiRecuperation
		assert(Plaquage.texteBouton(100, 100 + delai) == tostring(delai), "délai complet")
	end,
}
