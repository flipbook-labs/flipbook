local GuiService = game:GetService("GuiService")

local React = require("@pkg/React")

local function watchAbsolutePosition(container: GuiObject?, onChange: (position: Vector2) -> ()): (() -> ())?
	if not container then
		return nil
	end

	onChange(container.AbsolutePosition)
	local connection = container:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		onChange(container.AbsolutePosition)
	end)

	return function()
		connection:Disconnect()
	end
end

--[[
	Returns the unoccupied area of the Roblox topbar, relative to the top-left
	corner of `containerRef`.

	TopbarInset is measured from the top of the screen while AbsolutePosition
	starts below the GUI inset, so the GUI inset is added back before
	converting.
]]
local function useTopbarInset(containerRef: { current: GuiObject? }): Rect
	local topbarInset, setTopbarInset = React.useState(GuiService.TopbarInset)
	local containerPosition, setContainerPosition = React.useState(Vector2.zero)

	React.useEffect(function()
		local connection = GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
			setTopbarInset(GuiService.TopbarInset)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	React.useEffect(function()
		return watchAbsolutePosition(containerRef.current, setContainerPosition)
	end, { containerRef })

	local offset = containerPosition + GuiService:GetGuiInset()

	return Rect.new(topbarInset.Min - offset, topbarInset.Max - offset)
end

return useTopbarInset
