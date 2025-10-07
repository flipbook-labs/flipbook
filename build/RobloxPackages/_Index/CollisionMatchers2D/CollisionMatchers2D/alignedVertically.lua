local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use  to test that the given GuiObject or Rect is left, center, or right
	aligned with the other GuiObject or Rect.

	This can be especially useful to determine if a given pair of elements are
	under the influence of the same `UIListLayout`.

	```lua
	expect(a).toBeAlignedVertically(b, Enum.VerticalAlignment.Top) -- Jest
	expect(a).to.be.alignedVertically(b, Enum.VerticalAlignment.Top) -- TestEZ
	```

	![Example of alignedVertically(a, b, Enum.VerticalAlignment.Top)](/alignedVertically(a,%20b,%20Enum.VerticalAlignment.Top).png)

	```lua
	expect(a).toBeAlignedVertically(b, Enum.VerticalAlignment.Bottom) -- Jest
	expect(a).to.be.alignedVertically(b, Enum.VerticalAlignment.Bottom) -- TestEZ
	```

	![Example of alignedVertically(a, b, Enum.VerticalAlignment.Bottom)](/alignedVertically(a,%20b,%20Enum.VerticalAlignment.Bottom).png)


	@tag alignment
	@within CollisionMatchers2D
]=]
local function alignedVertically(a: GuiObject | Rect, b: GuiObject | Rect, verticalAlignment: Enum.VerticalAlignment)
	local aRect = toRect(a)
	local bRect = toRect(b)

	if verticalAlignment == Enum.VerticalAlignment.Top then
		return returnValue(aRect.Min.Y == bRect.Min.Y, "", "")
	elseif verticalAlignment == Enum.VerticalAlignment.Center then
		local aMiddle = (aRect.Min + aRect.Max) / 2
		local bMiddle = (bRect.Min + bRect.Max) / 2
		return returnValue(aMiddle.Y == bMiddle.Y, "", "")
	elseif verticalAlignment == Enum.VerticalAlignment.Bottom then
		return returnValue(aRect.Max.Y == bRect.Max.Y, "", "")
	end

	return returnValue(false, "Invalid VerticalAlignment!")
end

return alignedVertically
