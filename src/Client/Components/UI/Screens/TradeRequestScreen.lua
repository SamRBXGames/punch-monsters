
--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local TradeRequestScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui:WaitForChild("MainUi") },
		Name = "TradeRequest",
		ClassName = "ImageLabel",
		Children = {
			Accept = { ClassName = "ImageButton" },
      Decline = { ClassName = "ImageButton" },
      Description = { ClassName = "TextLabel" }
		}
	};
}

function TradeRequestScreen:Initialize(): nil
	self._trades = Knit.GetService("TradeService")
  self._ui = Knit.GetController("UIController")
	
  self._fromPlayer = nil :: Player?
  self:AddToJanitor(self._trades.TradeReceived:Connect(function(sender: Player): nil
    if player == sender then return end
    self.Instance.Description.Text = `{sender.DisplayName} sent you a trade request!`
    self.Instance.Visible = true
    self._fromPlayer = sender
    return
  end))
  self:AddToJanitor(self._trades.TradeAccepted:Connect(function(sender: Player, tradeID: string): nil
    if player == sender then return end
    local tradeScreen = self._ui:SetScreen("Trading", true)
    tradeScreen:SetAttribute("ID", tradeID)
    tradeScreen:SetAttribute("RecipientName", self._fromPlayer.Name)
    self._fromPlayer = nil
    return
  end))
  self:AddToJanitor(self.Instance.Accept.MouseButton1Click:Connect(function(): nil
    if not self._fromPlayer then return end
    self.Instance.Visible = false
    self._ui:SetScreen("Trading", true)
    self._trades:Accept(self._fromPlayer)
    return
  end))
  self:AddToJanitor(self.Instance.Decline.MouseButton1Click:Connect(function(): nil
    self.Instance.Visible = false
    return
  end))

	return
end

return Component.new(TradeRequestScreen)