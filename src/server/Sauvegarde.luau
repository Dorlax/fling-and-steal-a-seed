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
local Collection = require(ReplicatedStorage.Shared.Collection)
local GestionBase = require(ReplicatedStorage.Shared.GestionBase)
local Bonus = require(ReplicatedStorage.Shared.Bonus)

type Session = {
	donnees: Donnees.DonneesJoueur,
	peutSauvegarder: boolean,
	gainHorsLigne: number,
}

local Sauvegarde = {}

local reglages = Config.Sauvegarde
local sessions: { [any]: Session } = {}
-- Créatures déposées dans la base de chaque joueur (raretés), tenues par le serveur.
local creaturesParJoueur: { [any]: { string } } = {}
-- Espèces déjà récoltées par chaque joueur (Bestiaire).
local decouvertesParJoueur: { [any]: { string } } = {}

local function envoyerMessage(joueur: any, texte: string)
	if typeof(joueur) ~= "Instance" or not joueur:IsA("Player") then
		return
	end
	local remote = ReplicatedStorage:FindFirstChild("MessageJeu")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireClient(joueur, texte)
	end
end

-- Multiplicateur permanent des revenus : renaissances et pages du Bestiaire.
local function multiplicateur(joueur: any): number
	return Bonus.revenus(
		joueur:GetAttribute("Renaissances"),
		Collection.pagesCompletes(decouvertesParJoueur[joueur] or {})
	)
end

-- Nouvelle liste des créatures de la base : revenu (bonus permanents compris)
-- et liste lisible par le client.
local function majListe(joueur: any, liste: { string })
	creaturesParJoueur[joueur] = liste
	joueur:SetAttribute("RevenuParSeconde", Revenus.total(liste) * multiplicateur(joueur))
	joueur:SetAttribute("CreaturesBase", GestionBase.encoder(liste))
end

-- Recalcule le revenu (après une renaissance ou une page complète).
function Sauvegarde.recalculer(joueur: any)
	majListe(joueur, creaturesParJoueur[joueur] or {})
end

-- Pages complètes du Bestiaire du joueur.
function Sauvegarde.pagesCompletes(joueur: any): number
	return Collection.pagesCompletes(decouvertesParJoueur[joueur] or {})
end

-- Ajoute l'espèce d'une fiche au Bestiaire du joueur ; renvoie true si nouvelle.
local function decouvrir(joueur: any, fiche: string): boolean
	local infos: any = Fiche.lire(fiche)
	if infos == nil or infos.Espece == nil then
		return false
	end
	local liste = decouvertesParJoueur[joueur]
	if liste == nil then
		liste = {}
		decouvertesParJoueur[joueur] = liste
	end
	if not Collection.ajouter(liste, infos.Espece) then
		return false
	end
	joueur:SetAttribute("Decouvertes", Collection.encoder(liste))
	joueur:SetAttribute("PagesCompletes", Collection.pagesCompletes(liste))
	return true
end

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
	joueur:SetAttribute("Etages", donnees.Etages)
	joueur:SetAttribute("Agrandissement", donnees.Agrandissement)
	joueur:SetAttribute("RecordBiome", donnees.RecordBiome)
	joueur:SetAttribute("SurForge", false)
	joueur:SetAttribute("Pieces", donnees.Pieces)
	joueur:SetAttribute("Renaissances", donnees.Renaissances)
	joueur:SetAttribute("Graines", table.concat(donnees.Graines, ","))
	joueur:SetAttribute("Graine", donnees.Graine)
	joueur:SetAttribute("Trainees", table.concat(donnees.Trainees, ","))
	joueur:SetAttribute("Trainee", donnees.Trainee)
	joueur:SetAttribute("ProchaineRoue", donnees.ProchaineRoue)
	-- Bestiaire : les créatures déjà dans la base comptent comme découvertes.
	decouvertesParJoueur[joueur] = table.clone(donnees.Decouvertes)
	joueur:SetAttribute("Decouvertes", Collection.encoder(donnees.Decouvertes))
	joueur:SetAttribute("PagesCompletes", Collection.pagesCompletes(donnees.Decouvertes))
	for _, fiche in donnees.CreaturesBase do
		decouvrir(joueur, fiche)
	end
	majListe(joueur, table.clone(donnees.CreaturesBase))
end

-- Espèces déjà récoltées par le joueur (copie).
function Sauvegarde.decouvertesDe(joueur: any): { string }
	return table.clone(decouvertesParJoueur[joueur] or {})
