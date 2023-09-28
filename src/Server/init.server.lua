local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

Knit.AddServicesDeep(script.Services)
Component.LoadFolder(script.Components)
Knit.Start({ServicePromises  = false}):andThen(function()
	Component.StartComponents()
	print("Knit started on server")
end):catch(warn)