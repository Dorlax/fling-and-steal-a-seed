local Style = require("../../src/shared/Style")

-- Textes distincts affichés au fil du temps, dans l'ordre.
local function parcourir(f, fin)
	local vus, ordre = {}, {}
	for i = 0, math.floor(fin / 0.05) do
		local c = Style.courant(f, i * 0.05)
		if c ~= nil and not vus[c] then
			vus[c] = true
			table.insert(ordre, c)
		end
	end
	return ordre
end

return {
	["C7 ajouter : ignore nil, vide et non-chaînes"] = function()
		local f = Style.nouvelleFile()
		local ajouter: any = Style.ajouter
		ajouter(f, nil, 0)
		ajouter(f, "", 0)
		ajouter(f, 42, 0)
		ajouter(f, {}, 0)
		assert(Style.courant(f, 0.5) == nil, "rien ne doit être affiché")
		assert(#parcourir(f, 20) == 0, "rien ne doit jamais s'afficher")
	end,

	["C7 ajouter : tronque à 80 caractères"] = function()
		local f = Style.nouvelleFile()
		Style.ajouter(f, string.rep("x", 200), 0)
		local c = Style.courant(f, 0.5)
		assert(c ~= nil, "le message doit être affiché")
		assert(#(c :: string) == 80, "80 caractères attendus, reçu " .. #(c :: string))
	end,

	["C7 ajouter : deux messages identiques à la suite = un seul"] = function()
		local f = Style.nouvelleFile()
		Style.ajouter(f, "Base pleine !", 0)
		Style.ajouter(f, "Base pleine !", 0.1)
		local fin = Style.Bandeau.Duree + 2 * Style.Bandeau.Glisse
		assert(Style.courant(f, 1) == "Base pleine !", "le message doit être affiché")
		assert(Style.courant(f, fin + 0.01) == nil, "aucun deuxième exemplaire après le premier")
	end,

	["C7 ajouter : au plus 3 messages en attente"] = function()
		local f = Style.nouvelleFile()
		for _, t in { "A", "B", "C", "D", "E", "F" } do
			Style.ajouter(f, t, 0)
		end
		local ordre = parcourir(f, 60)
		assert(#ordre <= 4, "au plus 1 affiché + 3 en attente, reçu " .. #ordre)
		assert(ordre[#ordre] == "F", "le plus récent doit être conservé")
		for i = 2, #ordre do
			assert(ordre[i] > ordre[i - 1], "l'ordre d'arrivée doit être respecté")
		end
	end,
}
