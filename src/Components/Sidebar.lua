local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local constants = require(flipbook.constants)
local createStoryNodes = require(flipbook.Story.createStoryNodes)
local Branding = require(flipbook.Components.Branding)
local ComponentTree = require(flipbook.Components.ComponentTree)
local Searchbar = require(flipbook.Components.Searchbar)
local ScrollingFrame = require(flipbook.Components.ScrollingFrame)
local types = require(script.Parent.Parent.types)

local e = Roact.createElement

type Props = {
	layoutOrder: number?,
	selectStory: (ModuleScript) -> (),
	selectStorybook: (types.Storybook) -> (),
	storybooks: { types.Storybook },
}

local function Sidebar(props: Props, hooks: any)
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

	return e("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, 267, 1, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
			PaddingTop = UDim.new(0, 16),
		}),

		Header = e("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 0,
			Size = UDim2.fromScale(1, 0),
			[Roact.Change.AbsoluteSize] = onHeaderSizeChanged,
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0, 20),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Branding = e(Branding, {
				layoutOrder = 0,
			}),

			Searchbar = e(Searchbar, {
				layoutOrder = 1,
			}),
		}),

		ScrollingFrame = e(ScrollingFrame, {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, headerHeight),
		}, {
			ComponentTree = e(ComponentTree, {
				activeNode = activeNode,
				nodes = storybookNodes,
				onClick = onClick,
			}),
		}),
	})
end

return hook(Sidebar)
