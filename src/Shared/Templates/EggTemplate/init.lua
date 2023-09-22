local ChancesTemplate = require(script.ChanceTemplate)

local module = {
	['Map1'] = {
		['Egg1'] = {
			['WinsCost'] = 15,
			['Chances'] = ChancesTemplate['Map1']['Egg1'],
		},
		['Egg2'] = {
			['WinsCost'] = 350,
			['Chances'] = ChancesTemplate['Map1']['Egg2'],
		},
		['Egg3Robux'] = {
			['Robux'] = 79,
			['Chances'] = ChancesTemplate['Map1']['Egg3Robux'],
		}
	},
	['Map2'] = {
		['Egg1'] = {
			['WinsCost'] = 10000,
			['Chances'] = ChancesTemplate['Map2']['Egg1'],
		},
		['Egg2'] = {
			['WinsCost'] = 1000000,
			['Chances'] = ChancesTemplate['Map2']['Egg2'],
		}
	},
	['Map3'] = {
		['Egg1'] = {
			['WinsCost'] = 15000000,
			['Chances'] = ChancesTemplate['Map3']['Egg1'],
		},
		['Egg2'] = {
			['WinsCost'] = 250000000,
			['Chances'] = ChancesTemplate['Map3']['Egg2'],
		}
	}
	
}

return module
