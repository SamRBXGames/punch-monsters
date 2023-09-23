--!native
--!strict
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local module = {
	Map1 = {
		VFX = ReplicatedStorage.Assets.VFX.Hit1,
		
		PunchBag1 = {
			PunchRequirement = 0,
			Hit = 1,
		},
		PunchBag2 = {
			PunchRequirement = 500,
			Hit = 2,
		},
		PunchBag3 = {
			PunchRequirement = 4000,
			Hit = 3,
		},
		PunchBag4 = {
			PunchRequirement = 22000,
			Hit = 4,
		},
		PunchBag5 = {
			PunchRequirement = 100000,
			Hit = 5,
		},
		PunchBag6VIP = {
			PunchRequirement = 0,
			Hit = 15,

			Vip = true,
		}
	},
	Map2 = {
		VFX = ReplicatedStorage.Assets.VFX.Hit2,

		PunchBag1 = {
			PunchRequirement = 0,
			Hit = 10,
		},
		PunchBag2 = {
			PunchRequirement = 500000,
			Hit = 15,
		},
		PunchBag3 = {
			PunchRequirement = 1000000,
			Hit = 20,
		},
		PunchBag4 = {
			PunchRequirement = 2000000,
			Hit = 30,
		},
		PunchBag5 = {
			PunchRequirement = 3500000,
			Hit = 50,
		},
		PunchBag6VIP = {
			PunchRequirement = 0,
			Hit = 150,

			Vip = true,
		}
	},
	Map3 = {
		VFX = ReplicatedStorage.Assets.VFX.Hit3,

		PunchBag1 = {
			PunchRequirement = 0,
			Hit = 75,
		},
		PunchBag2 = {
			PunchRequirement = 10000000,
			Hit = 100,
		},
		PunchBag3 = {
			PunchRequirement = 16000000,
			Hit = 135,
		},
		PunchBag4 = {
			PunchRequirement = 42000000,
			Hit = 175,
		},
		PunchBag5 = {
			PunchRequirement = 110000000,
			Hit = 220,
		},
		PunchBag6VIP = {
			PunchRequirement = 0,
			Hit = 660,

			Vip = true,
		}
	}
	
}

return module
