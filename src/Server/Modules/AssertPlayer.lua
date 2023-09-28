--!native
--!strict
return function(player)
	if player ~= nil and typeof(player) == "Instance" and player:IsA("Player") then return end
	error("Invalid player parameter passed", 2)
end