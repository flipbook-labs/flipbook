---
aliases: [Controls]
linter-yaml-title-alias: Controls
---

# Controls

Stories can define controls that make it possible to quickly test out the behavior and variants of the UI you're working on.

Here's an example React component that we will build a Story around. The props it takes in will be configurable by the Story's controls.

```code-sample
workspace/code-samples/src/React/ReactButtonControls.luau
```

The Story creates the element and passes in controls through the `props` argument.

```code-sample
workspace/code-samples/src/React/ReactButtonControls.story.luau
```

Opening the `ReactButtonControls` Story in Flipbook will include an accompanying panel for configuring the controls.

![[button-with-controls.png]]

As controls are modified the Story will live-reload with the new props.

![[button-with-controls-changed.png]]

Controls aren't specific to React. The same `controls` and `props.controls` pattern works with the function-based renderer and plain Roblox Instances:

```code-sample
workspace/code-samples/src/Default/ButtonWithControls.story.luau
```

## Simple Controls

The quickest way to declare a control is to give it a starting value. Flipbook infers the control from the value's type:

```lua
controls = {
	label = "Click Me", -- text input
	isDisabled = false, -- toggle
	count = 3, -- number input
}
```

## Richer Controls

When a control needs more than a starting value, such as a fixed set of options, a numeric range, or a color, use the constructor functions exported by [[concepts/storyteller|Storyteller]]. Each returns a control definition that goes in the same `controls` table, so simple and constructor-based controls can be mixed freely:

```lua
local Storyteller = require(path.to.Storyteller)

controls = {
	label = "Click Me",
	size = Storyteller.createSliderControl(16, NumberRange.new(8, 32), 1),
	weight = Storyteller.createSelectControl({ "Light", "Regular", "Bold" }),
}
```

> [!tip]
> The constructors come from Storyteller, which also provides the types for [[usage/typechecking|typechecking]] your Stories. See [[usage/frameworks/index|Frameworks]] for more on the relationship between Storyteller and Flipbook.

## Control Types

Every control accepts an optional `default`. The number-based controls add `range` and `step`; the list-based controls take an `items` array and an options table (`default`, a `tostring` label formatter, and `sort`).

| Control     | Declaration                                                                 | Value                    |
| ----------- | --------------------------------------------------------------------------- | ------------------------ |
| Boolean     | inferred from a `boolean`, or `createBooleanControl(default?)`              | `boolean`                |
| String      | inferred from a `string`, or `createStringControl(default?)`                | `string`                 |
| Number      | inferred from a `number`, or `createNumberControl(default?, range?, step?)` | `number`                 |
| Slider      | `createSliderControl(default?, range?, step?)`                              | `number`                 |
| Select      | `createSelectControl(items, options?)`                                      | one value from `items`   |
| Radio       | `createRadioControl(items, options?)`                                       | one value from `items`   |
| MultiSelect | `createMultiSelectControl(items, options?)`                                 | many values from `items` |
| Check       | `createCheckControl(items, options?)`                                       | many values from `items` |
| Color       | `createColorControl(default?)`                                              | `Color3`                 |
| Date        | `createDateControl(default?)`                                               | `DateTime`               |
| Object      | `createObjectControl(default?)`                                             | `Instance`               |

A control's value is always a `boolean`, `number`, `string`, `Color3`, `DateTime`, `EnumItem`, or `Instance`, or an array of these for the multi-select controls.

## Migrating Existing Controls

Flipbook automatically migrates controls written in [UI Labs](https://github.com/PepeElToro41/ui-labs)' schema or an older Storyteller schema when it loads your Story, so controls authored for those keep working without changes. A dedicated [[usage/migration-guides/index|migration guide]] covers converting them to the native schema.

> [!seealso]
> [[usage/writing-stories|Writing Stories]] · [[usage/typechecking|Typechecking]] · [[api/story-format|Story Format]]
