--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Debounce = require(ReplicatedStorage.Modules.Debounce)
local abbreviate = require(ReplicatedStorage.Modules.Abbreviate)
local randomPair = require(ReplicatedStorage.Modules.RandomPair)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local MegaQuestScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui },
		Name = "MegaQuest",
		ClassName = "ScreenGui",
		Children = {
			Background = {
				ClassName = "ImageLabel",
				Children = {
					Close = { ClassName = "ImageButton" },
					Claim = { ClassName = "ImageButton" },
					Buy = { ClassName = "ImageButton" },
          Note = { ClassName = "TextLabel" },
          Goal2Title = { ClassName = "TextLabel" },
          Goal1Title = { ClassName = "TextLabel" },
          PetName = { ClassName = "TextLabel" },
          PetRarity = { ClassName = "TextLabel" },
					Pet = {
						ClassName = "ImageLabel",
						Children = {
							Viewport = { ClassName = "ViewportFrame" }
						}
					},
          Goal1Progress = {
						ClassName = "ImageLabel",
						Children = {
							Bar = { ClassName = "ImageLabel" },
              Value = { ClassName = "TextLabel" }
						}
					},
          Goal2Progress = {
						ClassName = "ImageLabel",
						Children = {
							Bar = { ClassName = "ImageLabel" },
              Value = { ClassName = "TextLabel" }
						}
					}
				}
			}
		}
	};
}

function MegaQuestScreen:Initialize(): nil
	self._data = Knit.GetService("DataService")
  self._quests = Knit.GetService("QuestService")
  self._questGoals = self._quests:GetQuestGoals()
	self._background = self.Instance.Background

	local db = Debounce.new(0.5)
	self:AddToJanitor(self._background.Claim.MouseButton1Click:Connect(function(): nil
    if not self._quests:IsComplete() then return end
		if db:IsActive() then return end
		self._quests:Claim()
	end))

	self:AddToJanitor(self._data.DataUpdated:Connect(function(key): nil
		if key ~= "MegaQuestProgress" and key ~= "UpdatedQuestProgress" then return end
		return self:UpdateProgress()
	end))

  return self:UpdateProgress()
end

function MegaQuestScreen:UpdateProgress(): nil
	task.spawn(function(): nil
		local progressData = self._data:GetValue("MegaQuestProgress")
    local colorValue = if self._quests:IsComplete() then Color3.new(1, 1, 1) else Color3.new(0.74, 0.74, 0.74)
		self._background.Claim.ImageColor3 = colorValue
    self._background.Claim.Title.TextColor3 = colorValue

    local index = 1
    for name, currentValue in pairs(progressData) do
      task.spawn(function(): nil
        local barContainer = self._background[`Goal{index}Progress`]
        local title = self._background[`Goal{index}Title`]
        local goalValue = self._questGoals[name]
        local progress = currentValue / goalValue
        barContainer.Bar.Size = UDim2.fromScale(progress, 1)
        
        if name == "StayActive" then
          barContainer.Value.Text = `{currentValue / 60}/{goalValue / 60}`
        else
          barContainer.Value.Text = `{currentValue}/{goalValue}`
        end
        
        if name == "StayActive" then
          title.Text = `Stay Active for {goalValue / 60} Minutes`
        elseif name == "OpenEggs" then
          title.Text = `Open {goalValue} Eggs`
        elseif name == "GainStrength" then
          title.Text = `Gain {abbreviate(goalValue)} Strength`
        end
        return
      end)
      index += 1
    end
		return
	end)
	return
end

return Component.new(MegaQuestScreen)