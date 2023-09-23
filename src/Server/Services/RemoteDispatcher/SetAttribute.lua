return function<T>(player: Player, instance: Instance, name: string, value: T)
	instance:SetAttribute(name, value)
end