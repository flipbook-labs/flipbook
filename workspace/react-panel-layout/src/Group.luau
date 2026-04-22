local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local GroupContext = require("@root/GroupContext")

export type GroupProps = {
	fillDirection: Enum.FillDirection?,
	LayoutOrder: number?,
	children: React.Node?,
}

local defaultProps = {
	fillDirection = Enum.FillDirection.Vertical,
}

local function Group(groupProps: GroupProps)
	local props = Sift.Dictionary.join(defaultProps, groupProps)

	return React.createElement(
		Foundation.View,
		{
			tag = {
				["row"] = props.fillDirection == Enum.FillDirection.Horizontal,
				["col"] = props.fillDirection == Enum.FillDirection.Vertical,
				["auto-xy"] = true,
			},
			LayoutOrder = props.LayoutOrder,
		},
		React.createElement(GroupContext.Provider, {
			fillDirection = props.fillDirection,
		}, props.children)
	)
end

return Group
