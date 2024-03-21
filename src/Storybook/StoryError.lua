local React = require("@pkg/React")
local SelectableTextLabel = require("@root/Forms/SelectableTextLabel")
local useTheme = require("@root/Common/useTheme")

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
