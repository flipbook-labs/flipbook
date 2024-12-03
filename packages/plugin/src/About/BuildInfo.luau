local React = require("@pkg/React")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local BUILD_INFO = {
	{ label = "Version", value = _G.BUILD_VERSION },
	{ label = "Channel", value = _G.BUILD_CHANNEL },
	{ label = "Hash", value = _G.BUILD_HASH },
}

export type Props = {
	layoutOrder: number?,
}

local function BuildInfo(props: Props)
	local theme = useTheme()

	local children: { [string]: React.Node } = {}
	for _, info in BUILD_INFO do
		children[info.label] = React.createElement("TextLabel", {
			LayoutOrder = nextLayoutOrder(),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.font,
			Text = `{info.label}: {info.value}`,
			TextColor3 = theme.textSubtitle,
			TextSize = theme.textSize,
		})
	end

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = theme.paddingSmall,
		}),
	}, children)
end

return BuildInfo
