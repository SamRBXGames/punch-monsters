--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Marketplace = game:GetService("MarketplaceService")
local Sound = game:GetService("SoundService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local SoundController = Knit.CreateController {
	Name = "SoundController";
}

function SoundController:KnitInit(): nil
  local SoundService = Knit.GetService("SoundService")
  
  SoundService.SoundPlayed:Connect(function(soundName: string): nil
    assert(soundName)
    Sound.Master[soundName]:Play()
    return
  end)
  Marketplace.PromptGamePassPurchaseFinished:Connect(function(player, _, wasPurchased): nil
    if player ~= Players.LocalPlayer then return end
    if not wasPurchased then return end
    Sound.Master.RobuxPurchase:Play()
    return
  end)
  Marketplace.PromptProductPurchaseFinished:Connect(function(player, _, wasPurchased): nil
    if player ~= Players.LocalPlayer then return end
    if not wasPurchased then return end
    Sound.Master.RobuxPurchase:Play()
    return
  end)
  return
end

return SoundController