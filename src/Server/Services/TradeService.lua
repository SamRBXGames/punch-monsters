--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local TradeService = Knit.CreateService {
  Name = "TradeService";
	Client = {
		TradeReceived = Knit.CreateSignal(),
		TradeAccepted = Knit.CreateSignal(),
		TradeCompleted = Knit.CreateSignal()
	};
}

function TradeService:Complete(player: Player, recipient: Player): nil
	self.Client.TradeCompleted:FireFor({recipient, player})
	return
end

function TradeService:Send(sender: Player, recipient: Player): nil
	self.Client.TradeReceived:Fire(recipient, sender)
	return
end

function TradeService:Accept(recipient: Player, sender: Player): nil
	local tradeID = HttpService:GenerateGUID()
	self.Client.TradeAccepted:Fire(sender, tradeID)
	return
end

function TradeService.Client:Accept(player: Player, sender: Player): nil
	return self.Server:Accept(player, sender)
end

function TradeService.Client:Send(fromPlayer: Player, toPlayer: Player): nil
	return self.Server:Send(fromPlayer, toPlayer)
end

return TradeService