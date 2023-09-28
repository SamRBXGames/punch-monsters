--!native
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Welder = require(ReplicatedStorage.Modules.Welder)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local AssertPlayer = require(script.Parent.Parent.Modules.AssertPlayer)

type Dumbell = {
	Required: number;
	Gain: number;
	IsVIP: boolean;
}

type DumbellInfo = {
	Equipped: boolean;
	LiftDebounce: boolean;
	EquippedDumbellTemplate: Dumbell?;
}

local DumbellService = Knit.CreateService {
	Name = "DumbellService";
}

function DumbellService:KnitStart(): nil
	self._data = Knit.GetService("DataService")
	self._gamepass = Knit.GetService("GamepassService")
	self._playerDumbellInfo = {}

	self._liftAnimations = {}
	Players.PlayerAdded:Connect(function(player)
		if not self._playerDumbellInfo[player.UserId] then
			self._playerDumbellInfo[player.UserId] = {
				Equipped = false,
				LiftDebounce = false,
				EquippedDumbellTemplate = nil
			}
		end

		player.CharacterAppearanceLoaded:Connect(function(character)
			workspace:WaitForChild(character.Name)
			local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator") :: Animator
			local animations = ReplicatedStorage.Assets.Animations
			self._liftAnimations[player.UserId] = animator:LoadAnimation(animations.Lift)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self._liftAnimations[player.UserId] = nil
	end)

	return
end

function DumbellService:Lift(player: Player): nil
	AssertPlayer(player)

	local dumbellInfo = self._playerDumbellInfo[player.UserId]
	if not dumbellInfo.Equipped then return end
	if dumbellInfo.LiftDebounce then return end
	dumbellInfo.LiftDebounce = true
	self._playerDumbellInfo[player.UserId] = dumbellInfo

	local liftAnim = self._liftAnimations[player.UserId]
	liftAnim.Ended:Once(function()
		dumbellInfo.LiftDebounce = false
		self._playerDumbellInfo[player.UserId] = dumbellInfo
	end)
	liftAnim:Play()

	
	local strengthMultiplier = self._data:GetTotalStrengthMultiplier(player)
	local hasVIP = self._gamepass:DoesPlayerOwn(player, "VIP")
	if dumbellInfo.EquippedDumbellTemplate.IsVIP and not hasVIP then
		return self._gamepass:PromptPurchase(player, "VIP")
	end
	
	self._data:IncrementValue(player, "BicepsStrength", dumbellInfo.EquippedDumbellTemplate.Gain * strengthMultiplier)
	return
end

function DumbellService:Equip(player: Player, mapName: string, number: number, dumbell: Dumbell): nil
	AssertPlayer(player)

	local dumbellInfo = self._playerDumbellInfo[player.UserId]
	if dumbellInfo.EquippedDumbellTemplate == dumbell then return end
	if dumbellInfo.Equipped then return end

	local bicepsStrength = self._data:GetValue(player, "BicepsStrength")
	if dumbell.Required > bicepsStrength then return end

	task.spawn(function()
		local character = player.Character :: any
		local hand = character.RightHand
		local mesh = workspace[mapName].DumbellRack[tostring(number)]:Clone()
		mesh.Name = "Dumbell"
		Welder.WeldConstraint(hand, { mesh })
		mesh.CFrame = CFrame.new(hand.Position, -character.PrimaryPart.CFrame.RightVector)
		mesh.Anchored = false
		mesh.CanCollide = false
		mesh.Parent = character
	end)
	
	dumbellInfo.Equipped = true
	dumbellInfo.EquippedDumbellTemplate = dumbell
	self._playerDumbellInfo[player.UserId] = dumbellInfo
	return
end

function DumbellService:Unequip(player: Player): nil
	AssertPlayer(player)

	local dumbellInfo = self._playerDumbellInfo[player.UserId]
	if not dumbellInfo.Equipped then return end
	dumbellInfo.Equipped = false
	dumbellInfo.EquippedDumbellTemplate = nil
	self._playerDumbellInfo[player.UserId] = dumbellInfo

	task.spawn(function()
		local character = player.Character :: any
		if character:FindFirstChild("Dumbell") then
			character.Dumbell:Destroy()
		end
	end)
	return
end

function DumbellService.Client:Lift(player: Player): nil
	return self.Server:Lift(player)
end

function DumbellService.Client:Equip(player: Player, mapName: string, number: number, dumbell: Dumbell): nil
	return self.Server:Equip(player, mapName, number, dumbell)
end

function DumbellService.Client:Unequip(player: Player): nil
	return self.Server:Unequip(player)
end

function DumbellService.Client:IsEquipped(player: Player): boolean
	return self.Server._playerDumbellInfo[player.UserId].Equipped
end

return DumbellService