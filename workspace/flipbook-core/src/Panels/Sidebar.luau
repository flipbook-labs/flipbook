local FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local StorybookTreeView = require("@root/Storybook/StorybookTreeView")

local InputSize = Foundation.Enums.InputSize
local ScrollView = Foundation.ScrollView
local SearchInput = Foundation.SearchInput
local View = Foundation.View
local withCommonProps = Foundation.Utility.withCommonProps

local e = React.createElement
local useCallback = React.useCallback
local useState = React.useState

type SidebarProps = Foundation.CommonProps

local function Sidebar(props: SidebarProps)
	local flipbookStore = FlipbookStoreContext.use()
	local launchData = flipbookStore.getLaunchData()
	local initialSearchTerm = if launchData then launchData.search else nil
	local searchTerm: string?, setSearchTerm = useState(initialSearchTerm)
	local onSearchTermChanged = useCallback(function(newSearchTerm: string)
		setSearchTerm(if newSearchTerm == "" then nil else newSearchTerm)
	end, {})

	return e(
		View,
		withCommonProps(props, {
			tag = "bg-surface-0 col size-full",
		}),
		{
			Search = e(View, {
				LayoutOrder = 1,
				tag = "auto-y padding-medium size-full-0",
			}, {
				SearchBar = e(SearchInput, {
					onChanged = onSearchTermChanged,
					placeholder = "Search...",
					size = InputSize.Small,
					text = searchTerm or "",
					width = UDim.new(1, 0),
				}),
			}),

			Content = e(ScrollView, {
				LayoutOrder = 2,
				scroll = {
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.fromScale(0, 0),
					ScrollingDirection = Enum.ScrollingDirection.Y,
				},
				layout = {
					FillDirection = Enum.FillDirection.Vertical,
				},
				tag = "shrink size-full",
			}, {
				StorybookTreeView = e(StorybookTreeView, {
					searchTerm = searchTerm,
				}),
			}),
		}
	)
end

return React.memo(Sidebar)
