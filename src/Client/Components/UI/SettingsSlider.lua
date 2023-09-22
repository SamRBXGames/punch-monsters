local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Slider = require(ReplicatedStorage.Packages.Slider)
local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

local player = Players.LocalPlayer

local OFF_BACKGROUND = "rbxassetid://14509095890"
local ON_BACKGROUND = "rbxassetid://14509094060"
local OFF_TEXT = "rbxassetid://14509100683"
local ON_TEXT = "rbxassetid://14509109517"

local SettingsSlider = Component.new({
	Tag = script.Name,
	Ancestors = {player.PlayerGui}
})

function SettingsSlider:Start(): nil
	Knit.GetController("ComponentController"):Register(self)
	self._data = Knit.GetService("DataService")
	self._settingName = self.Instance.Parent.Name
	local slider = Slider.new(self.Instance, {
		MoveType = "Tween",
		MoveInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad),
		AllowBackgroundClick = true,
		SliderData = {
			Increment = 1,
			Start = 0,
			End = 100
		}
	})
	
	self._janitor =  Janitor.new()
	self._janitor:Add(self.Instance)
	self._janitor:Add(slider)
	
	local initialized = false
	self._janitor:Add(slider.Changed:Connect(function(value)
		if not initialized then return end
		self._data:SetSetting(self._settingName, value)
	end))
	
	self._data.DataUpdated:ConnectOnce(function(key, settings)
		if key ~= "Settings" then return end
		slider:OverrideValue(settings[self._settingName])
		initialized = true
	end)
	
	slider:Track()
end

function SettingsSlider:Destroy(): nil
	self._janitor:Destroy()
end

return SettingsSlider