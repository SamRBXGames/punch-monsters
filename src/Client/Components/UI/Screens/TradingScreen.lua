
--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local VerifyID = require(ReplicatedStorage.Modules.VerifyID)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local TradingScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui },
		Name = "Trading",
		ClassName = "ScreenGui",
		Children = {
			Background = {
        ClassName = "ImageLabel",
        Children = {
          Accept = { ClassName = "ImageButton" },
          Decline = { ClassName = "ImageButton" },
          Me = {
            ClassName = "ImageLabel",
            Children = {
              Container = { ClassName = "Frame" }
            }
          },
          Other = {
            ClassName = "ImageLabel",
            Children = {
              Container = { ClassName = "Frame" }
            }
          }
        }
      }
		}
	};
}

function TradingScreen:Initialize(): nil
	self._trades = Knit.GetService("TradeService")
  self._ui = Knit.GetController("UIController")

  

  local function completeTrade(): nil
    local tradeID = self.Attributes.ID
    VerifyID(player, tradeID)

    local recipientName = self.Attributes.RecipientName
    assert(typeof(recipientName) == "string")
    local recipient = Players:FindFirstChild(recipientName)
    if not recipient then return end
    return self._trades:Complete(tradeID, recipient)
  end
	
  local background = self.Instance.Background
  self:AddToJanitor(background.Decline.MouseButton1Click:Connect(function(): nil
    return completeTrade()
  end))
  self:AddToJanitor(background.Accept.MouseButton1Click:Connect(function(): nil
    -- exchange pets
    return completeTrade()
  end))
  self:AddToJanitor(self._trades.TradeCompleted:Connect(function(plr: Player, id: string): nil
    if player ~= plr then return end

    local tradeID = self.Attributes.ID
    if tradeID ~= id then return end
    VerifyID(player, tradeID)
    VerifyID(player, id)

    self.Attributes.ID = nil
    self.Attributes.RecipientName = nil
    self._ui:SetScreen("MainUi", false)
    return
  end))

	return
end

function TradingScreen:PropertyChanged_Enabled(): nil
  if not self.Instance.Enabled then return end
  -- reset stuff
  return
end

return Component.new(TradingScreen)