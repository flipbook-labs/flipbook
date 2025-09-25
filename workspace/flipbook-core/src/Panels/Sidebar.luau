local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local Branding = require("@root/Common/Branding")
local Searchbar = require("@root/Forms/Searchbar")
local StorybookTreeView = require("@root/Storybook/StorybookTreeView")
local createOnboardingStorybook = require("@root/Storybook/createOnboardingStorybook")
local getMostLikelyProjectSources = require("@root/RobloxInternal/getMostLikelyProjectSources")
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

			Searchbar = e(Searchbar, {
				layoutOrder = nextLayoutOrder(),
				onSearchChanged = onSearchChanged,
			}),

			--if #props.storybooks.available == 0
			CreateStorybook = React.createElement(Foundation.Button, {
				layoutOrder = nextLayoutOrder(),
				text = "Create Storybook",
				onActivated = function()
					local source = getMostLikelyProjectSources()[1]

					if source then
						createOnboardingStorybook(source.Name, source)
					else
						createOnboardingStorybook(string.gsub(game.Name, "%.", "_"), ReplicatedStorage)
					end
				end,
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
				onStoryChanged = props.onStoryChanged,
				onShowErrorPage = props.onShowErrorPage,
			}),
		}),
	})
end

return Sidebar
