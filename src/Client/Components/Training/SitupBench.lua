local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SitupBenchTemplate = require(ReplicatedStorage.Templates.SitupBenchTemplate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer
local defaultCameraMinZoom = player.CameraMinZoomDistance
local character = player.Character or player.CharacterAdded:Wait()
local characterRoot = character:WaitForChild("HumanoidRootPart")
local animator = character.Humanoid:WaitForChild("Animator") :: Animator
local animations = ReplicatedStorage.Assets.Animations

local SITUP_ANIM = animator:LoadAnimation(animations.Situp)

local SitupBench: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { workspace.Map1.SitupBenches, workspace.Map2.SitupBenches, workspace.Map3.SitupBenches },
		ClassName = "Model",
		Attributes = {
			InUse = { Type = "boolean" },
			SitupDebounce = { Type = "boolean" }
		},
		Children = {
			Cube = { ClassName = "MeshPart" },
			TP = {
				ClassName = "Part",
				Transparency = 1,
				Anchored = true,
				CanCollide = false
			}
		}
	};
}

function SitupBench:Initialize(): nil	
	task.spawn(function(): nil
		self._remoteDispatcher = Knit.GetService("RemoteDispatcher")
		self._data = Knit.GetService("DataService")
		self._gamepass = Knit.GetService("GamepassService")
		self._dumbell = Knit.GetService("DumbellService")
		self._ui = Knit.GetController("UIController")
		
		self._proximityPrompt = Instance.new("ProximityPrompt")
		self._proximityPrompt.HoldDuration = 1
		self._proximityPrompt.ObjectText = "Train"
		self._proximityPrompt.Parent = self.Instance.Cube
		
		local MainUi = player.PlayerGui.MainUi
		self._exitBench = MainUi.ExitBench
		
		self._benchTemplate = SitupBenchTemplate[self.Instance.Parent.Parent.Name][self.Instance.Name]
		self._absRequirement = self._benchTemplate.AbsRequirement
		self:AddToJanitor(self._proximityPrompt.Triggered:Connect(function(player)
			self:Enter()
		end))
		
		self:AddToJanitor(self._exitBench.MouseButton1Click:Connect(function()
			self:Exit()
		end))
		return
	end)
	return
end

function SitupBench:Toggle(on: boolean): nil
	self._remoteDispatcher:SetAttribute(self.Instance, "InUse", on)
	self._remoteDispatcher:SetShiftLockOption(not on)
	--self._ui:SetShiftLock(not on)
	self._proximityPrompt.Enabled = not on
	self._exitBench.Visible = on
	characterRoot.Anchored = on
	return
end

function SitupBench:Enter(): nil
	if self._dumbell:IsEquipped() then return end
	if self.Attributes.InUse then return end
	
	local absStrength = self._data:GetTotalStrength("Abs")
	if absStrength < self._absRequirement then return end
	
	self:Toggle(true)
	characterRoot.CFrame = self.Instance.TP.CFrame
	player.CameraMinZoomDistance = 4
	return
end

function SitupBench:Exit(): nil
	self:Toggle(false) 
	player.CameraMinZoomDistance = defaultCameraMinZoom
	return
end

function SitupBench:Situp(): nil
	if not self.Attributes.InUse then return end
	if self.Attributes.SitupDebounce then return end
	self.Attributes.SitupDebounce = true

	task.spawn(function()
		SITUP_ANIM.Ended:Once(function()
			self.Attributes.SitupDebounce = false
		end)
		SITUP_ANIM:Play()
		SITUP_ANIM:AdjustSpeed(1.75)
	end)

	local strengthMultiplier = self._data:GetTotalStrengthMultiplier(player)
	local hasVIP =  self._gamepass:DoesPlayerOwn("VIP")
	if self._benchTemplate.Vip and not hasVIP then
		return self._gamepass:PromptPurchase("VIP")
	end
	
	self._data:IncrementValue("AbsStrength", self._benchTemplate.Hit * strengthMultiplier)
	return
end

return Component.new(SitupBench)