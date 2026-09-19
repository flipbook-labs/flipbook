local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local constants = require("@root/constants")
local createAppAdapter = require("@root/Agent/createAppAdapter")
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
local embeddedRuntime: Instance?

beforeEach(function()
	root = Instance.new("Folder")
	root.Name = "AgentAppAdapterSpec"
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
	embeddedRuntime = nil
end)

afterEach(function()
	root:Destroy()
end)

local function createAdapter()
	return createAppAdapter({
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
			return openedStory, if openedStory then storybook else nil
		end,
		openStory = function(nextStory)
			openedStory = nextStory
		end,
	})
end

test("discovers Storybooks and their Stories without fixed DataModel paths", function()
	local adapter = createAdapter()

	expect(adapter.listStorybooks()).toEqual({
		{ name = "Example", path = getInstancePath(storybookModule) },
	})
	expect(adapter.listStories(getInstancePath(storybookModule))).toEqual({
		{
			name = "Button",
			path = getInstancePath(story),
			storybook = getInstancePath(storybookModule),
		},
	})
end)

test("embeds Flipbook at a discovered destination", function()
	local adapter = createAdapter()

	local result = adapter.embedFlipbook(getInstancePath(root), false)
	local runtime = assert(embeddedRuntime, "expected an embedded runtime")

	expect(runtime.Parent).toBe(root)
	expect(result).toBe(getInstancePath(runtime))
end)

test("requires opt-in before replacing an embedded runtime", function()
	local existing = Instance.new("Folder")
	existing.Name = "ExistingFlipbook"
	existing.Parent = root
	CollectionService:AddTag(existing, constants.FLIPBOOK_RUNTIME_TAG)

	local adapter = createAdapter()

	expect(function()
		adapter.embedFlipbook(getInstancePath(root), false)
	end).toThrow("pass overwrite = true to replace it")
end)

test("opens a discovered Story and reports it as current", function()
	local adapter = createAdapter()

	local result = adapter.openStory(getInstancePath(story), getInstancePath(storybookModule))

	expect(result.path).toBe(getInstancePath(story))
	expect(openedStory).toBe(story)
	expect(adapter.getCurrentStory()).toEqual(result)
end)

test("rejects a non-Story module", function()
	local helper = Instance.new("ModuleScript")
	helper.Name = "Helper"
	helper.Parent = story.Parent

	local adapter = createAdapter()

	expect(function()
		adapter.openStory(getInstancePath(helper), nil)
	end).toThrow("story must be a discovered .story ModuleScript")
end)

test("rejects a Story outside the selected Storybook", function()
	local orphan = Instance.new("ModuleScript")
	orphan.Name = "Orphan.story"
	orphan.Parent = root

	local adapter = createAdapter()

	expect(function()
		adapter.openStory(getInstancePath(orphan), getInstancePath(storybookModule))
	end).toThrow("story is not discovered by storybook")
end)
