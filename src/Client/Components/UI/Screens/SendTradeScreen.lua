--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Array = require(Packages.Array)

local player = Players.LocalPlayer

local SendTradeScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui },
		Name = "TradeSend",
		ClassName = "ScreenGui",
		Children = {
			Background = {
				ClassName = "ImageLabel",
				Children = {
					Close = { ClassName = "ImageButton" },
					Players = { ClassName = "ScrollingFrame" }
				}
			}
		}
	};
}

function SendTradeScreen:Initialize(): nil
	self._data = Knit.GetService("DataService")
	
  self._playerFrameTemplate = ReplicatedStorage.Assets.UserInterface.Trading.Player
  local playerContainer = self.Instance.Background.Players
	self:AddToJanitor(Players.PlayerAdded:Connect(function(newPlayer: Player): nil
    self:AddPlayerCard(newPlayer)
	end))
  self:AddToJanitor(Players.PlayerRemoving:Connect(function(leavingPlayer: Player): nil
    if leavingPlayer == player then return end
		local playerFrame = Array.new(playerContainer:GetChildren())
      :Find(function(playerFrame)
        return playerFrame.Name == tostring(leavingPlayer.UserId)
      end)

    if playerFrame then
      playerFrame:Destroy()
    end
    return
	end))
  
	for _, newPlayer in pairs(Players:GetPlayers()) do
		self:AddPlayerCard(newPlayer)
	end

	return
end

function SendTradeScreen:AddPlayerCard(newPlayer: Player): nil
	if newPlayer == player then return end

	local playerFrame = self._playerFrameTemplate:Clone()
	playerFrame.Name = tostring(newPlayer.UserId)
	playerFrame.NameLabel.Text = newPlayer.DisplayName
	playerFrame.Send.MouseButton1Click:Connect(function(): nil
		-- send a trade to `player`
		return
	end)
	return
end

return Component.new(SendTradeScreen)