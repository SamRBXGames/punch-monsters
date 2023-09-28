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
  local NotificationButton = Component.Get("NotificationButton")
  repeat task.wait()
    self._rewardsButton = NotificationButton:Find(self.Instance.Parent.MainUi.PlaytimeRewardButton)
  until self._rewardsButton
  self._rewardsButton:ToggleNotification(false)

	self._timedRewards = Knit.GetService("TimedRewardService")
  local data = Knit.GetService("DataService")
  local scheduler = Knit.GetController("SchedulerController")

  self._crateButtons = Array.new("Instance", self.Instance.Background.Crates:GetChildren())
    :Filter(function(element: Instance): boolean
      return element:IsA("ImageButton")
    end)

  for crateButton: CrateButton in self._crateButtons:Values() do
    local db = Debounce.new(0.5)
    self:AddToJanitor(crateButton.MouseButton1Click:Connect(function()
      if db:IsActive() then return end
      if self:GetRemainingTime(crateButton) ~= 0 then return end
      self._timedRewards:Claim(crateButton.LayoutOrder)
    end))
  end

  self:AddToJanitor(data.DataUpdated:Connect(function(key)
    if key ~= "ClaimedRewardsToday" then return end
    self:UpdateScreen()
  end))

  self:AddToJanitor(scheduler:Every("1 second", function(): nil
    self:UpdateScreen()
    return
  end))

	return
end

function RewardsScreen:UpdateScreen(): nil
  task.spawn(function(): nil
    local hasUnclaimed = self._crateButtons
      :Filter(function(crateButton: CrateButton): boolean
        return self:GetRemainingTime(crateButton) == 0
      end)
      :Some(function(crateButton: CrateButton): boolean
        return not self._timedRewards:IsClaimed(crateButton.LayoutOrder)
      end)

    if self._rewardsButton.Instance.Exclamation.Visible == hasUnclaimed then return end
    self._rewardsButton:ToggleNotification(hasUnclaimed)
    return
  end)

  for crateButton: CrateButton in self._crateButtons:Values() do
    task.spawn(function(): nil
      local isClaimed = self._timedRewards:IsClaimed(crateButton.LayoutOrder)
      local collectText = if isClaimed then "Collected!" else "Collect"
      if crateButton.Icon.TextLabel.Visible and crateButton.Icon.TextLabel.Text ~= collectText then
        crateButton.Icon.TextLabel.Text = collectText
      end
      return
    end)
    task.spawn(function(): nil
      local remainingTime = self:GetRemainingTime(crateButton)
      local timerFinished = remainingTime == 0
      crateButton.Icon.TextLabel.Visible = timerFinished
      crateButton.RemainingTime.Visible = not timerFinished

      if timerFinished then return end
      local timeObject = TFM.Convert(remainingTime)
      crateButton.RemainingTime.Text = TFM.FormatStr(timeObject, "%02h:%02m:%02S")
      return
    end)
  end
  return
end

function RewardsScreen:GetRemainingTime(crateButton: CrateButton): number
  local crateTime = parseTime(crateButton:GetAttribute("Length"))
  return math.round(math.max(crateTime - self._timedRewards:GetElapsedTime(), 0))
end

return Component.new(RewardsScreen)