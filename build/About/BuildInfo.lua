local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)

local nextLayoutOrder = require(script.Parent.Parent.Common.nextLayoutOrder)

local BUILD_INFO = {
	{ label = "Version", value = '2.2.0'},
	{ label = "Channel", value = 'production'},
	{ label = "Hash", value = 'fc8580b'},
}

export type Props = {
	layoutOrder: number?,
}

local function BuildInfo(props: Props)
	local children: { [string]: React.Node } = {}
	for _, info in BUILD_INFO do
		children[info.label] = React.createElement(Foundation.Text, {
			tag = "auto-xy text-body-medium content-muted",
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
