local toRect = require(script.Parent.toRect)
local returnValue = require(script.Parent.returnValue)

--[=[
	Used to test that the given GuiObject or Rect is left, center, or right
	aligned with the other GuiObject or Rect.

	This can be especially useful to determine if a given pair of elements are
	under the influence of the same `UIListLayout`.

	```lua
	expect(a).toBeAlignedHorizontally(b, Enum.HorizontalAlignment.Left) -- Jest
	expect(a).to.be.alignedHorizontally(b, Enum.HorizontalAlignment.Left) -- TestEZ
	```

	![Example of alignedHorizontally(a, b, Enum.HorizontalAlignment.Left)](/alignedHorizontally(a,%20b,%20Enum.HorizontalAlignment.Left).png)

	```lua
	expect(a).toBeAlignedHorizontally(b, Enum.HorizontalAlignment.Right) -- Jest
	expect(a).to.be.alignedHorizontally(b, Enum.HorizontalAlignment.Right) -- TestEZ
	```

	![Example of alignedHorizontally(a, b, Enum.HorizontalAlignment.Right)](/alignedHorizontally(a,%20b,%20Enum.HorizontalAlignment.Right).png)

	@tag alignment
	@within CollisionMatchers2D
]=]
local function alignedHorizontally(
	a: GuiObject | Rect,
	b: GuiObject | Rect,
	horizontalAlignment: Enum.HorizontalAlignment
)
	local aRect = toRect(a)
	local bRect = toRect(b)

	if horizontalAlignment == Enum.HorizontalAlignment.Left then
		return returnValue(aRect.Min.X == bRect.Min.X, "", "")
	elseif horizontalAlignment == Enum.HorizontalAlignment.Center then
		local aMiddle = (aRect.Min + aRect.Max) / 2
		local bMiddle = (bRect.Min + bRect.Max) / 2
		return returnValue(aMiddle.X == bMiddle.X, "", "")
	elseif horizontalAlignment == Enum.HorizontalAlignment.Right then
		return returnValue(aRect.Max.X == bRect.Max.X, "", "")
	end

	return returnValue(false, "Invalid horizontal alignment!")
end

return alignedHorizontally
