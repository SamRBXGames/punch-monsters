--!native
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService.Server.Modules
local VerifyID = require(Modules.VerifyID)
local AssertPlayer = require(Modules.AssertPlayer)

local PetsTemplate = require(ReplicatedStorage.Templates.PetsTemplate)
local Welder = require(ReplicatedStorage.Modules.Welder)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Janitor = require(Packages.Janitor)
local Array = require(Packages.Array)
local ProfileTemplate = require(ReplicatedStorage.Templates.ProfileTemplate)

local FOLLOW_SPEED = 15
local Y_OFFSET = 0
local PET_POSITIONS = Array.new("Vector3", {
	Vector3.new(2, Y_OFFSET, 3),
	Vector3.new(-4, Y_OFFSET, 6),
	Vector3.new(6, Y_OFFSET, 10),
	Vector3.new(-7, Y_OFFSET, 12),
	Vector3.new(10, Y_OFFSET, 15),
	Vector3.new(-10, Y_OFFSET, 15)
})

local PetService = Knit.CreateService {
	Name = "PetService";
	Client = {};
}

local lastEquippedPlayerPets: { [number]: boolean } = {}
local playersLastOwnVisible: { [number]: boolean } = {}
local playersLastOthersVisible: { [number]: boolean } = {}

function PetService:KnitStart()
	self._data = Knit.GetService("DataService")
	self._gamepass = Knit.GetService("GamepassService")
	
	self._data.DataUpdated.Event:Connect(function(player, key, value)
		if key == "Pets" then
			local lastEquippedPets = lastEquippedPlayerPets[player.UserId]
			if not lastEquippedPets then
				lastEquippedPets = {} :: any
				lastEquippedPlayerPets[player.UserId] = lastEquippedPets
			end
			
			local pets = value
			if lastEquippedPets == pets.Equipped then return end
			self:UpdateFollowingPets(player, pets.Equipped)
			lastEquippedPlayerPets[player.UserId] = pets.Equipped
		elseif key == "Settings" then
			task.spawn(function()
				local lastOwnVisible = playersLastOwnVisible[player.UserId]
				local settings: typeof(ProfileTemplate.Settings) = value
				if lastOwnVisible == settings.ShowOwnPets then return end

				self:ToggleVisibility(player, settings.ShowOwnPets)
				playersLastOwnVisible[player.UserId] = settings.ShowOwnPets
			end)
			task.spawn(function()
				local lastOthersVisible = playersLastOthersVisible[player.UserId]
				local settings: typeof(ProfileTemplate.Settings) = value

				if lastOthersVisible == settings.ShowOtherPets then return end
				for _, otherPlayer in pairs(Players:GetPlayers()) do
					if otherPlayer == player then continue end
					self:ToggleVisibility(otherPlayer, settings.ShowOtherPets)
				end

				playersLastOthersVisible[player.UserId] = settings.ShowOtherPets
			end)
		end
	end)
end

function PetService:ToggleVisibility(player: Player, on: boolean): nil
	task.spawn(function()
		local char = player.Character :: Model
		local petsFolder = char:FindFirstChild("Pets")
		if not petsFolder then return end

		for _, pet in pairs(petsFolder:GetChildren()) do
			task.spawn(function()
				for _, part in pairs(pet:GetChildren()) do
					task.spawn(function()
						if not part:IsA("BasePart") then return end
						part.Transparency = if on then 0 else 1
					end)
				end
			end)
		end
	end)
	return
end

function PetService:Find(player: Player, id: string): typeof(PetsTemplate.Dog)?
	AssertPlayer(player)
	VerifyID(player, id)

	local pets = self._data:GetValue(player, "Pets")
	return Array.new("table", pets.OwnedPets)
		:Find(function(pet)
			return pet.ID == id
		end)
end

function PetService:Add(player: Player, pet: typeof(PetsTemplate.Dog)): nil
	AssertPlayer(player)
	VerifyID(player, pet.ID)
	task.spawn(function()
		local pets = self._data:GetValue(player, "Pets")
		local ownedPets = pets.OwnedPets
		table.insert(ownedPets, pet)

		pets.OwnedPets = ownedPets
		self._data:SetValue(player, "Pets", pets)
	end)
	return
end

function PetService:GetPetSpace(player: Player): number
	AssertPlayer(player)
	
	local petSpace = 4
	if self._gamepass:DoesPlayerOwn(player, "+2 Pets Equipped") then
		petSpace += 2
	end
	if self._gamepass:DoesPlayerOwn(player, "+4 Pets Equipped") then
		petSpace += 4
	end
	return petSpace
end

function PetService:Equip(player: Player, pet: typeof(PetsTemplate.Dog)): nil
	task.spawn(function()
		AssertPlayer(player)
		VerifyID(player, pet.ID)

		local petSpace = self:GetPetSpace(player)
		local pets = self._data:GetValue(player, "Pets")
		local equippedPets = pets.Equipped
		if #equippedPets == petSpace then return end

		table.insert(equippedPets, pet)
		pets.Equipped = equippedPets
		self._data:SetValue(player, "Pets", pets)

		local visible = self._data:GetSetting(player, "ShowOwnPets")
		self:ToggleVisibility(player, visible)
	end)
	return
end

function PetService:Unequip(player: Player, pet: typeof(PetsTemplate.Dog)): nil
	task.spawn(function()
		AssertPlayer(player)
		VerifyID(player, pet.ID)

		local pets = self._data:GetValue(player, "Pets")
		local equippedPets = Array.new("table", pets.Equipped)
		equippedPets:RemoveValue(pet)
		pets.Equipped = equippedPets:ToTable()
		self._data:SetValue(player, "Pets", pets)
	end)
	return
