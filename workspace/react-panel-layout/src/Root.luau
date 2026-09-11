local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local GroupContext = require("@root/GroupContext")

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
	local isHorizontal = props.fillDirection == Enum.FillDirection.Horizontal

	return React.createElement(
		Foundation.View,
		{
			tag = {
				["size-full"] = true,
				["row"] = isHorizontal,
				["col"] = not isHorizontal,
			},
			LayoutOrder = props.LayoutOrder,
		},
		React.createElement(GroupContext.Provider, {
			fillDirection = props.fillDirection,
		}, props.children)
	)
end

return React.memo(Root)
