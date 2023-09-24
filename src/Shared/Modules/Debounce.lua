local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local Debounce = {}
Debounce.__index = Debounce

function Debounce.new(cooldown: number, initialState: boolean?)
  local self = setmetatable({}, Debounce)
  self.Cooldown = cooldown
  self.Active = if initialState == nil then false else initialState
  self.Deactivated = Signal.new()
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

return Debounce