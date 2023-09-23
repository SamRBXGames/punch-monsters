--!native
--!strict
local Tween = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local BlurController = Knit.CreateController {
	Name = "BlurController";
}

function BlurController:KnitInit(): nil
	self.blur = Instance.new("BlurEffect", game.Lighting)
	self:Toggle(false)
	return
end

function BlurController:Toggle(on)
	Tween:Create(self.blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
		Size = if on then 24 else 0,
	}):Play()
end

return BlurController