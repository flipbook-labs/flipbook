local Selection = game:GetService("Selection")

local Charm = require("@pkg/Charm")
local Storyteller = require("@pkg/Storyteller")

local AppMode = require("@root/Enums/AppMode")
local CommonTypes = require("@root/Common/types")
local StorySelectionKind = require("@root/Storybook/StorySelectionKind")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local createStoryControlsStore = require("@root/StoryControls/createStoryControlsStore")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local types = require("@root/Storybook/types")

type AppMode = AppMode.AppMode
type LoadedStorybook = Storyteller.LoadedStorybook
type Pluginlike = CommonTypes.Pluginlike
type SelectedStory = types.SelectedStory
type StoryControlsStore = createStoryControlsStore.StoryControlsStore
type StorySelection = types.StorySelection
type StorySelectionKind = StorySelectionKind.StorySelectionKind
type UnavailableStorybook = Storyteller.UnavailableStorybook

local ZOOM_INCREMENT = 0.25

export type Options = {
	mode: AppMode,
	plugin: Pluginlike,
}

export type StoryStore = {
	getSelectionKind: () -> StorySelectionKind,
	getSelectedStory: () -> SelectedStory?,
	getUnavailableStorybook: () -> UnavailableStorybook?,
	openStory: (storyModule: ModuleScript?, storybook: LoadedStorybook?) -> (),
	showUnavailableStorybook: (unavailableStorybook: UnavailableStorybook) -> (),

	getActiveControlsStore: () -> StoryControlsStore?,
	setActiveControlsStore: (store: StoryControlsStore?) -> (),

	getIsStoryActionsDisabled: () -> boolean,
	getIsMountedInViewport: () -> boolean,
	getMode: () -> AppMode,
	getStoryContainer: () -> GuiBase2d?,
	getZoom: () -> number,
	setStoryContainer: (storyContainer: GuiBase2d?) -> (),
	viewportPreview: () -> (),
	viewCode: () -> (),
	viewExplorer: () -> (),
	zoomIn: () -> (),
	zoomOut: () -> (),
}

local function createStoryStore(options: Options): StoryStore
	local defaultStorybook = createLoadedStorybook()
	local getSelection, setSelection = Charm.signal({
		kind = StorySelectionKind.None,
	} :: StorySelection)
	local getActiveControlsStore, setActiveControlsStore = Charm.signal(nil :: StoryControlsStore?)
	local getIsMountedInViewport, setIsMountedInViewport = Charm.signal(false)
	local getStoryContainer, setStoryContainer = Charm.signal(nil :: GuiBase2d?)
	local getZoom, setZoom = Charm.signal(0)

	local getSelectionKindSignal = Charm.computed(function(): StorySelectionKind
		return getSelection().kind
	end)
	local function getSelectionKind(): StorySelectionKind
		return getSelectionKindSignal() :: StorySelectionKind
	end

	local getSelectedStory = Charm.computed(function(): SelectedStory?
		local selection = getSelection()
		return if selection.kind == StorySelectionKind.Story then selection else nil
	end)

	local getUnavailableStorybook = Charm.computed(function(): UnavailableStorybook?
		local selection = getSelection()
		return if selection.kind == StorySelectionKind.UnavailableStorybook then selection.unavailableStorybook else nil
	end)

	local getIsStoryActionsDisabled = Charm.computed(function()
		return getSelectedStory() == nil
	end)

	local function getMode(): AppMode
		return options.mode
	end

	local function reportStoryOpened()
		task.spawn(function()
			fireEventAsync({
				eventName = "StoryOpened",
			})
		end)
	end

	local function openStory(storyModule: ModuleScript?, storybook: LoadedStorybook?)
		Charm.batch(function()
			setActiveControlsStore(nil)
			setStoryContainer(nil)
			setZoom(0)

			if storyModule == nil then
				setSelection({
					kind = StorySelectionKind.None,
				})
				return
			end

			setSelection({
				kind = StorySelectionKind.Story,
				storyModule = storyModule,
				storybook = storybook or defaultStorybook,
			})
		end)
		reportStoryOpened()
	end

	local function showUnavailableStorybook(unavailableStorybook: UnavailableStorybook)
		Charm.batch(function()
			setActiveControlsStore(nil)
			setStoryContainer(nil)
			setZoom(0)
			setSelection({
				kind = StorySelectionKind.UnavailableStorybook,
				unavailableStorybook = unavailableStorybook,
			})
		end)
	end

	local function viewportPreview()
		setIsMountedInViewport(function(isMounted)
			return not isMounted
		end)
	end

	local function viewCode()
		local selectedStory = getSelectedStory()
		if selectedStory == nil then
			return
		end

		Selection:Set({ selectedStory.storyModule })
		options.plugin:OpenScript(selectedStory.storyModule)
	end

	local function viewExplorer()
		local storyContainer = getStoryContainer()
		if storyContainer == nil then
			return
		end

		Selection:Set({ storyContainer:FindFirstAncestorWhichIsA("GuiObject") or storyContainer })
	end

	local function zoomIn()
		setZoom(function(currentZoom)
			return currentZoom + ZOOM_INCREMENT
		end)
	end

	local function zoomOut()
		setZoom(function(currentZoom)
			return currentZoom - ZOOM_INCREMENT
		end)
	end

	return {
		getSelectionKind = getSelectionKind,
		getSelectedStory = getSelectedStory,
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
		setStoryContainer = setStoryContainer,
		viewportPreview = viewportPreview,
		viewCode = viewCode,
		viewExplorer = viewExplorer,
		zoomIn = zoomIn,
		zoomOut = zoomOut,
	}
end

return createStoryStore
