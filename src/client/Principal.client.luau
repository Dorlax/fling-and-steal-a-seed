--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Animations = require(script.Parent:WaitForChild("Animations"))
local Ambiances = require(script.Parent:WaitForChild("Ambiances"))
local Bandeaux = require(script.Parent:WaitForChild("Bandeaux"))
local EffetsComiques = require(script.Parent:WaitForChild("EffetsComiques"))
local InterfaceClassement = require(script.Parent:WaitForChild("InterfaceClassement"))
local InterfaceEvenement = require(script.Parent:WaitForChild("InterfaceEvenement"))
local InterfaceLancer = require(script.Parent:WaitForChild("InterfaceLancer"))
local InterfacePieges = require(script.Parent:WaitForChild("InterfacePieges"))
local InterfacePieces = require(script.Parent:WaitForChild("InterfacePieces"))
local InterfacePlaquage = require(script.Parent:WaitForChild("InterfacePlaquage"))
local InterfaceRaid = require(script.Parent:WaitForChild("InterfaceRaid"))
local InterfaceStats = require(script.Parent:WaitForChild("InterfaceStats"))
local Panneaux = require(script.Parent:WaitForChild("Panneaux"))

-- Bandeau de messages et restylage local des panneaux avant les interfaces.
Bandeaux.demarrer()
Panneaux.demarrer()
InterfaceStats.demarrer()
InterfaceLancer.demarrer()
InterfacePieces.demarrer()
-- Après InterfaceLancer : l'action « Plaquer » passe en priorité sur la touche
-- partagée et laisse l'appui au lancer quand personne n'est à plaquer.
InterfacePlaquage.demarrer()
InterfaceRaid.demarrer()
InterfacePieges.demarrer()
-- Multijoueur : événement en cours et classements.
InterfaceEvenement.demarrer()
InterfaceClassement.demarrer()
-- Étoiles autour de la tête des joueurs étourdis par un monstre.
EffetsComiques.demarrer()
-- Sautillement des créatures et dandinement des monstres (affichage seulement).
Animations.demarrer()
-- Ambiance et nom du biome quand le joueur change de biome.
Ambiances.demarrer()

print(`{Config.NomDuJeu} : client démarré`)
