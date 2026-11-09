--!strict
-- Gestion de la base (logique pure, testable avec Lune) : prix de vente
-- d'une créature, tri par valeur, liste lisible par le client et gains
-- hors ligne.
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")
-- selene: allow(incorrect_standard_library_use)
local Revenus = if script then require(script.Parent.Revenus) else (require :: any)("./Revenus")
-- selene: allow(incorrect_standard_library_use)
local Fiche = if script then require(script.Parent.Fiche) else (require :: any)("./Fiche")

local GestionBase = {}

-- Prix de vente : Config.Vente.Secondes de revenu de la créature (au moins 1).
function GestionBase.prixVente(fiche: any): number
	if not Fiche.valide(fiche) then
		return 0
	end
	return math.max(1, Revenus.parSeconde(fiche) * Config.Vente.Secondes)
end

-- Copie triée : les créatures qui rapportent le plus d'abord (rez-de-chaussée).
function GestionBase.trier(liste: { string }): { string }
	local copie = table.clone(liste)
	table.sort(copie, function(a, b)
		local ra, rb = Revenus.parSeconde(a), Revenus.parSeconde(b)
		if ra ~= rb then
			return ra > rb
		end
		return a < b
	end)
	return copie
end

-- Liste pour un attribut (« fiche,fiche ») et retour (fiches valides seulement).
function GestionBase.encoder(liste: { string }): string
	return table.concat(liste, ",")
end

function GestionBase.decoder(texte: any): { string }
	local liste = {}
	if type(texte) ~= "string" or texte == "" then
		return liste
	end
	for _, fiche in string.split(texte, ",") do
		if Fiche.valide(fiche) then
			table.insert(liste, fiche)
		end
	end
	return liste
end

-- Pièces gagnées pendant `secondes` d'absence avec `revenu` pièces / s :
-- Taux du revenu, au plus MaxSecondes, rien en dessous de MinSecondes.
function GestionBase.gainHorsLigne(revenu: any, secondes: any): number
	local reglages = Config.HorsLigne
	if type(revenu) ~= "number" or revenu ~= revenu or revenu <= 0 or revenu == math.huge then
		return 0
	end
	if type(secondes) ~= "number" or secondes ~= secondes or secondes < reglages.MinSecondes then
		return 0
	end
	return math.floor(revenu * math.min(secondes, reglages.MaxSecondes) * reglages.Taux)
end

return GestionBase
