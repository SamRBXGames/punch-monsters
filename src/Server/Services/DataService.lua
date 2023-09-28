--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService.Server.Modules
local Packages = ReplicatedStorage.Packages

local AssertPlayer = require(Modules.AssertPlayer)
local abbreviate = require(ReplicatedStorage.Assets.Modules.Abbreviate)

local Knit = require(Packages.Knit)
local Promise = require(Packages.Promise)
local Array = require(Packages.Array)
local ProfileService = require(Packages.ProfileService)

local PROFILE_TEMPLATE = require(ReplicatedStorage.Templates.ProfileTemplate)

type Promise = typeof(Promise.new())

local Test = RunService:IsStudio()
-- local Test = false

local DataService = Knit.CreateService {
	Name = "DataService";
	DataUpdated = Instance.new("BindableEvent");
	Client = {
		DataUpdated = Knit.CreateSignal()
	};
}

local ProfileStore = ProfileService.GetProfileStore(
	"PlayerTestData#14",
	PROFILE_TEMPLATE
)

if Test then
	ProfileStore = ProfileService.GetProfileStore(
		`TestProfile#{HttpService:GenerateGUID()}`,
		PROFILE_TEMPLATE
	)
end

local PROFILE_CACHE = {}

local function GetProfile(player: Player)
	AssertPlayer(player)
	local profile = PROFILE_CACHE[player]
	if not profile then
		warn(`Waiting for {player}'s profile...`)
	end
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
	task.spawn(function()
		local PetFolder = Instance.new("Folder")
		PetFolder.Name = "PetFolder"
		PetFolder.Parent = player
	end)
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
		(leaderstats :: any).Rebirths.Value = abbreviate(Data.leaderstats.Rebirths)
	end)
	return
end

function DataService:KnitStart()
	self._pets = Knit.GetService("PetService")
	self._boosts = Knit.GetService("BoostService")
	self._gamepass = Knit.GetService("GamepassService")
		
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)
		self:OnPlayerAdded(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		local profile = PROFILE_CACHE[player]
		if not profile  then return end
		profile:Release()
	end)

	for _, player in Players:GetPlayers() do
		self:OnPlayerAdded(player):await()
	end
end

function DataService:OnPlayerAdded(player: Player): nil
	AssertPlayer(player)
	
	local profile = ProfileStore:LoadProfileAsync(`Player_{player.UserId}`)
	if not profile then
		return player:Kick()
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		PROFILE_CACHE[player] = nil
		player:Kick()
	end)

	if player:IsDescendantOf(Players) then
		PROFILE_CACHE[player] = profile
		CreateLeaderstats(player)
		CreatePetsFolder(player)
		UpdateLeaderstats(player)
		self:InitializeClientUpdate(player)
	else
		profile:Release()
	end

	return
end

function DataService:InitializeClientUpdate(player: Player): nil
	AssertPlayer(player)
	task.spawn(function(): nil
		local profile = GetProfile(player)
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
		self:DataUpdate(player, "Timers", profile.Data.Timers)
		self:DataUpdate(player, "ClaimedRewardsToday", profile.Data.ClaimedRewardsToday)
		self:DataUpdate(player, "FirstJoinToday", profile.Data.FirstJoinToday)
		self:DataUpdate(player, "AutoTrain", profile.Data.AutoTrain)
		self:DataUpdate(player, "AutoFight", profile.Data.AutoFight)
		return
	end)
	return
end

function DataService:DataUpdate<T>(player: Player, key: string, value: T): nil
	task.spawn(function(): nil
		self.Client.DataUpdated:Fire(player, key, value)
		return
	end)
	task.spawn(function(): nil
		self.DataUpdated:Fire(player, key, value)
		return
	end)
	return
end

--// General Functions

local function PetDuplicatesWereFound(): boolean
	local duplicatesFound = false
	local ids = Array.new("string")
	
	for player, profile in pairs(PROFILE_CACHE) do	
		local pets = Array.new("table", profile.Data.Pets.OwnedPets)
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

function DataService:SetValue<T>(player: Player, name: string, value: T): Promise
	AssertPlayer(player)
	return Promise.new(function(resolve, reject): nil
		local data = GetProfile(player).Data
		if name == "Pets" then
			if PetDuplicatesWereFound() then return end
		end

		if data[name] ~= nil then
			data[name] = value
		elseif data.leaderstats[name] ~= nil then
			data.leaderstats[name] = value
		else
			return reject(`Could not find key "{name}" in profile while setting {player.DisplayName}'s data.`)
		end

		UpdateLeaderstats(player)
		self:DataUpdate(player, name, value)
		return resolve()
	end)
end

function DataService:IncrementValue(player: Player, name: string, amount: number): Promise
	AssertPlayer(player)
	return Promise.new(function(resolve): nil
		local value = self:GetValue(player, name)
		self:SetValue(player, name, value + (amount or 1)):await()
		return resolve()
	end)
end

function DataService:GetValue<T>(player: Player, name: string): T
	AssertPlayer(player)
	local data = GetProfile(player).Data
	local value = data[name]
	return if value == nil then data.leaderstats[name] else value
end

function DataService:SetSetting<T>(player: Player, settingName: string, value: T): Promise
	AssertPlayer(player)
	return Promise.new(function(resolve): nil
		local settings = self:GetValue(player, "Settings")
		settings[settingName] = value
		self:SetValue(player, "Settings", settings)
		return resolve()
	end)
end

function DataService:GetSetting<T>(player: Player, settingName: string): T
	AssertPlayer(player)
	local settings = self:GetValue(player, "Settings")
	return settings[settingName]
end

function DataService:GetTotalStrength(player: Player, strengthType: "Punch" | "Abs" | "Biceps"?): number
	AssertPlayer(player)
	local initialStrength = self:GetValue(player, (strengthType or "") .. "Strength")
	return math.round(initialStrength * self:GetTotalStrengthMultiplier(player))
end

function DataService:GetTotalStrengthMultiplier(player: Player): number
	AssertPlayer(player)
	local petMultiplier = self._pets:GetTotalMultiplier(player)
	local rebirthMultiplier = self._rebirths:GetBoost(player, "Strength") / 100
	local gamepassMultiplier = if self._gamepass:DoesPlayerOwn(player, "2x Strength") then 2 else 1
	local boostMultiplier = if self._boosts:IsBoostActive(player, "2xStrength") then 2 else 1
	return petMultiplier * rebirthMultiplier * gamepassMultiplier * boostMultiplier
end

function DataService:AddDefeatedBoss(player: Player, bossMap: string): nil
	local defeatedBosses = self:GetValue(player, "DefeatedBosses")
	table.insert(defeatedBosses, bossMap)
	self:SetValue(player, "DefeatedBosses", defeatedBosses)
	return
end

-- client
function DataService.Client:GetValue(player, name)
	return self.Server:GetValue(player, name)
end

function DataService.Client:SetValue(player, name, value): Promise
	return self.Server:SetValue(player, name, value)
end

function DataService.Client:IncrementValue(player, name, amount): Promise
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

function DataService.Client:GetTotalStrengthMultiplier(player)
	return self.Server:GetTotalStrengthMultiplier(player)
end

function DataService.Client:AddDefeatedBoss(player: Player, bossMap: string): nil
	return self.Server:AddDefeatedBoss(player, bossMap)
end

return DataService