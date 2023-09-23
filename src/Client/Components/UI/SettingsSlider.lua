--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Slider = require(script.Parent.Parent.Parent.Modules.Slider)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local SettingsSlider: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui },
		ClassName = "ImageButton"
	};
}

function SettingsSlider:Initialize(): nil
	self._data = Knit.GetService("DataService")
	self._settingName = self.Instance.Parent.Name

	local initialized = false
	local slider = Slider.new(self.Instance :: any, {
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
	
	local conn: RBXScriptConnection; conn = self._data.DataUpdated:Connect(function(key, settings)
		if key ~= "Settings" then return end
		slider:OverrideValue(settings[self._settingName])
		conn:Disconnect()
		initialized = true
	end)
	
	slider:Track()
	return
end

return Component.new(SettingsSlider)