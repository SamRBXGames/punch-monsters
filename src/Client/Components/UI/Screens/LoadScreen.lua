local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tween = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Client = script:FindFirstAncestorOfClass("LocalScript")
local Packages = ReplicatedStorage.Packages
local Functions = Client.Functions

local Knit = require(Packages.Knit)
local Array = require(Packages.Array)
local Component = require(Packages.Component)
local Tweens = require(Functions.Tweens)

local player = Players.LocalPlayer

local LoadScreen: Component.Def = {
	Name = script.Name;
	IgnoreAncestors = { StarterGui };
	Guards = {
		ClassName = "ScreenGui",
		Ancestors = { player.PlayerGui }
	};
}


function LoadScreen:Initialize(): nil
	self._preloader = Knit.GetController("PreloadController")
	self._finished = false
	self._imageOffset = 0
	
	local playerGui = self.Instance:FindFirstAncestorOfClass("PlayerGui")
	self._mainUI = playerGui.MainUi
	
	local background = self.Instance.Background
	self._background = background
	self._bar = background.LoadingBar
	self._gloves = background.Gloves
	self._transition = self.Instance.Transition
	self:Activate()
end

function LoadScreen:Update(): nil
	self._imageOffset %= 800
	self._imageOffset += 1	
	local increment = if self._imageOffset < 400 then 1 else -1 
	self._gloves.Position += UDim2.fromOffset(increment, -increment)
end

function LoadScreen:Activate(): nil
	self._mainUI.Enabled = false
	self.Instance.Enabled = true
	self:UpdateProgressBar(0)
	self:AnimateBar()
	
	self._bar.Title.Text = "Loading decals, sounds, meshes..."
	task.delay(1, function()
		self._bar.Skip.Visible = true
	end)

	self._janitor:Add(self._bar.Skip.MouseButton1Click:Connect(function()
		self._preloader.FinishedLoading:Fire()
	end))

	self._janitor:Add(self._preloader.ContentLoaded:Connect(function()
		self:UpdateProgressBar(self._preloader:GetLoaded() / self._preloader:GetRemaining())
	end))

	self._preloader.FinishedLoading:Wait()
	local fadeIn = Tween:Create(
		self._transition,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{BackgroundTransparency = 0}
	)

	fadeIn:Play()
	fadeIn.Completed:Wait()
	self._background.Visible = false
	local fadeOut = Tween:Create(
		self._transition,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.5),
		{BackgroundTransparency = 1}
	)

	self._finished = true
	self._mainUI.Enabled = true
	player:SetAttribute("Loaded", true)

	fadeOut:Play()
	fadeOut.Completed:Wait()
	self:Destroy()
end

function LoadScreen:UpdateProgressBar(progress: number): nil
	self._bar.Title.Text = `Loading\n{math.round(progress * 100)}%`
	self._bar.Progress:TweenSize(
		UDim2.fromScale(math.max(progress, 0.05), 1),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Linear,
		0.35, true
	)
end

function LoadScreen:AnimateBar(): nil
	local tweens = Array.new("Instance")
	tweens:Push(
		Tweens.moveFromPosition(self._bar,
			self._bar.Position - UDim2.fromScale(0, 1),
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		)
	)

	for tween in tweens:Values() do
		tween:Play()
		tween.Completed:Wait()
	end
end

return Component.new(LoadScreen)