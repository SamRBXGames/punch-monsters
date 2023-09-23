--!native
--!strict
local Tween = game:GetService("TweenService")
local tween = {}

function tween.moveToPosition(guiObject: GuiObject, position: UDim2, tweenInfo: TweenInfo): Tween
	return Tween:Create(guiObject, tweenInfo, {Position = position})
end

function tween.moveFromPosition(guiObject: GuiObject, position: UDim2, tweenInfo: TweenInfo): Tween
	local startingPosition = guiObject.Position

	guiObject.Position = position
	guiObject.Visible = true

	return Tween:Create(guiObject, tweenInfo, {Position = startingPosition})
end

return tween
