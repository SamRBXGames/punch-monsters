local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

local player = Players.LocalPlayer

local Spin = Component.new({
	Tag = script.Name,
	Ancestors = {player.PlayerGui}
})

function Spin:Start(): nil
	Knit.GetController("ComponentController"):Register(self)
	self._data = Knit.GetService("DataService")
	
	self._janitor =  Janitor.new()
	self._janitor:Add(self.Instance)
	self._janitor:Add(RunService.RenderStepped:Connect(function()
		self.Instance.Rotation += 1
	end))
end

function Spin:Destroy(): nil
	self._janitor:Destroy()
end

return Spin