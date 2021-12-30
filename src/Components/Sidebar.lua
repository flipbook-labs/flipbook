local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local t = require(script.Parent.Parent.Packages.t)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

local STORY_LABEL_SIZE = 32 -- px

local validateProps = t.interface({
	stories = t.array(t.instance("ModuleScript")),
	maxSize = t.optional(t.Vector2),
})

type Props = {
	stories: { ModuleScript },
	maxSize: Vector2?,
}

local defaultProps: Props = {
	maxSize = Vector2.new(math.huge, math.huge),
}

local function Sidebar(props: Props, hooks: any)
	props = Llama.Dictionary.join(defaultProps, props)

	assert(validateProps(props))

	local theme = useTheme(hooks)

	local onStorySelected = hooks.useCallback(function(rbx: TextButton)
		print(rbx.Text, "selected")
	end, {})

	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	children.SizeConstraint = Roact.createElement("UISizeConstraint", {
		MaxSize = props.maxSize,
	})

	for index, story in ipairs(props.stories) do
		local name = story.Name:gsub("%.story", "")

		children[name] = Roact.createElement("TextButton", {
			LayoutOrder = index,
			Size = UDim2.new(1, 0, 0, STORY_LABEL_SIZE),
			Text = name,
			TextXAlignment = Enum.TextXAlignment.Left,
			[Roact.Event.Activated] = onStorySelected,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
			}),
		})
	end

	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		CanvasSize = UDim2.fromScale(1, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
	}, children)
end

return RoactHooks.new(Roact)(Sidebar)
