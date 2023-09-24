--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local DumbellsTemplate = require(ReplicatedStorage.Templates.DumbellsTemplate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local DumbellsScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui },
		ClassName = "ScreenGui",
		Attributes = {
			MapName = { Type = "string" }
		},
		Children = {
			Map1 = {
				ClassName = "ImageLabel",
				Children = {
					Close = { ClassName = "ImageButton" },
					Title = { ClassName = "ImageLabel" }
				}
			},
			Map2 = {
				ClassName = "ImageLabel",
				Children = {
					Close = { ClassName = "ImageButton" },
					Title = { ClassName = "ImageLabel" }
				}
			},
			Map3 = {
				ClassName = "ImageLabel",
				Children = {
					Close = { ClassName = "ImageButton" },
					Title = { ClassName = "ImageLabel" }
				}
			}
		}
	};
}

function DumbellsScreen:Initialize(): nil
	local Dumbell = Knit.GetController("DumbellController")
	local cards = Array.new("Instance", self.Instance.Map1:GetChildren())
		:Combine(Array.new("Instance", self.Instance.Map2:GetChildren()))
		:Combine(Array.new("Instance", self.Instance.Map3:GetChildren()))
		:Filter(function(element: Instance): boolean
			return element:IsA("ImageLabel") and element.Name ~= "Title"
		end)

	for card: ImageLabel & { ImageButton: ImageButton & { TextLabel: TextLabel } } in cards:Values() do
		task.spawn(function()
			local equipButton = card.ImageButton
			self:AddToJanitor(equipButton.MouseButton1Click:Connect(function()
				local mapName: string = self.Attributes.MapName
				local mapDumbells = DumbellsTemplate[mapName]
				local cardNumber = tonumber(card.Name) :: number
				local template = mapDumbells[cardNumber]
				template.IsVIP = cardNumber == 15

				if Dumbell.Equipped and Dumbell.EquippedDumbellTemplate ~= template then return end
				if Dumbell.Equipped then
					Dumbell:Unequip()
				else
					Dumbell:Equip(mapName, template)
				end
				equipButton.TextLabel.Text = if Dumbell.Equipped then "Unequip" else "Equip"
				equipButton.ImageColor3 = if Dumbell.Equipped then Color3.fromRGB(255, 46, 46) else Color3.fromRGB(255, 255, 255)
			end))
		end)
	end

	return
end

return Component.new(DumbellsScreen)