end

function PetService:IsEquipped(player: Player, pet: typeof(PetsTemplate.Dog)): boolean
	AssertPlayer(player)
	VerifyID(player, pet.ID)

	local pets = self._data:GetValue(player, "Pets")
	return Array.new("table", pets.Equipped)
		:Map(function(pet)
			return pet.ID
		end)
		:Has(pet.ID)
end

function PetService:GetTotalMultiplier(player: Player): number
	AssertPlayer(player)
	local pets = self._data:GetValue(player, "Pets")

	return Array.new("table", pets.Equipped)
		:Map(function(pet)
			return pet.StrengthMultiplier
		end)
		:Reduce(function(total: number, mult: number)
			return total + mult
		end, 1)
end

function PetService:GetPetOrder(player: Player): number?
	AssertPlayer(player)
	
	local character = player.Character or player.CharacterAdded:Wait()
	local petFolder = character:WaitForChild("Pets") :: Folder
	if #petFolder:GetChildren() == 0 then
		return 1
	end

	local activeSlots = {}
	for _, pet in petFolder:GetChildren() do
		local order = pet:GetAttribute("Order")
		activeSlots[order] = order
	end

	local petSpace = self:GetPetSpace(player)
	for availableSlot = 1, petSpace do
		if not activeSlots[availableSlot] then
			return availableSlot
		end
	end
	
	return
end

function PetService:StartFollowing(player: Player, pet: Model): nil
	AssertPlayer(player)
	task.spawn(function()
		local janitor = Janitor.new()
		janitor:LinkToInstance(pet, true)

		local character = player.Character or player.CharacterAdded:Wait()
		local petFolder = character:FindFirstChild("Pets") :: Folder?
		if not petFolder then
			petFolder = Instance.new("Folder", player.Character);
			(petFolder :: any).Name = "Pets"
		end

		local primaryPart = character.PrimaryPart :: Part
		pet:PivotTo(primaryPart.CFrame)
		local characterAttachment = Instance.new("Attachment", primaryPart)
		local petAttachment = Instance.new("Attachment", pet.PrimaryPart)
		janitor:Add(characterAttachment)
		janitor:Add(petAttachment)

		local positionAligner = Instance.new("AlignPosition")
		positionAligner.MaxForce = 25_000
		positionAligner.Attachment0 = petAttachment
		positionAligner.Attachment1 = characterAttachment
		positionAligner.Responsiveness = FOLLOW_SPEED
		positionAligner.Parent = pet.PrimaryPart
		janitor:Add(positionAligner)

		local orientationAligner = Instance.new("AlignOrientation")
		orientationAligner.MaxTorque = 25_000
		orientationAligner.Attachment0 = petAttachment
		orientationAligner.Attachment1 = characterAttachment
		orientationAligner.Responsiveness = FOLLOW_SPEED
		orientationAligner.Parent = pet.PrimaryPart
		janitor:Add(positionAligner)

		local order = self:GetPetOrder(player)
		pet:SetAttribute("Order", order)

		local position = PET_POSITIONS[order]
		characterAttachment.Position = position
		characterAttachment.Orientation = Vector3.new(0, -90, 0)
		
		local petParts = Array.new("Instance", pet:GetChildren())
			:Filter(function(e)
				return e:IsA("BasePart")
			end)
		
		for part: BasePart in petParts:Values() do
			part.Anchored = false
			part.CanCollide = false
			if part == pet.PrimaryPart then continue end
			Welder.Weld(pet.PrimaryPart, { part })
		end
		
		pet.Parent = petFolder
		if not pet.PrimaryPart then return end
		pet.PrimaryPart:SetNetworkOwner(player)
	end)
	return
end

local petJanitors: { [number]: typeof(Janitor.new()) } = {}
function PetService:UpdateFollowingPets(player: Player, pets: { typeof(PetsTemplate.Dog) & { Name: string } }): nil
	AssertPlayer(player)
	
	local petsJanitor = petJanitors[player.UserId]
	if not petsJanitor then
		petsJanitor = Janitor.new()
		petJanitors[player.UserId] = petsJanitor
	end
	petsJanitor:Cleanup()

	local visible = self._data:GetSetting(player, "ShowOwnPets")
	self:ToggleVisibility(player, visible)

	for _, pet in pets do
		task.spawn(function(): nil
			local petModelTemplate = ReplicatedStorage.Assets.Pets:FindFirstChild(pet.Name)
			if not petModelTemplate then
				return warn(`Could not find pet model "{pet.Name}"`)
			end

			local petModel = petModelTemplate:Clone()
			petsJanitor:Add(petModel)
			return self:StartFollowing(player, petModel)
		end)
	end
	return
end

function PetService.Client:Add(player, pet)
	return self.Server:Add(player, pet)
end

function PetService.Client:Equip(player, pet)
	return self.Server:Equip(player, pet)
end

function PetService.Client:Unequip(player, pet)
	return self.Server:Unequip(player, pet)
end

function PetService.Client:IsEquipped(player, pet)
	return self.Server:IsEquipped(player, pet)
end

function PetService.Client:GetPetSpace(player)
	return self.Server:GetPetSpace(player)
end

function PetService.Client:GetTotalMultiplier(player)
	return self.Server:GetTotalMultiplier(player)
end

return PetService