local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local createStoryNodes = require(script.Parent.Parent.Modules.createStoryNodes)
local constants = require(script.Parent.Parent.constants)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local Panel = require(script.Parent.Panel)
local TreeList = require(script.Parent.TreeList)
local SidebarToggle = require(script.Parent.SidebarToggle)

type Props = {
	isExpanded: boolean,
	width: NumberRange,
	storybooks: { types.Storybook },
	selectStory: (types.Story) -> nil,
	layoutOrder: number?,
	onToggleActivated: (() -> nil)?,
}

local function Sidebar(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local width = if props.isExpanded then props.width.Max else props.width.Min

	local onNodeActivated = hooks.useCallback(function(node: TreeList.Node)
		if node.instance and node.name:match(constants.STORY_NAME_PATTERN) then
			props.selectStory(node.instance)
		end
	end, {})

	local storybookNodes = hooks.useMemo(function()
		return createStoryNodes(props.storybooks)
	end, { props.storybooks })

	local children = {}

	children.StoryList = Roact.createElement(TreeList, {
		onNodeActivated = onNodeActivated,
		nodes = storybookNodes,
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, width, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Toggle = Roact.createElement(SidebarToggle, {
			isExpanded = props.isExpanded,
			onActivated = props.onToggleActivated,
			position = UDim2.fromScale(1, 0.5),
			anchorPoint = Vector2.new(0.5, 0.5),
		}),

		Panel = Roact.createElement(Panel, {}, {
			Layout = Roact.createElement("UIListLayout"),

			ScrollingFrame = Roact.createElement(
				"ScrollingFrame",
				Llama.Dictionary.join(styles.ScrollingFrame, {
					BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
				}),
				children
			),
		}),
	})
end

return RoactHooks.new(Roact)(Sidebar)
