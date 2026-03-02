local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local TreeView = require("@root/TreeView/TreeView")
local createTreeNodeStore = require("@root/TreeView/createTreeNodeStore")
local types = require("@root/TreeView/types")
local useTreeNodeFilter = require("@root/TreeView/useTreeNodeFilter")

local useCallback = React.useCallback
local useState = React.useState

type TreeNodeStore = types.TreeNodeStore

local root = createTreeNodeStore()
root.setName("<root>")

local deepStory

do
	local pins = createTreeNodeStore()
	pins.setName("Pinned Storybooks")
	pins.setIcon(types.TreeNodeIcon.Pin)
	pins.parentTo(root)

	local storybook = createTreeNodeStore()
	storybook.setName("Storybook 1")
	storybook.setIcon(types.TreeNodeIcon.Storybook)
	storybook.parentTo(root)

	local folder1 = createTreeNodeStore()
	folder1.setName("Folder 1")
	folder1.setIcon(types.TreeNodeIcon.Folder)
	folder1.parentTo(storybook)

	local folder2 = createTreeNodeStore()
	folder2.setName("Folder 2")
	folder2.setIcon(types.TreeNodeIcon.Folder)
	folder2.parentTo(folder1)

	local folder3 = createTreeNodeStore()
	folder3.setName("Folder 3")
	folder3.setIcon(types.TreeNodeIcon.Folder)
	folder3.parentTo(folder2)
end

do
	local storybook = createTreeNodeStore()
	storybook.setName("Storybook 2")
	storybook.setIcon(types.TreeNodeIcon.Storybook)
	storybook.parentTo(root)

	local folder1 = createTreeNodeStore()
	folder1.setName("Folder 1")
	folder1.setIcon(types.TreeNodeIcon.Folder)
	folder1.parentTo(storybook)

	local folder2 = createTreeNodeStore()
	folder2.setName("Folder 2")
	folder2.setIcon(types.TreeNodeIcon.Folder)
	folder2.parentTo(folder1)

	local folder3 = createTreeNodeStore()
	folder3.setName("Folder 3")
	folder3.setIcon(types.TreeNodeIcon.Folder)
	folder3.parentTo(folder2)

	deepStory = createTreeNodeStore()
	deepStory.setName("Deeply Nested Story")
	deepStory.setIcon(types.TreeNodeIcon.Story)
	deepStory.parentTo(folder3)
end

do
	local storybook = createTreeNodeStore()
	storybook.setName("Storybook 3")
	storybook.setIcon(types.TreeNodeIcon.Storybook)
	storybook.parentTo(root)

	local folder = createTreeNodeStore()
	folder.setName("Folder")
	folder.setIcon(types.TreeNodeIcon.Folder)
	folder.parentTo(storybook)

	local siblingStory1 = createTreeNodeStore()
	siblingStory1.setName("Story 1")
	siblingStory1.setIcon(types.TreeNodeIcon.Story)
	siblingStory1.parentTo(folder)

	local siblingStory2 = createTreeNodeStore()
	siblingStory2.setName("Story 2")
	siblingStory2.setIcon(types.TreeNodeIcon.Story)
	siblingStory2.parentTo(folder)

	local story1 = createTreeNodeStore()
	story1.setName("Story 1")
	story1.setIcon(types.TreeNodeIcon.Story)
	story1.parentTo(storybook)

	local story2 = createTreeNodeStore()
	story2.setName("Story 2")
	story2.setIcon(types.TreeNodeIcon.Story)
	story2.parentTo(storybook)

	local story3 = createTreeNodeStore()
	story3.setName("Story 3")
	story3.setIcon(types.TreeNodeIcon.Story)
	story3.parentTo(storybook)
end

do
	local storybook = createTreeNodeStore()
	storybook.setName("Storybook 4")
	storybook.setIcon(types.TreeNodeIcon.Storybook)
	storybook.parentTo(root)
end

return {
	story = function()
		local searchTerm: string?, setSearchTerm = useState(nil :: string?)

		local onExpand = useCallback(function()
			local node = root.findFirstDescendant(function(descendant)
				return descendant.id == deepStory.id
			end)

			if node then
				node.activate()
				node.expandUp()
			end
		end, {})

		useTreeNodeFilter(
			root,
			useCallback(function(node: TreeNodeStore)
				if not searchTerm or searchTerm == "" then
					return false
				end

				return node.getName(false):lower():match(searchTerm:lower()) == nil
			end, { searchTerm })
		)

		return React.createElement(Foundation.View, {
			tag = "auto-y col gap-large",
			Size = UDim2.fromOffset(300, 0),
		}, {
			Topbar = React.createElement(Foundation.View, {
				tag = "size-full-0 auto-y row gap-large",
				LayoutOrder = 1,
			}, {
				Search = React.createElement(Foundation.TextInput, {
					text = "",
					label = "",
					placeholder = "Search...",
					size = Foundation.Enums.InputSize.Medium,
					width = UDim.new(1, 0),
					iconLeading = Foundation.Enums.IconName.MagnifyingGlass,
					onChanged = setSearchTerm,
					LayoutOrder = 1,
				}),

				ExpandToNode = React.createElement(Foundation.Button, {
					text = "Expand",
					size = Foundation.Enums.ButtonSize.Small,
					onActivated = onExpand,
					LayoutOrder = 2,
				}),
			}),

			TreeView = React.createElement(TreeView, {
				root = root,
				layoutOrder = 2,
			}),
		})
	end,
}
