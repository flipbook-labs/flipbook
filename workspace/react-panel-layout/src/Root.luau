local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Group = require("@root/Group")
local constants = require("@root/constants")

export type RootProps = {
	fillDirection: Enum.FillDirection?,
	children: React.Node?,
	LayoutOrder: number?,
}

local defaultProps = {
	fillDirection = Enum.FillDirection.Horizontal,
}

local function Root(rootProps: RootProps)
	local props = Sift.Dictionary.join(defaultProps, rootProps)

	return React.createElement(Group, {
		id = constants.ROOT_ID,
		fillDirection = props.fillDirection,
		LayoutOrder = props.LayoutOrder,
	}, props.children)
end

return React.memo(Root)
