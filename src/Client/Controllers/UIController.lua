--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local player = Players.LocalPlayer

local UIController = Knit.CreateController {
	Name = "UIController";
}

function UIController:KnitStart(): nil
	self._blur = Knit.GetController("BlurController")
	task.delay(2.5, function()
		Knit.GetService("RemoteDispatcher"):InitializeClientUpdate()
	end)
	return
end

function UIController:KnitInit(): nil
	task.spawn(function()
		repeat 
			local success = pcall(function() 
				StarterGui:SetCore("ResetButtonCallback", false) 
			end)
			task.wait(1)
		until success
	end)
	return
end

function UIController:SetScreen(name: string, blur: boolean?): ScreenGui?
	if blur ~= nil then
		self._blur:Toggle(blur)
	end

	local setScreen: ScreenGui
	for _, screen in player:WaitForChild("PlayerGui"):GetChildren() do
		local on = screen.Name == name
		task.spawn(function()
			screen.Enabled = on
		end)
		if on then
			setScreen = screen
		end
	end
	
	return setScreen
end

--local PlayerModule = player.PlayerScripts:WaitForChild("PlayerModule")
--local Cameras = require(PlayerModule):GetCameras()
--local CameraController = Cameras.activeCameraController
--local MouseLockController = Cameras.activeMouseLockController
function UIController:SetShiftLock(on: boolean): nil
	--MouseLockController:OnMouseLockToggled()
	--CameraController:SetIsMouseLocked(on)
	return
end

function UIController:AddModelToViewport(viewport: ViewportFrame, modelTemplate: Model, options: { replaceModel: boolean? }?): nil
	task.spawn(function()
		if not modelTemplate then error("Missing viewport model template") end
		
		local replaceModel = if options then options.replaceModel else false
		if viewport:FindFirstChild("model") and not replaceModel then
			return warn(`Attempt to add model to viewport already containing a model. Viewport location: {viewport:GetFullName()}`)
		end
		
		if replaceModel and viewport:FindFirstChild("model") then
			(viewport :: any).model:Destroy()
		end
		
		local model: Model = modelTemplate:Clone()
		model.Name = "model"
		model.Parent = viewport
		
		local camera = viewport:WaitForChild("Camera") :: Camera
		local modelCFrame = CFrame.lookAt(Vector3.zero, camera.CFrame.Position)
		local fitModel = viewport:GetAttribute("FitModel")
		if fitModel then
			local cf, size = model:GetBoundingBox()
			modelCFrame *= CFrame.new(0, cf.Position.Y / 2, 0)
			camera.FieldOfView = viewport:GetAttribute("DefaultFOV") + size.Magnitude ^ 1.55
		end

		local modelRotation = viewport:GetAttribute("ModelRotation")
		if modelRotation then
			modelCFrame *= CFrame.Angles(0, math.rad(modelRotation or 0), 0)
		end

		model:PivotTo(modelCFrame)
	end)
	return
end

return UIController