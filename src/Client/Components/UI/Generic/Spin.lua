--!native
--!strict
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
		Ancestors = { player.PlayerGui },
		IsA = "GuiObject"
	};
}

function Spin:Update(): nil
	(self.Instance :: GuiObject).Rotation += 1
	return
end

return Component.new(Spin)