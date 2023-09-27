--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)
local Component = require(Packages.Component)
local Debounce = require(ReplicatedStorage.Modules.Debounce)

local player = Players.LocalPlayer

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
					Close = { ClassName = "ImageButton" },
					Skip = { ClassName = "ImageButton" },
					Rebirth = { ClassName = "ImageButton" },
					AutoRebirth = { ClassName = "ImageButton" }
				}
			}
		}
	};
}

function RebirthScreen:Initialize(): nil
	self._rebirths = Knit.GetService("RebirthService")
		
	local background = self.Instance.Background
	self:AddToJanitor(background.Skip.MouseButton1Click:Connect(function(): nil
		return
	end))

	local db = Debounce.new(0.5)
	self:AddToJanitor(background.Rebirth.MouseButton1Click:Connect(function(): nil
		if db:IsActive() then return end
		-- self._rebirths:Rebirth()
		return
	end))

	return
end

function RebirthScreen:UpdateStats(): nil
	local boosts = self._rebirths:GetBeforeAndAfter()
	return
end

return Component.new(RebirthScreen)