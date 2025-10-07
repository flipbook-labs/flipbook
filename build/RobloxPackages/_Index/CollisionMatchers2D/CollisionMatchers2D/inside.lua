local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

local function isPointInside(vector2, rect)
	return vector2.X >= rect.Min.X and vector2.X <= rect.Max.X and vector2.Y >= rect.Min.Y and vector2.Y <= rect.Max.Y
end

--[=[
	Use to determine if the given GuiObject or Rect is within the other
	GuiObject or Rect. This will fail if part of the given GuiObject or Rect
	extends beyond the extents of the other GuiObject or Rect.

	This can be useful in making sure child UI elements do not accidentally leak
	outside of their containers.

	```lua
	expect(a).toBeInside(b) --  Jest
	expect(a).to.be.inside(b) -- TestEZ
	```

	![Example of inside(a, b)](/inside(a,%20b).png)

	@tag relationship
	@within CollisionMatchers2D
]=]
local function inside(a: GuiObject | Rect, b: GuiObject | Rect)
	local aRect = toRect(a)
	local bRect = toRect(b)

	return returnValue(
		isPointInside(aRect.Min, bRect) and isPointInside(aRect.Max, bRect),
		"Is inside the element",
		"Is not inside the element"
	)
end

return inside
