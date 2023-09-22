local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local RemoteDispatcher = Knit.CreateService {
	Name = "RemoteDispatcher";
	Client = {};
}

local listenerModules: { ModuleScript } = script:GetChildren()
for _, listenerModule in listenerModules do
	local callback = require(listenerModule)
	RemoteDispatcher[listenerModule.Name] = function(_, player: Player, ...)
		callback(player, ...)
	end
	RemoteDispatcher.Client[listenerModule.Name] = function(self, player: Player, ...)
		RemoteDispatcher[listenerModule.Name](self, player, ...)
	end
end

return RemoteDispatcher