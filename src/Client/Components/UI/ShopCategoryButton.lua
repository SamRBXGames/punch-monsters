local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

local player = Players.LocalPlayer

local ShopCategoryButton = Component.new({
	Tag = script.Name,
	Ancestors = {player.PlayerGui}
})

function ShopCategoryButton:Start(): nil
	Knit.GetController("ComponentController"):Register(self)
	local scroller: ScrollingFrame = self.Instance.Parent:FindFirstChildOfClass("ScrollingFrame")
	local titleLabel: TextLabel = scroller[self.Instance.Name .. "Title"]
	
	self._janitor =  Janitor.new()
	self._janitor:Add(self.Instance)
	self._janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		scroller.CanvasPosition = Vector2.new(0, titleLabel.Position.Y.Scale * scroller.AbsoluteCanvasSize.Y)
	end))
end

function ShopCategoryButton:Destroy(): nil
	self._janitor:Destroy()
end

return ShopCategoryButton