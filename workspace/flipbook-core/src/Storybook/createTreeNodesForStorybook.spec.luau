local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local TreeView = require("@root/TreeView")
local createTreeNodesForStorybook = require("./createTreeNodesForStorybook")

local expect = JestGlobals.expect
local test = JestGlobals.test

type LoadedStory = Storyteller.LoadedStory<unknown>

test("creates and selects each Story from a Storybook-keyed record", function()
	local storybookSource = Instance.new("ModuleScript")
	local storyRoot = Instance.new("Folder")
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Button.story"
	storyModule.Parent = storyRoot

	local storybook: Storyteller.LoadedStorybook = {
		name = "Examples",
		source = storybookSource,
		storyRoots = { storyRoot },
	}
	local function makeStory(id: string, name: string): LoadedStory
		return {
			id = id,
			name = name,
			story = function()
				return nil
			end,
			source = storyModule,
			storybook = storybook,
		}
	end

	local root = createTreeNodesForStorybook(storybook, {
		[storybookSource] = {
			[storyModule] = {
				name = "Buttons",
				stories = {
					makeStory("primary", "Primary"),
					makeStory("secondary", "Secondary"),
				},
			},
		},
	})
	local group = root.getChildren()[1]
	local stories = group.getChildren()

	expect(group.getName()).toBe("Buttons")
	expect(group.getIcon()).toBe(TreeView.TreeNodeIcon.Folder)
	expect(#stories).toBe(2)
	expect(stories[1].getName()).toBe("Primary")
	expect(stories[1].getStoryId()).toBe("primary")
	expect(stories[2].getName()).toBe("Secondary")
	expect(stories[2].getStoryId()).toBe("secondary")

	stories[1].activate()
	expect(stories[1].getIsSelected()).toBe(true)
	stories[2].activate()
	expect(stories[1].getIsSelected()).toBe(false)
	expect(stories[2].getIsSelected()).toBe(true)
end)
