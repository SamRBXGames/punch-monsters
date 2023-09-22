local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

local Client = script:FindFirstAncestorOfClass("LocalScript")
local Packages = ReplicatedStorage.Packages
local Functions = Client.Functions
local CodeTemplate = require(ReplicatedStorage.Templates.CodeTemplate)

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)
local Array = require(Packages.Array)
local Tweens = require(Functions.Tweens)
local Constants = require(Functions.Constants)
local abbreviate = require(ReplicatedStorage.Assets.Modules.Abbreviate)

local player = Players.LocalPlayer

local Viewport = Component.new({
	Tag = script.Name,
	Ancestors = {player.PlayerGui}
})

function Viewport:Start(): nil
	Knit.GetController("ComponentController"):Register(self)

	self._janitor =  Janitor.new()
	self._janitor:Add(self.Instance)
	
	local camera = Instance.new("Camera")
	self.Instance:SetAttribute("DefaultFOV", self.Instance:GetAttribute("FOV") or 55)
	
	camera.CFrame = workspace:WaitForChild("ViewportCamera").CFrame
	camera.FieldOfView = self.Instance:GetAttribute("DefaultFOV")
	camera.Parent = self.Instance
	self._janitor:Add(camera)
	self._janitor:Add(self.Instance:GetAttributeChangedSignal("FOV"):Connect(function()
		camera.FieldOfView = self.Instance:GetAttribute("FOV") or 55
	end))
	
	self._camera = camera
	self.Instance.CurrentCamera = camera
end

function Viewport:Destroy(): nil
	self._janitor:Destroy()
end

return Viewport