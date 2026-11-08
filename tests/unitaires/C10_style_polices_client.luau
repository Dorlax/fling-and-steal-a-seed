local fs = require("@lune/fs")

return {
	["C10 aucun fichier client n'utilise Enum.Font.Gotham"] = function()
		local nombre = 0
		for _, nom in fs.readDir("src/client") do
			if string.sub(nom, -5) == ".luau" then
				nombre += 1
				local contenu = fs.readFile("src/client/" .. nom)
				assert(
					string.find(contenu, "Enum.Font.Gotham", 1, true) == nil,
					nom .. " utilise encore une police Gotham"
				)
			end
		end
		assert(nombre > 0, "aucun fichier client trouvé")
	end,
}
