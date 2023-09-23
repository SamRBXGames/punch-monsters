local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tween = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local PetsTemplate = require(ReplicatedStorage.Templates.PetsTemplate)
local Packages = ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets

local Knit = require(Packages.Knit)
local Janitor = require(Packages.Janitor)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

type Pet = typeof(PetsTemplate.Dog) & { Name: string }
local InventoryScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		ClassName = "ScreenGui",
		Ancestors = { player.PlayerGui },
		Children = {
			Background = {
				ClassName = "ImageLabel",
				Children = {
					Pets = { ClassName = "ScrollingFrame" },
					Stats = { ClassName = "ImageLabel" }
				}
			}
		}
	};
}

function InventoryScreen:Initialize(): nil
	self._data = Knit.GetService("DataService")
	self._pets = Knit.GetService("PetService")
	self._ui = Knit.GetController("UIController")
	
	local background: ImageLabel & { Pets: ScrollingFrame; Stats: ImageLabel } = self.Instance.Background
	self._background = background
	self._container = background.Pets
	self._petStats = background.Stats
	self._petStats.Visible = false
	
	self._updateJanitor = Janitor.new()
	self._janitor:Add(self._data.DataUpdated:Connect(function(key)
		if key ~= "Pets" then return end
		self:UpdatePetCards()
	end))
	return
end

function InventoryScreen:ToggleSelectionFrame(on: boolean): nil
	local backgroundPosition = self._background:GetAttribute(if on then "OpenedPosition" else "ClosedPosition")
	local statsPosition = self._petStats:GetAttribute(if on then "OpenedPosition" else "ClosedPosition")
	local info = TweenInfo.new(0.3, Enum.EasingStyle.Quad)
	
	if on then
		self._petStats.Visible = true
	end
	
	Tween:Create(self._background, info, {
		Position = backgroundPosition
	}):Play()
	local t = Tween:Create(self._petStats, info, {
		Position = statsPosition
	})

	t.Completed:Once(function()
		self._petStats.Visible = on
	end)
	t:Play()
	return
end

local lastPetSelected
local selectionJanitor = Janitor.new()
local function toggleButton(button: ImageButton & { Title: TextLabel & { UIGradient: UIGradient } }, on: boolean): nil
	task.spawn(function()
		button.Image = button:GetAttribute(if on then "OnImage" else "OffImage")
		button.Title.UIGradient.Color = button:GetAttribute(if on then "OnColor" else "OffColor")
		button.Title.Text = if on then "Equip" else "Unequip"
	end)
	return
end

function InventoryScreen:SelectPet(pet: Pet): nil
	selectionJanitor:Cleanup()
	if lastPetSelected == pet then
		lastPetSelected = nil
		return self:ToggleSelectionFrame(false)
	end
	lastPetSelected = pet
	
	local isEquipped = self._pets:IsEquipped(pet)
	toggleButton(self._petStats.Equip, not isEquipped)
	
	task.spawn(function(): nil
		self._petStats.PetName.Text = pet.Name
		self._petStats.Rarity.Text = pet.Rarity
		self._petStats.Strength.Text = `{pet.StrengthMultiplier}x`
		
		local petModel = Assets.Pets:FindFirstChild(pet.Name)
		if not petModel then
			return warn(`Could not find pet model "{pet.Name}"`)
		end
		
		self._ui:AddModelToViewport(self._petStats.Viewport, petModel, { replaceModel = true })
		return self:ToggleSelectionFrame(true)
	end)
	
	selectionJanitor:Add(self._petStats.Equip.MouseButton1Click:Connect(function()
		local isEquipped = self._pets:IsEquipped(pet)
		toggleButton(self._petStats.Equip, isEquipped)
		
		if isEquipped then
			self._pets:Unequip(pet)
		else
			self._pets:Equip(pet)
		end
	end))
	selectionJanitor:Add(self._petStats.Lock.MouseButton1Click:Connect(function()

	end))
	return
end

function InventoryScreen:UpdatePetCards(): nil
	-- cleanup old cards & their connections
	self._updateJanitor:Cleanup()
	
	local pets: { [string]: Pet } = self._data:GetValue("OwnedPets")
	for _, pet in pets do
		task.spawn(function()
			local card: ImageButton & { Viewport: ViewportFrame; StrengthMultiplier: TextLabel } = Assets.UserInterface.Inventory.PetCard:Clone()
			card.StrengthMultiplier.Text = `{pet.StrengthMultiplier}x`
			card.Parent = self._container
			
			local Viewport = Component.Get("Viewport")
			Viewport:Add(card.Viewport)
			self._ui:AddModelToViewport(card.Viewport, Assets.Pets[pet.Name])
			self._updateJanitor:Add(card)
			self._updateJanitor:Add(card.MouseButton1Click:Connect(function()
				self:SelectPet(pet)
			end))
		end)
	end
	return
end

return Component.new(InventoryScreen)