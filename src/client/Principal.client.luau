--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local InterfaceLancer = require(script.Parent:WaitForChild("InterfaceLancer"))
local InterfacePieces = require(script.Parent:WaitForChild("InterfacePieces"))
local InterfaceStats = require(script.Parent:WaitForChild("InterfaceStats"))

InterfaceStats.demarrer()
InterfaceLancer.demarrer()
InterfacePieces.demarrer()

print(`{Config.NomDuJeu} : client démarré`)
