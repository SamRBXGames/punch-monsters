--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local RemoteDispatcher = Knit.CreateService {
	Name = "RemoteDispatcher";
	Client = {};
}

local listenerModules: { ModuleScript } = script:GetChildren()
for _, listenerModule in pairs(listenerModules) do
	task.spawn(function()
		local callback = require(listenerModule) :: any
		RemoteDispatcher[listenerModule.Name] = function(_, player: Player, ...)
			callback(player, ...)
		end
		RemoteDispatcher.Client[listenerModule.Name] = function(self, player: Player, ...)
			RemoteDispatcher[listenerModule.Name](self, player, ...)
		end
	end)
end

return RemoteDispatcher