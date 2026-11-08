--!strict
-- Chargement / sauvegarde des données joueur (DataStore), côté serveur.
-- En cas d'échec de chargement : données par défaut et aucune sauvegarde
-- pour ce joueur durant la session (pour ne pas écraser ses vraies données).
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Fiche = require(ReplicatedStorage.Shared.Fiche)
local Donnees = require(ReplicatedStorage.Shared.Donnees)
local Raid = require(ReplicatedStorage.Shared.Raid)
local Revenus = require(ReplicatedStorage.Shared.Revenus)

type Session = {
	donnees: Donnees.DonneesJoueur,
	peutSauvegarder: boolean,
}

local Sauvegarde = {}

local reglages = Config.Sauvegarde
local sessions: { [any]: Session } = {}
-- Créatures déposées dans la base de chaque joueur (raretés), tenues par le serveur.
local creaturesParJoueur: { [any]: { string } } = {}

local magasin: DataStore? = nil
do
	local ok, resultat = pcall(function()
		return DataStoreService:GetDataStore(reglages.NomDataStore)
	end)
	if ok then
		magasin = resultat
	else
		warn("Sauvegarde : DataStore indisponible : " .. tostring(resultat))
	end
end

local function cle(joueur: Player): string
	return reglages.PrefixeCle .. tostring(joueur.UserId)
end

-- Appelle `action` jusqu'à `Tentatives` fois ; renvoie (ok, résultat).
local function avecTentatives(action: () -> ...any): (boolean, any)
	local ok, resultat = false, nil
	for essai = 1, reglages.Tentatives do
		ok, resultat = pcall(action)
		if ok then
			return true, resultat
		end
		if essai < reglages.Tentatives then
			task.wait(essai)
		end
	end
	return false, resultat
end

local function ecrireAttributs(joueur: Player, donnees: Donnees.DonneesJoueur)
	joueur:SetAttribute("Force", donnees.Force)
	joueur:SetAttribute("Vitesse", donnees.Vitesse)
	joueur:SetAttribute("ModeForge", donnees.ModeForge)
	joueur:SetAttribute("NiveauForge", donnees.NiveauForge)
	joueur:SetAttribute("SurForge", false)
	joueur:SetAttribute("Pieces", donnees.Pieces)
	creaturesParJoueur[joueur] = table.clone(donnees.CreaturesBase)
	joueur:SetAttribute("RevenuParSeconde", Revenus.total(donnees.CreaturesBase))
end

-- Créatures de la base du joueur (copie).
function Sauvegarde.creaturesDe(joueur: any): { string }
	return table.clone(creaturesParJoueur[joueur] or {})
end

-- Ajoute une créature (fiche valide : « Rarete[:Taille[:Espece]] ») à la
-- base si elle n'est pas pleine.
function Sauvegarde.ajouterCreature(joueur: any, rarete: any): boolean
	if not Fiche.valide(rarete) then
		return false
	end
	local liste = creaturesParJoueur[joueur]
	if liste == nil then
		liste = {}
		creaturesParJoueur[joueur] = liste
	end
	if #liste >= Config.Creatures.MaxCreaturesBase then
		return false
	end
	table.insert(liste, rarete)
	joueur:SetAttribute("RevenuParSeconde", Revenus.total(liste))
	return true
end

-- Retire la créature n° `numero` de la base (raid) ; les suivantes remontent.
-- Renvoie la rareté retirée, ou nil sans rien changer.
function Sauvegarde.retirerCreature(joueur: any, numero: any): string?
	local liste = creaturesParJoueur[joueur]
	if liste == nil then
		return nil
	end
	local nouvelle, rarete = Raid.retirerEmplacement(liste, numero)
	if rarete == nil then
		return nil
	end
	creaturesParJoueur[joueur] = nouvelle :: { string }
	joueur:SetAttribute("RevenuParSeconde", Revenus.total(nouvelle :: { string }))
	return rarete
end

-- Données actuelles du joueur (attributs serveur), nettoyées.
function Sauvegarde.collecter(joueur: any): Donnees.DonneesJoueur
	local session = sessions[joueur]
	return Donnees.nettoyer({
		Force = joueur:GetAttribute("Force"),
		Vitesse = joueur:GetAttribute("Vitesse"),
		ModeForge = joueur:GetAttribute("ModeForge"),
		NiveauForge = joueur:GetAttribute("NiveauForge")
			or (if session then session.donnees.NiveauForge else 1),
		Pieces = joueur:GetAttribute("Pieces"),
		CreaturesBase = creaturesParJoueur[joueur],
	})
end

-- Charge les données (bloquant) et les expose en attributs.
function Sauvegarde.charger(joueur: Player)
	local donnees = Donnees.parDefaut()
	local peutSauvegarder = false
	local store = magasin
	if store then
		local ok, brut = avecTentatives(function()
			return store:GetAsync(cle(joueur))
		end)
		if ok then
			donnees = Donnees.nettoyer(brut)
			peutSauvegarder = true
		else
			warn(`Sauvegarde : chargement impossible pour {joueur.Name} : {brut}`)
		end
	end
	if joueur.Parent == nil then
		return -- parti pendant le chargement
	end
	sessions[joueur] = { donnees = donnees, peutSauvegarder = peutSauvegarder }
	ecrireAttributs(joueur, donnees)
end

function Sauvegarde.estCharge(joueur: Player): boolean
	return sessions[joueur] ~= nil
end

function Sauvegarde.sauvegarder(joueur: Player)
	local session = sessions[joueur]
	local store = magasin
	if session == nil or store == nil or not session.peutSauvegarder then
		return
	end
	local donnees = Sauvegarde.collecter(joueur)
	session.donnees = donnees
	local ok, erreur = avecTentatives(function()
		(store :: DataStore):SetAsync(cle(joueur), donnees, { joueur.UserId })
	end)
	if not ok then
		warn(`Sauvegarde : échec pour {joueur.Name} : {erreur}`)
	end
end

-- Sauvegarde puis oublie la session (départ du joueur).
function Sauvegarde.terminer(joueur: Player)
	if sessions[joueur] == nil then
		creaturesParJoueur[joueur] = nil
		return
	end
	Sauvegarde.sauvegarder(joueur)
	sessions[joueur] = nil
	creaturesParJoueur[joueur] = nil
end

-- Branche l'arrêt du serveur et la sauvegarde automatique.
function Sauvegarde.demarrer()
	game:BindToClose(function()
		local restants = 0
		for _, joueur in Players:GetPlayers() do
			restants += 1
			task.spawn(function()
				Sauvegarde.terminer(joueur)
				restants -= 1
			end)
		end
		local debut = os.clock()
		while restants > 0 and os.clock() - debut < 25 do
			task.wait(0.1)
		end
	end)

	task.spawn(function()
		while true do
			task.wait(reglages.IntervalleAutoSecondes)
			for joueur in sessions do
				task.spawn(Sauvegarde.sauvegarder, joueur)
			end
		end
	end)
end

return Sauvegarde
