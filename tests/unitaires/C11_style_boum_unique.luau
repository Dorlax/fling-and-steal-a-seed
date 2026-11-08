local fs = require("@lune/fs")

return {
	["C11 Panneaux cache le BOUM ! serveur de EffetPlaquage"] = function()
		local src = fs.readFile("src/client/Panneaux.luau")
		assert(string.find(src, "EffetPlaquage", 1, true), "Panneaux doit gérer EffetPlaquage")
		assert(string.find(src, "Boum", 1, true), "Panneaux doit gérer le label Boum")
		assert(string.find(src, "Visible = false", 1, true), "Panneaux doit cacher le label (Visible = false)")
	end,

	["C11 InterfacePieces n'envoie pas BOUM ! aux bandeaux"] = function()
		local src = fs.readFile("src/client/InterfacePieces.luau")
		assert(string.find(src, "estBoum", 1, true), "InterfacePieces doit utiliser Style.estBoum")
		assert(string.find(src, "Bandeaux", 1, true), "InterfacePieces doit utiliser Bandeaux")
	end,
}
