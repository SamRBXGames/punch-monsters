--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Debounce = require(ReplicatedStorage.Modules.Debounce)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)
local Component = require(Packages.Component)

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
	self._trades = Knit.GetService("TradeService")
	
  local playerContainer = self.Instance.Background.Players
  self._playerFrameTemplate = ReplicatedStorage.Assets.UserInterface.Trading.Player
	self:AddToJanitor(Players.PlayerAdded:Connect(function(newPlayer: Player): nil
    self:AddPlayerCard(newPlayer)
		return
	end))
  self:AddToJanitor(Players.PlayerRemoving:Connect(function(leavingPlayer: Player): nil
    if leavingPlayer == player then return end
		local playerFrame = Array.new("Instance", playerContainer:GetChildren())
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

	local db = Debounce.new(5)
	local playerFrame = self._playerFrameTemplate:Clone()
	playerFrame.Name = tostring(newPlayer.UserId)
	playerFrame.NameLabel.Text = newPlayer.DisplayName
	playerFrame.Send.MouseButton1Click:Connect(function(): nil
		if db:IsActive() then return end
		self._trades:Send(player)
		return
	end)
	return
end

return Component.new(SendTradeScreen)