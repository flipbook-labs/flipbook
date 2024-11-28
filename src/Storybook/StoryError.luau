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
	}, {
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
	})
end

return StoryError
