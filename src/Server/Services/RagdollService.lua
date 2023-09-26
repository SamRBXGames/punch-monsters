--!native
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Physics = game:GetService("PhysicsService")

local Ragdoll = require(ReplicatedStorage.Modules.Ragdoll)

local Knit = require(ReplicatedStorage.Packages.Knit)

Physics:RegisterCollisionGroup("Players")
Physics:RegisterCollisionGroup("Collider")
Physics:CollisionGroupSetCollidable("Players", "Collider", false)

local RagdollService = Knit.CreateService {
	Name = "RagdollService";
	Client = {};
}

function RagdollService:KnitInit(): nil
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			self:RigModel(character)
		end)
	end)
	return
end

function RagdollService:RigModel(character: Model): nil
	task.spawn(function(): nil
		Ragdoll:RigModel(character)
		return
	end)
	return
end

function RagdollService.Client:RigModel(_, character: Model): nil
	return self.Server:RigModel(character)
end

return RagdollService