--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService.Server.Modules
local Packages = ReplicatedStorage.Packages

local ProfileService = require(Modules.ProfileService)
local AssertPlayer = require(Modules.AssertPlayer)
local abbreviate = require(ReplicatedStorage.Assets.Modules.Abbreviate)

local Knit = require(Packages.Knit)
local Array = require(Packages.Array)

local PROFILE_TEMPLATE = require(ReplicatedStorage.Templates.ProfileTemplate)

local Test = true

local DataService = Knit.CreateService {
	Name = "DataService";
	DataUpdated = Instance.new("BindableEvent");
	Client = {
		DataUpdated = Knit.CreateSignal()
	};
}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerTestData#12",
	PROFILE_TEMPLATE
)

if Test then
	ProfileStore = ProfileService.GetProfileStore(
		`TestProfile#{HttpService:GenerateGUID()}`,
		PROFILE_TEMPLATE
	)
end

local Profiles = {}

local function GetProfile(player: Player)
	AssertPlayer(player)
	local profile = Profiles[player]
	repeat task.wait(0.25) until profile
	return profile
end

local function CreateLeaderstats(player: Player): nil
	AssertPlayer(player)
	task.spawn(function()
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
	
		for name, value in pairs(PROFILE_TEMPLATE.leaderstats) do
			local stat = Instance.new("StringValue")
			stat.Name = name
			stat.Value = value
			stat.Parent = leaderstats
		end
	
		leaderstats.Parent = player
	end)
	return
end

local function CreatePetsFolder(player: Player): nil
	AssertPlayer(player)
	local PetFolder = Instance.new("Folder")
	PetFolder.Name = "PetFolder"
	PetFolder.Parent = player
	return
end

local function UpdateLeaderstats(player: Player): nil
	AssertPlayer(player)
	task.spawn(function()
		local Data = GetProfile(player).Data
		local leaderstats = player:WaitForChild("leaderstats")
	
		Data.leaderstats.Strength = Data.PunchStrength + Data.BicepsStrength + Data.AbsStrength;
		(leaderstats :: any).Strength.Value = abbreviate(Data.leaderstats.Strength);
		(leaderstats :: any).Eggs.Value = abbreviate(Data.leaderstats.Eggs);
		(leaderstats :: any).Rebirths.Value = abbreviate(Data.leaderstats.Eggs)
	end)
	return
end

function DataService:KnitStart()
	self._pets = Knit.GetService("PetService")
	
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:OnPlayerAdded(player)
		end)
	end
		
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		self:OnPlayerAdded(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		local profile = Profiles[player]
		if not profile  then return end
		profile:Release()
	end)
end

function DataService:OnPlayerAdded(player: Player): nil
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if not profile then
		return player:Kick()
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		Profiles[player] = nil
		player:Kick()
	end)

	if player:IsDescendantOf(Players) then
		Profiles[player] = profile
		CreateLeaderstats(player)
		CreatePetsFolder(player)
		UpdateLeaderstats(player)
		return self:InitializeClientUpdate(player)
	else
		return profile:Release()
	end
end

function DataService:InitializeClientUpdate(player: Player): nil
	AssertPlayer(player)
	local profile = GetProfile(player)
	task.spawn(function()
		self:DataUpdate(player, "leaderstats", profile.Data.leaderstats)
		self:DataUpdate(player, "Pets", profile.Data.Pets)
		self:DataUpdate(player, "ActiveBoosts", profile.Data.ActiveBoosts)
		self:DataUpdate(player, "Wins", profile.Data.Wins)
		self:DataUpdate(player, "PunchStrength", profile.Data.PunchStrength)
		self:DataUpdate(player, "AbsStrength", profile.Data.AbsStrength)
		self:DataUpdate(player, "BicepsStrength", profile.Data.BicepsStrength)
		self:DataUpdate(player, "ProductsLog", profile.Data.ProductsLog)
		self:DataUpdate(player, "RedeemedCodes", profile.Data.RedeemedCodes)
		self:DataUpdate(player, "Settings", profile.Data.Settings)
	end)
	return
end

function DataService:DataUpdate<T>(player: Player, key: string, value: T): nil
	self.Client.DataUpdated:Fire(player, key, value)
	self.DataUpdated:Fire(player, key, value)
	return
end

--// General Functions

local function ArePetDuplicatesFound(): boolean
	local duplicatesFound = false
	local ids = Array.new()
	
	for player, profile in Profiles do	
		local pets = Array.new(profile.Data.Pets.OwnedPets)
		for pet in pets:Values() do
			if ids:Has(pet.ID) then
				duplicatesFound = true
				player:Kick(`Exploiting | Duplicate pet ID found | Pet name: {pet.Name}`)
				break
			end
			ids:Push(pet.ID)
		end
	end

	return duplicatesFound
end

function DataService:SetValue<T>(player: Player, name: string, value: T): nil
	AssertPlayer(player)
	task.spawn(function()
		local Data = GetProfile(player).Data
		if name == "Pets" then
			if ArePetDuplicatesFound() then return end
		end

		if Data[name] ~= nil then
			Data[name] = value
		elseif Data.leaderstats[name] ~= nil then
			Data.leaderstats[name] = value
		end

		task.spawn(UpdateLeaderstats, player)
		self:DataUpdate(player, name, value)
	end)
	return
end

function DataService:IncrementValue(player: Player, name: string, amount: number): nil
	AssertPlayer(player)
	local value = self:GetValue(player, name)
	self:SetValue(player, name, value + amount)
	return
end

function DataService:GetValue(player: Player, name: string): any
	AssertPlayer(player)
	local Data = GetProfile(player).Data
	return Data[name] or Data.leaderstats[name] or Data.Pets[name]
end

function DataService:SetSetting<T>(player: Player, settingName: string, value: T): nil
	AssertPlayer(player)
	local Settings = self:GetValue(player, "Settings")
	Settings[settingName] = value
	self:SetValue(player, "Settings", Settings)
	return
end

function DataService:GetSetting(player: Player, settingName: string): any
	AssertPlayer(player)
	local Settings = self:GetValue(player, "Settings")
	return Settings[settingName]
end

function DataService:GetTotalStrength(player: Player, strengthType: "Punch" | "Abs" | "Biceps"?): number
	AssertPlayer(player)
	local initialStrength = self:GetValue(player, (strengthType or "") .. "Strength")
	local petMultiplier = self._pets:GetTotalMultiplier(player)
	return math.round(initialStrength * petMultiplier)
end

-- client
function DataService.Client:GetValue(player, name)
	return self.Server:GetValue(player, name)
end

function DataService.Client:SetValue(player, name, value)
	return self.Server:SetValue(player, name, value)
end

function DataService.Client:IncrementValue(player, name, amount)
	return self.Server:IncrementValue(player, name, amount)
end

function DataService.Client:GetSetting(player, name)
	return self.Server:GetSetting(player, name)
end

function DataService.Client:SetSetting(player, name, value)
	return self.Server:SetSetting(player, name, value)
end

function DataService.Client:GetTotalStrength(player, strengthType: "Punch" | "Abs" | "Biceps"?)
	return self.Server:GetTotalStrength(player, strengthType)
end

return DataService