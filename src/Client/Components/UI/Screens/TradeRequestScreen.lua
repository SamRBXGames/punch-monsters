
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
		Ancestors = { player.PlayerGui },
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
  self:AddToJanitor(self._trades.TradeAccepted:Connect(function(): nil
    self._ui:SetScreen("Trading", true)
    return
  end))
  self:AddToJanitor(self.Instance.Accept:Connect(function()
    self.Instance.Visible = false
    self._ui:SetScreen("Trading", true)
    self._trades:Accept(self._fromPlayer)
  end))
  self:AddToJanitor(self.Instance.Decline:Connect(function()
    self.Instance.Visible = false
  end))

	return
end

return Component.new(TradeRequestScreen)