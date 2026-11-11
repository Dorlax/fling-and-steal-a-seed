--!strict
-- Zone sûre (logique pure, testable avec Lune) : tout ce qui est avant la
-- ligne de départ des Terres Sauvages (Z < Config.Monstres.BordBases), bases
-- comprises. Là, aucun monstre ne frappe, aucun piège ne se pose et aucun
-- plaquage ne passe (sauf sur un voleur qui porte une créature volée).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local ZoneSure = {}

-- Z de la ligne (début des Terres Sauvages).
ZoneSure.Ligne = Config.Monstres.BordBases

-- Vrai si une position (table {Z} ou Vector3) est du côté sûr de la ligne.
-- Une valeur invalide n'est jamais considérée comme sûre.
function ZoneSure.contient(position: any): boolean
	if position == nil then
		return false
	end
	local z = position.Z
	if type(z) ~= "number" or z ~= z then
		return false
	end
	return z < ZoneSure.Ligne
end

return ZoneSure
