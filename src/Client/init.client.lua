local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

Knit.AddControllers(script.Controllers)

Knit.Start({ServicePromises  = false}):andThen(function()
	print('Knit started on client')
end):catch(warn)