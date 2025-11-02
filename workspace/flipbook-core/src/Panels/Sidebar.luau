local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local StorybookTreeView = require("@root/Storybook/StorybookTreeView")
local Storyteller = require("@pkg/Storyteller")

local createOnboardingStorybook = require("@root/Storybook/createOnboardingStorybook")
local getMostLikelyProjectSources = require("@root/RobloxInternal/getMostLikelyProjectSources")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local IconName = Foundation.Enums.IconName
local InputSize = Foundation.Enums.InputSize
local ScrollView = Foundation.ScrollView
local TextInput = Foundation.TextInput
local View = Foundation.View
local withCommonProps = Foundation.Utility.withCommonProps

local e = React.createElement
local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState

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

	-- Right now we just respond to available storybook changes. This should be
	-- updated into a `useOrphanedStoryModules` hook that will update based on
	-- .story modules being added/removed from the DM.
	local orphanedStoryModules = useMemo(function()
		return Storyteller.findOrphanedStoryModules(game, props.storybooks.available)
	end, { props.storybooks.available })

	return e(
		View,
		withCommonProps(props, {
			tag = "bg-surface-0 col size-full",
		}),
		{
			Search = e(View, {
				LayoutOrder = nextLayoutOrder(),
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

			--if #props.storybooks.available == 0
			CreateStorybook = React.createElement(Foundation.Button, {
				text = "Create Storybook",
				onActivated = function()
					local source = getMostLikelyProjectSources()[1]

					if source then
						createOnboardingStorybook(source.Name, source)
					else
						createOnboardingStorybook(string.gsub(game.Name, "%.", "_"), ReplicatedStorage)
					end
				end,
				LayoutOrder = nextLayoutOrder(),
			}),

			Content = e(ScrollView, {
				LayoutOrder = nextLayoutOrder(),
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
					orphanedStoryModules = orphanedStoryModules,
					searchTerm = searchTerm,
					storybooks = props.storybooks,
				}),
			}),
		}
	)
end

return React.memo(Sidebar)
