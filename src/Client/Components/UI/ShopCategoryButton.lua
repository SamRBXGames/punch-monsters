--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local ShopCategoryButton: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { player.PlayerGui }
	};
}

function ShopCategoryButton:Initialize(): nil
	self._scroller = self.Instance.Parent:FindFirstChildOfClass("ScrollingFrame")
	self._titleLabel = self._scroller:FindFirstChild(self.Instance.Name .. "Title")
end

function ShopCategoryButton:Event_MouseButton1Click(): nil
	local yPosition = self._titleLabel.Position.Y.Scale * self._scroller.AbsoluteCanvasSize.Y
	self._scroller.CanvasPosition = Vector2.new(0, yPosition)
end

return Component.new(ShopCategoryButton)