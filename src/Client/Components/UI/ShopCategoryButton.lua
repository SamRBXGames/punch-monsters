--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local ShopCategoryButton: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui }
	};
}

function ShopCategoryButton:Initialize(): nil
	self._scroller = self.Instance.Parent:FindFirstChildOfClass("ScrollingFrame")

	local titleName: string = self.Instance.Name
	self._titleLabel = self._scroller:FindFirstChild(titleName .. "Title")
	return
end

function ShopCategoryButton:Event_MouseButton1Click(): nil
	local titleScaleY: number = self._titleLabel.Position.Y.Scale
	local yPosition = titleScaleY * self._scroller.AbsoluteCanvasSize.Y
	self._scroller.CanvasPosition = Vector2.new(0, yPosition)
	return
end

return Component.new(ShopCategoryButton)