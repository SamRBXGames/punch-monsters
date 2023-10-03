--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Sound = game:GetService("SoundService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local CameraShaker = require(script.Parent.Parent.Parent.Modules.CameraShaker)

local PunchBagsTemplate = require(ReplicatedStorage.Templates.PunchBagsTemplate)

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Array = require(Packages.Array)
local Component = require(Packages.Component)

local camera = workspace.CurrentCamera

local cameraShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(shakeCF)
	camera.CFrame *= shakeCF
end)
cameraShaker:Start()

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local characterRoot = character:WaitForChild("HumanoidRootPart")
local animator = character.Humanoid:WaitForChild("Animator") :: Animator
local animations = ReplicatedStorage.Assets.Animations

local JAB1_ANIM = animator:LoadAnimation(animations.Jab)
local JAB2_ANIM = animator:LoadAnimation(animations.Jab2)
local MAX_BAG_DISTANCE = 6

local PunchingBag: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { workspace.Map1.PunchingBags, workspace.Map2.PunchingBags, workspace.Map3.PunchingBags },
		ClassName = "Model",
		Attributes = {
			PunchDebounce = { Type = "boolean" }
		},
		Children = {
			Cylinder = { ClassName = "MeshPart" }
		}
	};
}

function PunchingBag:Initialize(): nil	
	self._data = Knit.GetService("DataService")
	self._gamepass = Knit.GetService("GamepassService")
	self._dumbell = Knit.GetService("DumbellService")
	local scheduler = Knit.GetController("SchedulerController")
	local destroyAutoTrainClicker

	local function startAutoTrain(): nil
		if destroyAutoTrainClicker then
			self._janitor:RemoveNoClean("AutoTrain")
			destroyAutoTrainClicker()
		end
		destroyAutoTrainClicker = scheduler:Every("0.5 seconds", function()
			self:Punch()
		end)
		self:AddToJanitor(destroyAutoTrainClicker, true, "AutoTrain")
		return
	end

	self:AddToJanitor(self._data.DataUpdated:Connect(function(key, on: boolean): nil
		if key ~= "AutoTrain" then return end
		if not on then
			if destroyAutoTrainClicker then
				self._janitor:RemoveNoClean("AutoTrain")
				destroyAutoTrainClicker()
			end
			return
		end
		startAutoTrain()
		return
	end))

	self._jab1 = false
	return
end

local function getDistanceFromPlayer(bag: Model & { Cylinder: MeshPart }): number
	return (bag.Cylinder.Position - characterRoot.Position).Magnitude
end

function PunchingBag:IsClosest(): boolean
	local closestBag = Array.new("Instance", CollectionService:GetTagged(self.Name))
		:Filter(function(bag)
			local distance = getDistanceFromPlayer(bag)
			return distance <= MAX_BAG_DISTANCE
		end)
		:Sort(function(a, b)
			local distanceA = getDistanceFromPlayer(a)
			local distanceB = getDistanceFromPlayer(b)
			return distanceA < distanceB
		end)
		:First()

	return closestBag == self.Instance
end

function PunchingBag:Punch(): nil
	if self.Attributes.PunchDebounce then return end
	if self._dumbell:IsEquipped() then return end
	
	local isClosestBag = self:IsClosest()
	if not isClosestBag then return end
	
	local mapName = self.Instance.Parent.Parent.Name
	local bagTemplate = PunchBagsTemplate[mapName][self.Instance.Name]
	local punchStrength = self._data:GetTotalStrength("Punch")
	if punchStrength < bagTemplate.PunchRequirement then return end
	self.Attributes.PunchDebounce = true
	

	task.spawn(function()
		local punchAnim = if self._jab1 then JAB1_ANIM else JAB2_ANIM
		punchAnim.Ended:Once(function()
			self.Attributes.PunchDebounce = false
		end)
		punchAnim:Play()
		punchAnim:AdjustSpeed(1.5)
		self._jab1 = not self._jab1
	end)

	local strengthMultiplier = self._data:GetTotalStrengthMultiplier(player)
	local hasVIP =  self._gamepass:DoesPlayerOwn("VIP")
	if bagTemplate.Vip and not hasVIP then
		return self._gamepass:PromptPurchase("VIP")
	end
	
	Sound.Master.Punch:Play()
	task.spawn(function()
		cameraShaker:Shake(CameraShaker.Presets.Rock)
		local vfx = PunchBagsTemplate[mapName].VFX:Clone()
		vfx.Parent = self.Instance.Cylinder
		Debris:AddItem(vfx, 0.5)
	end)

	self._data:IncrementValue("PunchStrength", bagTemplate.Hit * strengthMultiplier)
	return
end

return Component.new(PunchingBag)