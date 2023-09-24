--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local trim = require(ReplicatedStorage.Assets.Modules.Trim)

local CodeTemplate = require(ReplicatedStorage.Templates.CodeTemplate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local SUCCESS_STATUS_COLOR = Color3.fromRGB(55, 255, 55)
local ERROR_STATUS_COLOR = Color3.fromRGB(255, 45, 45)

local CodesScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		Ancestors = { player.PlayerGui },
		ClassName = "ScreenGui",
		Children = {
			Background = {
				ClassName = "ImageLabel",
				Children = {
					Close = { ClassName = "ImageButton" },
					Redeem = { ClassName = "ImageButton" }
				}
			}
		}
	};
}

function CodesScreen:Initialize(): nil
	self._data = Knit.GetService("DataService")
	
	local background = self.Instance.Background
	self._close = background.Close
	self._redeem = background.Redeem
	self._status = background.Status
	self._textInput = background.TextBubble.Input
	
	self._janitor:Add(self._redeem.MouseButton1Click:Connect(function()
		self:Redeem()
	end))
	return
end

function CodesScreen:Redeem(): nil
	local code = trim(self._textInput.Text:lower())
	local reward = CodeTemplate[code]
	if not reward then 
		return self:PushStatus("Invalid code provided!", true)
	end

	local redeemedCodes = Array.new("string", self._data:GetValue("RedeemedCodes"))
	if redeemedCodes:Has(code) then
		return self:PushStatus("You've already redeemed this code!", true)
	end

	for key, value in reward do
		task.spawn(function()
			self._data:IncrementValue(key, value)
		end)
	end
	
	(self :: any):PushStatus("Successfully redeemed code!")
	redeemedCodes:Push(code)
	self._data:SetValue("RedeemedCodes", redeemedCodes:ToTable())
	return
end

function CodesScreen:PushStatus(message: string, err: boolean?): nil
	if self.Attributes.StatusDebounce then return end
	self.Attributes.StatusDebounce = true
	
	self._status.Visible = true
	self._status.Text = message
	self._status.TextColor3 = if err then ERROR_STATUS_COLOR else SUCCESS_STATUS_COLOR
	
	task.delay(1,  function()
		self._status.Visible = false
		self.Attributes.StatusDebounce = false
	end)
	return
end

return Component.new(CodesScreen)