--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Array = require(ReplicatedStorage.Packages.Array)

local TimerService = Knit.CreateService {
  Name = "TimerService"
}

type Timer = {
  Name: string;
  ID: string;
  BeginTime: number;
  Length: number;
}

function TimerService:KnitStart(): nil
  self._data = Knit.GetService("DataService")

  Players.PlayerAdded:Connect(function(player): nil
    self:RemoveFinished(player)
    return
  end)

  return
end

function TimerService:RemoveFinished(player: Player): nil
  task.spawn(function()
    local unfinishedTimers = Array.new("table", self:GetAll(player))
      :Filter(function(timer: Timer)
        return not self:IsFinished(timer)
      end)

    self._data:SetValue(player, "Timers", unfinishedTimers)
  end)
  return
end

function TimerService:IsFinished(timer: Timer): boolean
  return tick() - timer.BeginTime >= timer.Length
end

function TimerService:GetAll(player: Player): { Timer }
  return self._data:GetValue(player, "Timers")
end

function TimerService:Start(player: Player, name: string, length: number): nil
  task.spawn(function()
    local timer: Timer = {
      Name = name,
      ID = HttpService:GenerateGUID(),
      BeginTime = tick(),
      Length = length
    }
  
    local timers = self:GetAll(player)
    table.insert(timers, timer)
    self._data:SetValue(player, "Timers", timers)
    self:RemoveFinished(player)
  end)
  return
end

return TimerService