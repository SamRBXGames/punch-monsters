--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SoundService = Knit.CreateService {
  Name = "SoundService";
  Client = {
    SoundPlayed = Knit.CreateSignal()
  };
}

function SoundService:PlayFor(player: Player, soundName: string): nil
	self.Client.SoundPlayed:Fire(player, soundName)
  return
end

return SoundService