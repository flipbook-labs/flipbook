local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local StoryControls = require("./StoryControls")

local useCallback = React.useCallback
local useState = React.useState

return {
	summary = "Panel for configuring the controls of a story",
	story = function(props)
		local controls, setControls = useState({} :: Storyteller.StoryControls)

		local setControl = useCallback(function(key: string, value: any)
			setControls(function(prev)
				local new = table.clone(prev)
				new[key] = value
				return new
			end)
		end, {})

		local controlsSchema: Storyteller.StoryControlsSchema = {
			text = Storyteller.createStringControl(),

			number = Storyteller.createNumberControl(),
			slider = Storyteller.createSliderControl(0, NumberRange.new(0, 100)),

			toggle = Storyteller.createBooleanControl(),

			font = Storyteller.createSelectControl({
				Enum.Font.BuilderSans,
				Enum.Font.BuilderSansBold,
				Enum.Font.BuilderSansExtraBold,
			}, {
				default = Enum.Font.BuilderSansBold :: EnumItem,
				tostring = function(font)
					if typeof(font) == "EnumItem" then
						return font.Name
					end
					return tostring(font)
				end,
				sort = function(a, b)
					if typeof(a) == "EnumItem" and typeof(b) == "EnumItem" then
						return a.Name > b.Name
					end
					return a < b
				end,
			}),

			dogAttributes = Storyteller.createMultiSelectControl({
				"Big",
				"Small",
				"Fluffy",
				"Sniffer",
			}, {
				default = { "Big", "Sniffer" },
			}),

			tags = Storyteller.createCheckControl({
				"Cool",
				"Cute",
				"Quirky",
			}),

			sortDirection = Storyteller.createRadioControl({
				Enum.SortDirection.Ascending,
				Enum.SortDirection.Descending,
			}, {
				tostring = function(item)
					if typeof(item) == "EnumItem" then
						return item.Name
					end
					return tostring(item)
				end,
			}),

			color = Storyteller.createColorControl(),
			date = Storyteller.createDateControl(),
		}

		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
			overlayGui = props.container,
		}, {
			StoryControls = React.createElement(StoryControls, {
				controlsSchema = controlsSchema,
				controls = controls,
				setControl = setControl,
			}),
		})
	end,
}
