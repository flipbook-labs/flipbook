local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use to test that the right padding between the given GuiObject or Rect and the other GuiObject or Rect.

	The last argument is optional. If nil, the matcher will pass only if the difference **right** edge of the given GuiObject or Rect and the **right** edge of the other GuiObject or Rect is zero or positive.

	```lua
	-- Jest
	expect(instanceA).toBeInsideLeftOf(instanceB)
	expect(instanceA).toBeInsideLeftOf(instanceB, 10)
	expect(instanceA).toBeInsideLeftOf(instanceB, NumberRange.new(0, 10))
	```

	```lua
	-- TestEZ
	expect(instanceA).to.be.insideLeftOf(instanceB)
	expect(instanceA).to.be.insideLeftOf(instanceB, 10)
	expect(instanceA).to.be.insideLeftOf(instanceB, NumberRange.new(0, 10))
	```

	@tag inside
	@within CollisionMatchers2D
]=]
local function insideLeftOf(a: GuiObject | Rect, b: GuiObject | Rect, distance: number | NumberRange)
	local aRect = toRect(a)
	local bRect = toRect(b)

	local distanceFromSide = -(aRect.Max - bRect.Max)
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
		return returnValue(distanceFromSide.X >= 0, "Was not right of the element", "Was too far right of the element")
	end
end

return insideLeftOf
