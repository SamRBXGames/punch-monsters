--!native
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Welder = require(ReplicatedStorage.Modules.Welder)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator") :: Animator
local animations = ReplicatedStorage.Assets.Animations

local LIFT_ANIM = animator:LoadAnimation(animations.Lift)

type Dumbell = {
	Required: number;
	Gain: number;
	IsVIP: boolean;
}

local DumbellController = Knit.CreateController {
	Name = "DumbellController";
	Equipped = false;
	LiftDebounce = false;
	EquippedDumbellTemplate = nil;
}

function DumbellController:KnitStart(): nil
	self._data = Knit.GetService("DataService")
	self._pets = Knit.GetService("PetService")
	self._boosts = Knit.GetService("BoostService")
	self._gamepass = Knit.GetService("GamepassService")
	return
end

function DumbellController:Lift(): nil
	if not self.Equipped then return end
	if self.LiftDebounce then return end
	self.LiftDebounce = true

	LIFT_ANIM.Ended:Once(function()
		self.LiftDebounce = false
	end)
	LIFT_ANIM:Play()

	local hasVIP = self._gamepass:DoesPlayerOwn("VIP")
	local hasDoubleStrength = self._gamepass:DoesPlayerOwn("2x Strength")
	local hasStrengthBoost = self._boosts:IsBoostActive("2xStrength")
	local bicepsMultiplier = (if hasDoubleStrength then 2 else 1)
		* (if hasStrengthBoost then 2 else 1)
		* self._pets:GetTotalMultiplier()

	if self.EquippedDumbellTemplate.IsVIP and not hasVIP then
		return self._gamepass:PromptPurchase("VIP")
	end
	
	self._data:IncrementValue("BicepsStrength", self.EquippedDumbellTemplate.Gain * bicepsMultiplier)
	return
end

function DumbellController:Equip(mapName: string, number: number, dumbell: Dumbell): nil
	local bicepsStrength = self._data:GetValue("BicepsStrength")
	if dumbell.Required > bicepsStrength then return end

	local hand = character.RightHand
	local mesh = workspace[mapName].DumbellRack[tostring(number)]:Clone()
	mesh.Name = "Dumbell"
	mesh.CFrame = CFrame.new(hand.Position, character.PrimaryPart.CFrame.LookVector)
	Welder.Weld(hand, { mesh })
	mesh.Anchored = false
	mesh.CanCollide = false
	mesh.Parent = character

	self.Equipped = true
	self.EquippedDumbellTemplate = dumbell
	return
end

function DumbellController:Unequip(): nil
	self.Equipped = false
	self.EquippedDumbellTemplate = nil
	if character:FindFirstChild("Dumbell") then
		character.Dumbell:Destroy()
	end
	return
end

return DumbellController