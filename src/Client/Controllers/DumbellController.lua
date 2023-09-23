--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local LIFT_COOLDOWN = 0.5

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
	self._gamepass = Knit.GetService("GamepassService")
	self._pets = Knit.GetService("PetService")
	return
end

function DumbellController:Lift(): nil
	if not self.Equipped then return end
	if self.LiftDebounce then return end

	 self.LiftDebounce = true
	task.delay(LIFT_COOLDOWN, function()
		self.LiftDebounce = false
	end)

	local hasVIP = self._gamepass:DoesPlayerOwn("VIP")
	local hasStrengthBoost = self._gamepass:DoesPlayerOwn("2x Strength")
	local bicepsMultiplier = (if hasStrengthBoost then 2 else 1) * self._pets:GetTotalMultiplier()
	if self.EquippedDumbellTemplate.IsVIP and not hasVIP then
		return self._gamepass:PromptPurchase("VIP")
	end
	
	self._data:IncrementValue("BicepsStrength", self.EquippedDumbellTemplate.Gain * bicepsMultiplier)
	return
end

function DumbellController:Equip(mapName: string, dumbell: Dumbell): nil
	local bicepsStrength = self._data:GetValue("BicepsStrength")
	if dumbell.Required > bicepsStrength then return end

	self.Equipped = true
	self.EquippedDumbellTemplate = dumbell
	return
end

function DumbellController:Unequip(): nil
	self.Equipped = false
	self.EquippedDumbellTemplate = nil
	return
end

return DumbellController