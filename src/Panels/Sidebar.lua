local React = require("@pkg/React")
local constants = require("@root/constants")
local createStoryNodes = require("@root/Storybook/createStoryNodes")
local Branding = require("@root/Common/Branding")
local ComponentTree = require("@root/Explorer")
local Searchbar = require("@root/Forms/Searchbar")
local ScrollingFrame = require("@root/Common/ScrollingFrame")
local useTheme = require("@root/Common/useTheme")
local storybookTypes = require("@root/Storybook/types")
local explorerTypes = require("@root/Explorer/types")

type Storybook = storybookTypes.Storybook
type ComponentTreeNode = explorerTypes.ComponentTreeNode

local e = React.createElement

type Props = {
	layoutOrder: number?,
	selectStory: (ModuleScript) -> (),
	selectStorybook: (Storybook) -> (),
	storybooks: { Storybook },
}

local function Sidebar(props: Props)
	local theme = useTheme()

	local activeNode, setActiveNode = React.useState(nil)
	local onClick = React.useCallback(function(node: ComponentTreeNode)
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

	local storybookNodes = React.useMemo(function()
		return createStoryNodes(props.storybooks)
	end, { props.storybooks })

	local headerHeight, setHeaderHeight = React.useState(0)
	local onHeaderSizeChanged = React.useCallback(function(rbx: Frame)
		setHeaderHeight(rbx.AbsoluteSize.Y)
	end, { setHeaderHeight })

	local search, setSearch = React.useState(nil)
	local onSearchChanged = React.useCallback(function(value: string)
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
		Size = UDim2.fromScale(1, 1),
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
			[React.Change.AbsoluteSize] = onHeaderSizeChanged,
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

return Sidebar
