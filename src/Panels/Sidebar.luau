local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local Branding = require("@root/Common/Branding")
local ScrollingFrame = require("@root/Common/ScrollingFrame")
local Searchbar = require("@root/Forms/Searchbar")
local StorybookTreeView = require("@root/Storybook/StorybookTreeView")
local useTheme = require("@root/Common/useTheme")

type LoadedStorybook = Storyteller.LoadedStorybook

local e = React.createElement

type Props = {
	layoutOrder: number?,
	onStoryChanged: (storyModule: ModuleScript?, storybook: LoadedStorybook?) -> (),
	storybooks: { LoadedStorybook },
}

local function Sidebar(props: Props)
	local theme = useTheme()

	local headerHeight, setHeaderHeight = React.useState(0)
	local onHeaderSizeChanged = React.useCallback(function(rbx: Frame)
		setHeaderHeight(rbx.AbsoluteSize.Y)
	end, { setHeaderHeight })

	local search: string?, setSearch = React.useState(nil :: string?)
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
			StorybookTreeView = e(StorybookTreeView, {
				searchTerm = search,
				storybooks = props.storybooks,
				onStoryChanged = props.onStoryChanged,
			}),
		}),
	})
end

return Sidebar
