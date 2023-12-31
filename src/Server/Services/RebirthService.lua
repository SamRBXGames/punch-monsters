--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RebirthRequirementsTemplate = require(ReplicatedStorage.Templates.RebirthRequirementsTemplate)

local Knit = require(ReplicatedStorage.Packages.Knit)

type BeforeAndAfter = {
  BeforeRebirth: number;
  AfterRebirth: number;
}
type BeforeAndAfterBoosts = {
  Wins: BeforeAndAfter;
  Strength: BeforeAndAfter;
}

local RebirthService = Knit.CreateService {
  Name = "RebirthService";
  Client = {};
}

function RebirthService:KnitStart(): nil
  self._data = Knit.GetService("DataService")
  return
end

function RebirthService:Get(player: Player): number
  return self._data:GetValue(player, "Rebirths")
end

function RebirthService:Rebirth(player: Player): nil
  local rebirths = self:Get(player)
  local winRequirement = RebirthRequirementsTemplate[rebirths + 1 :: number]
  local wins: number = self._data:GetValue(player, "Wins")
  if wins < winRequirement then return end

  self:_AddRebirth(player)
  return
end

function RebirthService:_AddRebirth(player: Player): nil
  local boosts = self:GetBeforeAndAfter(player)
  self._data:IncrementValue(player, "Rebirths"):await()
  self._data:SetValue(player, "RebirthBoosts", {
    Wins = boosts.Wins.AfterRebirth,
    Strength = boosts.Strength.AfterRebirth
  })

  return
end

  

function RebirthService:GetBeforeAndAfter(player: Player): BeforeAndAfterBoosts
  local currentBoost = self._data:GetValue(player, "RebirthBoosts")
  return table.freeze {
    Wins = {
      BeforeRebirth = currentBoost.Wins,
      AfterRebirth = self:GetBoost(player, "Wins", 1) * 100
    },
    Strength = {
      BeforeRebirth = currentBoost.Strength,
      AfterRebirth = self:GetBoost(player, "Strength", 1) * 100
    }
  }
end

function RebirthService:GetBoost(player: Player, boostType: "Wins" | "Strength", addRebirths: number?): number
  local rebirths = self:Get(player) + (if addRebirths ~= nil then addRebirths else 0)
  return 1 + if boostType == "Wins" then
    rebirths ^ 0.025 * (rebirths / 4)
  else
    rebirths ^ 0.285 * (rebirths / 5)
end

function RebirthService.Client:Rebirth(player: Player): nil
  return self.Server:Rebirth(player)
end

function RebirthService.Client:GetBeforeAndAfter(player: Player): BeforeAndAfterBoosts
  return self.Server:GetBeforeAndAfter(player)
end

function RebirthService.Client:Get(player: Player): number
  return self.Server:Get(player)
end

return RebirthService