local JestGlobals = require("@pkg/JestGlobals")

local AppMode = require("@root/Enums/AppMode")
local MockPlugin = require("@root/Testing/MockPlugin")
local StorySelectionKind = require("@root/Storybook/StorySelectionKind")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")
local createStoryStore = require("./createStoryStore")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function createStore()
	return createStoryStore({
		mode = AppMode.PluginWidget,
		plugin = MockPlugin.new(),
	})
end

local function createStoryModule(): ModuleScript
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = "Example.story"
	return storyModule
end

describe("story selection", function()
	test("starts without a selection", function()
		local store = createStore()

		expect(store.getSelectionKind()).toBe(StorySelectionKind.None)
		expect(store.getSelectedStory()).toBeUndefined()
		expect(store.getUnavailableStorybook()).toBeUndefined()
	end)

	test("opens a story as one complete selection", function()
		local store = createStore()
		local storyModule = createStoryModule()
		local storybook = createLoadedStorybook()

		store.openStory(storyModule, storybook)

		local selectedStory = store.getSelectedStory()
		assert(selectedStory ~= nil, "opening a story should create a selection")
		expect(selectedStory.storyModule).toBe(storyModule)
		expect(selectedStory.storybook).toBe(storybook)
		expect(store.getSelectionKind()).toBe(StorySelectionKind.Story)
		expect(store.getUnavailableStorybook()).toBeUndefined()
	end)

	test("uses the default storybook for an orphan story", function()
		local store = createStore()
		local storyModule = createStoryModule()

		store.openStory(storyModule, nil)

		local selectedStory = store.getSelectedStory()
		assert(selectedStory ~= nil, "opening an orphan story should create a selection")
		expect(selectedStory.storyModule).toBe(storyModule)
		expect(selectedStory.storybook.name).toBe("Storybook")
	end)

	test("replaces a story with an unavailable Storybook", function()
		local store = createStore()
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

		expect(store.getSelectionKind()).toBe(StorySelectionKind.UnavailableStorybook)
		expect(store.getSelectedStory()).toBeUndefined()
		expect(store.getUnavailableStorybook()).toBe(unavailableStorybook)
	end)
end)

describe("story-scoped state", function()
	test("clears controls and zoom when the story changes", function()
		local store = createStore()
		local controlsStore = createStoryControlsStore(nil)

		store.openStory(createStoryModule(), createLoadedStorybook())
		store.setActiveControlsStore(controlsStore)
		store.zoomIn()
		store.openStory(createStoryModule(), createLoadedStorybook())

		expect(store.getActiveControlsStore()).toBeUndefined()
		expect(store.getZoom()).toBe(0)
	end)

	test("toggles viewport preview state", function()
		local store = createStore()

		expect(store.getIsMountedInViewport()).toBe(false)
		store.viewportPreview()
		expect(store.getIsMountedInViewport()).toBe(true)
		store.viewportPreview()
		expect(store.getIsMountedInViewport()).toBe(false)
	end)

	test("zooms in and out by one increment", function()
		local store = createStore()

		store.zoomIn()
		store.zoomIn()
		store.zoomOut()

		expect(store.getZoom()).toBe(0.25)
	end)
end)
