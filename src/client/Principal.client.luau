--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local InterfaceLancer = require(script.Parent:WaitForChild("InterfaceLancer"))
local InterfaceStats = require(script.Parent:WaitForChild("InterfaceStats"))

InterfaceStats.demarrer()
InterfaceLancer.demarrer()

print(`{Config.NomDuJeu} : client démarré`)
