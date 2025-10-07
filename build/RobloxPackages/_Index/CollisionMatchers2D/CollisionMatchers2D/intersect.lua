local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use to determine if the given GuiObject or Rect is intersecting the other
	GuiObject or Rect. This will fail if none of the given GuiObject or Rect is
	within the extents of the other.

	This will pass even if all of the given object is within the other.

	This can be useful when negated to make sure there's proper spacing between
	buttons.

	```lua
	expect(a).toIntersect(b) -- Jest
	expect(a).to.intersect(b) -- TestEZ
	```

	![Example of intersect(a, b)](/intersect(a,%20b).png)

	@tag relationship
	@within CollisionMatchers2D
]=]
local function intersect(a: GuiObject | Rect, b: GuiObject | Rect)
	local aRect = toRect(a)
	local bRect = toRect(b)

	return returnValue(
		math.abs(aRect.Min.X - bRect.Min.X) * 2 < (aRect.Width + bRect.Width)
			and math.abs(aRect.Min.Y - bRect.Min.Y) * 2 < (aRect.Height + bRect.Height),
		"Intersects the element",
		"Does not intersect the element"
	)
end

return intersect
