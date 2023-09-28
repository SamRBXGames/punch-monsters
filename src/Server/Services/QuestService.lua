--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Runtime = game:GetService("RunService")
local Players = game:GetService("Players")
local GameData = DataStoreService:GetDataStore("GameData")

local randomPair = require(ReplicatedStorage.Modules.RandomPair)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local QUEST_GOALS = {
  StayActive = 45 * 60, -- 45 mins
  OpenEggs = 1500,
  EarnStrength = 35_000,
}

local QuestService = Knit.CreateService {
  Name = "QuestService";
  Client = {};
}

function QuestService:KnitStart(): nil
  self._data = Knit.GetService("DataService")
  self._playtime = Knit.GetService("DataService")

  local elapsed = 0
  Runtime.Heartbeat:Connect(function(dt: number): nil
    if elapsed >= 1 then
      local date = os.date("!*t")
      local questsWereReset = GameData:GetAsync("QuestsResetThisWeek")
      if date.wday == 1 then
        if not questsWereReset then
          GameData:SetAsync("GoalsThisWeek", nil)
          GameData:SetAsync("QuestsResetThisWeek", true)
          for _, player in pairs(Players:GetPlayers()) do
            task.spawn(function(): nil
              self._data:SetValue(player, "UpdatedQuestProgress", false):await()
              self:_Reset(player)
              return
            end)
          end
        end
      else
        GameData:SetAsync("QuestsResetThisWeek", false)
      end
    else
      elapsed += dt
    end
    return
  end)

  Players.PlayerAdded:Connect(function(player: Player): nil
    self:_Reset(player)
    return
  end)

  return
end

function QuestService:_Reset(player: Player): nil
  if self._data:GetValue(player, "UpdatedQuestProgress") then return end
  self._data:SetValue(player, "UpdatedQuestProgress", true)

  local goal1, goal2 = self:GetQuestGoals()
  local progress = self._data:GetValue(player, "MegaQuestProgress")
  progress[goal1] = 0
  progress[goal2] = 0

  return
end

function QuestService:IncrementProgress(player: Player, goalName: string, amount: number): nil
  local progress = self._data:GetValue(player, "MegaQuestProgress")
	if progress[goalName] then
    self:SetProgress(player, goalName, progress[goalName] + amount)
	end
  return
end

function QuestService:SetProgress(player: Player, goalName: string, value: number): nil
  local progress = self._data:GetValue(player, "MegaQuestProgress")
	if progress[goalName] then
		progress[goalName] = value
    self._data:SetValue(player, "MegaQuestProgress", progress)
	end
  return
end

function QuestService:GetQuestProgress(player: Player): (number, number)
  local goal1, goal2 = self:GetQuestGoals()
  return self:_GetGoalProgress(player, goal1), self:_GetGoalProgress(player, goal2)
end

function QuestService:_GetGoalProgress(player: Player, goalName: string): number
  local progress = self._data:GetValue(player, "MegaQuestProgress")
  return progress[goalName] / QUEST_GOALS[goalName]
end

function QuestService:GetQuestGoals(): (string, string)
  if not GameData:GetAsync("GoalsThisWeek") then
    local goal1 = randomPair(QUEST_GOALS)
    local goal2 = randomPair(QUEST_GOALS)
    GameData:SetAsync("GoalsThisWeek", {goal1, goal2})
    return goal1, goal2
  else
    return table.unpack(GameData:GetAsync("GoalsThisWeek"))
  end
end

function QuestService:AttemptClaim(player: Player): nil
  
  return
end

function QuestService.Client:AttemptClaim(player: Player): nil
  return self.Server:AttemptClaim(player)
end

function QuestService.Client:GetQuestProgress(player: Player): (number, number)
  return self.Server:GetQuestProgress(player)
end

return QuestService