local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local PurchasePromptButton: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
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

return Component.new(PurchasePromptButton)