--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local TradeService = Knit.CreateService {
  Name = "TradeService";
	Client = {
		TradeReceived = Knit.CreateSignal(),
		TradeAccepted = Knit.CreateSignal()
	};
}

function TradeService:Send(sender: Player, recipient: Player): nil
	self.Client.TradeReceived:Fire(recipient, sender)
	return
end

function TradeService:Accept(recipient: Player, sender: Player): nil
	self.Client.TradeAccepted:Fire(sender)
	return
end

function TradeService.Client:Accept(player: Player, sender: Player): nil
	return self.Server:Accept(player, sender)
end

function TradeService.Client:Send(fromPlayer: Player, toPlayer: Player): nil
	return self.Server:Send(fromPlayer, toPlayer)
end

return TradeService