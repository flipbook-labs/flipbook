local Charm = require("@pkg/Charm")
local Storyteller = require("@pkg/Storyteller")

local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")
local navigationEnums = require("@root/Navigation/enums")

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook
type Screen = navigationEnums.Screen
type StoryControlsStore = createStoryControlsStore.StoryControlsStore

export type Storybooks = {
	available: { LoadedStorybook },
	unavailable: { UnavailableStorybook },
}

export type AppStore = {
	getStorybooks: () -> Storybooks,
	getOrphanedStoryModules: () -> { ModuleScript },
	getHasRefreshedStorybooks: () -> boolean,
	refreshStorybooks: (parent: Instance?) -> Storybooks,

	getStoryModule: () -> ModuleScript?,
	getStorybook: () -> LoadedStorybook?,
	getUnavailableStorybook: () -> UnavailableStorybook?,
	openStory: (storyModule: ModuleScript?, storybook: LoadedStorybook?) -> (),
	showUnavailableStorybook: (unavailableStorybook: UnavailableStorybook) -> (),

	getNavigationStack: () -> { Screen },
	getCurrentScreen: () -> Screen,
	navigateTo: (newScreen: Screen) -> (),
	goBack: () -> (),
	canGoBack: () -> boolean,
	getBreadcrumbs: () -> { Screen },

	getActiveControlsStore: () -> StoryControlsStore?,
	setActiveControlsStore: (store: StoryControlsStore?) -> (),
}

local defaultStorybook = createLoadedStorybook()

local function createUnavailableStorybook(storybookModule: ModuleScript, problem: unknown): UnavailableStorybook
	return {
		problem = tostring(problem),
		storybook = {
			name = storybookModule.Name,
			source = storybookModule,
			storyRoots = {},
		},
	}
end

local function createAppStore(): AppStore
	local getStorybooks, setStorybooks = Charm.signal({
		available = {},
		unavailable = {},
	} :: Storybooks)
	local getOrphanedStoryModules, setOrphanedStoryModules = Charm.signal({} :: { ModuleScript })
	local getHasRefreshedStorybooks, setHasRefreshedStorybooks = Charm.signal(false)

	local getStoryModule, setStoryModule = Charm.signal(nil :: ModuleScript?)
	local getStorybook, setStorybook = Charm.signal(nil :: LoadedStorybook?)
	local getUnavailableStorybook, setUnavailableStorybook = Charm.signal(nil :: UnavailableStorybook?)

	local getNavigationStack, setNavigationStack = Charm.signal({ navigationEnums.Screen.Home } :: { Screen })
	local getActiveControlsStore, setActiveControlsStore = Charm.signal(nil :: StoryControlsStore?)

	local getCurrentScreenSignal = Charm.computed(function()
		local stack = getNavigationStack()
		return stack[#stack]
	end)

	local function getCurrentScreen(): Screen
		return getCurrentScreenSignal() :: Screen
	end

	local function refreshStorybooks(parent: Instance?): Storybooks
		local root = parent or game
		local available = {}
		local unavailable = {}

		for _, storybookModule in Storyteller.findStorybookModules(root) do
			local ok, result = pcall(Storyteller.loadStorybookModule, storybookModule)
			if ok then
				table.insert(available, result)
			else
				table.insert(unavailable, createUnavailableStorybook(storybookModule, result))
			end
		end

		local orphanedStoryModules = Storyteller.findOrphanedStoryModules(root, available)
		local storybooks = {
			available = available,
			unavailable = unavailable,
		}

		Charm.batch(function()
			setStorybooks(storybooks)
			setOrphanedStoryModules(orphanedStoryModules)
			setHasRefreshedStorybooks(true)
		end)

		return storybooks
	end

	local function openStory(storyModule: ModuleScript?, storybook: LoadedStorybook?)
		Charm.batch(function()
			setUnavailableStorybook(nil)
			setStoryModule(storyModule)
			setStorybook(if storyModule and not storybook then defaultStorybook else storybook)
		end)
	end

	local function showUnavailableStorybook(unavailableStorybook: UnavailableStorybook)
		Charm.batch(function()
			setStoryModule(nil)
			setStorybook(nil)
			setUnavailableStorybook(unavailableStorybook)
		end)
	end

	local function navigateTo(newScreen: Screen)
		setNavigationStack(function(prev)
			local new = table.clone(prev)
			table.insert(new, newScreen)
			return new
		end)
	end

	local function canGoBack(): boolean
		return #getNavigationStack() > 1
	end

	local function goBack()
		if canGoBack() then
			setNavigationStack(function(prev)
				local new = table.clone(prev)
				table.remove(new)
				return new
			end)
		end
	end

	local function getBreadcrumbs(): { Screen }
		return getNavigationStack()
	end

	return {
		getStorybooks = getStorybooks,
		getOrphanedStoryModules = getOrphanedStoryModules,
		getHasRefreshedStorybooks = getHasRefreshedStorybooks,
		refreshStorybooks = refreshStorybooks,

		getStoryModule = getStoryModule,
		getStorybook = getStorybook,
		getUnavailableStorybook = getUnavailableStorybook,
		openStory = openStory,
		showUnavailableStorybook = showUnavailableStorybook,

		getNavigationStack = getNavigationStack,
		getCurrentScreen = getCurrentScreen,
		navigateTo = navigateTo,
		goBack = goBack,
		canGoBack = canGoBack,
		getBreadcrumbs = getBreadcrumbs,

		getActiveControlsStore = getActiveControlsStore,
		setActiveControlsStore = setActiveControlsStore,
	}
end

return createAppStore
