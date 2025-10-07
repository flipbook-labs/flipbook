local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Use  to test that the left padding between the given GuiObject or Rect and
	the other GuiObject or Rect.

	The last argument is optional. If nil, the matcher will pass only if the
	difference **left** edge of the given GuiObject or Rect and the **left**
	edge of the other GuiObject or Rect is zero or positive.

	```lua
	-- Jest
	expect(instanceA).toBeInsideRightOf(instanceB)
	expect(instanceA).toBeInsideRightOf(instanceB, 10)
	expect(instanceA).toBeInsideRightOf(instanceB, NumberRange.new(0, 10))
	```

	```lua
	-- TestEZ
	expect(instanceA).to.be.insideRightOf(instanceB)
	expect(instanceA).to.be.insideRightOf(instanceB, 10)
	expect(instanceA).to.be.insideRightOf(instanceB, NumberRange.new(0, 10))
	```

	@tag inside
	@within CollisionMatchers2D
]=]
local function insideRightOf(a: GuiObject | Rect, b: GuiObject | Rect, distance: number | NumberRange)
	local aRect = toRect(a)
	local bRect = toRect(b)

	local distanceFromSide = (aRect.Min - bRect.Min)
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
		return returnValue(distanceFromSide.X >= 0, "Was not left of the element", "Was too far left of the element")
	end
end

return insideRightOf
