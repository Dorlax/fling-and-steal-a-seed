--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local InterfaceLancer = require(script.Parent:WaitForChild("InterfaceLancer"))
local InterfacePieces = require(script.Parent:WaitForChild("InterfacePieces"))
local InterfacePlaquage = require(script.Parent:WaitForChild("InterfacePlaquage"))
local InterfaceRaid = require(script.Parent:WaitForChild("InterfaceRaid"))
local InterfaceStats = require(script.Parent:WaitForChild("InterfaceStats"))

InterfaceStats.demarrer()
InterfaceLancer.demarrer()
InterfacePieces.demarrer()
-- Après InterfaceLancer : l'action « Plaquer » passe en priorité sur la touche
-- partagée et laisse l'appui au lancer quand personne n'est à plaquer.
InterfacePlaquage.demarrer()
InterfaceRaid.demarrer()

print(`{Config.NomDuJeu} : client démarré`)
