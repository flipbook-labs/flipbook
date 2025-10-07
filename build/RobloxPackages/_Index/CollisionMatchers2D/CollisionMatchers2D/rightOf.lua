local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use to test that the given GuiObject or Rect is to the right of the other GuiObject or Rect.

	The last argument is optional. If nil, the matcher will pass only if the difference **left** edge of the given GuiObject or Rect and the **right** edge of the other GuiObject or Rect is zero or positive.

	Usage:

	```lua
	expect(a).toBeRightOf(b) -- Jest
	expect(a).to.be.rightOf(b) -- TestEZ
	```

	![Example of rightOf(a, b)](/rightOf(a,%20b).png)

	```lua
	expect(a).toBeRightOf(b, 5) -- Jest
	expect(a).to.be.rightOf(b, 5) -- TestEZ
	```

	![Example of rightOf(a, b, 5)](/rightOf(a,%20b,%205).png)

	```lua
	expect(a).toBeRightOf(b, NumberRange.new(0, 5)) -- Jest
	expect(a).to.be.rightOf(b, NumberRange.new(0, 5)) -- TestEZ
	```

	![Example of rightOf(a, b, NumberRange.new(0, 5))](/rightOf(a,%20b,%20NumberRange.new(0,%205)).png)

	@tag outside
	@within CollisionMatchers2D
]=]
local function rightOf(a: GuiObject | Rect, b: GuiObject | Rect, distance: number | NumberRange)
	local aRect = toRect(a)
	local bRect = toRect(b)

	local distanceFromSide = aRect.Min - bRect.Max
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
		return returnValue(distanceFromSide.X >= 0, "Was not left of the element", "Was to the left of the element")
	end
end

return rightOf
