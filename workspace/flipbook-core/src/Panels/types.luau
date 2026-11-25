local types = {}

export type DragHandle = "Top" | "Right" | "Bottom" | "Left"

types.DragHandle = table.freeze({
	Top = "Top" :: "Top",
	Right = "Right" :: "Right",
	Bottom = "Bottom" :: "Bottom",
	Left = "Left" :: "Left",
})

return types
