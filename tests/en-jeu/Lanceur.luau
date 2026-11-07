--!strict
-- Lance tous les ModuleScripts de ce dossier (sauf celui-ci) dans un vrai serveur.
-- Appelé par scripts/tests-en-jeu.sh via Open Cloud (Luau Execution).
-- Lève une erreur si un test échoue : la CI échoue alors.
return function(): string
	local lignes, rates = {}, 0
	for _, module in script.Parent:GetChildren() do
		if module:IsA("ModuleScript") and module ~= script then
			for titre, test in require(module) :: any do
				local ok, err = pcall(test)
				if ok then
					table.insert(lignes, "✓ " .. titre)
				else
					rates += 1
					table.insert(lignes, "✗ " .. titre .. " : " .. tostring(err))
				end
			end
		end
	end
	local resume = table.concat(lignes, "\n")
	if rates > 0 then
		error(resume, 0)
	end
	return resume
end
