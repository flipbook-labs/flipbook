local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local constants = require(flipbook.constants)
local createStoryNodes = require(flipbook.Story.createStoryNodes)
local Branding = require(flipbook.Components.Branding)
local ComponentTree = require(flipbook.Components.ComponentTree)
local Searchbar = require(flipbook.Components.Searchbar)
local ScrollingFrame = require(flipbook.Components.ScrollingFrame)
local useTheme = require(flipbook.Hooks.useTheme)
local types = require(script.Parent.Parent.types)

local e = Roact.createElement

type Props = {
	layoutOrder: number?,
	selectStory: (ModuleScript) -> (),
	selectStorybook: (types.Storybook) -> (),
	storybooks: { types.Storybook },
}

local function Sidebar(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local activeNode, setActiveNode = hooks.useState(nil)
	local onClick = hooks.useCallback(function(node: ComponentTree.Node)
		if node.instance and node.instance:IsA("ModuleScript") and node.name:match(constants.STORY_NAME_PATTERN) then
			if node.storybook then
				props.selectStorybook(node.storybook)
			end
			props.selectStory(node.instance)
			setActiveNode(function(prevNode)
				return if prevNode ~= node then node else nil
			end)
		end
	end, {})

	local storybookNodes = hooks.useMemo(function()
		return createStoryNodes(props.storybooks)
	end, { props.storybooks })

	local headerHeight, setHeaderHeight = hooks.useState(0)
	local onHeaderSizeChanged = hooks.useCallback(function(rbx: Frame)
		setHeaderHeight(rbx.AbsoluteSize.Y)
	end, { setHeaderHeight })

	local search, setSearch = hooks.useState(nil)
	local onSearchChanged = hooks.useCallback(function(value: string)
		if value == "" then
			setSearch(nil)
		else
			setSearch(value)
		end
	end, {})

	return e("Frame", {
		BackgroundColor3 = theme.sidebar,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, 267, 1, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = theme.padding,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
			PaddingRight = theme.padding,
			PaddingTop = theme.padding,
		}),

		Header = e("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 0,
			Size = UDim2.fromScale(1, 0),
			[Roact.Change.AbsoluteSize] = onHeaderSizeChanged,
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = theme.paddingLarge,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Branding = e(Branding, {
				layoutOrder = 0,
			}),

			Searchbar = e(Searchbar, {
				layoutOrder = 1,
				onSearchChanged = onSearchChanged,
			}),
		}),

		ScrollingFrame = e(ScrollingFrame, {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, headerHeight),
		}, {
			ComponentTree = e(ComponentTree, {
				filter = search,
				activeNode = activeNode,
				nodes = storybookNodes,
				onClick = onClick,
			}),
		}),
	})
end

return hook(Sidebar)
