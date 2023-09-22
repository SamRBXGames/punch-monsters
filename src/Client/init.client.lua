local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

Knit.AddControllers(script.Controllers)
Knit.Start({ServicePromises  = false}):andThen(function()
	Component.LoadFolder(script.Components)
	print("Knit started on client")
end):catch(warn)