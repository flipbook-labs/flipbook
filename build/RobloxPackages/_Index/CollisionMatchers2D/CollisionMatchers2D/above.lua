local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use to test that the given GuiObject or Rect is above the other GuiObject or
	Rect.

	The last argument is optional. If nil, the matcher will pass only if the
	difference **bottom** edge of the given GuiObject or Rect and the **top**
	edge of the other GuiObject or Rect is zero or positive.

	Usage:

	```lua
	expect(a).toBeAbove(b) -- Jest
	expect(a).to.be.above(b) -- TestEZ
	```

	![Example of above(a, b)](/above(a,%20b).png)

	```lua
	expect(a).toBeAbove(b, 5) -- Jest
	expect(a).to.be.above(b, 5) -- TestEZ
	```

	![Example of above(a, b, 5)](/above(a,%20b,%205).png)

	```lua
	expect(a).toBeAbove(b, NumberRange.new(0, 5)) -- Jest
	expect(a).to.be.above(b, NumberRange.new(0, 5)) -- TestEZ
	```

	![Example of above(a, b, NumberRange.new(0, 5))](/above(a,%20b,%20NumberRange.new(0,%205)).png)

	@tag outside
	@within CollisionMatchers2D
]=]
local function above(a: GuiObject | Rect, b: GuiObject | Rect, distance: number)
	local aRect = toRect(a)
	local bRect = toRect(b)

	local distanceFromSide = -(aRect.Max - bRect.Min)
	if distance then
		if typeof(distance) == "number" then
			distance = NumberRange.new(distance)
		end

		return returnValue(
			distance.Min <= distanceFromSide.Y and distance.Max >= distanceFromSide.Y,
			"Was within range",
			"Was not within range ( " .. tostring(distance) .. ")"
		)
	else
		return returnValue(distanceFromSide.Y >= 0, "Was above the element", "Was below the element")
	end
end

return above
