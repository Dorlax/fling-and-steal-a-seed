local Style = require("../../src/shared/Style")

local function duree()
	return Style.Bandeau.Duree + 2 * Style.Bandeau.Glisse
end

return {
	["C6 file : le premier message, puis le suivant"] = function()
		local f = Style.nouvelleFile()
		Style.ajouter(f, "A", 0)
		Style.ajouter(f, "B", 0.1)
		assert(Style.courant(f, 1) == "A", "A doit être affiché à t=1")
		assert(Style.courant(f, duree() + 0.01) == "B", "B doit suivre A")
	end,

	["C6 file : jamais deux messages à la fois"] = function()
		local f = Style.nouvelleFile()
		Style.ajouter(f, "A", 0)
		Style.ajouter(f, "B", 0.1)
		local vus = {}
		for i = 0, 200 do
			local t = i * 0.05
			local c = Style.courant(f, t)
			assert(
				c == nil or type(c) == "string",
				"courant doit renvoyer un texte ou nil à t=" .. t
			)
			if c ~= nil then
				vus[c] = true
			end
		end
		assert(vus.A and vus.B, "A et B doivent être vus")
		assert(next(vus, next(vus, next(vus))) == nil, "seuls A et B peuvent apparaître")
	end,

	["C6 file : A reste affiché pendant toute sa durée"] = function()
		local f = Style.nouvelleFile()
		Style.ajouter(f, "A", 0)
		Style.ajouter(f, "B", 0.1)
		for i = 0, 50 do
			local t = i * 0.05
			if t < duree() - 0.01 then
				assert(Style.courant(f, t) == "A", "A attendu à t=" .. t)
			end
		end
	end,

	["C6 file : vide après la fin du dernier message"] = function()
		local f = Style.nouvelleFile()
		Style.ajouter(f, "A", 0)
		Style.ajouter(f, "B", 0.1)
		assert(Style.courant(f, 2 * duree() + 0.5) == nil, "plus rien après la fin de B")
		assert(Style.courant(Style.nouvelleFile(), 0) == nil, "file vide -> nil")
	end,

	["C6 file : un message ajouté plus tard est affiché à son tour"] = function()
		local f = Style.nouvelleFile()
		Style.ajouter(f, "A", 0)
		assert(Style.courant(f, duree() + 1) == nil, "file vide après A")
		Style.ajouter(f, "C", 20)
		assert(Style.courant(f, 21) == "C", "C doit s'afficher")
	end,
}
