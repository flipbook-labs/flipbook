local JestGlobals = require("@pkg/jest-globals")

local Storyteller = require("@pkg/storyteller")

local createStoryNodes = require("./createStoryNodes")
local newFolder = require("@root/Testing/newFolder")

local expect = JestGlobals.expect
local test = JestGlobals.test

local mockStoryModule = Instance.new("ModuleScript")

local mockStoryRoot = newFolder({
	Components = newFolder({
		["Component"] = Instance.new("ModuleScript"),
		["Component.story"] = mockStoryModule,
	}),
})

local mockStorybook: Storyteller.LoadedStorybook = {
	name = "MockStorybook",
	storyRoots = { mockStoryRoot },
}

test("use an icon for storybooks", function()
	local nodes = createStoryNodes({ mockStorybook })

	local storybook = nodes[1]
	expect(storybook).toBeDefined()
	expect(storybook.icon).toBe("storybook")
end)

test("use an icon for container instances", function()
	local nodes = createStoryNodes({ mockStorybook })

	local storybook = nodes[1]
	local components = storybook.children[1]

	expect(components).toBeDefined()
	expect(components.icon).toBe("folder")
end)

test("use an icon for stories", function()
	local nodes = createStoryNodes({ mockStorybook })

	local storybook = nodes[1]
	local components = storybook.children[1]
	local story = components.children[1]

	expect(story).toBeDefined()
	expect(story.icon).toBe("story")
end)

test("ignore other ModuleScripts", function()
	local nodes = createStoryNodes({ mockStorybook })

	local storybook = nodes[1]
	local components = storybook.children[1]

	-- In mockStoryRoot, there is a Component module and an accompanying
	-- story. We only want stories in the node tree, so we only expect to
	-- get one child
	expect(#components.children).toBe(1)
end)
