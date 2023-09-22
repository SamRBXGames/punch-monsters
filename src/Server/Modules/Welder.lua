local Weld = {}

function Weld.WeldConstraint(BasePart, WeldParts)
	for Number, Object in pairs(WeldParts) do
		if Object:IsA("BasePart") then
			if Object == BasePart then
			else
				local WeldConstraint = Instance.new("WeldConstraint")
				WeldConstraint.Part0 = Object
				WeldConstraint.Part1 = BasePart
				WeldConstraint.Parent = Object
			end
		end
	end
end

function Weld.Weld(BasePart, WeldParts)
	for Number, Object in pairs(WeldParts) do
		if Object:IsA("BasePart") then
			if Object == BasePart then
				continue
			end
			
			local Weld = Instance.new("Weld")
			Weld.Part0 = Object
			Weld.C0 = Weld.Part0.CFrame:Inverse()
			Weld.Part1 = BasePart
			Weld.C1 = Weld.Part1.CFrame:Inverse()
			Weld.Parent = Object
		end
	end
end

return Weld