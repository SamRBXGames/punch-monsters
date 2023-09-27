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
	ClaimedRewardsToday = {},
	FirstJoinToday = tick(),

	DefeatedBosses = {},
	Wins = 0,
	PunchStrength = 0,
	BicepsStrength = 0,
	AbsStrength = 0,

	ProductsLog = {},
	RedeemedCodes = {},
	
	AutoFight = false,
	AutoTrain = false,
	AutoRebirth = false,

	RebirthBoosts = {
		Wins = 100,
		Strength = 100
	},

	Settings = {
		Sound = 0, -- 0 to 100
		ShowOwnPets = true,
		ShowOtherPets = true,
		LowQuality = false
	}
}

return PROFILE_TEMPLATE