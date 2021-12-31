local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local t = require(script.Parent.Parent.Packages.t)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local styles = require(script.Parent.Parent.styles)

local STORY_LABEL_SIZE = 32 -- px

local validateProps = t.interface({
	stories = t.array(t.instance("ModuleScript")),
})

type Props = {
	stories: { ModuleScript },
	selectStory: () -> nil,
}

local function Sidebar(props: Props, hooks: any)
	assert(validateProps(props))

	local theme = useTheme(hooks)

	local onStorySelected = hooks.useCallback(function(rbx: TextButton)
		props.selectStory(rbx.Text)
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

	return Roact.createElement(
		"ScrollingFrame",
		Llama.Dictionary.join(styles.ScrollingFrame, {
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		}),
		children
	)
end

return RoactHooks.new(Roact)(Sidebar)
