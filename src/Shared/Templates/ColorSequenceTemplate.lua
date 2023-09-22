local Sequences = {
	['Rarities'] = {
		['Common'] = ColorSequence.new(
			{ColorSequenceKeypoint.new(0, Color3.new(0.615686, 0.615686, 0.615686)),
			ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}
		),
		['Uncommon'] = ColorSequence.new(
			{ColorSequenceKeypoint.new(0, Color3.new(0.0666667, 1, 0)),
			ColorSequenceKeypoint.new(1, Color3.new(0.25098, 0.839216, 0))}
		),
		['Rare'] = ColorSequence.new(
			{ColorSequenceKeypoint.new(0, Color3.new(0, 0.533333, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0, 0.733333, 1))}
		),
		['Epic'] = ColorSequence.new(
			{ColorSequenceKeypoint.new(0, Color3.new(0.635294, 0, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0.831373, 0, 1))}
		),
		['Legendary'] = ColorSequence.new(
			{ColorSequenceKeypoint.new(0, Color3.new(1, 0.615686, 0)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 0.882353, 0))}
		),
		['Special'] = ColorSequence.new(
			{ColorSequenceKeypoint.new(0, Color3.new(0.866667, 0.101961, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 0.294118, 1))}
		),
		['Huge'] = ColorSequence.new(
			{ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0.4)),
			ColorSequenceKeypoint.new(1, Color3.new(0.392157, 0, 0.00784314))}
		),
	},
}

return Sequences