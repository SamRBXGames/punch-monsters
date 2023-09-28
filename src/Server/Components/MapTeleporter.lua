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
      Portal = { ClassName = "MeshPart" },
      Back = {
        ClassName = "Model",
        Children = {
          Circle = { ClassName = "MeshPart" }
        }
      }
    }
  };
}

local playerTeleporterDebounces: { [number]: typeof(Debounce.new(0)) } = {}
local playerBackTeleporterDebounces: { [number]: typeof(Debounce.new(0)) } = {}
function MapTeleporter:Initialize(): nil
  self._data = Knit.GetService("DataService")
  self._mapName = self.Instance.Parent.Name
  local _, mapNumberString = table.unpack(self._mapName:split("Map"))

  local function getPlayerFromPart(hit: BasePart): Player?
    local character = hit:FindFirstAncestorOfClass("Model")
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    return Players:GetPlayerFromCharacter(character)
  end

  if self._mapName ~= "Map3" then
    local destinationMapName = `Map{tonumber(mapNumberString) :: number + 1}`
    local destinationMap = workspace:FindFirstChild(destinationMapName) :: Model
    local destinationTeleporter = destinationMap:FindFirstChild("Teleporter") :: Model
    local destinationCFrame = (destinationTeleporter.PrimaryPart :: BasePart).CFrame
    local destinationOffset = destinationCFrame.LookVector * 5

    self:AddToJanitor(self.Instance.Portal.Touched:Connect(function(hit: BasePart): nil
      if self._mapName == "Map3" then return end
  
      local player = getPlayerFromPart(hit)
      if not player then return end
      if not playerTeleporterDebounces[player.UserId] then
        local db = Debounce.new(2)
        playerTeleporterDebounces[player.UserId] = db
        self:AddToJanitor(db)
      end
      
      local db = playerTeleporterDebounces[player.UserId]
      if db:IsActive() then return end
      self:Teleport(player.Character, destinationCFrame + destinationOffset)
      return
    end))
  end

  if self._mapName ~= "Map1" then
    local previousMapName = `Map{tonumber(mapNumberString) :: number - 1}`
    local previousMap = workspace:FindFirstChild(previousMapName) :: Model
    local previousTeleporter = previousMap:FindFirstChild("Teleporter") :: Model
    local previousCFrame = (previousTeleporter.PrimaryPart :: BasePart).CFrame
    local previousOffset = previousCFrame.LookVector * 5

    self:AddToJanitor(self.Instance.Back.Circle.Touched:Connect(function(hit: BasePart): nil
      local player = getPlayerFromPart(hit)
      if not player then return end
      if not playerBackTeleporterDebounces[player.UserId] then
        local db = Debounce.new(2)
        playerBackTeleporterDebounces[player.UserId] = db
        self:AddToJanitor(db)
      end
      
      local db = playerBackTeleporterDebounces[player.UserId]
      if db:IsActive() then return end
      self:Teleport(player.Character, previousCFrame + previousOffset)
      return
    end))
  end

  return
end

function MapTeleporter:Teleport(character: Model, cframe: CFrame): nil
  if not Array.new(self._data:GetValue("DefeatedBosses")):Has(self._mapName) then return end
  if self._data:GetValue("Rebirths") < self.Attributes.RequiredRebirths then return end
  if self._data:GetValue("Wins") < self.Attributes.RequiredWins then return end
  (character.PrimaryPart :: BasePart).CFrame = cframe
  return
end

return Component.new(MapTeleporter)