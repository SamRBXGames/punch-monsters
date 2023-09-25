--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local Viewport: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		ClassName = "ViewportFrame",
		Attributes = {
			FOV = { Type = "number" },
			DefaultFOV = { Type = "number" }
		}
	};
}

function Viewport:Initialize(): nil
	self._camera = Instance.new("Camera")
	self.Attributes.DefaultFOV = self.Attributes.FOV or 55
	
	self:AddToJanitor(self._camera)
	self._camera.CFrame = workspace:WaitForChild("ViewportCamera").CFrame
	self._camera.FieldOfView = self.Attributes.DefaultFOV
	self._camera.Parent = self.Instance;
	(self.Instance :: ViewportFrame).CurrentCamera = self._camera
	return
end

function Viewport:AttributeChanged_FOV(): nil
	self._camera.FieldOfView = self.Attributes.FOV or 55
	return
end

return Component.new(Viewport)