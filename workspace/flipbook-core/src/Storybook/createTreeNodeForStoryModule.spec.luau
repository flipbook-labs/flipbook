local JestGlobals = require("@pkg/JestGlobals")

local TreeView = require("@root/TreeView")
local createTreeNodeForStoryModule = require("./createTreeNodeForStoryModule")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("keeps single-story modules as one leaf", function()
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Button.story"

	local node = createTreeNodeForStoryModule(storyModule, {
		name = "Buttons",
		source = storyModule,
		stories = {
			{
				id = "default",
				name = "Primary",
			},
		},
	})

	expect(node.getName()).toBe("Button")
	expect(node.getIcon()).toBe(TreeView.TreeNodeIcon.Story)
	expect(node.getStoryId()).toBe("default")
	expect(#node.getChildren()).toBe(0)
end)

test("creates an ordered group for multi-story modules", function()
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Button.story"

	local node = createTreeNodeForStoryModule(storyModule, {
		name = "Buttons",
		source = storyModule,
		stories = {
			{
				id = "secondary",
				name = "Secondary",
			},
			{
				id = "primary",
				name = "Primary",
			},
		},
	})
	local children = node.getChildren()

	expect(node.getName()).toBe("Buttons")
	expect(node.getIcon()).toBe(TreeView.TreeNodeIcon.Folder)
	expect(children[1].getName()).toBe("Secondary")
	expect(children[1].getStoryId()).toBe("secondary")
	expect(children[1].getOrder()).toBe(1)
	expect(children[2].getName()).toBe("Primary")
	expect(children[2].getStoryId()).toBe("primary")
	expect(children[2].getOrder()).toBe(2)
end)
