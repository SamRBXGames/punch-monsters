--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local AssertPlayer = require(ServerScriptService.Server.Modules.AssertPlayer)
local trim = require(ReplicatedStorage.Assets.Modules.trim)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)

local NAME_TO_ID_CACHE: { [string]: number } = {}

local GamepassService = Knit.CreateService {
	Name = "GamepassService"
}

local apiEndpoint = `https://games.roproxy.com/v1/games/{game.GameId}/game-passes?limit=25`
local PASS_CACHE

type Gamepass = {
	name: string;
	id: number;
}

local function getAllPasses(): { Gamepass }
	if PASS_CACHE then
		return PASS_CACHE
	end
	
	local res = HttpService:JSONDecode(HttpService:GetAsync(apiEndpoint, true))
	if res.errors then
		local err = table.unpack(res.errors)
		return error(`Failed to fetch gamepass info:  {err.userFacingMessage} - {err.message}`)
	end
	
	PASS_CACHE = res.data
	return PASS_CACHE
end

local function getPassIDByName(name: string): number?
	if NAME_TO_ID_CACHE[name] then
		return NAME_TO_ID_CACHE[name]
	end
	
	local pass: Gamepass? = Array.new("table", getAllPasses())
		:Find(function(pass: Gamepass)
			return trim(pass.name) == trim(name)
		end)
	
	if not pass then return end
	NAME_TO_ID_CACHE[name] = pass.id
	return pass.id
end

function GamepassService:DoesPlayerOwn(player: Player, passName: string): boolean
	AssertPlayer(player)
	local id = getPassIDByName(passName)
	assert(id, `Failed to find gamepass ID for {passName}`)
	return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
end

function GamepassService:PromptPurchase(player: Player, passName: string): nil
	AssertPlayer(player)
	task.spawn(function()
		local id = getPassIDByName(passName)
		assert(id, `Failed to find gamepass ID for {passName}`)
		MarketplaceService:PromptGamePassPurchase(player, id)
	end)
	return
end

function GamepassService.Client:DoesPlayerOwn(player: Player, passName: string): boolean
	return self.Server:DoesPlayerOwn(player, passName)
end

function GamepassService.Client:PromptPurchase(player: Player, passName: string): nil
	return self.Server:PromptPurchase(player, passName)
end

return GamepassService