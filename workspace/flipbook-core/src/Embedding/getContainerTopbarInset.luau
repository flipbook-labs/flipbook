--[[
	Converts the Roblox topbar's free area into coordinates relative to a
	container's top-left corner.

	`topbarInset` is GuiService.TopbarInset, which is measured from the top of
	the screen. A container's AbsolutePosition starts below the GUI inset
	instead, so `guiInset` (GuiService:GetGuiInset()) is added back before
	converting.
]]
local function getContainerTopbarInset(topbarInset: Rect, containerPosition: Vector2, guiInset: Vector2): Rect
	local offset = containerPosition + guiInset

	return Rect.new(topbarInset.Min - offset, topbarInset.Max - offset)
end

return getContainerTopbarInset
