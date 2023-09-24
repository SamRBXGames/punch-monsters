--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Array = require(ReplicatedStorage.Packages.Array)

local BoostService = Knit.CreateService {
  Name = "BoostService";
  Client = {};
}

local function minutes(seconds: number): number
  return seconds * 60
end

function BoostService:KnitStart(): nil
  self._timers = Knit.GetService("TimerService")
  return
end

function BoostService:_StartTimer(player: Player, name: string, length: number): nil
  self._timers:Start(player, name .. "Boost", length)
  return
end

function BoostService:IsBoostActive(player: Player, boostName: "10xLuck" | "100xLuck" | "2xWins" | "2xStrength"): boolean
  return Array.new("table", self._timers:GetAll(player))
    :Some(function(timer)
      return timer.Name == boostName .. "Boost"and not self._timers:IsFinished(player, timer)
    end)
end

function BoostService:Activate10xLuckBoost(player: Player): nil
  self:_StartTimer(player, "10xLuckBoost", minutes(30))
  return
end

function BoostService:Activate100xLuckBoost(player: Player): nil
  self:_StartTimer(player, "100xLuckBoost", minutes(15))
  return
end

function BoostService:ActivateDoubleWinsBoost(player: Player): nil
  self:_StartTimer(player, "2xWinsBoost", minutes(30))
  return
end

function BoostService:ActivateDoubleStrengthBoost(player: Player): nil
  self:_StartTimer(player, "2xStrengthBoost", minutes(30))
  return
end

function BoostService.Client:IsBoostActive(player: Player, boostName: "10xLuck" | "100xLuck" | "2xWins" | "2xStrength"): boolean
  return self.Server:IsBoostActive(player, boostName)
end

return BoostService