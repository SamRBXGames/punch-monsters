local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)

local TimedRewardService = Knit.CreateService {
  Name = "TimedRewardService";
  Client = {};
}

function TimedRewardService:KnitStart()
  self._data = Knit.GetService("DataService")

  Players.PlayerAdded:Connect(function(player)
    -- resets every 12 hours
    if self:GetElapsedTime(player) >= 12 * 60 * 60 then
      self._data:SetValue(player, "FirstJoinToday", tick())
      self._data:SetValue(player, "ClaimedRewardsToday", {})
    end
  end)
end

function TimedRewardService:Claim(player: Player, crateNumber: number): nil
  if self:IsClaimed(player, crateNumber) then return end
  local claimed = self._data:GetValue(player, "ClaimedRewardsToday")
  table.insert(claimed, crateNumber)
  self._data:SetValue(player, "ClaimedRewardsToday", claimed)
  return
end

function TimedRewardService:IsClaimed(player: Player, crateNumber: number): boolean
  return Array.new("number", self._data:GetValue(player, "ClaimedRewardsToday")):Has(crateNumber)
end

function TimedRewardService:GetElapsedTime(player: Player): number
  return math.round(tick() - self._data:GetValue(player, "FirstJoinToday"))
end

function TimedRewardService.Client:GetElapsedTime(player: Player): number
  return self.Server:GetElapsedTime(player)
end

function TimedRewardService.Client:Claim(player: Player, crateNumber: number): nil
  return self.Server:Claim(player, crateNumber)
end

function TimedRewardService.Client:IsClaimed(player: Player, crateNumber: number): boolean
  return self.Server:IsClaimed(player, crateNumber)
end

return TimedRewardService