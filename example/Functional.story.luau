local Example = script:FindFirstAncestor("Example")

local constants = require(Example.Parent.constants)

local controls = {
	text = "Functional Story",
}

type Props = {
	controls: typeof(controls),
}

local stories = {}

stories.Primary = function(parent: GuiObject, props: Props)
	local label = Instance.new("TextLabel")
	label.Text = props.controls.text
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(0, 0, 0)
	label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 16
	label.AutomaticSize = Enum.AutomaticSize.XY

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingRight = padding.PaddingTop
	padding.PaddingBottom = padding.PaddingTop
	padding.PaddingLeft = padding.PaddingTop
	padding.Parent = label

	label.Parent = parent

	return function()
		label:Destroy()
	end
end

return {
	summary = "This story uses a function with a cleanup callback to create and mount the gui elements. This works similarly to Hoarcekat stories but also supports controls and other metadata. Check out the source to learn more",
	controls = controls,
	story = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then nil else stories.Primary,
	stories = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then stories else nil,
}
