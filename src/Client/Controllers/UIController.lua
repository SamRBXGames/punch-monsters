local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local player = Players.LocalPlayer

local UIController = Knit.CreateController {
	Name = "UIController";
}

function UIController:KnitInit()
	task.spawn(function()
		repeat 
			local success = pcall(function() 
				StarterGui:SetCore("ResetButtonCallback", false) 
			end)
			task.wait(1)
		until success
	end)
end

function UIController:SetScreen(name: string, blur: boolean?): nil
	if blur ~= nil then
		TweenService:Create(game.Lighting:WaitForChild("Blur"), TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Size = if blur then 24 else 0,
		}):Play()
	end
	for _, screen in player:WaitForChild("PlayerGui"):GetChildren() do
		task.spawn(function()
			screen.Enabled = screen.Name == name
		end)
	end
end

--local PlayerModule = player.PlayerScripts:WaitForChild("PlayerModule")
--local Cameras = require(PlayerModule):GetCameras()
--local CameraController = Cameras.activeCameraController
--local MouseLockController = Cameras.activeMouseLockController
function UIController:SetShiftLock(on: boolean): nil
	--MouseLockController:OnMouseLockToggled()
	--CameraController:SetIsMouseLocked(on)
end

function UIController:AddModelToViewport(viewport: ViewportFrame, modelTemplate: Model, options: { replaceModel: boolean? }?): nil
	if not modelTemplate then error("Missing viewport model template") end
	
	local replaceModel = if options then options.replaceModel else false
	if viewport:FindFirstChild("model") and not replaceModel then
		return warn(`Attempt to add model to viewport already containing a model. Viewport location: {viewport:GetFullName()}`)
	end
	
	task.spawn(function()
		if replaceModel and viewport:FindFirstChild("model") then
			viewport:FindFirstChild("model"):Destroy()
		end
		
		local model: Model = modelTemplate:Clone()
		model.Name = "model"
		model.Parent = viewport
		
		local camera = viewport:WaitForChild("Camera")
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
end

return UIController