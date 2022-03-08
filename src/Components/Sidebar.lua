local constants = require(script.Parent.Parent.constants)
local createStoryNodes = require(script.Parent.Parent.Modules.createStoryNodes)
local Explorer = require(script.Parent.Explorer)
local Llama = require(script.Parent.Parent.Packages.Llama)
local Panel = require(script.Parent.Panel)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local SidebarToggle = require(script.Parent.SidebarToggle)
local Branding = require(script.Parent.Branding)
local styles = require(script.Parent.Parent.styles)
local TreeList = require(script.Parent.TreeList)
local types = require(script.Parent.Parent.types)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

type Props = {
	isExpanded: boolean,
	width: NumberRange,
	storybooks: { types.Storybook },
	selectStory: (types.Story) -> (),
	selectStorybook: (types.Storybook) -> (),
	layoutOrder: number?,
	onToggleActivated: (() -> ())?,
}

local function Sidebar(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local width = if props.isExpanded then props.width.Max else props.width.Min
	local activeNode, setActiveNode = hooks.useState(nil)

	local onNodeActivated = hooks.useCallback(function(node: TreeList.Node)
		if node.instance and node.name:match(constants.STORY_NAME_PATTERN) then
			props.selectStorybook(node.storybook)
			props.selectStory(node.instance)
			setActiveNode(node)
		end
	end, {})

	local storybookNodes = hooks.useMemo(function()
		return createStoryNodes(props.storybooks)
	end, { props.storybooks })

	local children = {}

	children.StoryList = Roact.createElement(Explorer, {
		activeNode = activeNode,
		nodes = storybookNodes,
		onNodeActivated = onNodeActivated,
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, width, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Branding = Roact.createElement(Branding, {
			size = 22,
			position = UDim2.fromOffset(20, 20),
		}),

		Panel = Roact.createElement(Panel, {}, {
			Layout = Roact.createElement("UIListLayout"),

			ScrollingFrame = Roact.createElement(
				"ScrollingFrame",
				Llama.Dictionary.join(styles.ScrollingFrame, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}),
				children
			),
		}),
	})
end

return RoactHooks.new(Roact)(Sidebar)
