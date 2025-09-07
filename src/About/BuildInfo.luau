local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local BUILD_INFO = {
	{ label = "Version", value = _G.BUILD_VERSION },
	{ label = "Channel", value = _G.BUILD_CHANNEL },
	{ label = "Hash", value = _G.BUILD_HASH },
}

export type Props = {
	layoutOrder: number?,
}

local function BuildInfo(props: Props)
	local children: { [string]: React.Node } = {}
	for _, info in BUILD_INFO do
		children[info.label] = React.createElement(Foundation.Text, {
			tag = "auto-xy text-body-medium",
			LayoutOrder = nextLayoutOrder(),
			Text = `{info.label}: {info.value}`,
		})
	end

	return React.createElement(Foundation.View, {
		tag = "auto-xy col gap-medium align-x-center",
		LayoutOrder = props.layoutOrder,
	}, children)
end

return BuildInfo
