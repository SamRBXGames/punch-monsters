--!native
--!strict
local Weld = {}

function Weld.WeldConstraint(BasePart, WeldParts): nil
	for _, Object in pairs(WeldParts) do
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
	return
end

function Weld.Weld(BasePart, WeldParts): nil
	for _, Object in pairs(WeldParts) do
		if Object:IsA("BasePart") then
			if Object == BasePart then
				continue
			end
			
			local Weld = Instance.new("Weld")
			Weld.Part0 = Object
			Weld.C0 = (Weld.Part0 :: Part).CFrame:Inverse()
			Weld.Part1 = BasePart
			Weld.C1 = (Weld.Part1 :: Part).CFrame:Inverse()
			Weld.Parent = Object
		end
	end
	return
end

return Weld