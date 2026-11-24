local GuiService = game:GetService("GuiService")

local React = require("@pkg/React")

local getContainerTopbarInset = require("@root/Embedding/getContainerTopbarInset")

--[[
	Where the hook reads the Roblox topbar from. In a running experience this is
	GuiService. Specs pass their own, because GuiService.TopbarInset is
	read-only and can't be changed to simulate the topbar moving.
]]
export type TopbarSource = {
	getTopbarInset: () -> Rect,
	-- Calls `onChange` whenever the topbar inset changes. Returns a function
	-- that stops the calls.
	subscribe: (onChange: () -> ()) -> () -> (),
	-- The size of the GUI inset at the top-left of the screen, the first value
	-- GuiService:GetGuiInset() returns.
	getGuiInset: () -> Vector2,
}

local guiServiceSource: TopbarSource = {
	getTopbarInset = function()
		return GuiService.TopbarInset
	end,
	subscribe = function(onChange)
		local connection = GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(onChange)
		return function()
			connection:Disconnect()
		end
	end,
	getGuiInset = function()
		local topLeftInset = GuiService:GetGuiInset()
		return topLeftInset
	end,
}

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
	Returns the part of the Roblox topbar that Roblox's own buttons leave free,
	in coordinates relative to the top-left corner of `containerRef`. It
	updates when the topbar changes, and when the container moves if
	`containerRef` is set by the time the component mounts.
]]
local function useTopbarInset(containerRef: { current: GuiObject? }, source: TopbarSource?): Rect
	local topbarSource = source or guiServiceSource
	local topbarInset, setTopbarInset = React.useState(topbarSource.getTopbarInset)
	local containerPosition, setContainerPosition = React.useState(Vector2.zero)

	React.useEffect(function()
		setTopbarInset(topbarSource.getTopbarInset())

		return topbarSource.subscribe(function()
			setTopbarInset(topbarSource.getTopbarInset())
		end)
	end, { topbarSource })

	React.useEffect(function()
		return watchAbsolutePosition(containerRef.current, setContainerPosition)
	end, { containerRef })

	return getContainerTopbarInset(topbarInset, containerPosition, topbarSource.getGuiInset())
end

return useTopbarInset
