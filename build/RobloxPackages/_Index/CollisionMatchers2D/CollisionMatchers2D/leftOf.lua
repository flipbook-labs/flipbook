local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use to test that the given GuiObject or Rect is to the left of the other
	GuiObject or Rect.

	The last argument is optional. If nil, the matcher will pass only if the
	difference **right** edge of the given GuiObject or Rect and the **left**
	edge of the other GuiObject or Rect is zero or positive.

	Usage:

	```lua
	expect(a).toBeLeftOf(b) -- Jest
	expect(a).to.be.leftOf(b) -- TestEZ
	```

	![Example of leftOf(a, b)](/leftOf(a,%20b).png)

	```lua
	expect(a).toBeLeftOf(b, 5) -- Jest
	expect(a).to.be.leftOf(b, 5) -- TestEZ
	```

	![Example of leftOf(a, b, 5)](/leftOf(a,%20b,%205).png)

	```lua
	expect(a).toBeLeftOf(b, NumberRange.new(0, 5)) -- Jest
	expect(a).to.be.leftOf(b, NumberRange.new(0, 5)) -- TestEZ
	```

	![Example of leftOf(a, b, NumberRange.new(0, 5))](/leftOf(a,%20b,%20NumberRange.new(0,%205)).png)

	@tag outside
	@within CollisionMatchers2D
]=]
local function leftOf(a: GuiObject | Rect, b: GuiObject | Rect, distance: number | NumberRange)
	local aRect = toRect(a)
	local bRect = toRect(b)

	local distanceFromSide = -(aRect.Max - bRect.Min)
	if distance then
		if typeof(distance) == "number" then
			distance = NumberRange.new(distance)
		end

		return returnValue(
			distance.Min <= distanceFromSide.X and distance.Max >= distanceFromSide.X,
			"Was within range",
			"Was not within range ( " .. tostring(distance) .. ")"
		)
	else
		return returnValue(distanceFromSide.X >= 0, "Was not right of the element", "Was to the right of the element")
	end
end

return leftOf
