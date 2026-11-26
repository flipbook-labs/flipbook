local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local FlipbookAgents = require("@workspace/flipbook-agents/src")
local constants = require("@root/constants")
local createAppAdapter = require("@root/Agent/createAppAdapter")
local getInstancePath = require("@root/Common/getInstancePath")

local StoryStatus = FlipbookAgents.StoryStatus

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

type AppAdapter = FlipbookAgents.AppAdapter
type LoadedStorybook = Storyteller.LoadedStorybook
type StoryInfo = FlipbookAgents.StoryInfo

local root: Folder
local story: ModuleScript
local storybookModule: ModuleScript
local storybook: LoadedStorybook
local openedStory: ModuleScript?
local openedStoryId: string?
local embeddedRuntime: Instance?
local releases: { () -> () } = {}

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
	for _, release in releases do
		release()
	end
	table.clear(releases)
	root:Destroy()
end)

local function createAdapter(): AppAdapter
	local adapter, releaseRequests = createAppAdapter({
		embedFlipbook = function(destination)
			local result = Instance.new("Folder")
			result.Name = "Flipbook"
			result.Parent = destination
			embeddedRuntime = result
			return result
		end,
		getStorybooks = function()
			return {
				available = { storybook },
				unavailable = {},
			}
		end,
		getCurrentStory = function()
			return openedStory, if openedStory then storybook else nil, openedStoryId
		end,
		openStory = function(nextStory, _, nextStoryId)
			openedStory = nextStory
			openedStoryId = nextStoryId
		end,
	})
	table.insert(releases, releaseRequests)
	return adapter
end

-- Storyteller loads requested modules after the request returns, so specs
-- poll until the record they need arrives.
local function waitFor<T>(read: () -> T?): T
	for _ = 1, 100 do
		local value = read()
		if value ~= nil then
			return value
		end
		task.wait()
	end
	error("timed out waiting for Storyteller to load the Story module")
end

local function waitForStories(adapter: AppAdapter): { StoryInfo }
	return waitFor(function()
		local stories = adapter.listStories(getInstancePath(storybookModule))
		for _, storyInfo in stories do
			if storyInfo.status == "Loading" then
				return nil
			end
		end
		return stories
	end)
end

test("lists a module as loading until Storyteller loads its Stories", function()
	local adapter = createAdapter()

	expect(adapter.listStorybooks()).toEqual({
		{ name = "Example", path = getInstancePath(storybookModule) },
	})
	expect(adapter.listStories(getInstancePath(storybookModule))).toEqual({
		{
			name = "Button",
			path = getInstancePath(story),
			storybook = getInstancePath(storybookModule),
			status = StoryStatus.Loading,
		},
	})
	expect(waitForStories(adapter)).toEqual({
		{
			id = "primary",
			name = "Primary",
			path = getInstancePath(story),
			storybook = getInstancePath(storybookModule),
			status = StoryStatus.Loaded,
		},
		{
			id = "secondary",
			name = "Secondary",
			path = getInstancePath(story),
			storybook = getInstancePath(storybookModule),
			status = StoryStatus.Loaded,
		},
	})
end)

test("lists orphaned Stories without a Storybook path", function()
	local orphan = Instance.new("ModuleScript")
	orphan.Name = "Orphan.story"
	orphan.Source = "return { story = function() end }"
	orphan.Parent = root

	local adapter = createAdapter()
	local orphanPath = getInstancePath(orphan)
	local orphanedStory = waitFor(function(): StoryInfo?
		for _, storyInfo in adapter.listStories(nil) do
			if storyInfo.path == orphanPath and storyInfo.status ~= "Loading" then
				return storyInfo
			end
		end
		return nil
	end)

	expect(orphanedStory).toEqual({
		id = "default",
		name = "Orphan",
		path = orphanPath,
		status = StoryStatus.Loaded,
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

test("opens a module's first Story when no id is given", function()
	local adapter = createAdapter()
	waitForStories(adapter)

	local result = adapter.openStory(getInstancePath(story), getInstancePath(storybookModule))

	expect(result.id).toBe("primary")
	expect(result.status).toBe("Loaded")
	expect(openedStory).toBe(story)
	expect(openedStoryId).toBe("primary")
	expect(adapter.getCurrentStory()).toEqual(result)
end)

test("opens a Story by id and reports it as current", function()
	local adapter = createAdapter()
	waitForStories(adapter)

	local result = adapter.openStory(getInstancePath(story), getInstancePath(storybookModule), "secondary")

	expect(result.id).toBe("secondary")
	expect(result.name).toBe("Secondary")
	expect(openedStoryId).toBe("secondary")
	expect(adapter.getCurrentStory()).toEqual(result)
end)

test("opens a Story by id before its module loads", function()
	local adapter = createAdapter()

	local result = adapter.openStory(getInstancePath(story), getInstancePath(storybookModule), "secondary")

	expect(result).toEqual({
		id = "secondary",
		name = "Button",
		path = getInstancePath(story),
		storybook = getInstancePath(storybookModule),
		status = StoryStatus.Loading,
	})
	expect(openedStoryId).toBe("secondary")

	local current = waitFor(function(): StoryInfo?
		local currentStory = adapter.getCurrentStory()
		return if currentStory and currentStory.status ~= "Loading" then currentStory else nil
	end)
	expect(current.id).toBe("secondary")
	expect(current.name).toBe("Secondary")
	expect(current.status).toBe("Loaded")
end)

test("rejects an unknown Story id once the module has loaded", function()
	local adapter = createAdapter()
	waitForStories(adapter)

	expect(function()
		adapter.openStory(getInstancePath(story), getInstancePath(storybookModule), "missing")
	end).toThrow("story id not found")
	expect(openedStory).toBeNil()
end)

test("lists and opens a Story module that fails to load", function()
	story.Source = "error('broken story')"
	local adapter = createAdapter()

	local listed = waitForStories(adapter)
	expect(#listed).toBe(1)
	expect(listed[1].id).toBeNil()
	expect(listed[1].name).toBe("Button")
	expect(listed[1].status).toBe("Unavailable")
	expect(listed[1].problem).toEqual(expect.stringContaining("broken story"))

	local opened = adapter.openStory(getInstancePath(story), getInstancePath(storybookModule))
	expect(opened.status).toBe("Unavailable")
	expect(openedStory).toBe(story)
	expect(openedStoryId).toBeNil()
	expect(adapter.getCurrentStory()).toEqual(opened)

	expect(function()
		adapter.openStory(getInstancePath(story), getInstancePath(storybookModule), "primary")
	end).toThrow("broken story")
end)

test("releases its Storyteller requests", function()
	local adapter, releaseRequests = createAppAdapter({
		embedFlipbook = function(destination)
			return destination
		end,
		getStorybooks = function()
			return {
				available = { storybook },
				unavailable = {},
			}
		end,
		getCurrentStory = function()
			return nil, nil, nil
		end,
		openStory = function() end,
	})
	waitForStories(adapter)
	local request = { storyModule = story, storybook = storybook }
	expect(Storyteller.getStoryModuleRecord(request)).never.toBeNil()

	releaseRequests()

	expect(Storyteller.getStoryModuleRecord(request)).toBeNil()
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
