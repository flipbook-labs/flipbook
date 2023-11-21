local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local SelectableTextLabel = require(flipbook.Components.SelectableTextLabel)
local useTheme = require(flipbook.Hooks.useTheme)

export type Props = {
	err: string,
	layoutOrder: number?,
}

local function StoryError(props: Props)
	local theme = useTheme()

	return React.createElement(SelectableTextLabel, {
		LayoutOrder = props.layoutOrder,
		Text = props.err,
		TextColor3 = theme.alert,
	})
end

return StoryError
