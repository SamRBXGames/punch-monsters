--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local AnimationService = Knit.CreateService {
  Name = "AnimationService";
  Client = {
    SoundPlayed = Knit.CreateSignal()
  };
}

local PLAYER_TRACK_CACHE: { [number]: { [string]: AnimationTrack } } = {}
local ANIMATION_CACHE = {}
function AnimationService:KnitInit(): nil
	Players.PlayerAdded:Connect(function(player): nil
    PLAYER_TRACK_CACHE[player.UserId] = {}
    return
  end)
  Players.PlayerRemoving:Connect(function(player): nil
    PLAYER_TRACK_CACHE[player.UserId] = nil
    return
  end)
  return
end

function AnimationService:Play(player: Player, animationName: string, speed: number?): nil
  if not ANIMATION_CACHE[animationName] then
    ANIMATION_CACHE[animationName] = ReplicatedStorage.Assets.Animations:FindFirstChild(animationName)
  end

  local animation = ANIMATION_CACHE[animationName]
  if not PLAYER_TRACK_CACHE[player.UserId][animationName] then
    PLAYER_TRACK_CACHE[player.UserId][animationName] = (player.Character :: any).Humanoid.Animator:LoadAnimation(animation)
  end

	local track = PLAYER_TRACK_CACHE[player.UserId][animationName]
  track:Play()
  if speed then
    track:AdjustSpeed(speed)
  end
  
  return
end

function AnimationService.Client:Play(player: Player, animation: Animation, speed: number?): nil
  return self.Server:Play(player, animation, speed)
end

return AnimationService