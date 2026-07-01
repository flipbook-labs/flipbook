local Selection = game:GetService("Selection")

local Charm = require("@pkg/Charm")
local Storyteller = require("@pkg/Storyteller")

local AppMode = require("@root/Enums/AppMode")
local PluginStore = require("@root/Plugin/PluginStore")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")

type AppMode = AppMode.AppMode
type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook
type StoryControlsStore = createStoryControlsStore.StoryControlsStore

local ZOOM_INCREMENT = 0.25

export type Storybooks = {
	available: { LoadedStorybook },
	unavailable: { UnavailableStorybook },
}

export type StoryStore = {
	getStorybooks: () -> Storybooks,
	getOrphanedStoryModules: () -> { ModuleScript },
	getHasRefreshedStorybooks: () -> boolean,
	refreshStorybooks: (parent: Instance?) -> Storybooks,

	getStoryModule: () -> ModuleScript?,
	getStorybook: () -> LoadedStorybook?,
	getUnavailableStorybook: () -> UnavailableStorybook?,
	openStory: (storyModule: ModuleScript?, storybook: LoadedStorybook?) -> (),
	showUnavailableStorybook: (unavailableStorybook: UnavailableStorybook) -> (),

	getActiveControlsStore: () -> StoryControlsStore?,
	setActiveControlsStore: (store: StoryControlsStore?) -> (),

	getIsStoryActionsDisabled: () -> boolean,
	getIsMountedInViewport: () -> boolean,
	getMode: () -> AppMode,
	getStoryContainer: () -> GuiObject?,
	getZoom: () -> number,
	setMode: (mode: AppMode) -> (),
	setStoryContainer: (storyContainer: GuiObject?) -> (),
	viewportPreview: () -> (),
	viewCode: () -> (),
	viewExplorer: () -> (),
	zoomIn: () -> (),
	zoomOut: () -> (),
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

local function createStoryStore(): StoryStore
	local getStorybooks, setStorybooks = Charm.signal({
		available = {},
		unavailable = {},
	} :: Storybooks)
	local getOrphanedStoryModules, setOrphanedStoryModules = Charm.signal({} :: { ModuleScript })
	local getHasRefreshedStorybooks, setHasRefreshedStorybooks = Charm.signal(false)

	local getStoryModule, setStoryModule = Charm.signal(nil :: ModuleScript?)
	local getStorybook, setStorybook = Charm.signal(nil :: LoadedStorybook?)
	local getUnavailableStorybook, setUnavailableStorybook = Charm.signal(nil :: UnavailableStorybook?)

	local getActiveControlsStore, setActiveControlsStore = Charm.signal(nil :: StoryControlsStore?)

	local getIsMountedInViewport, setIsMountedInViewport = Charm.signal(false)
	local getModeSignal, setMode = Charm.signal(AppMode.PluginWidget :: AppMode)
	local getStoryContainer, setStoryContainer = Charm.signal(nil :: GuiObject?)
	local getZoom, setZoom = Charm.signal(0)

	local getIsStoryActionsDisabled = Charm.computed(function()
		return getStoryModule() == nil
	end)

	local function getMode(): AppMode
		return getModeSignal() :: AppMode
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
			setZoom(0)
		end)
	end

	local function showUnavailableStorybook(unavailableStorybook: UnavailableStorybook)
		Charm.batch(function()
			setStoryModule(nil)
			setStorybook(nil)
			setUnavailableStorybook(unavailableStorybook)
		end)
	end

	local function viewportPreview()
		setIsMountedInViewport(function(currentValue)
			return not currentValue
		end)
	end

	local function viewCode()
		local storyModule = getStoryModule()
		if storyModule == nil then
			return
		end

		Selection:Set({ storyModule })

		local plugin = PluginStore.get().getPlugin()
		if plugin ~= nil then
			plugin:OpenScript(storyModule)
		end
	end

	local function viewExplorer()
		local storyContainer = getStoryContainer()
		if storyContainer == nil then
			return
		end

		Selection:Set({ storyContainer:FindFirstAncestorWhichIsA("GuiObject") or storyContainer })
	end

	local function zoomIn()
		setZoom(function(currentValue)
			return currentValue + ZOOM_INCREMENT
		end)
	end

	local function zoomOut()
		setZoom(function(currentValue)
			return currentValue - ZOOM_INCREMENT
		end)
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

		getActiveControlsStore = getActiveControlsStore,
		setActiveControlsStore = setActiveControlsStore,

		getIsStoryActionsDisabled = getIsStoryActionsDisabled,
		getIsMountedInViewport = getIsMountedInViewport,
		getMode = getMode,
		getStoryContainer = getStoryContainer,
		getZoom = getZoom,
		setMode = setMode,
		setStoryContainer = setStoryContainer,
		viewportPreview = viewportPreview,
		viewCode = viewCode,
		viewExplorer = viewExplorer,
		zoomIn = zoomIn,
		zoomOut = zoomOut,
	}
end

return createStoryStore
