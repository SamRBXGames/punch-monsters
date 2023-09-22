local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

local Client = script:FindFirstAncestorOfClass("LocalScript")
local Packages = ReplicatedStorage.Packages
local Functions = Client.Functions
local CodeTemplate = require(ReplicatedStorage.Templates.CodeTemplate)

local trim = require(ReplicatedStorage.Assets.Modules.trim)
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)
local Array = require(Packages.Array)

local player = Players.LocalPlayer

local SUCCESS_STATUS_COLOR = Color3.fromRGB(55, 255, 55)
local ERROR_STATUS_COLOR = Color3.fromRGB(255, 45, 45)

local CodesScreen = Component.new({
	Tag = script.Name,
	Ancestors = {player.PlayerGui}
})

function CodesScreen:Start(): nil
	Knit.GetController("ComponentController"):Register(self)
	self._data = Knit.GetService("DataService")
	
	self._janitor =  Janitor.new()
	self._janitor:Add(self.Instance)
	
	local background = self.Instance.Background
	self._close = background.Close
	self._redeem = background.Redeem
	self._status = background.Status
	self._textInput = background.TextBubble.Input
	
	self._janitor:Add(self._redeem.MouseButton1Click:Connect(function()
		self:Redeem()
	end))
end

function CodesScreen:Redeem(): nil
	local code = trim(self._textInput.Text:lower())
	local reward = CodeTemplate[code]
	if not reward then 
		return self:PushStatus("Invalid code provided!", true)
	end

	local redeemedCodes = Array.new(self._data:GetValue("RedeemedCodes"))
	if redeemedCodes:Has(code) then
		return self:PushStatus("You've already redeemed this code!", true)
	end

	for key, value in reward do
		task.spawn(function()
			self._data:IncrementValue(key, value)
		end)
	end
	
	self:PushStatus("Successfully redeemed code!")
	redeemedCodes:Push(code)
	self._data:SetValue("RedeemedCodes", redeemedCodes:ToTable())
end

function CodesScreen:PushStatus(message: string, err: boolean?): nil
	if self.Instance:GetAttribute("StatusDebounce") then return end
	self.Instance:SetAttribute("StatusDebounce", true)
	
	self._status.Visible = true
	self._status.Text = message
	self._status.TextColor3 = if err then ERROR_STATUS_COLOR else SUCCESS_STATUS_COLOR
	
	task.delay(1,  function()
		self._status.Visible = false
		self.Instance:SetAttribute("StatusDebounce", false)
	end)
end

function CodesScreen:Destroy(): nil
	self._janitor:Destroy()
end

return CodesScreen