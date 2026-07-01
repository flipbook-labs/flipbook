local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Selection = game:GetService("Selection")

local AgentGateway = require("@pkg/AgentGateway")
local Storyteller = require("@pkg/Storyteller")

local NavigationStore = require("@root/Navigation/NavigationStore")
local StoryStore = require("@root/Storybook/StoryStore")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local constants = require("@root/constants")
local embedFlipbookRuntime = require("@root/Embedding/embedFlipbookRuntime")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")
local navigationEnums = require("@root/Navigation/enums")

type LoadedStorybook = Storyteller.LoadedStorybook
type StoryControls = Storyteller.StoryControls

export type Context = {
	widget: DockWidgetPluginGui,
}

type Action = AgentGateway.Action<Context>

local function asTable(params: unknown?): { [string]: unknown }
	if type(params) == "table" then
		return params :: any
	end
	return {}
end

local function getStringField(params: { [string]: unknown }, key: string): string?
	local value = params[key]
	return if type(value) == "string" and value ~= "" then value else nil
end

local function ensureStorybooks()
	local storyStore = StoryStore.get()
	if not storyStore.getHasRefreshedStorybooks() then
		storyStore.refreshStorybooks()
	end
end

local function serializeStorybook(storybook: LoadedStorybook)
	return {
		name = storybook.name,
		path = getInstancePath(storybook.source),
	}
end

local function serializeStoryModule(storyModule: ModuleScript, storybook: LoadedStorybook?)
	return {
		name = storyModule.Name,
		path = getInstancePath(storyModule),
		storybook = if storybook then getInstancePath(storybook.source) else nil,
	}
end

local function resolveModuleScript(path: string, label: string): ModuleScript
	local instance = getInstanceFromPath(path)
	if instance == nil then
		error(`{label} not found at path: {path}`)
	end
	if not instance:IsA("ModuleScript") then
		error(`{label} must be a ModuleScript: {path}`)
	end
	return instance
end

local function getStorybookByPath(path: string): LoadedStorybook
	local storybookModule = resolveModuleScript(path, "storybook")
	for _, storybook in StoryStore.get().getStorybooks().available do
		if storybook.source == storybookModule then
			return storybook
		end
	end
	error(`storybook is unavailable or not loaded: {path}`)
end

local function findStorybookForStory(storyModule: ModuleScript): LoadedStorybook?
	for _, storybook in StoryStore.get().getStorybooks().available do
		for _, storyRoot in storybook.storyRoots do
			if storyRoot:IsAncestorOf(storyModule) then
				return storybook
			end
		end
	end
	return nil
end

local function serializeWidget(widget: DockWidgetPluginGui)
	return {
		name = widget.Name,
		title = widget.Title,
		enabled = widget.Enabled,
	}
end

local function isThemeName(theme: string): boolean
	return theme == "system" or theme == "dark" or theme == "light"
end

local function ensureOpenStory(actionName: string)
	if StoryStore.get().getStoryModule() == nil then
		error(`{actionName} requires an open story`)
	end
end

