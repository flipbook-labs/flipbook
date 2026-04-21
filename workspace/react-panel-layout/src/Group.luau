local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Dragger = require("@root/Dragger")
local GroupContext = require("@root/GroupContext")

export type GroupProps = {
	fillDirection: Enum.FillDirection?,
	key: string?,
	children: React.Node?,
}

local defaultProps = {
	fillDirection = Enum.FillDirection.Vertical,
}

local function Group(groupProps: GroupProps)
	local props = Sift.Dictionary.join(defaultProps, groupProps)

	-- TODO: Loop over the children, then calculate where a divider should be.
	-- Use flex layouts for as much as possible.

	local children: { [string]: React.Node } = {}

	-- Add a drag handle to the right of a panel if it has another panel after
	-- it.
	local childrenArray = React.Children.toArray(props.children)
	for index, child in childrenArray do
		if type(child) == "table" then
			local nextChild = select(index + 1, childrenArray)

			children[tostring(child)] = React.cloneElement(child, {
				hasDragHandle = nextChild ~= nil,
				LayoutOrder = index,
			})
		end
	end

	-- for i, entry in panels do
	-- 	local panelOrder = i * 2 - 1
	-- 	children["p" .. i] = React.cloneElement(entry.child, {
	-- 		id = entry.id,
	-- 		LayoutOrder = panelOrder,
	-- 	})

	-- 	if panels[i + 1] ~= nil then
	-- 		local sepLayoutOrder = i * 2
	-- 		children["s" .. i] = React.createElement(Dragger, {
	-- 			LayoutOrder = sepLayoutOrder,
	-- 			panelA = entry.id,
	-- 			panelB = panels[i + 1].id,
	-- 		})
	-- 	end
	-- end

	return React.createElement(GroupContext.Provider, {
		fillDirection = props.fillDirection,
	}, {
		Group = React.createElement(Foundation.View, {
			tag = {
				["row"] = props.fillDirection == Enum.FillDirection.Horizontal,
				["col"] = props.fillDirection == Enum.FillDirection.Vertical,
				["size-full"] = true,
			},
		}, children),
	})
end

return Group
