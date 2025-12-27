local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryControls = require("@root/Storybook/StoryControls")

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
					string = {
						control = ControlType.String,
						default = "bar",
						placeholder = "Some cool text...",
					},
					boolean = {
						control = ControlType.Boolean,
						default = false,
					},
					number = {
						control = ControlType.Number,
						default = 10,
						step = 1,
						range = NumberRange.new(1, 100),
					},
					range = {
						control = ControlType.Slider,
						default = 1,
						step = 1,
						range = NumberRange.new(1, 100),
					},
					select = {
						control = ControlType.Select,
						mapping = Enum.Font,
						options = Sift.List.map(Enum.Font:GetEnumItems(), function(font)
							return font.Name
						end),
					},
					multiSelect = {
						control = ControlType.MultiSelect,
						options = {
							"Option 1",
							"Option 2",
							"Option 3",
						},
					},
					check = {
						control = ControlType.Check,
						options = {
							"Option 1",
							"Option 2",
							"Option 3",
						},
					},
					radio = {
						control = ControlType.Radio,
						options = {
							"Option 1",
							"Option 2",
							"Option 3",
						},
					},
					color = {
						control = ControlType.Color,
						default = Color3.fromRGB(255, 0, 200),
					},
					date = {
						control = ControlType.Date,
						default = DateTime.now(),
					},
					onlyTwentyCharacters = {
						control = ControlType.String,
						default = "OnlyTwentyCharacters",
					},
					badControlType = function() end,
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
