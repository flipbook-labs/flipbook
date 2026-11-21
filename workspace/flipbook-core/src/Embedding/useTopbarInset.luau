local GuiService = game:GetService("GuiService")

local React = require("@pkg/React")

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
		local container = containerRef.current
		if not container then
			return
		end

		local function updateContainerPosition()
			setContainerPosition(container.AbsolutePosition)
		end

		updateContainerPosition()
		local connection = container:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateContainerPosition)

		return function()
			connection:Disconnect()
		end
	end, { containerRef })

	local offset = containerPosition + GuiService:GetGuiInset()

	return Rect.new(topbarInset.Min - offset, topbarInset.Max - offset)
end

return useTopbarInset
