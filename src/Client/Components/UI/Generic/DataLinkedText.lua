local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

local Client = script:FindFirstAncestorOfClass("LocalScript")
local Packages = ReplicatedStorage.Packages
local Functions = Client.Functions
local CodeTemplate = require(ReplicatedStorage.Templates.CodeTemplate)

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)
local Array = require(Packages.Array)
local Tweens = require(Functions.Tweens)
local Constants = require(Functions.Constants)
local abbreviate = require(ReplicatedStorage.Assets.Modules.Abbreviate)

local player = Players.LocalPlayer

local DataLinkedText = Component.new({
	Tag = script.Name,
	Ancestors = {player.PlayerGui}
})

function DataLinkedText:Start(): nil
	Knit.GetController("ComponentController"):Register(self)
	self._data = Knit.GetService("DataService")

	self._janitor =  Janitor.new()
	self._janitor:Add(self.Instance)
	self._janitor:Add(self._data.DataUpdated:Connect(function(key, data)
		local linkedKey = self.Instance:GetAttribute("DataKey")
		if key ~= linkedKey then return end
		
		local value = self._data:GetValue(linkedKey)
		self.Instance.Text = if self.Instance:GetAttribute("Abbreviate") then abbreviate(value) else tostring(value)
	end))
end

function DataLinkedText:Destroy(): nil
	self._janitor:Destroy()
end

return DataLinkedText