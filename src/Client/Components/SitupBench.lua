local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local SitupBenchTemplate = require(ReplicatedStorage.Templates.SitupBenchTemplate)

local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local characterRoot = character:WaitForChild("HumanoidRootPart")
local defaultCameraMinZoom = player.CameraMinZoomDistance

local SITUP_COOLDOWN = 0.5

local SitupBench = Component.new({
	Tag = script.Name,
	Ancestors = {workspace.Map1.SitupBenches, workspace.Map2.SitupBenches, workspace.Map3.SitupBenches}
})

function SitupBench:Start(): nil
	Knit.GetController("ComponentController"):Register(self)
	
	self._remoteDispatcher = Knit.GetService("RemoteDispatcher")
	self._data = Knit.GetService("DataService")
	self._gamepass = Knit.GetService("GamepassService")
	self._ui = Knit.GetController("UIController")
	
	self._janitor =  Janitor.new()
	self._janitor:Add(self.Instance)
	
	self._proximityPrompt = Instance.new("ProximityPrompt")
	self._proximityPrompt.HoldDuration = 1
	self._proximityPrompt.ObjectText = "Train"
	self._proximityPrompt.Parent = self.Instance.Cube
	
	local MainUi = player.PlayerGui.MainUi
	self._exitBench = MainUi.ExitBench
	
	self._benchTemplate = SitupBenchTemplate[self.Instance.Parent.Parent.Name][self.Instance.Name]
	self._AbsRequirement = self._benchTemplate.AbsRequirement
	self._janitor:Add(self._proximityPrompt.Triggered:Connect(function(player)
		self:Enter()
	end))
	
	self._janitor:Add(self._exitBench.MouseButton1Click:Connect(function()
		self:Exit()
	end))
end

function SitupBench:Toggle(on: boolean): nil
	self._remoteDispatcher:SetAttribute(self.Instance, "InUse", on)
	self._remoteDispatcher:SetShiftLockOption(not on)
	--self._ui:SetShiftLock(not on)
	self._proximityPrompt.Enabled = not on
	self._exitBench.Visible = on
	characterRoot.Anchored = on
end

function SitupBench:Enter(): nil
	if self.Instance:GetAttribute("InUse") then return end
	
	local absStrength = self._data:GetTotalStrength("Abs")
	if absStrength < self._AbsRequirement then return end
	
	self:Toggle(true)
	characterRoot.CFrame = self.Instance.TP.CFrame
	player.CameraMinZoomDistance = 4
end

function SitupBench:Exit(): nil
	self:Toggle(false) 
	player.CameraMinZoomDistance = defaultCameraMinZoom
end

function SitupBench:Situp(): nil
	if not self.Instance:GetAttribute("InUse") then return end
	if self.Instance:GetAttribute("SitupDebounce") then return end

	 self.Instance:SetAttribute("SitupDebounce", true)
	task.delay(SITUP_COOLDOWN, function()
		self.Instance:SetAttribute("SitupDebounce", false)
	end)

	local vip = self._gamepass:DoesPlayerOwn("VIP")
	local hasStrengthBoost = self._gamepass:DoesPlayerOwn("2x Strength")
	local absMultiplier = if hasStrengthBoost then 2 else 1
	
	if self._benchTemplate.Vip and not vip then
		return self._gamepass:PromptPurchase("VIP")
	end
	
	self._data:IncrementValue("AbsStrength", self._benchTemplate.Hit * absMultiplier)
end

function SitupBench:Destroy(): nil
	self._janitor:Destroy()
end

return SitupBench