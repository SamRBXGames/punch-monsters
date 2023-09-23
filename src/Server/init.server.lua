local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

Knit.AddServicesDeep(script.Services)
Knit.Start():andThen(function()
	print("Knit started on server")
end):catch(warn)