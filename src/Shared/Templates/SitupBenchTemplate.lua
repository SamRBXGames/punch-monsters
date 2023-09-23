--!native
--!strict
local module = {
	Map1 = {
		SitupBench1 = {
			AbsRequirement = 0,
			Hit = 1,
		},
		SitupBench2 = {
			AbsRequirement = 500,
			Hit = 2,
		},
		SitupBench3 = {
			AbsRequirement = 4000,
			Hit = 3,
		},
		SitupBench4 = {
			AbsRequirement = 22000,
			Hit = 4,
		},
		SitupBench5 = {
			AbsRequirement = 100000,
			Hit = 5,
		},
		SitupBench6VIP = {
			AbsRequirement = 0,
			Hit = 15,

			Vip = true,
		}
	},
	Map2 = {
		SitupBench1 = {
			AbsRequirement = 0,
			Hit = 10,
		},
		SitupBench2 = {
			AbsRequirement = 500000,
			Hit = 15,
		},
		SitupBench3 = {
			AbsRequirement = 1000000,
			Hit = 20,
		},
		SitupBench4 = {
			AbsRequirement = 2000000,
			Hit = 30,
		},
		SitupBench5 = {
			AbsRequirement = 3500000,
			Hit = 50,
		},
		SitupBench6VIP = {
			AbsRequirement = 0,
			Hit = 150,

			Vip = true,
		}
	},
	Map3 = {
		SitupBench1 = {
			AbsRequirement = 0,
			Hit = 75,
		},
		SitupBench2 = {
			AbsRequirement = 10000000,
			Hit = 100,
		},
		SitupBench3 = {
			AbsRequirement = 15000000,
			Hit = 135,
		},
		SitupBench4 = {
			AbsRequirement = 42000000,
			Hit = 175,
		},
		SitupBench5 = {
			AbsRequirement = 110000000,
			Hit = 220,
		},
		SitupBench6VIP = {
			AbsRequirement = 0,
			Hit = 660,

			Vip = true,
		}
	}
	
}

return module
