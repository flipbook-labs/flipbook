local JestGlobals = require("@pkg/JestGlobals")

local createTreeNodeStore = require("./createTreeNodeStore")
local findTreeNodeFromPath = require("./findTreeNodeFromPath")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("finds a node by its path relative to the supplied root", function()
	local root = createTreeNodeStore()
	root.setName("<root>")

	local storybook = createTreeNodeStore()
	storybook.setName("FlipbookCore")
	storybook.parentTo(root)

	local folder = createTreeNodeStore()
	folder.setName("About")
	folder.parentTo(storybook)

	local story = createTreeNodeStore()
	story.setName("RobloxProfile")
	story.parentTo(folder)

	expect(findTreeNodeFromPath(root, "FlipbookCore/About/RobloxProfile")).toBe(story)
	expect(findTreeNodeFromPath(root, "About/RobloxProfile")).toBeUndefined()
end)
