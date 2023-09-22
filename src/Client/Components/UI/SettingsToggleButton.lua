--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local OFF_BACKGROUND = "rbxassetid://14509095890"
local ON_BACKGROUND = "rbxassetid://14509094060"
local OFF_TEXT = "rbxassetid://14509100683"
local ON_TEXT = "rbxassetid://14509109517"

local SettingsToggleButton: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { player.PlayerGui }
	}
}

function SettingsToggleButton:Initialize(): nil
	self._data = Knit.GetService("DataService")
	self._settingName = self.Instance.Parent.Name
	
	self._janitor:Add(self._data.DataUpdated:Connect(function(key)
		if key ~= "Settings" then return end
		self:UpdateImages()
	end))
end

function SettingsToggleButton:Event_MouseButton1Click(): nil
	local on: boolean = self._data:GetSetting(self._settingName)
	self._data:SetSetting(self._settingName, not on)
end

function SettingsToggleButton:UpdateImages(): nil
	local on: boolean = self._data:GetSetting(self._settingName)
	self.Instance.Image = if on then ON_BACKGROUND else OFF_BACKGROUND
	self.Instance.Text.Image = if on then ON_TEXT else OFF_TEXT
end

return Component.new(SettingsToggleButton)