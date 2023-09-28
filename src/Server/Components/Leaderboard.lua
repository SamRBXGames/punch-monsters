--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local abbreviate = require(ReplicatedStorage.Modules.Abbreviate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Array = require(Packages.Array)

local Leaderboard: Component.Def = {
  Name = script.Name;
  Guards = {
    Ancestors = { workspace },
    ClassName = "SurfaceGui",
    Attributes = {
      Type = { Type = "string" }
    },
    Children = {
      Content = { ClassName = "ScrollingFrame" }
    }
  };
}

function Leaderboard:Initialize(): nil
  self._data = Knit.GetService("DataService")
  self._playtime = Knit.GetService("PlaytimeService")

  self._leaderboardEntry = ReplicatedStorage.Assets.UserInterface.Leaderboard.Entry
  self._updateTime = 0
  self._dataInitialized = false

  if self.Attributes.Type == "Strength" then
    self:AddToJanitor(self._data.DataUpdated.Event:Connect(function(_, key): nil
      if key ~= "PunchStrength" and key ~= "AbsStrength" and key ~= "BicepsStrength" then return end
      self._dataInitialized = true
      return self:UpdateEntries()
    end))
  end
end

function Leaderboard:Update(dt: number): nil
  if self.Attributes.Type ~= "Playtime" then return end
  if not self._dataInitialized then return end
  if self._updateTime >= 1 then
    self._updateTime = 0
    self:UpdateEntries()
  else
    self._updateTime += dt
  end
  return
end

function Leaderboard:UpdateEntries(): nil
  task.spawn(function()
    self.Instance.Content:ClearAllChildren()
  end)

  local bestPlayers = Array.new("Instance", Players:GetPlayers())
    :Sort(function(a, b)
      return self:_GetScore(a) > self:_GetScore(b)
    end)
    :Truncate(50)

  for player, i in bestPlayers:Values() do
    task.spawn(function()
      local entryFrame = self._leaderboardEntry:Clone()
      entryFrame.PlayerName.Text = player.DisplayName
      entryFrame.Score.Text = abbreviate(self:_GetScore(player))
      entryFrame.Icon.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
      entryFrame.LayoutOrder = i
      entryFrame.Parent = self.Instance.Content
    end)
  end

  return
end

function Leaderboard:_GetScore(player: Player): number
  return if self.Attributes.Type == "Strength" then
    self._data:GetValue(player, "Strength")
  else
    self._playtime:Get(player)
end

return Component.new(Leaderboard)