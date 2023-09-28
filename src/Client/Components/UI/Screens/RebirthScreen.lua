--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local RebirthRequirementsTemplate = require(ReplicatedStorage.Templates.RebirthRequirementsTemplate)
local Debounce = require(ReplicatedStorage.Modules.Debounce)
local abbreviate = require(ReplicatedStorage.Modules.Abbreviate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local beforeAfterGuard = {
	ClassName = "ImageLabel",
	Children = {
		Value = { ClassName = "TextLabel" }
	}
}

local RebirthScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui },
		Name = "RebirthUi",
		ClassName = "ScreenGui",
		Children = {
			Background = {
				ClassName = "ImageLabel",
				Children = {
					BeforeRebirthWins = beforeAfterGuard,
					AfterRebirthWins = beforeAfterGuard,
					BeforeRebirthStrength = beforeAfterGuard,
					AfterRebirthStrength = beforeAfterGuard,
					Close = { ClassName = "ImageButton" },
					Skip = { ClassName = "ImageButton" },
					Rebirth = { ClassName = "ImageButton" },
					AutoRebirth = { ClassName = "ImageButton" },
					Wins = {
						ClassName = "ImageLabel",
						Children = {
							Progress = { ClassName = "TextLabel" }
						}
					}
				}
			}
		}
	};
}

function RebirthScreen:Initialize(): nil
	self._data = Knit.GetService("DataService")
	self._rebirths = Knit.GetService("RebirthService")
	self._background = self.Instance.Background

	local db = Debounce.new(0.5)
	self:AddToJanitor(self._background.Rebirth.MouseButton1Click:Connect(function(): nil
		if db:IsActive() then return end
		self._rebirths:Rebirth()
		return self:UpdateStats()
	end))

	self:AddToJanitor(self._data.DataUpdated:Connect(function(key)
		if key ~= "Rebirths" then return end
		self:UpdateStats()
	end))

	return self:UpdateStats()
end

function RebirthScreen:UpdateStats(): nil
	task.spawn(function(): nil
		local autoRebirth = self._data:GetValue("AutoRebirth")
		if not autoRebirth then return end
		self._rebirths:Rebirth()
		return
	end)
	task.spawn(function(): nil
		local boosts = self._rebirths:GetBeforeAndAfter()
		local wins = self._data:GetValue("Wins")
		local rebirths = self._rebirths:Get()
		local rebirthWinRequirement = RebirthRequirementsTemplate[rebirths + 1 :: number]
		self._background.Wins.Progress.Text = `{abbreviate(wins)}/{abbreviate(rebirthWinRequirement)} Wins`
		self._background.BeforeRebirthWins.Value.Text = `{abbreviate(boosts.Wins.BeforeRebirth)}%`
		self._background.AfterRebirthWins.Value.Text = `{abbreviate(boosts.Wins.AfterRebirth)}%`
		self._background.BeforeRebirthStrength.Value.Text = `{abbreviate(boosts.Strength.BeforeRebirth)}%`
		self._background.AfterRebirthStrength.Value.Text = `{abbreviate(boosts.Strength.AfterRebirth)}%`
		return
	end)
	return
end

return Component.new(RebirthScreen)