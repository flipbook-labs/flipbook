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

type Props = {
	storybooks: { types.Storybook },
	selectStory: (types.Story) -> nil,
}

local function Sidebar(props: Props, hooks: any)
	local theme = useTheme(hooks)

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

	return Roact.createElement(Panel, {}, {
		ScrollingFrame = Roact.createElement(
			"ScrollingFrame",
			Llama.Dictionary.join(styles.ScrollingFrame, {
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
			}),
			children
		),
	})
end

return RoactHooks.new(Roact)(Sidebar)
