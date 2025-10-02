local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local Branding = require("@root/Common/Branding")
local StorybookTreeView = require("@root/Storybook/StorybookTreeView")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local e = React.createElement

type Props = {
	layoutOrder: number?,
	onStoryChanged: (storyModule: ModuleScript?, storybook: LoadedStorybook?) -> (),
	onShowErrorPage: (unavailableStorybook: UnavailableStorybook) -> (),
	storybooks: {
		available: { LoadedStorybook },
		unavailable: { UnavailableStorybook },
	},
}

local function Sidebar(props: Props)
	local search: string?, setSearch = React.useState(nil :: string?)
	local onSearchChanged = React.useCallback(function(value: string)
		if value == "" then
			setSearch(nil)
		else
			setSearch(value)
		end
	end, {})

	-- Right now we just respond to available storybook changes. This should be
	-- updated into a `useOrphanedStoryModules` hook that will update based on
	-- .story modules being added/removed from the DM.
	local orphanedStoryModules = React.useMemo(function()
		return Storyteller.findOrphanedStoryModules(game, props.storybooks.available)
	end, { props.storybooks.available })

	return e(Foundation.View, {
		tag = "size-full bg-surface-0 col gap-medium padding-medium flex-between",
		LayoutOrder = props.layoutOrder,
	}, {
		Header = e(Foundation.View, {
			tag = "size-full-0 auto-y col gap-xlarge",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Branding = e(Branding, {
				layoutOrder = nextLayoutOrder(),
			}),

			Searchbar = e(Foundation.TextInput, {
				label = "",
				text = "",
				placeholder = "Search...",
				iconLeading = Foundation.Enums.IconName.MagnifyingGlass,
				size = Foundation.Enums.InputSize.Small,
				width = UDim.new(1, 0),
				onChanged = onSearchChanged,
				LayoutOrder = nextLayoutOrder(),
			}),
		}),

		ScrollingFrame = e(Foundation.ScrollView, {
			tag = "size-full shrink",
			scroll = {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(1, 0),
				ScrollingDirection = Enum.ScrollingDirection.Y,
			},
			LayoutOrder = nextLayoutOrder(),
		}, {
			StorybookTreeView = e(StorybookTreeView, {
				searchTerm = search,
				storybooks = props.storybooks,
				orphanedStoryModules = orphanedStoryModules,
				onStoryChanged = props.onStoryChanged,
				onShowErrorPage = props.onShowErrorPage,
			}),
		}),
	})
end

return Sidebar
