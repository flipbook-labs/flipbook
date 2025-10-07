local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use to test that the given GuiObject or Rect is below the other GuiObject or Rect.

	The last argument is optional. If nil, the matcher will pass only if the difference **top** edge of the given GuiObject or Rect and the **bottom** edge of the other GuiObject or Rect is zero or positive.


	```lua
	expect(a).toBeBelow(b) -- Jest
	expect(a).to.be.below(b) -- TestEZ
	```

	![Example of below(a, b)](/below(a,%20b).png)

	```lua
	expect(a).toBeBelow(b, 5) -- Jest
	expect(a).to.be.below(b, 5) -- TestEZ
	```

	![Example of below(a, b, 5)](/below(a,%20b,%205).png)

	```lua
	expect(a).toBeBelow(b, NumberRange.new(0, 5)) -- Jest
	expect(a).to.be.below(b, NumberRange.new(0, 5)) -- TestEZ
	```

	![Example of below(a, b, NumberRange.new(0, 5))](/below(a,%20b,%20NumberRange.new(0,%205)).png)
	@tag outside
	@within CollisionMatchers2D
]=]
local function below(a: GuiObject | Rect, b: GuiObject | Rect, distance: number | NumberRange)
	local aRect = toRect(a)
	local bRect = toRect(b)

	local distanceFromSide = aRect.Min - bRect.Max
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
		return returnValue(distanceFromSide.Y >= 0, "Was below the element", "Was above the element")
	end
end

return below
