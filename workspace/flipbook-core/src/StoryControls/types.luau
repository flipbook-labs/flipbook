local ControlType = require("@root/StoryControls/Enums/ControlType")

type ControlType = ControlType.ControlType

export type Mapping = { [any]: any }

type BaseControl<ControlType, Value> = {
	control: ControlType,
	default: Value?,
}

type BaseNumberControl<ControlType> = BaseControl<ControlType, number> & {
	step: number?,
	range: NumberRange?,
}

type BaseListControl<ControlType, Value> = BaseControl<ControlType, Value> & {
	options: { Value },
	mapping: Mapping?,
}

export type StringControl = BaseControl<"String", string>
export type BooleanControl = BaseControl<"Boolean", boolean>
export type NumberControl = BaseNumberControl<"Number">
export type SliderControl = BaseNumberControl<"Slider">
export type SelectControl<T> = BaseListControl<"Select", T>
export type MultiSelectControl<T> = BaseListControl<"MultiSelect", T>
export type CheckControl<T> = BaseListControl<"Check", T>
export type RadioControl<T> = BaseListControl<"Radio", T>
export type ColorControl = BaseControl<"Color", Color3>
export type ColourControl = ColorControl
export type DateControl = BaseControl<"Date", DateTime>

export type StoryControl =
	StringControl
	| BooleanControl
	| NumberControl
	| SliderControl
	| SelectControl<unknown>
	| MultiSelectControl<unknown>
	| CheckControl<unknown>
	| RadioControl<unknown>
	| ColorControl
	| DateControl

export type StoryControlsSchema = {
	[string]: StoryControl,
}

export type StoryControls = {
	[string]: any,
}

return nil
