local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local Branding = require("@root/Common/Branding")
local Button = require("@root/Forms/Button")
local ScrollingFrame = require("@root/Common/ScrollingFrame")
local Searchbar = require("@root/Forms/Searchbar")
local StorybookTreeView = require("@root/Storybook/StorybookTreeView")
local createOnboardingStorybook = require("@root/Storybook/createOnboardingStorybook")
local getMostLikelyProjectSources = require("@root/RobloxInternal/getMostLikelyProjectSources")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local e = React.createElement

type Props = {
	layoutOrder: number?,
	onStoryChanged: (storyModule: ModuleScript?, storybook: LoadedStorybook?) -> (),
	onShowErrorPage: (unavailableStorybook: UnavailableStorybook) -> (),
	storybooks: {
		avialable: { LoadedStorybook },
		unavailable: { UnavailableStorybook },
	},
}

local function Sidebar(props: Props)
	local theme = useTheme()

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
			VerticalFlex = Enum.UIFlexAlignment.Fill,
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
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(1, 0),
		}, {
			FlexItem = React.createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Grow,
			}),

			UIListLayout = e("UIListLayout", {
				Padding = theme.paddingLarge,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Branding = e(Branding, {
				layoutOrder = nextLayoutOrder(),
			}),

			Searchbar = e(Searchbar, {
				layoutOrder = nextLayoutOrder(),
				onSearchChanged = onSearchChanged,
			}),

			--if #props.storybooks.available == 0
			CreateStorybook = React.createElement(Button, {
				layoutOrder = nextLayoutOrder(),
				text = "Create Storybook",
				onClick = function()
					local source = getMostLikelyProjectSources()[1]

					if source then
						createOnboardingStorybook(source.Name, source)
					else
						createOnboardingStorybook(string.gsub(game.Name, "%.", "_"), ReplicatedStorage)
					end
				end,
			}),
		}),

		ScrollingFrame = e(ScrollingFrame, {
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(1, 1),
		}, {
			FlexItem = React.createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Shrink,
			}),

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