end

-- Créatures de la base du joueur (copie).
function Sauvegarde.creaturesDe(joueur: any): { string }
	return table.clone(creaturesParJoueur[joueur] or {})
end

-- Nombre de places de la base : MaxCreaturesBase par étage acheté.
function Sauvegarde.capacite(joueur: any): number
	local etages = joueur:GetAttribute("Etages")
	if type(etages) ~= "number" or etages ~= etages or etages < 1 then
		etages = 1
	end
	return Config.Creatures.MaxCreaturesBase * math.min(math.floor(etages), Config.Bases.EtagesMax)
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
	if #liste >= Sauvegarde.capacite(joueur) then
		return false
	end
	table.insert(liste, rarete)
	majListe(joueur, liste)
	local pagesAvant = Sauvegarde.pagesCompletes(joueur)
	if decouvrir(joueur, rarete) then
		if Sauvegarde.pagesCompletes(joueur) > pagesAvant then
			Sauvegarde.recalculer(joueur)
			envoyerMessage(joueur, "Page du Bestiaire complète ! Revenus +10 % pour toujours.")
		end
		local infos = Fiche.lire(rarete)
		local nombre = #(decouvertesParJoueur[joueur] or {})
		envoyerMessage(
			joueur,
			`Nouvelle espèce au Bestiaire : {(infos :: any).Espece} ! ({nombre}/{Collection.total()})`
		)
	end
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
	majListe(joueur, nouvelle :: { string })
	return rarete
end

-- Vend la créature n° `numero` de la base. Renvoie le prix encaissé (0 si refusé).
function Sauvegarde.vendre(joueur: any, numero: any): number
	local liste = creaturesParJoueur[joueur]
	if liste == nil then
		return 0
	end
	local nouvelle, fiche = Raid.retirerEmplacement(liste, numero)
	if fiche == nil then
		return 0
	end
	local prix = GestionBase.prixVente(fiche)
	majListe(joueur, nouvelle :: { string })
	joueur:SetAttribute("Pieces", Revenus.ajouter(joueur:GetAttribute("Pieces"), prix))
	return prix
end

-- Range les créatures par valeur (les meilleures au rez-de-chaussée).
function Sauvegarde.trier(joueur: any): boolean
	local liste = creaturesParJoueur[joueur]
	if liste == nil or #liste < 2 then
		return false
	end
	majListe(joueur, GestionBase.trier(liste))
	return true
end

-- Pièces gagnées hors ligne au chargement (une seule fois, puis 0).
function Sauvegarde.prendreGainHorsLigne(joueur: any): number
	local session = sessions[joueur]
	if session == nil then
		return 0
	end
	local gain = session.gainHorsLigne
	session.gainHorsLigne = 0
	return gain
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
		Etages = joueur:GetAttribute("Etages"),
		Agrandissement = joueur:GetAttribute("Agrandissement"),
		RecordBiome = joueur:GetAttribute("RecordBiome"),
		Decouvertes = decouvertesParJoueur[joueur],
		DerniereConnexion = os.time(),
		Renaissances = joueur:GetAttribute("Renaissances"),
		Graines = string.split(tostring(joueur:GetAttribute("Graines") or ""), ","),
		Graine = joueur:GetAttribute("Graine"),
		Trainees = string.split(tostring(joueur:GetAttribute("Trainees") or ""), ","),
		Trainee = joueur:GetAttribute("Trainee"),
		ProchaineRoue = joueur:GetAttribute("ProchaineRoue"),
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
	sessions[joueur] = { donnees = donnees, peutSauvegarder = peutSauvegarder, gainHorsLigne = 0 }
	ecrireAttributs(joueur, donnees)
	-- Gains hors ligne : les créatures ont travaillé pendant l'absence.
	if donnees.DerniereConnexion > 0 then
		local gain = GestionBase.gainHorsLigne(
			joueur:GetAttribute("RevenuParSeconde"),
			os.time() - donnees.DerniereConnexion
		)
		if gain > 0 then
			joueur:SetAttribute("Pieces", Revenus.ajouter(joueur:GetAttribute("Pieces"), gain))
			sessions[joueur].gainHorsLigne = gain
		end
	end
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
		decouvertesParJoueur[joueur] = nil
		return
	end
	Sauvegarde.sauvegarder(joueur)
	sessions[joueur] = nil
	creaturesParJoueur[joueur] = nil
	decouvertesParJoueur[joueur] = nil
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
