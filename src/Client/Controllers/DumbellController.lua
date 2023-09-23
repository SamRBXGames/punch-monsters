--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

type Dumbell = {
	Required: number;
	Gain: number;
	IsVIP: boolean;
}

local DumbellController = Knit.CreateController {
	Name = "DumbellController";
	Equipped = false;
	EquippedDumbellTemplate = nil;
}

function DumbellController:Lift(): nil
	if not self.Equipped then return end

	return
end

function DumbellController:Equip(mapName: string, dumbell: Dumbell): nil
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