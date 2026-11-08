--!strict
-- Fiche d'une créature (logique pure, testable avec Lune).
-- Une créature de base est enregistrée sous forme de texte :
--   "Rarete"                 (anciennes sauvegardes : taille Normale)
--   "Rarete:Taille"
--   "Rarete:Taille:Espece"
-- Le serveur ne fait jamais confiance à une fiche reçue : tout passe par
-- Fiche.lire, qui refuse une rareté, une taille ou une espèce inconnues.
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local Fiche = {}

export type Infos = { Rarete: string, Taille: string, Espece: string? }

local tailles = Config.Tailles

function Fiche.ecrire(rarete: string, taille: string?, espece: string?): string
	local texte = rarete
	if (taille ~= nil and taille ~= "Normale") or espece ~= nil then
		texte ..= ":" .. (taille or "Normale")
	end
	if espece ~= nil then
		texte ..= ":" .. espece
	end
	return texte
end

-- Lit une fiche ; nil si elle est invalide. `especesValides` (facultatif)
-- liste les espèces permises pour chaque rareté.
function Fiche.lire(texte: any, especesValides: { [string]: { string } }?): Infos?
	if type(texte) ~= "string" or #texte > 64 then
		return nil
	end
	local morceaux = string.split(texte, ":")
	if #morceaux > 3 then
		return nil
	end
	local rarete = morceaux[1]
	if not table.find(Config.Raretes.Ordre, rarete) then
		return nil
	end
	local taille = morceaux[2] or "Normale"
	if not table.find(tailles.Ordre, taille) then
		return nil
	end
	local espece = morceaux[3]
	if espece ~= nil and especesValides ~= nil then
		local permises = (especesValides :: any)[rarete]
		if permises == nil or not table.find(permises, espece) then
			return nil
		end
	end
	return { Rarete = rarete, Taille = taille, Espece = espece }
end

function Fiche.valide(texte: any): boolean
	return Fiche.lire(texte) ~= nil
end

-- Taille tirée avec `tirage` dans [0, 1[ selon les taux (en %).
function Fiche.tirerTaille(tirage: number): string
	local cumul = 0
	local seuil = math.clamp(tirage, 0, 0.999999) * 100
	for _, taille in tailles.Ordre do
		cumul += (tailles.Taux :: any)[taille]
		if seuil < cumul then
			return taille
		end
	end
	return tailles.Ordre[1]
end

function Fiche.echelle(taille: string): number
	return (tailles.Echelle :: any)[taille] or 1
end

function Fiche.multiplicateur(taille: string): number
	return (tailles.Multiplicateur :: any)[taille] or 1
end

-- Texte affiché : « Géante Épique » (taille Normale : juste la rareté).
function Fiche.texte(rarete: string, taille: string): string
	local nomRarete = (Config.Raretes.Noms :: any)[rarete] or rarete
	if taille == "Normale" then
		return nomRarete
	end
	return ((tailles.Noms :: any)[taille] or taille) .. " " .. nomRarete
end

return Fiche
