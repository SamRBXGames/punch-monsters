--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local AutoButton: Component.Def = {
  Name = script.Name;
  IgnoreAncestors = { StarterGui };
  Guards = {
    Ancestors = { player.PlayerGui },
    ClassName = "ImageButton",
    Attributes = {
      Type = { Type = "string" }
    },
    Children = {
      Title = { ClassName = "TextLabel" }
    }
  };
}

function AutoButton:Initialize(): nil
  self._data = Knit.GetService("DataService")
  self._gamepass = Knit.GetService("GamepassService")
  self._dataKey = self.Attributes.Type:gsub(" ", "")
  
  self:AddToJanitor(self._data.DataUpdated:Connect(function(key): nil
    if key ~= self._dataKey then return end
    return self:UpdateText()
  end))
  
  return
end

function AutoButton:Event_MouseButton1Click(): nil
  if self.Attributes.Type == "Auto Rebirth" and not self._gamepass:DoesPlayerOwn("Auto Rebirth") then
		return self._gamepass:PromptPurchase("Auto Rebirth")
	end
  return self._data:SetValue(self._dataKey, not self._data:GetValue(self._dataKey))
end

function AutoButton:UpdateText(): nil
  local on: boolean = self._data:GetValue(self._dataKey)
  self.Instance.Title.Text = `{self.Attributes.Type}: {if on then "ON" else "OFF"}`
  return
end

return Component.new(AutoButton)