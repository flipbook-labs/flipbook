local types = {}

type ControlType = "String" | "Boolean" | "Number" | "Select" | "MultiSelect" | "Radio" | "Check" | "Color" | "Date"

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
types.ControlType = ControlType

type Mapping = { [any]: any }

type StringControl = {
	control: "String",

	default: string?,
	placeholder: string?,
}

type BooleanControl = {
	control: "Boolean",

	default: boolean?,
}

type NumberControl = {
	control: "Number",

	default: number?,
	step: number?,
	range: NumberRange?,
}

type SelectControl = {
	control: "Select",
	options: { any },

	mapping: Mapping?,
}

type MultiSelectControl = {
	control: "MultiSelect",
	options: { any },

	mapping: Mapping?,
}

type SliderControl = {
	control: "Slider",
	range: NumberRange,

	default: number?,
	step: number?,
}

type CheckControl = {
	control: "Check",
	options: { any },

	mapping: Mapping?,
}

type RadioControl = {
	control: "Radio",
	options: { any },

	mapping: Mapping?,
}

type ColorControl = {
	control: "Color",
	default: Color3?,
}

type DateControl = {
	control: "Date",
	default: DateTime?,
}

export type StoryControl =
	StringControl
	| BooleanControl
	| NumberControl
	| SelectControl
	| MultiSelectControl
	| SliderControl
	| CheckControl
	| RadioControl
	| ColorControl
	| DateControl

export type StoryControlsSchema = {
	[string]: StoryControl,
}

return types
