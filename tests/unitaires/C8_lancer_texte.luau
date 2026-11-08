local Lancer = require("../../src/shared/Lancer")

return {
	["C8 texteTaux Proche : virgule française"] = function()
		local texte = Lancer.texteTaux("Proche")
		assert(string.find(texte, "Commune 70 %", 1, true), "Commune 70 % manquant : " .. texte)
		assert(
			string.find(texte, "Légendaire 1,8 %", 1, true),
			"Légendaire 1,8 % manquant : " .. texte
		)
		assert(string.find(texte, "Mythique 0,2 %", 1, true), "Mythique 0,2 % manquant : " .. texte)
	end,

	["C8 texteTaux Moyenne : pas de .0 ni ,0"] = function()
		local texte = Lancer.texteTaux("Moyenne")
		assert(string.find(texte, "Mythique 1 %", 1, true), "Mythique 1 % manquant : " .. texte)
		assert(not string.find(texte, "1,0", 1, true), "ne doit pas contenir 1,0 : " .. texte)
	end,
}
