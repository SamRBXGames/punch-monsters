local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local Viewport: Component.Def = {
	Name = script.Name;
	Guards = {
		ClassName = "ViewportFrame",
		Ancestors = { player.PlayerGui }
	};
}

function Viewport:Initialize(): nil
	self._camera = Instance.new("Camera")
	self.Attributes.DefaultFOV = self.Attributes.FOV or 55
	
	self._janitor:Add(self._camera)
	self._camera.CFrame = workspace:WaitForChild("ViewportCamera").CFrame
	self._camera.FieldOfView = self.Attributes.DefaultFOV
	self._camera.Parent = self.Instance
	self.Instance.CurrentCamera = self._camera
end

function Viewport:AttributeChanged_FOV(): nil
	self._camera.FieldOfView = self.Attributes.FOV or 55
end

return Component.new(Viewport)