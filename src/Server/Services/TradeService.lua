--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local TradeService = Knit.CreateService {
  Name = "TradeService";
	Client = {
		TradeReceived = Knit.CreateSignal()
	};
}

function TradeService:Send(fromPlayer: Player, toPlayer: Player): nil
	self.Client.TradeReceived:Fire(toPlayer, fromPlayer)
	return
end

function TradeService.Client:Send(fromPlayer: Player, toPlayer: Player): nil
	return self.Server:Send(fromPlayer, toPlayer)
end

return TradeService