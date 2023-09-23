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
	task.spawn(function()
		local componentManager = Component.Get(componentName)
		local components = componentManager.OwnedComponents:Filter(function(component)
			return component.Name == componentName
		end)

		for component in components:Values() do
			local action = component[actionName]
			task.spawn(action, component)
		end
	end)
	return
end

local InputTypeMap = {
	MouseButton1 = function()
		forEachComponent("PunchingBag", "Punch")
		forEachComponent("SitupBench", "Situp")
		forEachComponent("EnemyFighting", "Attack")

		local Dumbell = Knit.GetController("DumbellController")
		Dumbell:Lift()
	end
}

local KeyboardInputMap = {
	E = function()
		forEachComponent("HatchingStand", "BuyOne")
	end,
	R = function()
		forEachComponent("HatchingStand", "BuyThree")
	end,
	T = function()
		forEachComponent("HatchingStand", "Auto")
	end
}

function InputController:KnitStart()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if not player:GetAttribute("Loaded") then return end
		self:ExecuteAction(input, "UserInputType")
		self:ExecuteAction(input, "KeyCode")
	end)
end

function InputController:ExecuteAction(input: InputObject, type: "UserInputType" | "KeyCode")
	local actionMap = if type == "KeyCode" then KeyboardInputMap else InputTypeMap
	for inputType in pairs(actionMap) do
		if not (Enum :: any)[type][inputType] then
			warn(`Listening for input on invalid {if type == "KeyCode" then "keycode" else "input type"}: {inputType}`)
		end
	end
	
	local actionName: string = (input :: any)[type].Name
	local action: () -> () = (actionMap :: any)[actionName]
	if not action then return end
	task.spawn(action)
end

return InputController