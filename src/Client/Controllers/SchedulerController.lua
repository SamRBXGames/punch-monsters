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
  local id = HttpService:GenerateGUID()
  
  task.spawn(function(): nil
    local elapsed = 0
    local interval = parseTime(timeExpression)

    Runtime:BindToRenderStep(id, Enum.RenderPriority.Camera.Value, function(dt)
      if elapsed >= interval then
        task.spawn(callback)
      else
        elapsed += dt
      end
    end)
    return
  end)

	return function(): nil
    return Runtime:UnbindFromRenderStep(id)
  end
end

return SchedulerController