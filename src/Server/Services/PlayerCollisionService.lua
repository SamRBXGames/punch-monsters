--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Physics = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerCollisionService = Knit.CreateService {
  Name = "PlayerCollisionService"
}

local function assignPlayerCollisionGroup(char: Model): nil
	char:WaitForChild("HumanoidRootPart")
	char:WaitForChild("Head")
	char:WaitForChild("Humanoid")

	for _, descendant: Instance in pairs(char:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Player"
		end
	end
  return
end

function PlayerCollisionService:KnitInit()
	Physics:RegisterCollisionGroup("Player")
	Physics:CollisionGroupSetCollidable("Player", "Player", false)
	
  Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAppearanceLoaded:Connect(function(char)
      assignPlayerCollisionGroup(char)
    end)
  end)
end

return PlayerCollisionService