local function create(_context: Context): { Action }
	return {
		{
			name = "openWidget",
			title = "Open Widget",
			description = "Open the Flipbook plugin widget.",
			run = function(ctx)
				ctx.widget.Enabled = true
				return serializeWidget(ctx.widget)
			end,
		},

		{
			name = "closeWidget",
			title = "Close Widget",
			description = "Close the Flipbook plugin widget.",
			run = function(ctx)
				ctx.widget.Enabled = false
				return serializeWidget(ctx.widget)
			end,
		},

		{
			name = "getWidget",
			title = "Get Widget",
			description = "Return the Flipbook plugin widget state.",
			run = function(ctx)
				return serializeWidget(ctx.widget)
			end,
		},

		{
			name = "refreshStorybooks",
			title = "Refresh Storybooks",
			description = "Refresh Flipbook's cached Storyteller discovery results.",
			run = function()
				local storyStore = StoryStore.get()
				local storybooks = storyStore.refreshStorybooks()
				return {
					available = #storybooks.available,
					unavailable = #storybooks.unavailable,
					orphaned = #storyStore.getOrphanedStoryModules(),
				}
			end,
		},

		{
			name = "listStorybooks",
			title = "List Storybooks",
			description = "Return the available and unavailable storybooks from Flipbook's cached discovery store.",
			run = function()
				ensureStorybooks()

				local available = {}
				local storyStore = StoryStore.get()
				for _, storybook in storyStore.getStorybooks().available do
					table.insert(available, serializeStorybook(storybook))
				end

				local unavailable = {}
				for _, unavailableStorybook in storyStore.getStorybooks().unavailable do
					table.insert(unavailable, {
						name = unavailableStorybook.storybook.name,
						path = getInstancePath(unavailableStorybook.storybook.source),
						problem = unavailableStorybook.problem,
					})
				end

				return {
					available = available,
					unavailable = unavailable,
					orphaned = #storyStore.getOrphanedStoryModules(),
				}
			end,
		},

		{
			name = "listStories",
			title = "List Stories",
			description = "Return the story modules for a loaded storybook.",
			inputSchema = {
				type = "object",
				properties = {
					storybook = { type = "string", description = "Path to a .storybook ModuleScript" },
				} :: { [string]: unknown },
				required = { "storybook" },
			},
			run = function(_ctx, params)
				ensureStorybooks()

				local options = asTable(params)
				local storybookPath = getStringField(options, "storybook")
				if storybookPath == nil then
					error("listStories requires a non-empty string 'storybook'")
				end

				local storybook = getStorybookByPath(storybookPath)
				local stories = {}
				for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook) do
					table.insert(stories, serializeStoryModule(storyModule, storybook))
				end

				return {
					storybook = serializeStorybook(storybook),
					stories = stories,
				}
			end,
		},

		{
			name = "openStory",
			title = "Open Story",
			description = "Open a story in Flipbook.",
			inputSchema = {
				type = "object",
				properties = {
					story = { type = "string", description = "Path to a .story ModuleScript" },
					storybook = { type = "string", description = "Optional path to a .storybook ModuleScript" },
				} :: { [string]: unknown },
				required = { "story" },
			},
			run = function(ctx, params)
				ensureStorybooks()

				local options = asTable(params)
				local storyPath = getStringField(options, "story")
				if storyPath == nil then
					error("openStory requires a non-empty string 'story'")
				end

				local storyModule = resolveModuleScript(storyPath, "story")
				local storybookPath = getStringField(options, "storybook")
				local storybook = if storybookPath
					then getStorybookByPath(storybookPath)
					else findStorybookForStory(storyModule)

				ctx.widget.Enabled = true
				StoryStore.get().openStory(storyModule, storybook)
				NavigationStore.get().navigateTo(navigationEnums.Screen.Home)

				return serializeStoryModule(storyModule, storybook)
			end,
		},

		{
			name = "setControls",
			title = "Set Controls",
			description = "Set one or more controls for the active story.",
			inputSchema = {
				type = "object",
				properties = {
					controls = { type = "object", description = "Map of control key to value" },
				} :: { [string]: unknown },
				required = { "controls" },
			},
			run = function(_ctx, params)
				local storyStore = StoryStore.get()
				local activeControlsStore = storyStore.getActiveControlsStore()
				if storyStore.getStoryModule() == nil then
					error("setControls requires an open story")
				end
				if activeControlsStore == nil then
					error("setControls requires the story view to be mounted")
				end

				local options = asTable(params)
				local controls = options.controls
				if type(controls) ~= "table" then
					error("setControls requires a table 'controls'")
				end

				for key, value in controls :: { [string]: unknown } do
					if type(key) ~= "string" then
						error("setControls control keys must be strings")
					end
					activeControlsStore.setControl(key, value :: any)
				end

				return {
					controls = (activeControlsStore.getControls() :: any) :: StoryControls,
				}
			end,
		},

		{
			name = "viewportPreview",
			title = "Viewport Preview",
			description = "Toggle whether the active story renders in the viewport preview.",
			run = function()
				local storyStore = StoryStore.get()
				ensureOpenStory("viewportPreview")
				storyStore.viewportPreview()
				return {
					isMountedInViewport = storyStore.getIsMountedInViewport(),
				}
			end,
		},

		{
			name = "viewCode",
			title = "View Code",
			description = "Open the currently active story module source.",
			run = function()
				local storyStore = StoryStore.get()
				ensureOpenStory("viewCode")
				storyStore.viewCode()
				return serializeStoryModule(storyStore.getStoryModule() :: ModuleScript, storyStore.getStorybook())
			end,
		},

		{
			name = "viewExplorer",
			title = "View Explorer",
			description = "Select the currently rendered story container in Explorer.",
			run = function()
				local storyStore = StoryStore.get()
				ensureOpenStory("viewExplorer")
				if storyStore.storyContainerRef.current == nil then
					error("viewExplorer requires the story view to be mounted")
				end
				storyStore.viewExplorer()
				return {
					selected = true,
				}
			end,
		},

		{
			name = "zoomIn",
			title = "Zoom In",
			description = "Increase the preview zoom for the active story.",
			run = function()
				local storyStore = StoryStore.get()
				ensureOpenStory("zoomIn")
				storyStore.zoomIn()
				return {
					zoom = storyStore.getZoom(),
				}
			end,
		},

		{
			name = "zoomOut",
			title = "Zoom Out",
			description = "Decrease the preview zoom for the active story.",
			run = function()
				local storyStore = StoryStore.get()
				ensureOpenStory("zoomOut")
				storyStore.zoomOut()
				return {
					zoom = storyStore.getZoom(),
				}
			end,
		},

		{
			name = "navigate",
			title = "Navigate",
			description = "Navigate Flipbook to a top-level screen.",
			inputSchema = {
				type = "object",
				properties = {
					screen = { type = "string", description = "One of Home, Settings, About, Logs" },
				} :: { [string]: unknown },
				required = { "screen" },
			},
			run = function(_ctx, params)
				local options = asTable(params)
				local screen = getStringField(options, "screen")
				if screen == nil or (navigationEnums.Screen :: any)[screen] == nil then
					error("navigate requires screen to be one of Home, Settings, About, Logs")
				end

				local navigationStore = NavigationStore.get()
				navigationStore.navigateTo((navigationEnums.Screen :: any)[screen])
				return {
					screen = navigationStore.getCurrentScreen(),
				}
			end,
		},

		{
			name = "setTheme",
			title = "Set Theme",
			description = "Set Flipbook's UI theme setting.",
			inputSchema = {
				type = "object",
				properties = {
					theme = { type = "string", description = "One of system, dark, light" },
				} :: { [string]: unknown },
				required = { "theme" },
			},
			run = function(_ctx, params)
				local options = asTable(params)
				local theme = getStringField(options, "theme")
				if theme == nil or not isThemeName(theme) then
					error("setTheme requires theme to be one of system, dark, light")
				end

				local userSettingsStore = UserSettingsStore.get()
				userSettingsStore.waitForLoaded()
				local settings = userSettingsStore.setStorage(function(prev)
					local nextSettings = table.clone(prev)
					nextSettings.theme = theme
					return nextSettings
				end)

				return {
					theme = settings.theme,
				}
			end,
		},

		{
			name = "embedFlipbook",
			title = "Embed Flipbook",
			description = "Embed the Flipbook runtime into the experience.",
			inputSchema = {
				type = "object",
				properties = {
					parent = {
						type = "string",
						description = "Optional destination path. Defaults to ReplicatedStorage.",
					},
					overwrite = { type = "boolean", description = "Overwrite an existing embedded runtime." },
				} :: { [string]: unknown },
			},
			run = function(_ctx, params)
				local options = asTable(params)
				local parentPath = getStringField(options, "parent")
				local destination = if parentPath then getInstanceFromPath(parentPath) else ReplicatedStorage
				if destination == nil then
					error(`embedFlipbook parent not found: {parentPath}`)
				end

				local overwrite = options.overwrite == true
				local existing = CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG)
				if #existing > 0 and not overwrite then
					error(
						`Flipbook runtime already exists at {getInstancePath(existing[1])}; pass overwrite = true to replace it`
					)
				end

				local embeddedFlipbook = embedFlipbookRuntime(destination)
				Selection:Set({ embeddedFlipbook })

				return {
					path = getInstancePath(embeddedFlipbook),
				}
			end,
		},

		{
			name = "getCurrentStory",
			title = "Get Current Story",
			description = "Return the currently open story.",
			run = function()
				local storyStore = StoryStore.get()
				local storyModule = storyStore.getStoryModule()
				if storyModule == nil then
					return nil
				end

				return serializeStoryModule(storyModule, storyStore.getStorybook())
			end,
		},

		{
			name = "getControls",
			title = "Get Controls",
			description = "Return the hydrated controls for the active story.",
			run = function()
				local activeControlsStore = StoryStore.get().getActiveControlsStore()
				return {
					controls = if activeControlsStore then activeControlsStore.getControls() else {},
				}
			end,
		},

		{
			name = "getStoryActions",
			title = "Get Story Actions",
			description = "Return the current active story action state.",
			run = function()
				local storyStore = StoryStore.get()
				return {
					isDisabled = storyStore.getIsStoryActionsDisabled(),
					isMountedInViewport = storyStore.getIsMountedInViewport(),
					mode = storyStore.getMode(),
					zoom = storyStore.getZoom(),
				}
			end,
		},

		{
			name = "getScreen",
			title = "Get Screen",
			description = "Return the active Flipbook screen.",
			run = function()
				return {
					screen = NavigationStore.get().getCurrentScreen(),
				}
			end,
		},
	}
end

return {
	create = create,
}
