return function(player)
	assert(player ~= nil and typeof(player) == "Instance" and player:IsA("Player"), "Invalid player parameter passed")
end