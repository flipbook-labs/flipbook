local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local Dropdown = require("@root/Forms/Dropdown")
local MockPlugin = require("@root/Testing/MockPlugin")

local controls = {
	useDefault = true,
	numOptions = 3,
}

type Props = {
	controls: typeof(controls),
}

return {
	controls = controls,
	story = function(props: Props)
		local options = {}
		for i = 1, props.controls.numOptions do
			table.insert(options, "Option " .. i)
		end

		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			Dropdown = React.createElement(Dropdown, {
				placeholder = "Select an option",
				default = if props.controls.useDefault then options[1] else nil,
				options = options,
				onOptionChange = function(option)
					print("Selected", option)
				end,
			}),
		})
	end,
}
