local Abbreviator = require(game:GetService('ReplicatedStorage').Assets.Modules.Abbreviator)

local module = {
	-- Map1
	
	['Popup'] = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0),
--	^ For the Iventory Open, Settings, Codes, etc
	['ButtonClick'] = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true, 0),
	['ButtonHoverEnter'] = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),
}

return module
