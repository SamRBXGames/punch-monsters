local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local Dumbells: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { workspace.Map1 }, -- workspace.Map2, workspace.Map3
		ClassName = "Model",
		Children = {
			Circle = { ClassName = "MeshPart" },
			Dashes = { ClassName = "MeshPart" }
		}
	};
}

function Dumbells:Initialize(): nil	
  local ui = Knit.GetController("UIController")
  local touching = false
  local db = false

  self:AddToJanitor(self.Instance.Circle.Touched:Connect(function(hit: BasePart)
    if touching then return end
    if db then return end
    db = true
    task.delay(4, function()
      db = false
    end)

    local char = hit:FindFirstAncestorOfClass("Model")
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end

    touching = true
    local mapName = self.Instance.Parent.Name
    local dumbellsUI: ScreenGui = ui:SetScreen("Weights", true)
    dumbellsUI:SetAttribute("MapName", mapName)
    for _, window in pairs(dumbellsUI:GetChildren()) do
      (window :: ImageLabel).Visible = window.Name == mapName
    end
  end))
  self:AddToJanitor(self.Instance.Circle.TouchEnded:Connect(function(hit: BasePart)
    if not touching then return end
    if db then return end
    
    local char = hit:FindFirstAncestorOfClass("Model")
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end

    touching = false
    ui:SetScreen("MainUi", false)
  end))

  return
end

return Component.new(Dumbells)