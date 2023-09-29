
--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

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
	
  local background = self.Instance.Background
  self:AddToJanitor(background.Decline.MouseButton1Click:Connect(function(): nil
    self._ui:SetScreen("MainUi", false)
    return
  end))
  self:AddToJanitor(background.Accept.MouseButton1Click:Connect(function(): nil
    -- exchange pets
    self._ui:SetScreen("MainUi", false)
    return
  end))

	return
end

return Component.new(TradingScreen)