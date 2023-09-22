local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

local player = Players.LocalPlayer

local PurchasePromptButton = Component.new({
	Tag = script.Name,
	Ancestors = {player.PlayerGui}
})

function PurchasePromptButton:Start(): nil
	Knit.GetController("ComponentController"):Register(self)
	local scroller = self.Instance.Parent:FindFirstChildOfClass("ScrollingFrame")
	local productID = self.Instance:GetAttribute("ProductID")
	local isGamepass = self.Instance:GetAttribute("Gamepass")
	
	self._janitor =  Janitor.new()
	self._janitor:Add(self.Instance)
	self._janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		if isGamepass then
			MarketplaceService:PromptGamePassPurchase(player, productID)
		else
			MarketplaceService:PromptProductPurchase(player, productID)
		end
	end))
end

function PurchasePromptButton:Destroy(): nil
	self._janitor:Destroy()
end

return PurchasePromptButton