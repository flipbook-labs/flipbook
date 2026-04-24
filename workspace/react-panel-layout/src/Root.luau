local React = require("@pkg/React")

local Group = require("@root/Group")

export type RootProps = {
	fillDirection: Enum.FillDirection?,
	children: React.Node?,
}

local function Root(props: RootProps)
	return React.createElement(Group, {
		fillDirection = props.fillDirection,
	}, props.children)
end

return React.memo(Root)
