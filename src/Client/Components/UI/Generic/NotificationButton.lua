--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local NotificationButton: Component.Def = {
  Name = script.Name;
  LoadOrder = 0;
  IgnoreAncestors = { StarterGui };
  Guards = {
    Ancestors = { player.PlayerGui },
    IsA = "GuiButton",
    Children = {
      Exclamation = { ClassName = "ImageLabel" }
    }
  };
}

function NotificationButton:ToggleNotification(on: boolean): nil
  self.Instance.Exclamation.Visible = on
  return
end

return Component.new(NotificationButton)