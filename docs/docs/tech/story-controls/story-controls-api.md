---
notion-id: 2db95b79-12f8-8040-ac59-e926896108f4
aliases: [Story Controls API]
linter-yaml-title-alias: Story Controls API
---

# Story Controls API

Each control type has an accompanying constructor function to improve the ergonomics for Story authors.

## Enums

### ControlType

```lua

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
```

## Types

### StoryControlValue

```lua
export type StoryControlValue =
	boolean
	| number
	| string
	-- Roblox datatypes
	| Color3
	| DateTime
	| EnumItem
	| { StoryControlValue }
```

All possible types for a control's value to be.

### ControlType

A type representing each of the `ControlType` enums.

```lua
export type ControlType = "String" | "Boolean" | "Number" | "Select" | "MultiSelect" | "Radio" | "Check" | "Color" | "Date"
```

### BooleanControl

```lua
export type BooleanControl = {
	control: "Boolean",
	default: boolean?
}
```

A Boolean control represents a true/false state. There's an accompanying `createBooleanControl` constructor for creating this type.

### CheckControl

### ColorControl

```lua
export type ColorControl = {
	control: "Color",
	default: Color3?
}
```

A Color control represents a Color3 value. There's an accompanying `createColorControl` constructor for creating this type.

### DateControl

```lua
export type DateControl = {
	control: "Date",
	default: DateTime?
}
```

A Date control represents a DateTime value. There's an accompanying `createDateControl` constructor for creating this type.

### MultiSelectControl

```lua
export type MultiSelectControl = {
	control: "MultiSelect",
	options: { string }?,
	mapping: { [string]: StoryControlValue }?
}
```

### NumberControl

```lua
export type NumberControl = {
	control: "Number",
	default: number?
	range: NumberRange?,
	step: number?
}
```

A Number control represents a number value. There's an accompanying `createNumberControl` constructor for creating this type.

Providing `range` and `step` will constrain the possible values that can be passed in `StoryControls`.

### RadioControl

### SelectControl

### SliderControl

### StringControl

### StoryControl

### StoryControlsSchema

### StoryControls

## Constructors

### createBooleanControl

`createBooleanControl(default: boolean?): BooleanControl`

### createCheckControl

`createCheckControl<T>(``*options*``: { string }, ``*default*``: { string }?, ``*mapping*``: Mapping<T>?): CheckControl<T>`

### createColorControl

`createColorControl(``*default*``: Color3?): ColorControl`

### createDateControl

createDateControl(default: DateTime?): DateControl

### createMultiSelectControl

### createNumberControl

### createRadioControl

### createSelectControl

### createSliderControl

### createStringControl

## Functions

hydrateControls
