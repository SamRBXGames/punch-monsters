--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local TFM = require(script.Parent.Parent.Parent.Parent.Modules.TFMv2)
local Debounce = require(ReplicatedStorage.Modules.Debounce)
local parseTime = require(ReplicatedStorage.Modules.ParseTime)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

type CrateButton = ImageButton & {
  RemainingTime: TextLabel;
  Icon: ImageLabel & {
    TextLabel: TextLabel
  };
}

local RewardsScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui },
		ClassName = "ScreenGui",
		Children = {
			Background = {
				ClassName = "ImageLabel",
				Children = {
					Close = { ClassName = "ImageButton" },
					Title = { ClassName = "ImageLabel" },
          Crates = { ClassName = "Frame" }
				}
			}
		}
	};
}

function RewardsScreen:Initialize(): nil
  local data = Knit.GetService("DataService")
	self._timedRewards = Knit.GetService("TimedRewardService")

  self._updateTime = 0
  self._crateButtons = Array.new("Instance", self.Instance.Background.Crates:GetChildren())
    :Filter(function(element: Instance): boolean
      return element:IsA("ImageButton")
    end)

  for crateButton: CrateButton in self._crateButtons:Values() do
    local db = Debounce.new(0.5)
    self:AddToJanitor(crateButton.MouseButton1Click:Connect(function()
      if self:GetRemainingTime(crateButton) ~= 0 then return end
      if db:IsActive() then return end
      self._timedRewards:Claim(crateButton.LayoutOrder)
    end))
  end

  self:AddToJanitor(data.DataUpdated:Connect(function(key)
    if key ~= "ClaimedRewardsToday" then return end
    self._updateTime = 1
    self:Update(0)
  end))

	return
end

function RewardsScreen:Update(dt: number): nil
  if not self._crateButtons then return end
  if self._updateTime >= 1 then
    self._updateTime = 0
    for crateButton: CrateButton in self._crateButtons:Values() do
      task.spawn(function(): nil
        local remainingTime = self:GetRemainingTime(crateButton)
        local isClaimed = self._timedRewards:IsClaimed(crateButton.LayoutOrder)
        local timerFinished = remainingTime == 0
        task.spawn(function(): nil
          crateButton.Icon.TextLabel.Visible = timerFinished
          crateButton.RemainingTime.Visible = not timerFinished
          return
        end)
        task.spawn(function(): nil
          print(isClaimed)
          local collectText = if isClaimed then "Collected!" else "Collect"
          if crateButton.Icon.TextLabel.Visible and crateButton.Icon.TextLabel.Text ~= collectText then
            crateButton.Icon.TextLabel.Text = collectText
          end
          return
        end)
        task.spawn(function(): nil
          if timerFinished then return end
          local timeObject = TFM.Convert(remainingTime)
          crateButton.RemainingTime.Text = TFM.FormatStr(timeObject, "%02h:%02m:%02S")
          return
        end)
        return
      end)
    end
  else
    self._updateTime += dt
  end
  return
end

function RewardsScreen:GetRemainingTime(crateButton: CrateButton): number
  local crateTime = parseTime(crateButton:GetAttribute("Length"))
  return math.round(math.max(crateTime - self._timedRewards:GetElapsedTime(), 0))
end

return Component.new(RewardsScreen)