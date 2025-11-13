local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local StorybookTreeView = require("@root/Storybook/StorybookTreeView")
local Storyteller = require("@pkg/Storyteller")

local IconName = Foundation.Enums.IconName
local InputSize = Foundation.Enums.InputSize
local ScrollView = Foundation.ScrollView
local TextInput = Foundation.TextInput
local View = Foundation.View
local withCommonProps = Foundation.Utility.withCommonProps

local e = React.createElement
local useCallback = React.useCallback
local useState = React.useState
local useOrphanedStoryModules = Storyteller.useOrphanedStoryModules

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

type SidebarProps = {
	onStoryChanged: (storyModule: ModuleScript?, storybook: LoadedStorybook?) -> (),
	onShowErrorPage: (unavailableStorybook: UnavailableStorybook) -> (),
	storybooks: {
		available: { LoadedStorybook },
		unavailable: { UnavailableStorybook },
	},
} & Foundation.CommonProps

local function Sidebar(props: SidebarProps)
	local searchTerm: string?, setSearchTerm = useState(nil :: string?)
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
				tag = "auto-y padding-x-medium padding-y-large size-full-0",
			}, {
				SearchBar = e(TextInput, {
					label = "",
					leadingIcon = IconName.MagnifyingGlass,
					onChanged = onSearchTermChanged,
					placeholder = "Search...",
					size = InputSize.Small,
					text = "",
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
				tag = "shrink size-full",
			}, {
				StorybookTreeView = e(StorybookTreeView, {
					onShowErrorPage = props.onShowErrorPage,
					onStoryChanged = props.onStoryChanged,
					searchTerm = searchTerm,
					storybooks = props.storybooks,
				}),
			}),
		}
	)
end

return React.memo(Sidebar)
