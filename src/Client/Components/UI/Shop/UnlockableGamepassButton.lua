--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local UnlockableGamepassButton: Component.Def = {
  Name = script.Name;
  IgnoreAncestors = { StarterGui };
  Guards = {
    Ancestors = { player.PlayerGui },
    ClassName = "ImageButton",
    Attributes = {
      Requirement = { Type = "string" }
    }
  };
}

function UnlockableGamepassButton:Initialize(): nil
  local data = Knit.GetService("DataService")
  self._gamepass = Knit.GetService("GamepassService")
  self._lockedOverlay = self.Instance:FindFirstChild("Locked")

  self:AddToJanitor(data.DataUpdated:Connect(function(key)
    if key ~= "PurchaseLog" then return end
    self:UpdateLockedState()
  end))

  self:UpdateLockedState()
  return
end

function UnlockableGamepassButton:UpdateLockedState(): nil
  if not self._lockedOverlay then return end
  task.spawn(function(): nil
    local hasRequired = self._gamepass:DoesPlayerOwn(self.Attributes.Requirement)
    self._lockedOverlay.Visible = not hasRequired
    return
  end)
  return
end

return Component.new(UnlockableGamepassButton)