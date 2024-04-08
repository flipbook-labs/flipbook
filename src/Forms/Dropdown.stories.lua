local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Dropdown = require(flipbook.Forms.Dropdown)

local controls = {
	useDefault = true,
	numOptions = 3,
}

type Props = {
	controls: typeof(controls),
}

local stories = {}

stories.Primary = function(props: Props)
	local options = {}
	for i = 1, props.controls.numOptions do
		table.insert(options, "Option " .. i)
	end

	return React.createElement(Dropdown, {
		placeholder = "Select an option",
		default = if props.controls.useDefault then options[1] else nil,
		options = options,
		onOptionChange = function(option)
			print("Selected", option)
		end,
	})
end

return {
	controls = controls,
	stories = stories,
}
