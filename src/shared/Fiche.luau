--!strict
-- Fiche d'une créature (logique pure, testable avec Lune).
-- Une créature de base est enregistrée sous forme de texte :
--   "Rarete"                 (anciennes sauvegardes : taille Normale)
--   "Rarete:Taille"
--   "Rarete:Taille:Espece"
--   "Rarete:Taille:Espece:Mutation" (Dorée, Cristal, Arc-en-ciel)
-- Le serveur ne fait jamais confiance à une fiche reçue : tout passe par
-- Fiche.lire, qui refuse une rareté, une taille ou une espèce inconnues.
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local Fiche = {}

export type Infos = { Rarete: string, Taille: string, Espece: string?, Mutation: string? }

local tailles = Config.Tailles

function Fiche.ecrire(rarete: string, taille: string?, espece: string?, mutation: string?): string
	local texte = rarete
	if (taille ~= nil and taille ~= "Normale") or espece ~= nil or mutation ~= nil then
		texte ..= ":" .. (taille or "Normale")
	end
	if espece ~= nil or mutation ~= nil then
		texte ..= ":" .. (espece or "")
	end
	if mutation ~= nil then
		texte ..= ":" .. mutation
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
	if #morceaux > 4 then
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
	local espece: string? = morceaux[3]
	if espece == "" then
		espece = nil
	end
	local mutation = morceaux[4]
	if mutation ~= nil and (Config.Mutations.Liste :: any)[mutation] == nil then
		return nil
	end
	if espece ~= nil and especesValides ~= nil then
		local permises = (especesValides :: any)[rarete]
		if permises == nil or not table.find(permises, espece) then
			return nil
		end
	end
	return { Rarete = rarete, Taille = taille, Espece = espece, Mutation = mutation }
end

function Fiche.valide(texte: any): boolean
	return Fiche.lire(texte) ~= nil
end

-- Taux des tailles (en %, total 100) dans le biome n : ceux de Config au
-- biome 1, puis de plus en plus de grosses tailles à chaque biome.
function Fiche.tauxTailles(biome: number?): { [string]: number }
	local n = if type(biome) == "number" and biome == biome
		then math.max(1, math.floor(biome))
		else 1
	local facteur = 1 + (tailles.BonusParBiome or 0) * (n - 1)
	local poids: { [string]: number } = {}
	local total = 0
	for rang, taille in tailles.Ordre do
		local p = (tailles.Taux :: any)[taille] * facteur ^ (rang - 1)
		poids[taille] = p
		total += p
	end
	for taille, p in poids do
		poids[taille] = p / total * 100
	end
	return poids
end

-- Taille tirée avec `tirage` dans [0, 1[ selon les taux du biome (1 par défaut).
function Fiche.tirerTaille(tirage: number, biome: number?): string
	local taux = Fiche.tauxTailles(biome)
	local cumul = 0
	local seuil = math.clamp(tirage, 0, 0.999999) * 100
	for _, taille in tailles.Ordre do
		cumul += taux[taille]
		if seuil < cumul then
			return taille
		end
	end
	return tailles.Ordre[#tailles.Ordre]
end

function Fiche.echelle(taille: string): number
	return (tailles.Echelle :: any)[taille] or 1
end

function Fiche.multiplicateur(taille: string): number
	return (tailles.Multiplicateur :: any)[taille] or 1
end

-- Multiplicateur de revenus d'une mutation (1 sans mutation).
function Fiche.multiplicateurMutation(mutation: string?): number
	local infos = if mutation then (Config.Mutations.Liste :: any)[mutation] else nil
	return if infos then infos.Mult else 1
end

-- Mutation tirée avec `tirage` dans [0, 1[ ; `bonus` multiplie les chances.
-- Renvoie nil le plus souvent (aucune mutation).
function Fiche.tirerMutation(tirage: number, bonus: number?): string?
	local t = if type(tirage) == "number" and tirage == tirage then tirage else 1
	local b = bonus or 1
	local cumul = 0
	-- Les plus rares d'abord, pour que chaque chance reste la sienne.
	for i = #Config.Mutations.Ordre, 1, -1 do
		local nom = Config.Mutations.Ordre[i]
		cumul += (Config.Mutations.Liste :: any)[nom].Chance * b
		if t < cumul then
			return nom
		end
	end
	return nil
end

-- Texte affiché : « Géante Épique », « Dorée Géante Épique » (taille Normale :
-- juste la rareté).
function Fiche.texte(rarete: string, taille: string, mutation: string?): string
	local nomRarete = (Config.Raretes.Noms :: any)[rarete] or rarete
	local texte = if taille == "Normale"
		then nomRarete
		else ((tailles.Noms :: any)[taille] or taille) .. " " .. nomRarete
	local infos = if mutation then (Config.Mutations.Liste :: any)[mutation] else nil
	return if infos then infos.Nom .. " " .. texte else texte
end

return Fiche
