local types = {}

type Mapping = { [any]: any }

export type StringControl = {
	control: "String",

	default: string?,
	placeholder: string?,
}

export type BooleanControl = {
	control: "Boolean",

	default: boolean?,
}

export type NumberControl = {
	control: "Number",

	default: number?,
	step: number?,
	range: NumberRange?,
}

export type SelectControl = {
	control: "Select",
	options: { any },

	mapping: Mapping?,
}

export type MultiSelectControl = {
	control: "MultiSelect",
	options: { any },

	mapping: Mapping?,
}

export type SliderControl = {
	control: "Slider",
	range: NumberRange,

	default: number?,
	step: number?,
}

export type CheckControl = {
	control: "Check",
	options: { any },

	mapping: Mapping?,
}

export type RadioControl = {
	control: "Radio",
	options: { any },

	mapping: Mapping?,
}

export type ColorControl = {
	control: "Color",
	default: Color3?,
}

export type DateControl = {
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

export type StoryControls = {
	[string]: any,
}

return types
