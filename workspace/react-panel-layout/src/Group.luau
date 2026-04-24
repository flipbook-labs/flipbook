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

	local fillDirection: Enum.FillDirection = props.fillDirection
	local isHorizontal = fillDirection == Enum.FillDirection.Horizontal

	-- TODO: Between each Panel we need to insert a Dragger. Or something to
	-- that effect.

	return React.createElement(
		Foundation.View,
		{
			tag = {
				["row"] = isHorizontal,
				["col"] = not isHorizontal,
				["auto-xy fill gap-small"] = true,
			},
			layout = {
				FillDirection = fillDirection,
			},
			LayoutOrder = props.LayoutOrder,
		},
		React.createElement(GroupContext.Provider, {
			fillDirection = fillDirection,
		}, props.children)
	)
end

return React.memo(Group)
