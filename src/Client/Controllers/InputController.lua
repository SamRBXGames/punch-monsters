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

local COMPONENT_CLASS_CACHE = {}
local COMPONENT_INSTANCES_CACHE = {}

local function forEachComponent(componentName: string, actionName: string): nil
	task.spawn(function(): nil
		local componentManager
		if COMPONENT_CLASS_CACHE[componentName] then
			componentManager = COMPONENT_CLASS_CACHE[componentName]
		else
			componentManager = Component.Get(componentName)
			COMPONENT_CLASS_CACHE[componentName] = componentManager
		end

		local components
		if COMPONENT_INSTANCES_CACHE[componentName] then
			components = COMPONENT_INSTANCES_CACHE[componentName]
		else
			components = componentManager.OwnedComponents:Filter(function(component: Component.Component)
				return component.Name == componentName
			end)
			COMPONENT_INSTANCES_CACHE[componentName] = components
		end
	
		for component in components:Values() do
			local action = component[actionName]
			task.spawn(action, component)
		end
		return
	end)
	return
end

local function liftDumbell(): nil
	local dumbell = Knit.GetService("DumbellService")
	dumbell:Lift()
	return
end

local InputTypeMap = {
	MouseButton1 = function(): nil
		forEachComponent("PunchingBag", "Punch")
		forEachComponent("SitupBench", "Situp")
		forEachComponent("EnemyFighting", "Attack")
		task.spawn(liftDumbell)
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
	local data = Knit.GetService("DataService")
	local scheduler = Knit.GetController("SchedulerController")
	local destroyAutoTrainClicker

	local function startAutoTrain(): nil
		if destroyAutoTrainClicker then
			destroyAutoTrainClicker()
		end
		destroyAutoTrainClicker = scheduler:Every("0.5 seconds", function()
			task.spawn(liftDumbell)
		end)
		return
	end

	if data:GetValue("AutoTrain") then
		startAutoTrain()
	end
	
	data.DataUpdated:Connect(function(key)
		if key ~= "AutoTrain" then return end
		startAutoTrain()
	end)

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