local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)
local Roact = require(flipbook.Packages.Roact)
local constants = require(flipbook.constants)
local hook = require(flipbook.hook)
local styles = require(flipbook.styles)
local themes = require(flipbook.themes)
local types = require(flipbook.types)
local createStoryNodes = require(flipbook.Story.createStoryNodes)
local Branding = require(script.Parent.Branding)
local Explorer = require(script.Parent.Explorer)
local Searchbar = require(script.Parent.Searchbar)

local e = Roact.createElement

type Props = {
	layoutOrder: number?,
	selectStory: (ModuleScript) -> (),
	selectStorybook: (types.Storybook) -> (),
	storybooks: { types.Storybook },
}

local function Sidebar(props: Props, hooks: any)
	local activeNode, setActiveNode = hooks.useState(nil)

	local onNodeActivated = hooks.useCallback(function(node: Explorer.Node)
		if node.instance and node.instance:IsA("ModuleScript") and node.name:match(constants.STORY_NAME_PATTERN) then
			if node.storybook then
				props.selectStorybook(node.storybook)
			end
			props.selectStory(node.instance)
			setActiveNode(node)
		end
	end, {})

	local storybookNodes = hooks.useMemo(function()
		return createStoryNodes(props.storybooks)
	end, { props.storybooks })

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, 230, 1, 0),
	}, {
		UIPadding = e("UIPadding", {
			PaddingBottom = styles.LARGE_PADDING,
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 0),
			PaddingTop = styles.LARGE_PADDING,
		}),

		Branding = e(Branding, {
			position = UDim2.fromOffset(20, 0),
			size = 22,
			tag = if constants.IS_DEV_MODE then "DEV" else nil,
			tagColor = themes.Brand,
			tagSize = 8,
		}),

		Searchbar = e(Searchbar),

		Entries = e(
			"ScrollingFrame",
			Llama.Dictionary.merge(styles.ScrollingFrame, {
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 102),
				Size = UDim2.new(1, 0, 1, -102),
			}),
			{
				Explorer = e(Explorer, {
					activeNode = activeNode,
					nodes = storybookNodes,
					onNodeActivated = onNodeActivated,
				}),
			}
		),
	})
end

return hook(Sidebar)
