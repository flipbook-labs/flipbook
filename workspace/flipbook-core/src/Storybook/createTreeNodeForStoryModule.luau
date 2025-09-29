local HttpService = game:GetService("HttpService")

local TreeView = require("@root/TreeView")

type TreeNode = TreeView.TreeNode

local function createTreeNodeForStoryModule(storyModule: ModuleScript): TreeNode
	return {
		id = HttpService:GenerateGUID(),
		label = storyModule.Name:gsub("%.story", ""),
		icon = "story",
		isExpanded = false,
		instance = storyModule,
		children = {},
	}
end

return createTreeNodeForStoryModule
