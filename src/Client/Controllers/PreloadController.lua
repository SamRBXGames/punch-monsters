--!native
--!strict
local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local toPreload = CollectionService:GetTagged("Preload")
local loaded = 0
local toLoad = #toPreload

local PreloadController = Knit.CreateController {
	Name = "PreloadController";
	ContentLoaded = Signal.new();
	FinishedLoading = Signal.new();
}

function PreloadController:KnitInit(): nil
	task.spawn(function()
		for _, asset in toPreload do
			local id
			if asset:IsA("ImageLabel") or asset:IsA("ImageButton") then
				id = asset.Image
			elseif asset:IsA("Sound") then
				id = asset.SoundId
			elseif asset:IsA("Animation") then
				id = asset.AnimationId
			elseif asset:IsA("MeshPart") or asset:IsA("FileMesh") then
				id = asset.MeshId
			end

			ContentProvider:PreloadAsync({ id }, function()
				loaded += 1
				self.ContentLoaded:Fire()
			end)
		end
		
		self.FinishedLoading:Fire()
	end)
	return
end

function PreloadController:GetLoaded(): number
	return loaded
end

function PreloadController:GetRemaining(): number
	return toLoad
end

return PreloadController