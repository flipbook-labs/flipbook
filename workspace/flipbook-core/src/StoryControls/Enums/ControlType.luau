export type ControlType = "String" | "Boolean" | "Number" | "Select" | "MultiSelect" | "Radio" | "Check" | "Color" | "Date"

local ControlType = {
	-- Primitives
	Boolean = "Boolean" :: "Boolean",
	Number = "Number" :: "Number",
	String = "String" :: "String",

	-- Advanced
	Check = "Check" :: "Check",
	Color = "Color" :: "Color",
	Date = "Date" :: "Date",
	MultiSelect = "MultiSelect" :: "MultiSelect",
	Radio = "Radio" :: "Radio",
	Select = "Select" :: "Select",
	Slider = "Slider" :: "Slider",
}

return ControlType
