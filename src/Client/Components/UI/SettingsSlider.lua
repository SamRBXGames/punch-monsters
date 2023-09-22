local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Client = script:FindFirstAncestorOfClass("LocalScript")
local Slider = require(Client.Modules.Slider)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local SettingsSlider: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { player.PlayerGui }
	};
}

function SettingsSlider:Initialize(): nil
	self._data = Knit.GetService("DataService")
	self._settingName = self.Instance.Parent.Name

	local initialized = false
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
	
	self._janitor:Add(slider)
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

return Component.new(SettingsSlider)