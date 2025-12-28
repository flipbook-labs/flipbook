local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local createBooleanControl = require("@root/StoryControls/Creators/createBooleanControl")
local createCheckControl = require("@root/StoryControls/Creators/createCheckControl")
local createColorControl = require("@root/StoryControls/Creators/createColorControl")
local createDateControl = require("@root/StoryControls/Creators/createDateControl")
local createMultiSelectControl = require("@root/StoryControls/Creators/createMultiSelectControl")
local createNumberControl = require("@root/StoryControls/Creators/createNumberControl")
local createRadioControl = require("@root/StoryControls/Creators/createRadioControl")
local createSelectControl = require("@root/StoryControls/Creators/createSelectControl")
local createSliderControl = require("@root/StoryControls/Creators/createSliderControl")
local createStringControl = require("@root/StoryControls/Creators/createStringControl")

local StoryControls = require("./StoryControls")

return {
	summary = "Panel for configuring the controls of a story",
	story = function(props)
		local controls, setControls = React.useState({})

		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
			overlayGui = props.container,
		}, {
			StoryControls = React.createElement(StoryControls, {
				controlsSchema = {
					string = createStringControl("Hello, World!"),
					boolean = createBooleanControl(false),
					number = createNumberControl(10, NumberRange.new(1, 100), 1),
					range = createSliderControl(1, NumberRange.new(1, 100), 1),
					select = createSelectControl(
						Sift.List.map(Enum.Font:GetEnumItems(), function(font)
							return font.Name
						end),
						Sift.List.reduce(Enum.Font:GetEnumItems(), function(mapping, font)
							mapping[font.Name] = font
							return mapping
						end, {})
					),
					multiSelect = createMultiSelectControl({
						"Option 1",
						"Option 2",
						"Option 3",
					}),
					check = createCheckControl({
						"Option 1",
						"Option 2",
						"Option 3",
					}),
					radio = createRadioControl({
						"Option 1",
						"Option 2",
						"Option 3",
					}),
					color = createColorControl(Color3.fromRGB(255, 0, 200)),
					date = createDateControl(DateTime.now()),
					onlyTwentyCharacters = createStringControl("OnlyTwentyCharacters"),
					badControlType = function() end :: any,
				},
				controls = controls,
				setControl = function(key, value)
					setControls(function(prev)
						local new = table.clone(prev)
						new[key] = value
						return new
					end)
				end,
			}),
		})
	end,
}
