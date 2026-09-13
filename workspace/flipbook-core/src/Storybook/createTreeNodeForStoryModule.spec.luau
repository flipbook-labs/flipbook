local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local TreeView = require("@root/TreeView")
local createTreeNodeForStoryModule = require("./createTreeNodeForStoryModule")

local expect = JestGlobals.expect
local test = JestGlobals.test

type LoadedStory = Storyteller.LoadedStory<unknown>

local function makeStory(id: string, name: string): LoadedStory
	return {
		id = id,
		name = name,
		story = function()
			return nil
		end,
		source = Instance.new("ModuleScript"),
		storybook = {
			name = "Storybook",
			source = Instance.new("ModuleScript"),
			storyRoots = {},
		},
	}
end

test("creates a leaf while story metadata is loading", function()
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Button.story"

	local node = createTreeNodeForStoryModule(storyModule)

	expect(node.getName()).toBe("Button")
	expect(node.getIcon()).toBe(TreeView.TreeNodeIcon.Story)
	expect(node.getStoryId()).toBeUndefined()
end)

test("keeps single-story modules as one leaf", function()
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Button.story"

	local node = createTreeNodeForStoryModule(storyModule, {
		name = "Buttons",
		stories = {
			makeStory("default", "Primary"),
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
		stories = {
			makeStory("secondary", "Secondary"),
			makeStory("primary", "Primary"),
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
