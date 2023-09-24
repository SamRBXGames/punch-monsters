--!native
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)
local ProfileTemplate = require(ReplicatedStorage.Templates.ProfileTemplate)

local MasterSounds: Component.Def = {
	Name = script.Name;
	Guards = {
		Ancestors = { SoundService },
		ClassName = "SoundGroup",
		Children = {
			Circle = { ClassName = "MeshPart" },
			Dashes = { ClassName = "MeshPart" }
		}
	};
}

function MasterSounds:Initialize(): nil	
  local data = Knit.GetService("DataService")

  data.DataUpdated:Connect(function(key, value): nil
    if key ~= "Settings" then return end

    local settings: typeof(ProfileTemplate.Settings) = value
    self.Instance.Volume = settings.Sound / 100
    return
  end)

  return
end

return Component.new(MasterSounds)