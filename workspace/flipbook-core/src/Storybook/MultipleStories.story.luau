local React = require("@pkg/React")

local controls = {
	label = "Multiple stories work",
}

type Props = {
	controls: typeof(controls),
}

local function createStory(backgroundColor: Color3)
	return function(props: Props)
		return React.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = backgroundColor,
			BorderSizePixel = 0,
			Font = Enum.Font.BuilderSans,
			Text = props.controls.label,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 24,
		})
	end
end

return {
	name = "Multiple Stories",
	controls = controls,
	stories = {
		{
			id = "primary",
			name = "Primary",
			summary = "The first Story in an ordered array.",
			story = createStory(Color3.fromRGB(0, 162, 255)),
		},
		{
			id = "secondary",
			name = "Secondary",
			summary = "The second Story inherits the module controls.",
			story = createStory(Color3.fromRGB(163, 75, 255)),
		},
	},
}
