--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Debounce = require(ReplicatedStorage.Modules.Debounce)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Array = require(Packages.Array)

local MapTeleporter: Component.Def = {
  Name = script.Name;
  Guards = {
    Ancestors = { workspace.Map1, workspace.Map2, workspace.Map3 },
    ClassName = "Model",
    PrimaryPart = function(primary)
      return primary ~= nil
    end,
    Attributes = {
      RequiredRebirths = { Type = "number" },
      RequiredWins = { Type = "number" },
    },
    Children = {
      Portal = { ClassName = "MeshPart" }
    }
  };
}

local playerDebounces: { [number]: typeof(Debounce.new(0)) } = {}
function MapTeleporter:Initialize(): nil
  self._data = Knit.GetService("DataService")

  self._mapName = self.Instance.Parent.Name
  local _, mapNumberString = table.unpack(self._mapName:split("Map"))
  local destinationMapName = `Map{tonumber(mapNumberString) :: number + 1}`
  local destinationMap = workspace:FindFirstChild(destinationMapName) :: Model
  local destinationTeleporter = destinationMap:FindFirstChild("Teleporter") :: Model
  local destinationCFrame = (destinationTeleporter.PrimaryPart :: BasePart).CFrame
  local destinationOffset = destinationCFrame.LookVector * 5

  self:AddToJanitor(self.Instance.Portal.Touched:Connect(function(hit: BasePart)
    if self._mapName == "Map3" then return end

    local character = hit:FindFirstAncestorOfClass("Model")
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end
    if not playerDebounces[player.UserId] then
      local db = Debounce.new(3)
      playerDebounces[player.UserId] = db
      self:AddToJanitor(db)
    end
    
    local db = playerDebounces[player.UserId]
    if db:IsActive() then return end
    self:Teleport(character, destinationCFrame + destinationOffset)
  end))
  return
end

function MapTeleporter:Teleport(character: Model, cframe: CFrame): nil
  if not Array.new(self._data:GetValue("DefeatedBosses")):Has(self._mapName) then return end
  if self._data:GetValue("Rebirths") < self.Attributes.RequiredRebirths then return end
  if self._data:GetValue("Wins") < self.Attributes.RequiredWins then return end
  return character:PivotTo(cframe)
end

return Component.new(MapTeleporter)