local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local abbreviate = require(ReplicatedStorage.Assets.Modules.Abbreviate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local DataLinkedText: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		ClassName = "TextLabel",
		Ancestors = { player.PlayerGui }
	};
}

function DataLinkedText:Initialize(): nil
	self._data = Knit.GetService("DataService")

	self._janitor:Add(self._data.DataUpdated:Connect(function(key)
		local linkedKey = self.Attributes.DataKey
		if key ~= linkedKey then return end
		
		local value = self._data:GetValue(linkedKey)
		self.Instance.Text = if self.Attributes.Abbreviate then abbreviate(value) else tostring(value)
	end))
end

return Component.new(DataLinkedText)