local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

Knit.AddControllers(script.Controllers)
Component.LoadFolder(script.Components)
Knit.Start({ServicePromises  = false}):andThen(function()
	Component.StartComponents()
	print("Knit started on client")
end):catch(warn)