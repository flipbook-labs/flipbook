local JestGlobals = require("@pkg/JestGlobals")

local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")
local createStoryStore = require("./createStoryStore")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function createStoryModule(): ModuleScript
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Example.story"
	return storyModule
end

describe("openStory", function()
	test("sets the active story and storybook", function()
		local store = createStoryStore()
		local storyModule = createStoryModule()
		local storybook = createLoadedStorybook()

		store.openStory(storyModule, storybook)

		expect(store.getStoryModule()).toBe(storyModule)
		expect(store.getStorybook()).toBe(storybook)
		expect(store.getUnavailableStorybook()).toBeUndefined()
		expect(store.getIsStoryActionsDisabled()).toBe(false)
	end)

	test("uses the default storybook when opening an orphan story", function()
		local store = createStoryStore()
		local storyModule = createStoryModule()

		store.openStory(storyModule, nil)

		local storybook = store.getStorybook()
		assert(storybook ~= nil, "orphan stories should use the default storybook")

		expect(store.getStoryModule()).toBe(storyModule)
		expect(storybook.name).toBe("Storybook")
	end)

	test("clears unavailable storybook state", function()
		local store = createStoryStore()
		local unavailableStorybook = {
			problem = "load failed",
			storybook = {
				name = "Broken",
				source = Instance.new("ModuleScript"),
				storyRoots = {},
			},
		}

		store.showUnavailableStorybook(unavailableStorybook)
		store.openStory(createStoryModule(), createLoadedStorybook())

		expect(store.getUnavailableStorybook()).toBeUndefined()
	end)
end)

describe("showUnavailableStorybook", function()
	test("clears active story state", function()
		local store = createStoryStore()
		local unavailableStorybook = {
			problem = "load failed",
			storybook = {
				name = "Broken",
				source = Instance.new("ModuleScript"),
				storyRoots = {},
			},
		}

		store.openStory(createStoryModule(), createLoadedStorybook())
		store.showUnavailableStorybook(unavailableStorybook)

		expect(store.getStoryModule()).toBeUndefined()
		expect(store.getStorybook()).toBeUndefined()
		expect(store.getUnavailableStorybook()).toBe(unavailableStorybook)
		expect(store.getIsStoryActionsDisabled()).toBe(true)
	end)
end)

describe("active controls store", function()
	test("can publish and clear the active controls store", function()
		local store = createStoryStore()
		local controlsStore = createStoryControlsStore()

		store.setActiveControlsStore(controlsStore)

		expect(store.getActiveControlsStore()).toBe(controlsStore)

		store.setActiveControlsStore(nil)

		expect(store.getActiveControlsStore()).toBeUndefined()
	end)
end)

describe("story actions", function()
	test("are disabled until a story is open", function()
		local store = createStoryStore()

		expect(store.getIsStoryActionsDisabled()).toBe(true)

		store.openStory(createStoryModule(), createLoadedStorybook())

		expect(store.getIsStoryActionsDisabled()).toBe(false)
	end)

	test("toggles viewport preview state", function()
		local store = createStoryStore()

		expect(store.getIsMountedInViewport()).toBe(false)

		store.viewportPreview()

		expect(store.getIsMountedInViewport()).toBe(true)

		store.viewportPreview()

		expect(store.getIsMountedInViewport()).toBe(false)
	end)

	test("zooms in and out", function()
		local store = createStoryStore()

		expect(store.getZoom()).toBe(0)

		store.zoomIn()
		store.zoomIn()
		store.zoomOut()

		expect(store.getZoom()).toBe(0.25)
	end)

	test("resets zoom when the story changes", function()
		local store = createStoryStore()

		store.openStory(createStoryModule(), createLoadedStorybook())
		store.zoomIn()

		expect(store.getZoom()).toBe(0.25)

		store.openStory(createStoryModule(), createLoadedStorybook())

		expect(store.getZoom()).toBe(0)
	end)
end)
