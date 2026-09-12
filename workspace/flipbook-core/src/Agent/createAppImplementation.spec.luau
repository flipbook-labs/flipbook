local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local createAppImplementation = require("@root/Agent/createAppImplementation")
local getInstancePath = require("@root/Common/getInstancePath")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local root: Folder
local story: ModuleScript
local storybookModule: ModuleScript
local storybook: Storyteller.LoadedStorybook
local openedStory: ModuleScript?

beforeEach(function()
	root = Instance.new("Folder")
	root.Name = "AgentAppImplementationSpec"
	root.Parent = ReplicatedStorage

	storybookModule = Instance.new("ModuleScript")
	storybookModule.Name = "Example.storybook"
	storybookModule.Parent = root

	local stories = Instance.new("Folder")
	stories.Name = "Stories"
	stories.Parent = root

	story = Instance.new("ModuleScript")
	story.Name = "Button.story"
	story.Parent = stories

	storybook = {
		name = "Example",
		source = storybookModule,
		storyRoots = { stories :: Instance },
	}
	openedStory = nil
end)

afterEach(function()
	root:Destroy()
end)

local function createImplementation()
	return createAppImplementation({
		getStorybooks = function()
			return { available = { storybook }, unavailable = {} }
		end,
		getCurrentStory = function()
			return openedStory, if openedStory then storybook else nil
		end,
		openStory = function(nextStory)
			openedStory = nextStory
		end,
	})
end

test("discovers Storybooks and their Stories without fixed DataModel paths", function()
	local implementation = createImplementation()

	expect(implementation.listStorybooks()).toEqual({
		{ name = "Example", path = getInstancePath(storybookModule) },
	})
	expect(implementation.listStories(getInstancePath(storybookModule))).toEqual({
		{
			name = "Button",
			path = getInstancePath(story),
			storybook = getInstancePath(storybookModule),
		},
	})
end)

test("opens a discovered Story and reports it as current", function()
	local implementation = createImplementation()

	local result = implementation.openStory(getInstancePath(story), getInstancePath(storybookModule))

	expect(result.path).toBe(getInstancePath(story))
	expect(openedStory).toBe(story)
	expect(implementation.getCurrentStory()).toEqual(result)
end)
