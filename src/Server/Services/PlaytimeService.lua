--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlaytimeService = Knit.CreateService {
	Name = "PlaytimeService";
}

function PlaytimeService:KnitStart(): nil
	self._quests = Knit.GetService("QuestService")
	return
end

function PlaytimeService:KnitInit(): nil
	self._playersJoinedAt = {}

	Players.PlayerAdded:Connect(function(player: Player): nil
		self._playersJoinedAt[player.UserId] = tick()
		return
	end)
	Players.PlayerRemoving:Connect(function(player: Player): nil
		self._playersJoinedAt[player.UserId] = nil
		return
	end)

	return
end

function PlaytimeService:Get(player: Player): number
	local joinedAt = self._playersJoinedAt[player.UserId]
	if not joinedAt then
		joinedAt = tick()
		self._playersJoinedAt[player.UserId] = joinedAt
	end

	local playtime = math.round(tick() - joinedAt)
	self._quests:SetProgress(player, "StayActive", playtime)
	return playtime
end

function PlaytimeService.Client:Get(player: Player): number
	return self.Server:Get(player)
end

return PlaytimeService