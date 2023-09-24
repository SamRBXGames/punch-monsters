--!native
--!strict
local PROFILE_TEMPLATE = {	
	leaderstats = {
		Strength = 0,
		Rebirths = 0,
		Eggs = 0
	},
	
	Pets = {
		OwnedPets = {},
		MaxEquip = 4,
		RobuxPurchasedPets = {},
		Equipped = {}
	},
	
	Timers = {},
	FirstJoinToday = tick(),

	Wins = 0,
	PunchStrength = 0,
	BicepsStrength = 0,
	AbsStrength = 0,

	ProductsLog = {},
	RedeemedCodes = {},
	
	AutoFight = false,
	AutoTrain = false,

	Settings = {
		Sound = 0, -- 0 to 100
		ShowOwnPets = true,
		ShowOtherPets = true,
		AutoRebirth = false,
		LowQuality = false
	}
}

return PROFILE_TEMPLATE