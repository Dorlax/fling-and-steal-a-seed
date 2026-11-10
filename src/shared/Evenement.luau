--!strict
-- Logique pure des événements de serveur (Heure dorée, Vent porteur,
-- Graines géantes, Nuit des étoiles filantes, Arc-en-ciel de chance,
-- Frénésie de la Forge) : tirage et effets. Testable avec Lune.
-- Sans événement (nil ou nom inconnu), tous les effets sont neutres.
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")

export type Infos = {
	Nom: string,
	Texte: string,
	Couleur: { number },
	Revenus: number?,
	Distance: number?,
	BonusTailles: number?,
	Mutations: number?,
	Chance: number?,
	Forge: number?,
	Icone: string?,
}

local Evenement = {}

local reglages = Config.Evenements

-- Infos d'un événement, ou nil s'il est inconnu.
function Evenement.infos(id: any): Infos?
	if type(id) ~= "string" then
		return nil
	end
	return (reglages.Liste :: any)[id]
end

-- Événement tiré avec `tirage` dans [0, 1[, jamais le même que `precedent`
-- (s'il y en a au moins deux).
function Evenement.tirer(tirage: number, precedent: string?): string
	local choix = {}
	for _, id in reglages.Ordre do
		if id ~= precedent then
			table.insert(choix, id)
		end
	end
	if #choix == 0 then
		choix = table.clone(reglages.Ordre)
	end
	local t = if type(tirage) == "number" and tirage == tirage then tirage else 0
	local rang = math.clamp(math.floor(t * #choix) + 1, 1, #choix)
	return choix[rang]
end

-- Multiplicateur des revenus (1 sans événement).
function Evenement.multiplicateurRevenus(id: any): number
	local infos = Evenement.infos(id)
	return if infos and infos.Revenus then infos.Revenus else 1
end

-- Studs ajoutés à la distance des lancers (0 sans événement).
function Evenement.bonusDistance(id: any): number
	local infos = Evenement.infos(id)
	return if infos and infos.Distance then infos.Distance else 0
end

-- Biomes ajoutés au calcul des taux de taille (0 sans événement).
function Evenement.bonusTailles(id: any): number
	local infos = Evenement.infos(id)
	return if infos and infos.BonusTailles then infos.BonusTailles else 0
end

-- Multiplicateur des chances de mutation : celui de l'événement s'il en
-- donne un, sinon Config.Mutations.BonusEvenement pendant tout événement.
function Evenement.multiplicateurMutation(id: any): number
	local trouve = Evenement.infos(id)
	if trouve == nil then
		return 1
	end
	local infos = trouve :: Infos
	return infos.Mutations or Config.Mutations.BonusEvenement
end

-- Chance ajoutée aux raretés hautes (0 sans événement).
function Evenement.bonusChance(id: any): number
	local infos = Evenement.infos(id)
	return if infos and infos.Chance then infos.Chance else 0
end

-- Multiplicateur des gains de la Forge (1 sans événement).
function Evenement.multiplicateurForge(id: any): number
	local infos = Evenement.infos(id)
	return if infos and infos.Forge then infos.Forge else 1
end

-- Secondes restantes (entier, jamais négatif).
function Evenement.restant(fin: any, maintenant: number): number
	if type(fin) ~= "number" or fin ~= fin then
		return 0
	end
	return math.max(0, math.ceil(fin - maintenant))
end

-- 125 -> « 2:05 ».
function Evenement.texteDuree(secondes: number): string
	local s = math.max(0, math.floor(secondes))
	return string.format("%d:%02d", s // 60, s % 60)
end

return Evenement
