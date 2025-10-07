--[=[
	Converts a GuiObject into a Rect.

	For convenience, a Rect can also be passed in and will be returned. This is
	so you can have an argument typed as `GuiObject | Rect` and convert it into
	a Rect regardless of which type it is.

	@private
	@within CollisionMatchers2D
]=]
local function toRect(instanceOrRect: GuiObject | Rect)
	local typeOf = typeof(instanceOrRect)
	if typeOf == "Rect" then
		return instanceOrRect
	elseif typeOf == "Instance" then
		return Rect.new(instanceOrRect.AbsolutePosition, instanceOrRect.AbsolutePosition + instanceOrRect.AbsoluteSize)
	end
end

return toRect
