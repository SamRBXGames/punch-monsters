--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Client = script:FindFirstAncestorOfClass("LocalScript")
local CameraShaker = require(Client.Modules.CameraShaker)

local abbreviate = require(ReplicatedStorage.Assets.Modules.Abbreviate)

local EnemyTemplate = require(ReplicatedStorage.Templates.EnemiesTemplate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local characterRoot = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

local cameraShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(shakeCF)
	camera.CFrame *= shakeCF
end)
cameraShaker:Start()

local PUNCH_COOLDOWN = 0.25

local EnemyFighting: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { workspace.Map1.Enemies }
	};
}

function EnemyFighting:Initialize(): nil
	self._remoteDispatcher = Knit.GetService("RemoteDispatcher")	
	self._data = Knit.GetService("DataService")
	self._gamepass = Knit.GetService("GamepassService")
	self._ui = Knit.GetController("UIController")
	
	self._proxyPart = self.Instance:WaitForChild("ProxyPart")
	self._proximityPrompt = Instance.new("ProximityPrompt")
	self._proximityPrompt.HoldDuration = 1
	self._proximityPrompt.ObjectText = "Fight"
	self._proximityPrompt.Parent = self._proxyPart
	
	self._fighting = false
	self._healthToDamageRatio = 5
	self._strengthToHealthRatio = 20
	
	self._enemyTemplate = EnemyTemplate[self.Instance.Name]
	self._enemyStrength = self._enemyTemplate.Strength
	self._enemyMaxHealth = self._enemyStrength * self._strengthToHealthRatio
	self._enemyHealth = self._enemyMaxHealth
	self._enemyDamage = self._enemyStrength / self._healthToDamageRatio
	
	self._fightUi = player.PlayerGui.FightUi
	self._janitor:Add(self._proximityPrompt.Triggered:Connect(function(player)
		self:Enter()
	end))
	
	self._janitor:Add(self._fightUi.Exit.MouseButton1Click:Connect(function()
		self:Exit()
	end))
end

local defaultSpeed = humanoid.WalkSpeed
function EnemyFighting:Toggle(on: boolean): nil
	humanoid.WalkSpeed = if on then 0 else defaultSpeed
	self._proximityPrompt.Enabled = not on
	self._remoteDispatcher:SetAttribute(self.Instance, "InUse", on)
	self._remoteDispatcher:SetShiftLockOption(not on)
end

function EnemyFighting:Enter(): nil
	if self.Instance:GetAttribute("InUse") then return end
	
	local playerStrength = self._data:GetValue("Strength")
	self._playerMaxHealth = playerStrength * self._healthToDamageRatio
	self._playerHealth = self._playerMaxHealth
	self._playerDamage = playerStrength
	
	characterRoot.CFrame = self._proxyPart.CFrame + Vector3.new(0, 2.5 * humanoid.BodyHeightScale.Value, 0)
	self:Toggle(true)
	
	task.spawn(function()
		self._fightUi.Me.ImageLabel.Image = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
	end)
	
	self._fightUi.Me.TextLabel.Text = abbreviate(playerStrength)
	self._fightUi.Enemy.TextLabel.Text = abbreviate(self._enemyStrength)
	
	local viewport = self._fightUi.Enemy.Viewport
	self._ui:AddModelToViewport(viewport, self.Instance, { replaceModel = true })
	self._ui:SetScreen("FightUi")
	
	for i = 3, 1, -1 do
		task.wait(0.75)
		self._fightUi.Countdown.Text = tostring(i)
	end
	self._fightUi.Countdown.Text = "Fight!"
	
	self:StartFight()
end

function EnemyFighting:StartFight()
	self._fighting = true
	task.spawn(function()
		repeat task.wait(0.25)
			self._playerHealth -= self._enemyDamage
			self:UpdateBar()
		until (self._playerHealth <= 0) or (self._enemyHealth <= 0)
		if self._playerHealth <= 0 then
			self:PlayerKill()
		end	
	end)
end

function EnemyFighting:Reset()
	self._ui:SetScreen("MainUi")
	self._fightUi.Countdown.Text = "3"
	self._fightUi.Me.HP.Bar.Size = UDim2.new(1, 0, 1, 0)
	self._fightUi.Enemy.HP.Bar.Size = UDim2.new(1, 0, 1, 0)
end

function EnemyFighting:Exit(): nil
	if not self.Instance:GetAttribute("InUse") then return end
	self:Toggle(false)
	self:Reset()
	self._fighting = false
end

function EnemyFighting:UpdateBar()
	local PlayerHPSize = math.clamp(self._playerHealth / self._playerMaxHealth, 0, 1)
	local EnemyHPSize = math.clamp(self._enemyHealth / self._enemyMaxHealth, 0, 1)
	
	self._fightUi.Me.HP.Bar:TweenSize(
		UDim2.fromScale(PlayerHPSize, 1),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Linear,
		0.2
	)
	self._fightUi.Enemy.HP.Bar:TweenSize(
		UDim2.fromScale(EnemyHPSize, 1),
		Enum.EasingDirection.In,
		Enum.EasingStyle.Linear,
		0.2
	)
end

function EnemyFighting:Attack(): nil
	if not self._fighting then return end
	if not self.Instance:GetAttribute("InUse") then return end
	if self.Instance:GetAttribute("PunchDebounce") then return end
	
	self.Instance:SetAttribute("PunchDebounce", true)
	task.delay(PUNCH_COOLDOWN, function()
		self.Instance:SetAttribute("PunchDebounce", false)
	end)
	
	cameraShaker:Shake(CameraShaker.Presets.Rock)
	
	self._enemyHealth -= self._playerDamage
	self:UpdateBar()
	if self._enemyHealth <= 0 then
		self:Kill()
	end
end

function EnemyFighting:AddWin()
	local hasWinsBoost = self._gamepass:DoesPlayerOwn("2x Wins")
	local multiplier = if hasWinsBoost then 2 else 1

	self._data:IncrementValue("Wins", self._enemyTemplate.Wins * multiplier)
end

function EnemyFighting:PlayerKill()
	self._fighting = false
	self._fightUi.Countdown.Text = `{self.Instance.Name} has won!`
	task.wait(2)
	self:Exit()
end

function EnemyFighting:Kill()
	self._fighting = false
	self._fightUi.Countdown.Text = "You won!"
	self:AddWin()
	task.wait(2)
	self:Exit()
end

return Component.new(EnemyFighting)