local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local constants = require("@root/constants")
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
local openedStoryId: string?
local embeddedRuntime: Instance?

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
	story.Source = [[
		return {
			name = "Buttons",
			stories = {
				{ id = "primary", name = "Primary", story = function() end },
				{ id = "secondary", name = "Secondary", story = function() end },
			},
		}
	]]
	story.Parent = stories

	storybook = {
		name = "Example",
		source = storybookModule,
		storyRoots = { stories :: Instance },
	}
	openedStory = nil
	openedStoryId = nil
	embeddedRuntime = nil
end)

afterEach(function()
	root:Destroy()
end)

local function createImplementation()
	return createAppImplementation({
		embedFlipbook = function(destination)
			local result = Instance.new("Folder")
			result.Name = "Flipbook"
			result.Parent = destination
			embeddedRuntime = result
			return result
		end,
		getStorybooks = function()
			return { available = { storybook }, unavailable = {} }
		end,
		getCurrentStory = function()
			return openedStory, if openedStory then storybook else nil, openedStoryId
		end,
		openStory = function(nextStory, _, nextStoryId)
			openedStory = nextStory
			openedStoryId = nextStoryId
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
			id = "primary",
			name = "Primary",
			path = getInstancePath(story),
			storybook = getInstancePath(storybookModule),
		},
		{
			id = "secondary",
			name = "Secondary",
			path = getInstancePath(story),
			storybook = getInstancePath(storybookModule),
		},
	})
end)

test("embeds Flipbook at a discovered destination", function()
	local implementation = createImplementation()

	local result = implementation.embedFlipbook(getInstancePath(root), false)
	local runtime = assert(embeddedRuntime, "expected an embedded runtime")

	expect(runtime.Parent).toBe(root)
	expect(result).toBe(getInstancePath(runtime))
end)

test("requires opt-in before replacing an embedded runtime", function()
	local existing = Instance.new("Folder")
	existing.Name = "ExistingFlipbook"
	existing.Parent = root
	CollectionService:AddTag(existing, constants.FLIPBOOK_RUNTIME_TAG)

	local implementation = createImplementation()

	expect(function()
		implementation.embedFlipbook(getInstancePath(root), false)
	end).toThrow("pass overwrite = true to replace it")
end)

test("opens a concrete Story and reports its identity as current", function()
	local implementation = createImplementation()

	local result = implementation.openStory(getInstancePath(story), getInstancePath(storybookModule), "secondary")

	expect(result.path).toBe(getInstancePath(story))
	expect(result.id).toBe("secondary")
	expect(openedStory).toBe(story)
	expect(openedStoryId).toBe("secondary")
	expect(implementation.getCurrentStory()).toEqual(result)
end)

test("rejects an unknown concrete Story ID", function()
	local implementation = createImplementation()

	expect(function()
		implementation.openStory(getInstancePath(story), getInstancePath(storybookModule), "missing")
	end).toThrow("story id not found")
end)
