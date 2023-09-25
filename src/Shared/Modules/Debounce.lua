local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)
local Janitor = require(Packages.Janitor)

local Debounce = {}
Debounce.__index = Debounce

function Debounce.new(cooldown: number, initialState: boolean?)
  local self = setmetatable({}, Debounce)

  self._janitor = Janitor.new()
  self.Cooldown = cooldown
  self.Active = if initialState == nil then false else initialState
  self.Deactivated = Signal.new()

  self._janitor:Add(self.Deactivated)
  self._janitor:Add(function()
    self.Cooldown = nil
    self.Active = nil
    self.Deactivated = nil
  end)

  return self
end

function Debounce:IsActive(): boolean
  local active = self.Active
  if not active then
    self.Active = true
    task.delay(self.Cooldown, function()
      self.Active = false
      self.Deactivated:Fire()
    end)
  end
  return active
end

function Debounce:Destroy(): nil
  return self._janitor:Destroy()
end

return Debounce