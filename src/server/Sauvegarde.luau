--!strict
-- Chargement / sauvegarde des données joueur (DataStore), côté serveur.
-- En cas d'échec de chargement : données par défaut et aucune sauvegarde
-- pour ce joueur durant la session (pour ne pas écraser ses vraies données).
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Donnees = require(ReplicatedStorage.Shared.Donnees)

type Session = {
	donnees: Donnees.DonneesJoueur,
	peutSauvegarder: boolean,
}

local Sauvegarde = {}

local reglages = Config.Sauvegarde
local sessions: { [Player]: Session } = {}

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
	joueur:SetAttribute("SurForge", false)
end

-- Données actuelles du joueur (attributs serveur), nettoyées.
local function collecter(joueur: Player, session: Session): Donnees.DonneesJoueur
	return Donnees.nettoyer({
		Force = joueur:GetAttribute("Force"),
		Vitesse = joueur:GetAttribute("Vitesse"),
		ModeForge = joueur:GetAttribute("ModeForge"),
		NiveauForge = session.donnees.NiveauForge,
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
	local donnees = collecter(joueur, session)
	session.donnees = donnees
	local ok, erreur = avecTentatives(function()
		store:SetAsync(cle(joueur), donnees, { joueur.UserId })
	end)
	if not ok then
		warn(`Sauvegarde : échec pour {joueur.Name} : {erreur}`)
	end
end

-- Sauvegarde puis oublie la session (départ du joueur).
function Sauvegarde.terminer(joueur: Player)
	if sessions[joueur] == nil then
		return
	end
	Sauvegarde.sauvegarder(joueur)
	sessions[joueur] = nil
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
