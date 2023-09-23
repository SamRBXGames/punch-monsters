--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(player: Player)
	Knit.GetService("DataService"):InitializeClientUpdate(player)
end