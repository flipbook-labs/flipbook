---
notion-id: 2dd95b79-12f8-80f3-ae6a-e26a8e78f52a
aliases:
  - Overview
linter-yaml-title-alias: Overview
tags:
  - tech-spec
STATUS: pending
---

# Flipbook Companion Package

# Overview

The Flipbook companion package re-exports a subset of Storyteller's API, creating a friendlier API for Flipbook users.

The motivations for this package are:

1. We want the name of the package that user's import in their stories to match the name of the plugin
2. Storyteller exports a slew of members that are irrelevant to story authors, like all of the discovery logic

Reason being that I think it would be good when a user is consuming our utils package for them to have to write…

```lua
local Flipbook = require(...)
```

…so they know right away that the package is associated with the plugin. Re-exports can also be re-named, which is a + for me since then Storyteller can keep its more verbose naming style.

It would be the difference between these two:

```lua
toggle = Storyteller.createBooleanControl(true)
-- vs.
toggle = Flipboook.boolean(true)
```

For a larger example, it would be the difference between these two:



Storyteller :

```lua
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local Button = require("./Button")

local story: Storyteller.Story = {
	controls = {
		isDisabled = Storyteller.createBooleanControl()
	},
	story = function(props)
		return React.createElement(Button, {
			text = "Click Me",
			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
	end,
}

return story
```

Flipbook

   ```lua
   local React = require("@pkg/React")
	local Flipbook = require("@pkg/Flipbook")
	
	local Button = require("./Button")
	
	local story: Flipbook.Story = {
	    controls = {
	        isDisabled = Flipbook.boolean()
	    },
	    story = function(props)
	        return React.createElement(Button, {
	            text = "Click Me",
	            isDisabled = props.controls.isDisabled,
	            onActivated = function()
	                print("click")
	            end,
	        })
	    end,
	}
	
	return story
   ```

# API

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

### ControlType

```lua
export type ControlType = "String" | "Boolean" | "Number" | "Select" | "MultiSelect" | "Radio" | "Check" | "Color" | "Date"
```

### BooleanControl

```lua
export type BooleanControl = {
  type: "Boolean",
  default: boolean?,
 }
```

### CheckOptions

```lua
export type CheckOptions<T=StoryControlValue> = {
	default: { T },
	tostring: ((item: T) -> string)?,
	sort: ((itemA: T, itemB: T) - boolean)?
}
```

### CheckControl

```lua
export type CheckControl = {
  type: "Check",
  items: { T },
 } & CheckOptions<T>
```

### ColorControl

```lua
export type ColorControl = {
  type: "Color",
  default: Color3?
 }
```

### DateControl

```lua
export type DateControl = {
  type: "Date",
  default: DateTime?
 }
```

### MultiSelectOptions

```lua
export type MultiSelectOptions<T=StoryControlValue> = {
	default: { T },
	tostring: ((item: T) -> string)?,
	sort: ((itemA: T, itemB: T) - boolean)?
}
```

### MultiSelectControl

```lua
export type MultiSelectControl<T=StoryControlValue> = {
  type: "MultiSelect",
  items: { T },
 } & MultiSelectOptions<T>
```

### NumberOptions

```lua
export type NumberOptions = {
  range: NumberRange?,
  step: number?,
}
```

### NumberControl

```lua
export type NumberControl = {
  type: "Number",
  default: number?
 } & NumberOptions
```

### RadioOptions

```lua
export type RadioOptions<T=StoryControlValue> = {
	default: { T },
	tostring: ((item: T) -> string)?,
	sort: ((itemA: T, itemB: T) - boolean)?
}
```

### RadioControl

```lua
export type RadioControl<T> = {
  type: "Radio",
  items: { T },
 } & RadioOptions<T>
```

### SelectOptions

```lua
export type SelectOptions<T> = {
	default: T?,
	tostring: ((item: T) -> string)?,
	sort: ((itemA: T, itemB: T) - boolean)?
}
```

### SelectControl

```lua
export type SelectControl<T> = {
  type: "Select",
  items: { T } | { [string]: T },
 } & SelectOptions<T>
```

### SliderControl

```lua
export type SliderControl = {
  type: "Slider",
  default: number?
  range: NumberRange?,
  step: number?
 }
```

### StringOptions

```lua
export type StringOptions = {
	validate: (input: string) -> boolean,
}
```

### StringControl

```lua
export type StringControl = {
  type: "String",
  default: string?
 } & StringOptions
```

## Functions

### Boolean

`boolean(default: boolean?): BooleanControl`

Provides a toggle for switching between possible states.

Example:

```lua
controls = {
	-- Defaults to `false`
	toggle = Flipbook.boolean(),

	isEnabled = Flipbook.boolean(true)
}
```

### Check

`check<T>(items: { T }, options: CheckOptions<T>?): CheckControl`

Provides a set of checkboxes for making multiple selections.

Example:

```lua
controls = {
	tags = Flipbook.check({
		"Cool",
		"Cute",
		"Quirky",
	}),
}
```

### Color

`color(default: (Color3 | string)?): ColorControl`

Provides a color picker for selecting different colors.

Example:

```lua
controls = {
	-- Defaults to Color3.fromRGB(255, 255, 255)
	colorPicker = Flipbook.color(),

	-- Optionally provide your own starting color
	favoriteColor = Flipbook.color(Color3.fromRGB(255, 100, 100))

	-- Colors can also be supplied as their hex representations
	hexed = Flipbook.color("#333")
}
```

### Date

`date(default: (DateTime | string)?): DateControl`

