--!strict
-- Collection du Bestiaire (logique pure, testable avec Lune) : la liste des
-- espèces de créatures qu'un joueur a déjà récoltées, et sa progression par
-- biome. Les monstres ne se collectionnent pas.
-- selene: allow(incorrect_standard_library_use)
local Biomes = if script then require(script.Parent.Biomes) else (require :: any)("./Biomes")
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

local Collection = {}

-- Toutes les créatures collectionnables, dans l'ordre (biome, rareté).
local ordre: { string } = {}
local estCreature: { [string]: boolean } = {}
for _, biome in Biomes.Liste do
	for _, rarete in Config.Raretes.Ordre do
		for _, nom in (biome.Creatures :: any)[rarete] or {} do
			if not estCreature[nom] then
				estCreature[nom] = true
				table.insert(ordre, nom)
			end
		end
	end
end

-- Nombre total d'espèces à collectionner.
function Collection.total(): number
	return #ordre
end

function Collection.estCreature(nom: any): boolean
	return type(nom) == "string" and estCreature[nom] == true
end

-- Liste propre : espèces connues, sans doublon, dans l'ordre du Bestiaire.
function Collection.nettoyer(brut: any): { string }
	local vues: { [string]: boolean } = {}
	if type(brut) == "table" then
		for _, nom in ipairs(brut) do
			if Collection.estCreature(nom) then
				vues[nom] = true
			end
		end
	end
	local propre = {}
	for _, nom in ordre do
		if vues[nom] then
			table.insert(propre, nom)
		end
	end
	return propre
end

-- Ajoute `nom` à la liste (en place). Renvoie true si c'est une nouvelle espèce.
function Collection.ajouter(liste: { string }, nom: any): boolean
	if not Collection.estCreature(nom) or table.find(liste, nom) ~= nil then
		return false
	end
	table.insert(liste, nom)
	return true
end

-- Texte compact pour un attribut (« A,B,C ») et retour.
function Collection.encoder(liste: { string }): string
	return table.concat(liste, ",")
end

function Collection.decoder(texte: any): { string }
	if type(texte) ~= "string" or texte == "" then
		return {}
	end
	-- Nombre de pages de biome complètes (toutes leurs créatures découvertes).
	function Collection.pagesCompletes(liste: { string }): number
		local n = 0
		for numero = 1, #Biomes.Liste do
			local trouvees, total = Collection.progression(liste, numero)
			if total > 0 and trouvees == total then
				n += 1
			end
		end
		return n
	end

	return Collection.nettoyer(string.split(texte, ","))
end

-- Espèces découvertes et total pour le biome n (10 créatures par biome).
function Collection.progression(liste: { string }, biome: number): (number, number)
	local infos = Biomes.Liste[biome]
	if infos == nil then
		return 0, 0
	end
	local trouvees, total = 0, 0
	for _, rarete in Config.Raretes.Ordre do
		for _, nom in (infos.Creatures :: any)[rarete] or {} do
			total += 1
			if table.find(liste, nom) then
				trouvees += 1
			end
		end
	end
	return trouvees, total
end

return Collection
