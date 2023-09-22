local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)

shared.components = shared.components or Array.new()

local ComponentController = Knit.CreateController {
	Name = "ComponentController";
}

function ComponentController:KnitStart()
	for _, componentModule: Instance in script.Parent.Parent.Components:GetDescendants() do
		if componentModule:IsA("ModuleScript") then
			task.spawn(require, componentModule)
		end
	end
end

function ComponentController:Register(component): Array
	shared.components:Push(component)
end

return ComponentController