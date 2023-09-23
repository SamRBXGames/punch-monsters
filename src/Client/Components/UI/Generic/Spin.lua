local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local Spin: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		IsA = "GuiObject",
		Ancestors = { player.PlayerGui }
	};
}

function Spin:Update()
	self.Instance.Rotation += 1
end

return Component.new(Spin)