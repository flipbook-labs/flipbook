local Storyteller = require("@pkg/Storyteller")

export type Story<T> = Storyteller.Story<T>
export type Storybook = Storyteller.Storybook
export type UnavailableStorybook = Storyteller.UnavailableStorybook
export type StoryControls = Storyteller.StoryControls
export type StoryProps = Storyteller.StoryProps

export type ControlType = Storyteller.ControlType

export type BooleanControl = Storyteller.BooleanControl
export type CheckControl = Storyteller.CheckControl
export type CheckOptions = Storyteller.CheckOptions
export type ColorControl = Storyteller.ColorControl
export type DateControl = Storyteller.DateControl
export type MultiSelectControl = Storyteller.MultiSelectControl
export type MultiSelectOptions = Storyteller.MultiSelectOptions
export type NumberControl = Storyteller.NumberControl
export type NumberOptions = Storyteller.NumberOptions
export type RadioControl = Storyteller.RadioControl
export type RadioOptions = Storyteller.RadioOptions
export type SelectControl = Storyteller.SelectControl
export type SelectOptions = Storyteller.SelectOptions
export type SliderControl = Storyteller.SliderControl
export type StringControl = Storyteller.StringControl
export type StringOptions = Storyteller.StringOptions

return {
	ControlType = Storyteller.ControlType,

	boolean = Storyteller.createBooleanControl,
	check = Storyteller.createCheckControl,
	color = Storyteller.createColorControl,
	date = Storyteller.createDateControl,
	multiSelect = Storyteller.createMultiSelectControl,
	number = Storyteller.createNumberControl,
	radio = Storyteller.createRadioControl,
	select = Storyteller.createSelectControl,
	slider = Storyteller.createSliderControl,
	string = Storyteller.createStringControl,
}
