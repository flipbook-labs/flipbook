local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local createOnboardingStorybook = require("@root/Storybook/createOnboardingStorybook")
local getMostLikelyProjectSources = require("@root/RobloxInternal/getMostLikelyProjectSources")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement

export type Props = {
	availableStorybooks: { Storyteller.LoadedStorybook },
}

local function NoStorySelected(props)
	local tokens = useTokens()

	return e(Foundation.View, {
		tag = "size-full col bg-surface-200 gap-xlarge align-y-center align-x-center",
	}, {
		MainContent = e(Foundation.View, {
			tag = "auto-xy col gap-medium align-x-center",
			LayoutOrder = nextLayoutOrder(),
	}, {
		Icon = e(Foundation.Icon, {
			name = Foundation.Enums.IconName.SquareBooks,
			style = tokens.Color.ActionStandard.Foreground,
			size = Foundation.Enums.IconSize.Large,
			LayoutOrder = nextLayoutOrder(),
		}),

		Message = e(Foundation.Text, {
			tag = "auto-xy text-heading-medium",
			Text = "Select a story to preview it",
			LayoutOrder = nextLayoutOrder(),
			}),
		}),

		CreateStorybook = if #props.availableStorybooks == 0
			then e(Foundation.Button, {
				text = "Create your first Storybook",
				variant = Foundation.Enums.ButtonVariant.Emphasis,
				onActivated = function()
					local source = getMostLikelyProjectSources()[1]

					if source then
						createOnboardingStorybook(source.Name, source)
					else
						createOnboardingStorybook(string.gsub(game.Name, "%.", "_"), ReplicatedStorage)
					end
				end,
				LayoutOrder = nextLayoutOrder(),
			})
			else nil,
	})
end

return NoStorySelected
