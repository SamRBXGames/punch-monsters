local SliderFuncs = {}

function SliderFuncs.snapToScale(val: number, step: number): number
	return math.clamp(math.round(val / step) * step, 0, 1)
end

function lerp(start: number, finish: number, percent: number): number
	return (1 - percent) * start + percent * finish
end

function SliderFuncs.map(value: number, start: number, stop: number, newStart: number, newEnd: number, constrain: boolean): number
	local newVal = lerp(newStart, newEnd, SliderFuncs.getAlphaBetween(start, stop, value))
	if not constrain then
		return newVal
	end

	if newStart < newEnd then
		newStart, newEnd = newEnd, newStart
	end

	return math.max(math.min(newVal, newStart), newEnd)
end

function SliderFuncs.getNewPosition(self): UDim2
	local absoluteSize = self._data.Button.AbsoluteSize[self._config.Axis]
	local holderSize = self._holder.AbsoluteSize[self._config.Axis]

	local anchorPoint = self._data.Button.AnchorPoint[self._config.Axis]

	local paddingScale = (self._config.Padding / holderSize)

	local minScale = ((anchorPoint * absoluteSize) / holderSize + paddingScale)
	local decrement = ((2 * absoluteSize) * anchorPoint) - absoluteSize
	local maxScale = (1 - minScale) + (decrement / holderSize)

	local newPercent = SliderFuncs.map(self._data._percent, 0, 1, minScale, maxScale, true)
	
	return 
		if self._config.Axis == "X" then UDim2.fromScale(newPercent, self._data.Button.Position.Y.Scale)
		else UDim2.fromScale(self._data.Button.Position.X.Scale, newPercent)
end

function SliderFuncs.getScaleIncrement(self)
	return 1 / ((self._config.SliderData.End - self._config.SliderData.Start) / self._config.SliderData.Increment)
end

function SliderFuncs.getAlphaBetween(a: number, b: number, c: number): number
	return (c - a) / (b - a)
end

function SliderFuncs.getNewValue(self)
	local newValue = lerp(self._config.SliderData.Start, self._config.SliderData.End, self._data._percent)
	local incrementScale = (1 / self._config.SliderData.Increment)

	newValue = math.round(newValue * incrementScale) / incrementScale
	return newValue
end

return SliderFuncs