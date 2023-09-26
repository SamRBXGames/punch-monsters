local mod = {}

function mod:RigModel(Character : Model)
	local hum : Humanoid? = Character:WaitForChild("Humanoid")
	local hrp : BasePart? = Character:WaitForChild("HumanoidRootPart")

	assert(hum,Character.Name.." isnt a humanoid")

	hum.BreakJointsOnDeath = false
	local WeldConstranint = Instance.new("WeldConstraint",hrp)
	for _,v in pairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			local BallSocket = Instance.new("BallSocketConstraint",v.Part0)
			BallSocket.Name = "BC"
			if v.Part1 ~= Character.PrimaryPart and v.Part0 ~= Character.PrimaryPart then
				v.Part1.CanCollide = false
				v.Part0.CanCollide = false
			end

			local att1 = Instance.new("Attachment",v.Part0) att1.Name = "AttRag"
			local att2 = Instance.new("Attachment",v.Part1) att1.Name = "AttRag"
			att2.Position = v.C1.Position
			att1.WorldPosition= att2.WorldPosition

			BallSocket.LimitsEnabled = true
			BallSocket.TwistLimitsEnabled = true

			BallSocket.Attachment0 = att1
			BallSocket.Attachment1 = att2

			if v.Part0 == Character.PrimaryPart and v.Part1 ~= Character.PrimaryPart then
				WeldConstranint.Part0 = Character.PrimaryPart
				WeldConstranint.Part1 = v.Part1
				WeldConstranint.Enabled = false
			end
		end
	end
end

function mod:Ragdoll(Character : Model)
	for _, v in ipairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if v.Part1 ~= Character.PrimaryPart and v.Part0 ~= Character.PrimaryPart then
				v.Part1.CanCollide = true
				v.Enabled = false
			else
				Character.PrimaryPart:FindFirstChild("WeldConstraint").Enabled = true
				Character.PrimaryPart.CanCollide = false
			end
		end
	end
end

function mod:Recover(Character : Model)
	for _, v in ipairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if v.Part1 ~= Character.PrimaryPart and v.Part0 ~= Character.PrimaryPart then
				v.Part1.CanCollide = false
				v.Enabled = true
			else
				Character.PrimaryPart:FindFirstChild("WeldConstraint").Enabled = false
				Character.PrimaryPart.CanCollide = true
			end
		end
	end
end

function mod:Deathphysics(Character : Model)
	for _, v in ipairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if v.Part1 ~= Character.PrimaryPart and v.Part0 ~= Character.PrimaryPart then
				v.Part1.CanCollide = true
				v:Destroy()
			else
				Character.PrimaryPart:FindFirstChild("WeldConstraint").Enabled = true
				Character.PrimaryPart.CanCollide = false
			end
		end
	end
end

return mod