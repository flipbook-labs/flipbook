local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryControls = require("@root/Storybook/StoryControls")

type ControlType =
	"String"
	| "Boolean"
	| "Number"
	| "Select"
	| "MultiSelect"
	| "Radio"
	| "InlineRadio"
	| "Check"
	| "InlineCheck"
	| "Color"
	| "Date"

local ControlType = {
	String = "String" :: "String",
	Boolean = "Boolean" :: "Boolean",
	Number = "Number" :: "Number",
	Select = "Select" :: "Select",
	MultiSelect = "MultiSelect" :: "MultiSelect",
	Radio = "Radio" :: "Radio",
	InlineRadio = "InlineRadio" :: "InlineRadio",
	Check = "Check" :: "Check",
	InlineCheck = "InlineCheck" :: "InlineCheck",
	Color = "Color" :: "Color",
	Date = "Date" :: "Date",
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
					foo = {
						control = ControlType.String,
						default = "bar",
						placeholder = "Some cool text...",
					},
					checkbox = {
						control = ControlType.Boolean,
						default = false,
					},
					number = {
						control = ControlType.Number,
						default = 10,
						step = 1,
						range = NumberRange.new(1, 100),
					},
					dropdown = {
						control = ControlType.Select,
						options = {
							"Option 1",
							"Option 2",
							"Option 3",
						},
					},
					font = {
						control = ControlType.Select,
						mapping = Enum.Font,
						options = Sift.List.map(Enum.Font:GetEnumItems(), function(font)
							return font.Name
						end),
					},
					color = {
						control = ControlType.Color,
						default = Color3.fromRGB(255, 0, 255),
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
