local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)
local Storyteller = require(script.Parent.Parent.Packages.Storyteller)

local CodeBlock = require(script.Parent.Parent.Common.CodeBlock)
local nextLayoutOrder = require(script.Parent.Parent.Common.nextLayoutOrder)

local useTokens = Foundation.Hooks.useTokens

type UnavailableStorybook = Storyteller.UnavailableStorybook

export type Props = {
	unavailableStorybook: UnavailableStorybook,
	layoutOrder: number?,
}

local function StorybookError(props: Props)
	local tokens = useTokens()

	local storybookSource = props.unavailableStorybook.storybook.source.Source

	return React.createElement(Foundation.ScrollView, {
		tag = "size-full col padding-large gap-large",
		scroll = {
			ScrollingDirection = Enum.ScrollingDirection.XY,
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			CanvasSize = UDim2.fromScale(0, 0),
		},
		LayoutOrder = props.layoutOrder,
	}, {
		MainText = React.createElement(Foundation.Text, {
			tag = "auto-xy text-body-medium text-align-x-left",
			Text = `Failed to load {props.unavailableStorybook.storybook.name}`,
			LayoutOrder = nextLayoutOrder(),
		}),

		Problem = React.createElement(Foundation.View, {
			tag = "auto-xy gap-medium col",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Title = React.createElement(Foundation.Text, {
				tag = "auto-xy text-heading-medium",
				Text = "Error",
				LayoutOrder = nextLayoutOrder(),
			}),

			CodeBlock = React.createElement(CodeBlock, {
				source = props.unavailableStorybook.problem,
				sourceColor = tokens.Color.ActionAlert.Foreground.Color3,
				layoutOrder = nextLayoutOrder(),
			}),
		}),

		StorybookSource = React.createElement(Foundation.View, {
			tag = "auto-xy gap-medium col",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Title = React.createElement(Foundation.Text, {
				tag = "auto-xy text-heading-medium",
				Text = "Storybook Source",
				LayoutOrder = nextLayoutOrder(),
			}),

			CodeBlock = React.createElement(CodeBlock, {
				source = storybookSource,
				layoutOrder = nextLayoutOrder(),
			}),
		}),
	})
end

return StorybookError
