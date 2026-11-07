--!strict
-- Lance tous les tests de tests/unitaires avec Lune : `lune run tests/lanceur`
-- Chaque fichier renvoie { ["C1 description"] = function() ... end }.
local fs = require("@lune/fs")
local process = require("@lune/process")

local reussis, rates = 0, 0
for _, nom in fs.readDir("tests/unitaires") do
	if string.sub(nom, -5) == ".luau" then
		local tests = require("./unitaires/" .. string.sub(nom, 1, -6))
		for titre, test in tests do
			local ok, err = pcall(test)
			if ok then
				reussis += 1
				print("✓ " .. titre)
			else
				rates += 1
				print("✗ " .. titre .. " : " .. tostring(err))
			end
		end
	end
end

print(string.format("%d réussi(s), %d raté(s)", reussis, rates))
if rates > 0 then
	process.exit(1)
end
