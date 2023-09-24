local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local TimedRewardService = Knit.CreateService {
  Name = "TimedRewardService";
  Client = {};
}

function TimedRewardService:KnitStart()
  self._data = Knit.GetService("DataService")

  Players.PlayerAdded:Connect(function(player)
    if self:GetElapsedTime(player) >= 24 * 60 * 60 then
      self._data:SetValue(player, "FirstJoinToday", tick())
    end
  end)
end

function TimedRewardService:GetElapsedTime(player: Player): number
  return tick() - self._data:GetValue(player, "FirstJoinToday")
end

return TimedRewardService