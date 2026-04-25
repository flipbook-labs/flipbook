local React = require("@pkg/React")

local Group = require("@root/Group")

export type RootProps = {
	fillDirection: Enum.FillDirection?,
	children: React.Node?,
	LayoutOrder: number?,
}

local function Root(props: RootProps)
	return React.createElement(Group, {
		id = "<root>",
		fillDirection = props.fillDirection,
		LayoutOrder = props.LayoutOrder,
	}, props.children)
end

return React.memo(Root)
