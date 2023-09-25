--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local EggTemplate = require(ReplicatedStorage.Templates.EggTemplate)
local PetsTemplate = require(ReplicatedStorage.Templates.PetsTemplate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)
local Component = require(Packages.Component)

local UserInterface = ReplicatedStorage.Assets.UserInterface
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local characterRoot = character:WaitForChild("HumanoidRootPart")

local MAX_STAND_DISTANCE = 8

local HatchingStand: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { workspace.Map1.Eggs }, --workspace.Map2.Eggs, workspace.Map3.Eggs
		ClassName = "Model",
		Children = {
			Egg = {
				ClassName = "Model",
				PrimaryPart = function(primary)
					return primary ~= nil
				end
			}
		}
	};
}

function HatchingStand:Initialize(): nil
	self._data = Knit.GetService("DataService")
	self._pets = Knit.GetService("PetService")
	self._boosts = Knit.GetService("BoostService")
	self._gamepass = Knit.GetService("GamepassService")
	self._dumbell = Knit.GetService("DumbellService")
	self._ui = Knit.GetController("UIController")
	self._hatching = false
	
	local eggUi = player.PlayerGui.EggUi
	self._eggViewport = eggUi.EggViewport
	self._egg = self.Instance.Egg
	self._map = self.Instance.Parent.Parent.Name
	self._eggTemplate = EggTemplate[self._map][self.Instance.Name]
	
	self:AddPetCards()
	return
end

local function createPet(petName: string): typeof(PetsTemplate.Dog)
	local pet = PetsTemplate[petName]
	return {
		Name = petName,
		ID = HttpService:GenerateGUID(),
		Rarity = pet.Rarity,
		StrengthMultiplier = pet.StrengthMultiplier
	}
end

function HatchingStand:ReturnPet(): typeof(PetsTemplate.Dog)?
	local has2xLuck = self._gamepass:DoesPlayerOwn("2x Luck")
	local has10xLuck = self._gamepass:DoesPlayerOwn("10x Luck")
	local has100xLuck = self._gamepass:DoesPlayerOwn("100x Luck")
	local has10xLuckBoost = self._boosts:IsBoostActive("10xLuck")
	local has100xLuckBoost = self._boosts:IsBoostActive("100xLuck")
	local luckMultiplier = 0
	
	if has2xLuck then
		luckMultiplier += 2
	end
	if has10xLuck then
		luckMultiplier += 10
	end
	if has100xLuck then
		luckMultiplier += 100
	end
	if has10xLuckBoost then
		luckMultiplier += 10
	end
	if has100xLuckBoost then
		luckMultiplier += 100
	end
	
	local totalProbability = 0
	local cumulativeProbabilities = {}
	for petName, probability in self._eggTemplate.Chances do
		totalProbability += probability * luckMultiplier
		cumulativeProbabilities[petName] = totalProbability
	end
	
	local random = Random.new():NextNumber() * totalProbability
	for petName, cumulativeProbability in cumulativeProbabilities do
		if random <= cumulativeProbability then
			return createPet(petName)
		end
	end
	
	for petName in self._eggTemplate.Chances do
		return createPet(petName)
	end

	return
end

function HatchingStand:Hatch(): nil
	if self._dumbell:IsEquipped() then return end
	if self._hatching then return end
	self._hatching = true
	
	local pet = self:ReturnPet()
	if not pet then
		self._hatching = false
		return warn("No pet returned from HatchingStand")
	end
	
	local petModel = ReplicatedStorage.Assets.Pets:FindFirstChild(pet.Name)
	if not petModel then
		self._hatching = false
		return warn(`Could not find pet model "{pet.Model}"`)
	end
	
	self._pets:Add(pet)
	self._eggViewport:SetAttribute("FitModel", false)
	self._eggViewport:SetAttribute("FOV", nil :: any)
	self._eggViewport:SetAttribute("ModelRotation", 0 :: any)
	self._ui:AddModelToViewport(self._eggViewport, self._egg, { replaceModel = true })
	self._ui:SetScreen("EggUi", true)

	task.delay(2.5, function()
		self._eggViewport:SetAttribute("FitModel", true)
		self._eggViewport:SetAttribute("FOV", 15 :: any)
		self._eggViewport:SetAttribute("ModelRotation", -120 :: any)
		self._ui:AddModelToViewport(self._eggViewport, petModel, { replaceModel = true })

		task.wait(2.5)
		self._ui:SetScreen("MainUi", false)
	end)
	
	local cost = self._eggTemplate.WinsCost
	if self._eggTemplate.Robux and not cost then
		print("devproduct here")
	end
	
	self._data:IncrementValue("Eggs")
	self._hatching = false
	self._chancesUI.Enabled = true
	return
end

function HatchingStand:BuyOne(): nil
	if not self:IsClosest() then return end
	self:Hatch()
	return
end

function HatchingStand:BuyThree(): nil
	if not self:IsClosest() then return end
	
	for _ = 1, 3 do
		task.spawn(function()
			self:Hatch()
		end)
	end
	return
end

function HatchingStand:Auto(): nil
	if not self:IsClosest() then return end
	-- do stuff
	return
end

local function getDistanceFromPlayer(stand: Model & { Egg: Model }): number
	local primaryPart = stand.Egg.PrimaryPart
	return if primaryPart then (primaryPart.Position - characterRoot.Position).Magnitude else 1000
end

function HatchingStand:IsClosest(): boolean
	local closestStand= Array.new("Instance", CollectionService:GetTagged(self.Name))
		:Filter(function(stand)
			local distance = getDistanceFromPlayer(stand)
			return distance <= MAX_STAND_DISTANCE
		end)
		:Sort(function(a, b)
			local distanceA = getDistanceFromPlayer(a)
			local distanceB = getDistanceFromPlayer(b)
			return distanceA < distanceB
		end)
		:First()
		
	return closestStand == self.Instance
end

function HatchingStand:AddPetCards(): nil
	self._chancesUI = UserInterface.Hatching.HatchingUi:Clone()
	self._chancesUI.Enabled = true
	
	local container: Frame = self._chancesUI.Background.PetChances
	task.spawn(function()
		local pets = Array.new("table")
		type ChanceTable = {
			Name: string;
			Chance: number;
		}

		local chances: { [string]: number } = self._eggTemplate.Chances
		for pet, chance in pairs(chances) do
			pets:Push({
				Name = pet, 
				Chance = chance
			})
		end
		
		pets:SortMutable(function(a: ChanceTable, b: ChanceTable)
			return a.Chance > b.Chance
		end)
		
		for pet in pets:Values() do
			self._chancesUI.Enabled = true
			local petModel: Model? = ReplicatedStorage.Assets.Pets:FindFirstChild(pet.Name)		
			local petCard: ImageLabel & { Viewport: ViewportFrame; Chance: TextLabel } = UserInterface.Hatching.PetChanceCard:Clone()
			local viewport = petCard.Viewport
			petCard.Chance.Text = `{pet.Chance}%`
			petCard.Parent = container
			
			local Viewport = Component.Get("Viewport")
			Viewport:Add(viewport)
			self._ui:AddModelToViewport(viewport, petModel)
			self:AddToJanitor(petCard)
		end
	end)
	
	self._chancesUI.Adornee = self._egg.PrimaryPart
	self._chancesUI.Parent = player.PlayerGui
	self._chancesUI.Enabled = true
	return
end

return Component.new(HatchingStand)