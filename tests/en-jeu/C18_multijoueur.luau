local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Revenus = require(ReplicatedStorage.Shared.Revenus)

local function module(nom: string): any
	local dossier = ServerScriptService:WaitForChild("Server", 5)
	assert(dossier, "dossier Server introuvable")
	local m = dossier:FindFirstChild(nom)
	assert(m and m:IsA("ModuleScript"), "module serveur manquant : " .. nom)
	return require(m)
end

local prochainId = -1800

local function fauxJoueur(): any
	prochainId -= 1
	local attributs: { [string]: any } = { Pieces = 0, Etages = 1 }
	return {
		Name = "FauxMulti" .. prochainId,
		UserId = prochainId,
		GetAttribute = function(_, nom: string)
			return attributs[nom]
		end,
		SetAttribute = function(_, nom: string, valeur: any)
			attributs[nom] = valeur
		end,
	}
end

return {
	["C18 événement : publié dans Workspace puis terminé"] = function()
		local Evenements = module("Evenements")
		assert(Evenements.lancer("Inconnu", 5) == false, "événement inconnu refusé")
		assert(Evenements.lancer("VentPorteur", 30) == true, "lancement attendu")
		local ok, err = pcall(function()
			assert(Evenements.actuel() == "VentPorteur", "événement en cours")
			assert(Workspace:GetAttribute("Evenement") == "VentPorteur", "attribut Evenement")
			local fin = Workspace:GetAttribute("EvenementFin")
			assert(
				type(fin) == "number" and fin > Workspace:GetServerTimeNow(),
				"fin dans le futur"
			)
		end)
		Evenements.finir()
		assert(ok, err)
		assert(Evenements.actuel() == nil, "plus d'événement")
		assert(Workspace:GetAttribute("Evenement") == "", "attribut vidé")
	end,

	["C18 Pluie dorée : revenus × 2 pendant l'événement seulement"] = function()
		local Evenements, Portage, Sauvegarde =
			module("Evenements"), module("Portage"), module("Sauvegarde")
		local j = fauxJoueur()
		assert(Sauvegarde.ajouterCreature(j, "Commune"), "créature ajoutée")
		local base = Revenus.total(Sauvegarde.creaturesDe(j))
		assert(base > 0, "revenu de base")
		Portage.tickRevenus(j)
		assert(j:GetAttribute("Pieces") == base, "sans événement : × 1")
		Evenements.lancer("PluieDoree", 30)
		local ok, err = pcall(function()
			Portage.tickRevenus(j)
			assert(j:GetAttribute("Pieces") == base * 3, "Pluie dorée : × 2")
		end)
		Evenements.finir()
		Sauvegarde.terminer(j)
		assert(ok, err)
	end,

	["C18 record de biome : monte, ne redescend pas"] = function()
		local Classements = module("Classements")
		local j = fauxJoueur()
		assert(Classements.noterBiome(j, 3) == true, "3 bat le défaut")
		assert(j:GetAttribute("RecordBiome") == 3, "record 3")
		assert(Classements.noterBiome(j, 2) == false, "2 ne bat pas 3")
		assert(j:GetAttribute("RecordBiome") == 3, "record inchangé")
	end,

	["C18 bestiaire : déposer une nouvelle espèce l'ajoute aux découvertes"] = function()
		local Sauvegarde = module("Sauvegarde")
		local Biomes = require(ReplicatedStorage.Shared.Biomes)
		local Collection = require(ReplicatedStorage.Shared.Collection)
		local nom = Biomes.Liste[2].Creatures.Rare[1]
		local j = fauxJoueur()
		assert(Sauvegarde.ajouterCreature(j, "Rare:Normale:" .. nom), "créature ajoutée")
		local ok, err = pcall(function()
			local liste = Collection.decoder(j:GetAttribute("Decouvertes"))
			assert(table.find(liste, nom), "espèce découverte")
			assert(#Sauvegarde.decouvertesDe(j) == 1, "une seule découverte")
			assert(Sauvegarde.ajouterCreature(j, "Rare:Grande:" .. nom), "deuxième exemplaire")
			assert(#Sauvegarde.decouvertesDe(j) == 1, "pas de doublon")
		end)
		Sauvegarde.terminer(j)
		assert(ok, err)
	end,

	["C18 base : vendre encaisse le prix, trier range par valeur"] = function()
		local Sauvegarde = module("Sauvegarde")
		local GestionBase = require(ReplicatedStorage.Shared.GestionBase)
		local j = fauxJoueur()
		assert(Sauvegarde.ajouterCreature(j, "Commune"), "commune")
		assert(Sauvegarde.ajouterCreature(j, "Mythique"), "mythique")
		local ok, err = pcall(function()
			assert(Sauvegarde.trier(j), "tri")
			assert(Sauvegarde.creaturesDe(j)[1] == "Mythique", "mythique en premier")
			local prix = Sauvegarde.vendre(j, 2)
			assert(
				prix == GestionBase.prixVente("Commune") and j:GetAttribute("Pieces") == prix,
				"vente"
			)
			assert(#Sauvegarde.creaturesDe(j) == 1, "une créature en moins")
			assert(Sauvegarde.vendre(j, 5) == 0, "numéro invalide refusé")
			assert(
				GestionBase.decoder(j:GetAttribute("CreaturesBase"))[1] == "Mythique",
				"liste client"
			)
		end)
		Sauvegarde.terminer(j)
		assert(ok, err)
	end,

	["C18 progression : renaissance, graine, roue et traînée"] = function()
		local Progression = module("Progression")
		local Sauvegarde = module("Sauvegarde")
		local Bonus = require(ReplicatedStorage.Shared.Bonus)
		local Config = require(ReplicatedStorage.Shared.Config)
		local j = fauxJoueur()
		j:SetAttribute("Graines", "Simple")
		j:SetAttribute("Graine", "Simple")
		j:SetAttribute("Trainees", "")
		j:SetAttribute("Trainee", "")
		j:SetAttribute("ProchaineRoue", 0)
		local ok, err = pcall(function()
			assert(Progression.renaitre(j) == false, "pas assez de pièces")
			j:SetAttribute("Pieces", Bonus.prixRenaissance(0))
			assert(Progression.renaitre(j) == true, "renaissance")
			assert(
				j:GetAttribute("Pieces") == 0 and j:GetAttribute("Renaissances") == 1,
				"remise à 0"
			)
			assert(
				string.find(j:GetAttribute("Trainees"), "Arcenciel"),
				"traînée de la 1re renaissance"
			)
			assert(Progression.equiperTrainee(j, "Arcenciel"), "traînée équipée")
			assert(not Progression.equiperTrainee(j, "Galaxie"), "traînée verrouillée refusée")
			j:SetAttribute("Pieces", Config.Graines.Liste.Doree.Prix)
			assert(Progression.acheterGraine(j, "Doree"), "achat")
			assert(
				j:GetAttribute("Graine") == "Doree" and j:GetAttribute("Pieces") == 0,
				"équipée et payée"
			)
			assert(not Progression.acheterGraine(j, "Doree"), "déjà achetée")
			assert(not Progression.equiperGraine(j, "Cosmique"), "graine non possédée")
			assert(Progression.tournerRoue(j, 0.5) ~= nil, "premier tour")
			assert(Progression.tournerRoue(j, 0.5) == nil, "il faut attendre")
		end)
		Sauvegarde.terminer(j)
		assert(ok, err)
	end,
}
