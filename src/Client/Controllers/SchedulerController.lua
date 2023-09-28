--!native
--!strict
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Runtime = game:GetService("RunService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local parseTime = require(ReplicatedStorage.Modules.ParseTime)

local SchedulerController = Knit.CreateController {
	Name = "SchedulerController";
}

function SchedulerController:Every(timeExpression: string, callback: () -> ()): () -> ()
  local elapsed = 0
  local interval = parseTime(timeExpression)
  local id = HttpService:GenerateGUID()

  Runtime:BindToRenderStep(id, Enum.RenderPriority.Camera, function(dt)
    if elapsed >= interval then
      callback()
    else
      elapsed += dt
    end
  end)

	return function(): nil
    return Runtime:UnbindFromRenderStep(id)
  end
end

return SchedulerController