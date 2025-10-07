local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use to test that the bottom padding between the given GuiObject or Rect and the other GuiObject or Rect.

	The last argument is optional. If nil, the matcher will pass only if the difference **bottom** edge of the given GuiObject or Rect and the **bottom** edge of the other GuiObject or Rect is zero or positive.

	```lua
	-- Jest
	expect(instanceA).toBeInsideAbove(instanceB)
	expect(instanceA).toBeInsideAbove(instanceB, 10)
	expect(instanceA).toBeInsideAbove(instanceB, NumberRange.new(0, 10))
	```

	```lua
	-- TestEZ
	expect(instanceA).to.be.insideAbove(instanceB)
	expect(instanceA).to.be.insideAbove(instanceB, 10)
	expect(instanceA).to.be.insideAbove(instanceB, NumberRange.new(0, 10))
	```

	@tag inside
	@within CollisionMatchers2D
]=]
local function insideAbove(a: GuiObject | Rect, b: GuiObject | Rect, distance: number | NumberRange)
	local aRect = toRect(a)
	local bRect = toRect(b)

	local distanceFromSide = -(aRect.Max - bRect.Max)
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
		return returnValue(distanceFromSide.Y >= 0, "Was not below the element", "Was too far below the element")
	end
end

return insideAbove
