local Storyteller = require("@pkg/Storyteller")
local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local AppMode = require("@root/Enums/AppMode")
local CommonTypes = require("@root/Common/types")
local createNavigationStore = require("@root/Navigation/createNavigationStore")
local createStoryStore = require("@root/Storybook/createStoryStore")
local createTelemetry = require("@root/Telemetry/createTelemetry")
local navigationEnums = require("@root/Navigation/enums")

type AppMode = AppMode.AppMode
type LoadedStorybook = Storyteller.LoadedStorybook
type NavigationStore = createNavigationStore.NavigationStore
type Pluginlike = CommonTypes.Pluginlike
type StoryStore = createStoryStore.StoryStore
type TelemetryClient = Telemetry.TelemetryClient
type UnavailableStorybook = Storyteller.UnavailableStorybook

export type Options = {
	mode: AppMode,
	plugin: Pluginlike,
}

export type FlipbookStore = {
	navigation: NavigationStore,
	story: StoryStore,
	telemetry: TelemetryClient,
	openStory: (storyModule: ModuleScript?, storybook: LoadedStorybook?) -> (),
	showUnavailableStorybook: (unavailableStorybook: UnavailableStorybook) -> (),
}

local function createFlipbookStore(options: Options): FlipbookStore
	local telemetry = createTelemetry(options.mode, options.plugin)
	local navigation = createNavigationStore(telemetry)
	local story = createStoryStore({
		mode = options.mode,
		plugin = options.plugin,
		telemetry = telemetry,
	})

	local function openStory(storyModule: ModuleScript?, storybook: LoadedStorybook?)
		navigation.navigateTo(navigationEnums.Screen.Home)
		story.openStory(storyModule, storybook)
	end

	return {
		navigation = navigation,
		story = story,
		telemetry = telemetry,
		openStory = openStory,
		showUnavailableStorybook = story.showUnavailableStorybook,
	}
end

return createFlipbookStore
