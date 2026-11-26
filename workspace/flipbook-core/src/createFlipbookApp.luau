local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Telemetry = require(script.Parent.Parent["flipbook-telemetry"])

local AppErrorFallback = require("@root/Common/AppErrorFallback")
local AppMode = require("@root/Enums/AppMode")
local CommonTypes = require("@root/Common/types")
local ContextProviders = require("@root/Common/ContextProviders")
local EmbeddingTypes = require("@root/Embedding/types")
local ErrorBoundary = require("@root/Common/ErrorBoundary")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local FlipbookApp = require("@root/FlipbookApp")
local createFlipbookStore = require("@root/FlipbookStore/createFlipbookStore")
local logger = require("@root/logger")

type AppMode = AppMode.AppMode
type AgentController = FlipbookAgents.AgentController
type LaunchData = EmbeddingTypes.LaunchData
type Pluginlike = CommonTypes.Pluginlike
type TelemetryClient = Telemetry.TelemetryClient

export type Options = {
	launchData: LaunchData?,
	plugin: Pluginlike?,
	overlayGui: GuiBase2d?,
	mode: AppMode?,
	agentController: AgentController?,
	telemetry: TelemetryClient?,
	trackLifecycleTelemetry: boolean?,
}

local defaultPlugin: Pluginlike = {
	GetMouse = function()
		-- PluginMouse can't be created outside a plugin. This stand-in only has
		-- the Icon field Flipbook sets, which doesn't satisfy PluginMouse's type.
		-- lute-lint-ignore(no_any)
		return {
			Icon = "",
		} :: any
	end,
	GetSetting = function()
		return nil
	end,
	OpenScript = function() end,
	SetSetting = function() end,
}

local function stopwatch(callback: () -> ()): string
	local start = os.clock()
	callback()
	return ("%.2fms"):format((os.clock() - start) * 1000)
end

local function createFlipbookApp(container: GuiBase2d, options: Options?)
	local root = ReactRoblox.createRoot(container)
	local appOptions: Options = options or {}
	local appPlugin = appOptions.plugin or defaultPlugin
	local appMode: AppMode = appOptions.mode or AppMode.PluginWidget
	local trackLifecycleTelemetry = appOptions.trackLifecycleTelemetry ~= false

	--[[
		Each mount builds a new store, so mounting again starts on Home with no
		story selected. A story comes back only when rememberLastOpenedStory is
		on and restores the last one opened. The plugin mounts the app when it
		starts and keeps it mounted while the widget is hidden, so agents
		connected through the agent gateway can still reach it. Its store
		therefore lasts until the plugin unmounts the app.
	]]
	local store: createFlipbookStore.FlipbookStore? = nil

	local function createApp(): React.Node
		local newStore = createFlipbookStore({
			mode = appMode,
			plugin = appPlugin,
			launchData = appOptions.launchData,
			telemetry = appOptions.telemetry,
		})
		store = newStore

		-- FIXME: ContextProviders having an error won't fail tests. We really need
		-- a smoketest for this file
		return React.createElement(ContextProviders, {
			plugin = appPlugin,
			overlayGui = appOptions.overlayGui or container,
			mode = appMode,
			store = newStore,
			agentController = appOptions.agentController,
		}, {
			-- An error that escapes the app shows a way to reload it, instead of
			-- unmounting Flipbook until Studio restarts.
			ErrorBoundary = React.createElement(ErrorBoundary, {
				fallback = function(problem: string, reset: () -> ())
					return React.createElement(AppErrorFallback, {
						problem = problem,
						onReload = reset,
					})
				end,
			}, {
				FlipbookApp = React.createElement(FlipbookApp),
			}),
		})
	end

	local function unmount()
		logger:Info("unmounting app...")
		local elapsedMs = stopwatch(function()
			root:unmount()
		end)
		logger:Info(`unmounted app in {elapsedMs}`)

		if store and trackLifecycleTelemetry then
			store.telemetry.capture({
				eventName = "AppClosed",
			})
		end
	end

	local function mount()
		logger:Info("mounting app...")
		local elapsedMs = stopwatch(function()
			root:render(createApp())
		end)
		logger:Info(`mounted app in {elapsedMs}`)

		if store and trackLifecycleTelemetry then
			store.telemetry.capture({
				eventName = "AppOpened",
			})
		end
	end

	local function destroy()
		logger:Info("destroying app...")
		local elapsedMs = stopwatch(unmount)
		logger:Info(`destroyed app in {elapsedMs}`)
	end

	return {
		mount = mount,
		unmount = unmount,
		destroy = destroy,
	}
end

return createFlipbookApp
