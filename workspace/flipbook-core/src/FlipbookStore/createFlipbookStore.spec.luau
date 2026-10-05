local Charm = require("@pkg/Charm")
local JestGlobals = require("@pkg/JestGlobals")

local AppMode = require("@root/Enums/AppMode")
local MockPlugin = require("@root/Testing/MockPlugin")
local StorySelectionKind = require("@root/Storybook/StorySelectionKind")
local createFlipbookStore = require("./createFlipbookStore")
local navigationEnums = require("@root/Navigation/enums")

local expect = JestGlobals.expect
local test = JestGlobals.test

local function createStore()
	return createFlipbookStore({
		mode = AppMode.PluginWidget,
		plugin = MockPlugin.new(),
	})
end

test("creates independent app state", function()
	local firstStore = createStore()
	local secondStore = createStore()

	firstStore.navigation.navigateTo(navigationEnums.Screen.Settings)
	firstStore.story.openStory(Instance.new("ModuleScript"), nil)

	expect(firstStore.navigation.getCurrentScreen()).toBe(navigationEnums.Screen.Settings)
	expect(firstStore.story.getSelectionKind()).toBe(StorySelectionKind.Story)
	expect(secondStore.navigation.getCurrentScreen()).toBe(navigationEnums.Screen.Home)
	expect(secondStore.story.getSelectionKind()).toBe(StorySelectionKind.None)
end)

test("opens stories through one app command", function()
	local store = createStore()
	local storyModule = Instance.new("ModuleScript")
	store.navigation.navigateTo(navigationEnums.Screen.Settings)

	store.openStory(storyModule, nil)

	local selectedStory = store.story.getSelectedStory()
	assert(selectedStory ~= nil, "the app command should select the story")
	expect(selectedStory.storyModule).toBe(storyModule)
	expect(store.navigation.getCurrentScreen()).toBe(navigationEnums.Screen.Home)
end)

test("notifies only subscribers affected by a state change", function()
	local store = createStore()
	store.story.openStory(Instance.new("ModuleScript"), nil)

	local selectionUpdates = 0
	local zoomUpdates = 0
	local stopSelection = Charm.subscribe(store.story.getSelectedStory, function()
		selectionUpdates += 1
	end)
	local stopZoom = Charm.subscribe(store.story.getZoom, function()
		zoomUpdates += 1
	end)

	store.story.zoomIn()
	store.navigation.navigateTo(navigationEnums.Screen.Settings)
	stopSelection()
	stopZoom()

	expect(selectionUpdates).toBe(0)
	expect(zoomUpdates).toBe(1)
end)
