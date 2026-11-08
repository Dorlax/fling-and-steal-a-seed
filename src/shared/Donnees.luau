--!strict
-- Logique pure des données joueur : valeurs par défaut et nettoyage.
-- Testable avec Lune (pas de dépendance à Roblox).
-- Roblox : require(script.Parent.X) ; Lune (tests) : require("./X").
-- selene: allow(incorrect_standard_library_use)
local Config = if script then require(script.Parent.Config) else (require :: any)("./Config")
-- selene: allow(incorrect_standard_library_use)
local Forge = if script then require(script.Parent.Forge) else (require :: any)("./Forge")

export type DonneesJoueur = {
	Force: number,
	Vitesse: number,
	ModeForge: string,
	NiveauForge: number,
}

local Donnees = {}

function Donnees.parDefaut(): DonneesJoueur
	return {
		Force = 0,
		Vitesse = 0,
		ModeForge = Config.Forge.ModeParDefaut,
		NiveauForge = 1,
	}
end

-- Stat valide : nombre fini, entre 0 et PlafondStat.
local function nettoyerStat(valeur: any): number
	if type(valeur) ~= "number" or valeur ~= valeur or valeur < 0 then
		return 0
	end
	return math.min(valeur, Config.Forge.PlafondStat)
end

-- Corrige des données chargées (ou reçues) : jamais de confiance aveugle.
function Donnees.nettoyer(brut: any): DonneesJoueur
	local donnees = Donnees.parDefaut()
	if type(brut) ~= "table" then
		return donnees
	end
	donnees.Force = nettoyerStat(brut.Force)
	donnees.Vitesse = nettoyerStat(brut.Vitesse)
	if Forge.estModeValide(brut.ModeForge) then
		donnees.ModeForge = brut.ModeForge
	end
	local niveau = brut.NiveauForge
	if type(niveau) == "number" and niveau == niveau and niveau >= 1 and niveau < math.huge then
		donnees.NiveauForge = math.floor(niveau)
	end
	return donnees
end

return Donnees
