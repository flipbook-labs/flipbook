local React = require("@pkg/React")

local TreeView = require("@root/TreeView/Treeview")
local storybookTypes = require("@root/Storybook/types")
local treeViewTypes = require("@root/TreeView/types")

type TreeNode = treeViewTypes.TreeNode
type Storybook = storybookTypes.Storybook

local useMemo = React.useMemo

export type Props = {
	storybooks: { Storybook },
}

local function StorybookTreeView(props: Props)
	local storyModules = useMemo(function()
		-- TODO: Collect all story modules under each storybook's `storyRoots` array
	end, { props.storybooks })

	local leafNodes = useMemo(function()
		local nodes: { TreeNode } = {}
		for _, storyModule in storyModules do
			table.insert(nodes, {})
		end
		return nodes
	end, { storyModules })

	local roots = useMemo(function() end, { props.storybooks })

	return React.createElement(TreeView, {
		roots = roots,
	})
end

return StorybookTreeView
