--!native
--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = Players.LocalPlayer

local InputController = Knit.CreateController {
	Name = "InputController";
}

local function forEachComponent(componentName: string, actionName: string): nil
	task.spawn(function(): nil
		local componentManager = Component.Get(componentName)
		local components = componentManager.OwnedComponents:Filter(function(component: Component.Component)
			return component.Name == componentName
		end)
	
		for component in components:Values() do
			local action = component[actionName]
			task.spawn(action, component)
		end
		return
	end)
	return
end

local InputTypeMap = {
	MouseButton1 = function(): nil
		forEachComponent("PunchingBag", "Punch")
		forEachComponent("SitupBench", "Situp")
		forEachComponent("EnemyFighting", "Attack")

		task.spawn(function()
			local dumbell = Knit.GetService("DumbellService")
			dumbell:Lift()
		end)
		return
	end
}

local KeyboardInputMap = {
	E = function(): nil
		forEachComponent("HatchingStand", "BuyOne")
		return
	end,
	R = function(): nil
		forEachComponent("HatchingStand", "BuyThree")
		return
	end,
	T = function(): nil
		forEachComponent("HatchingStand", "Auto")
		return
	end
}

function InputController:KnitStart(): nil
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if not player:GetAttribute("Loaded") then return end
		self:ExecuteAction(input, "UserInputType")
		self:ExecuteAction(input, "KeyCode")
	end)
	return
end

function InputController:ExecuteAction(input: InputObject, type: "UserInputType" | "KeyCode"): nil
	task.spawn(function()
		local actionMap = if type == "KeyCode" then KeyboardInputMap else InputTypeMap
		for inputType in pairs(actionMap) do
			if (Enum :: any)[type][inputType] then continue end
			warn(`Listening for input on invalid {if type == "KeyCode" then "keycode" else "input type"}: {inputType}`)
		end
		
		local actionName: string = (input :: any)[type].Name
		local action: () -> ()? = (actionMap :: any)[actionName]
		if not action then return end
		task.spawn(action)
	end)
	return
end

return InputController