Provides a date picker for selecting different dates and times.

Example:

```lua
controls = {
  -- Defaults to `DateTime.now()`
	datePicker = Flipbook.date(),

	-- Optionally provide your own starting date
	tomorrow = Flipbook.date(DateTime.fromWhatever(DateTime.now():ToSeconds() + 1 day as seconds)

	-- Dates can also be supplied as a string in the form `YYYY-MM-DD-HH:MM:SS`
	futureProof = Flipbook.date("3000-01-01")
}
```

### multiSelect

`multiSelect<T>(items: { T }, options: MultiSelectOptions<T>?): MultiSelectControl`

Provides a dropdown list that allows multiple selected values.

Example:

```lua
controls = {
	dogAttributes = Flipbook.multiSelect({
		"Big",
		"Small",
		"Fluffy",
		"Sniffer",
	}, {
		default = { "Big", "Sniffer", },
	}),
}
```

### Number

`number(default: number?, options: NumberOptions?): NumberControl`

Provides a numeric input to include the range of all possible values.

Parameter defaults:

- `default = 0`
- `step = 1`

Providing `range` will constrain the possible values of the number, and `step` controls how much the number will be changed up/down by the UI.

Example:

```lua
controls = {
	-- Starts at 0 and allows the user to step up/down by 1
	number = Flipbook.number(),

	alpha = Flipbook.number(0, NumberRange.new(0, 1), 0.01)
}
```

### Radio

`radio(options: { string }, default: string?, mapping: Mapping?): RadioControl`

Provides a set of radio buttons for making a single selection.

Example:

```lua
control = {
	sortDirection = Flipbook.radio({
		Enum.SortDirection.Ascending,
		Enum.SortDirection.Descending,
	}),
}
```

### Select

`select<T>(items: { T }, options: SelectOptions<T>?): SelectControl`

Provides a dropdown list for single value selection.

Example:

```lua
controls = {
	font = Flipbook.select({
		Enum.Font.BuilderSans,
		Enum.Font.BuilderSansBold,
		Enum.Font.BuilderSansExtraBold,
	}, {
		-- Optional default value.
		default = Enum.Font.BuilderSansBold,

		-- Optional function for mapping each of the possible values to a
		-- human-friendly string. This is what shows up when interacting with
		-- the dropdown.
		tostring = function(font)
			return font.Name
		end,

		-- Optional sorting function for the values. By default, the order the
		-- array is defined is the order that items will appear in the dropdown.
		-- This function allows you to change that order as you see fit
		sort = function(a: Enum.Font, b: Enum.Font)
			return a.Name > b.Name
		end,
	}),
}
```

### Slider

`slider(default: number?, range: NumberRange?): SliderControl`

Provides a range slider to include all possible values.

Parameter defaults:

- `default = 0`
- `range = NumberRange.new(0, 100)`

Example:

```lua
control = {
	slider = Flipbook.slider()

	percent = Flipbook.slider(0, NumberRange.new(0, 1)),
}
```

### String

`string(default: string?, options: StringOptions?): StringControl`

Provides a freeform text input field.

Example:

```lua
controls = {
	text = Flipbook.string(),

	greeting = Flipbook.string("Hello, World!"),

	constraint = Flipbook.string("OnlyTwentyCharacters", {
		validate = function(input)
			return input:len() <= 20
		end
	})
}
```

# Scratchpad

```lua
local Flipbook = {} -- require(ReplicatedStorage.Packages.Flipbook)

local controls: Flipbook.StoryControls = {
	-- Provides a numeric input to include the range of all possible values
	number = Flipbook.number(1),

	-- Provides a range slider to include all possible values
	percent = Flipbook.slider(NumberRange.new(0, 100), 0, 5),

	-- Provides a toggle for switching between possible states
	toggle = Flipbook.boolean(),

	-- Provides a freeform text input field
	text = Flipbook.string(),

	-- Provides a dropdown list for single value selection.
	font = Flipbook.select({
		Enum.Font.BuilderSans,
		Enum.Font.BuilderSansBold,
		Enum.Font.BuilderSansExtraBold,
	}, {
		-- Optional default value.
		default = Enum.Font.BuilderSansBold,

		-- Optional function for mapping each of the possible values to a
		-- human-friendly string. This is what shows up when interacting with
		-- the dropdown.
		tostring = function(font)
			return font.Name
		end,

		-- Optional sorting function for the values. By default, the order the
		-- array is defined is the order that items will appear in the dropdown.
		-- This function allows you to change that order as you see fit
		sort = function(a: Enum.Font, b: Enum.Font)
			return a.Name > b.Name
		end,
	}),

	-- Provides a dropdown list that allows multiple selected values
	dogAttributes = Flipbook.multiSelect({
		"Big",
		"Small",
		"Fluffy",
		"Sniffer",
	}, {
		default = { "Big", "Sniffer", },
	}),

	-- Provides a set of radio buttons for making a single selection
	sortDirection = Flipbook.radio({
		Enum.SortDirection.Ascending,
		Enum.SortDirection.Descending,
	}),

	-- Provides a set of checkboxes for making multiple selections
	tags = Flipbook.check({ "Cool", "Cute", "Quirky" }),

	-- Provides a color picker for selecting different colors
	colorPicker = Flipbook.color(), -- (default: (Color3 | string)?) -> ColorControl

	-- Provides a date picker for selecting different dates and times
	datePicker = Flipbook.date(), -- (default: (DateTime | string)?) -> DateControl
}

return {
	controls = controls,
}
```
