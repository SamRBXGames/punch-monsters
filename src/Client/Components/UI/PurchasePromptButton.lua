local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local PurchasePromptButton: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { player.PlayerGui }
	};
}

function PurchasePromptButton:Event_MouseButton1Click(): nil
	local productID: number = self.Attributes.ProductID
	if self.Attributes.Gamepass then
		MarketplaceService:PromptGamePassPurchase(player, productID)
	else
		MarketplaceService:PromptProductPurchase(player, productID)
	end
end

return PurchasePromptButton