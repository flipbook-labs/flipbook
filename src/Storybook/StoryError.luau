local React = require("@pkg/React")

local CodeBlock = require("@root/Common/CodeBlock")
local ScrollingFrame = require("@root/Common/ScrollingFrame")
local useTheme = require("@root/Common/useTheme")

export type Props = {
	err: string,
	layoutOrder: number?,
}

local function StoryError(props: Props)
	local theme = useTheme()

	return React.createElement(ScrollingFrame, {
		ScrollingDirection = Enum.ScrollingDirection.XY,
		LayoutOrder = props.layoutOrder,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = theme.padding,
		}),

		Padding = React.createElement("UIPadding", {
			PaddingTop = theme.paddingSmall,
			PaddingRight = theme.paddingSmall,
			PaddingBottom = theme.paddingSmall,
			PaddingLeft = theme.paddingSmall,
		}),

		CodeBlock = React.createElement(CodeBlock, {
			source = props.err,
			sourceColor = theme.alert,
		}),
	})
end

return StoryError
