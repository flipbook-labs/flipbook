local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local CodeBlock = require("@root/Common/CodeBlock")
local ScrollingFrame = require("@root/Common/ScrollingFrame")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

type UnavailableStorybook = Storyteller.UnavailableStorybook

export type Props = {
	unavailableStorybook: UnavailableStorybook,
	layoutOrder: number?,
}

local function StorybookError(props: Props)
	local theme = useTheme()

	local storybookSource = props.unavailableStorybook.storybook.source.Source

	return React.createElement(ScrollingFrame, {
		ScrollingDirection = Enum.ScrollingDirection.XY,
		LayoutOrder = props.layoutOrder,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = theme.paddingLarge,
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = theme.paddingLarge,
			PaddingRight = theme.paddingLarge,
			PaddingBottom = theme.paddingLarge,
			PaddingLeft = theme.paddingLarge,
		}),

		MainText = React.createElement("TextLabel", {
			LayoutOrder = nextLayoutOrder(),
			Text = `Failed to load {props.unavailableStorybook.storybook.name}`,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			TextColor3 = theme.text,
			TextSize = theme.textSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		}),

		Problem = React.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextLayoutOrder(),
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = theme.padding,
			}),

			Title = React.createElement("TextLabel", {
				LayoutOrder = nextLayoutOrder(),
				Text = "Error",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.headerFont,
				TextColor3 = theme.text,
				TextSize = theme.headerTextSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),

			CodeBlock = React.createElement(CodeBlock, {
				source = props.unavailableStorybook.problem,
				sourceColor = theme.alert,
				layoutOrder = nextLayoutOrder(),
			}),
		}),

		StorybookSource = React.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextLayoutOrder(),
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = theme.padding,
			}),

			Title = React.createElement("TextLabel", {
				LayoutOrder = nextLayoutOrder(),
				Text = "Storybook Source",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.headerFont,
				TextColor3 = theme.text,
				TextSize = theme.headerTextSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),

			CodeBlock = React.createElement(CodeBlock, {
				source = storybookSource,
				layoutOrder = nextLayoutOrder(),
			}),
		}),
	})
end

return StorybookError
