local tweenService = game:GetService("TweenService")

local module = {}

function module.moveToPosition(guiObject: GuiObject, position: UDim2, tweenInfo: TweenInfo): Tween
	return tweenService:Create(guiObject, tweenInfo, {Position = position})
end

function module.moveFromPosition(guiObject: GuiObject, position: UDim2, tweenInfo: TweenInfo): Tween
	local startingPosition = guiObject.Position

	guiObject.Position = position
	guiObject.Visible = true

	return tweenService:Create(guiObject, tweenInfo, {Position = startingPosition})
end

return module
