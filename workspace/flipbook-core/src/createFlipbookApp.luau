local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local AppMode = require("@root/Enums/AppMode")
local CommonTypes = require("@root/Common/types")
local ContextProviders = require("@root/Common/ContextProviders")
local EmbeddingTypes = require("@root/Embedding/types")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local FlipbookApp = require("@root/FlipbookApp")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local logger = require("@root/logger")

type AppMode = AppMode.AppMode
type AgentController = FlipbookAgents.AgentController
type LaunchData = EmbeddingTypes.LaunchData
type Pluginlike = CommonTypes.Pluginlike

export type Options = {
	launchData: LaunchData?,
	plugin: Pluginlike?,
	overlayGui: GuiBase2d?,
	mode: AppMode?,
	agentController: AgentController?,
	trackLifecycleTelemetry: boolean?,
}

local defaultPlugin: Pluginlike = {
	GetMouse = function()
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
	local trackLifecycleTelemetry = appOptions.trackLifecycleTelemetry ~= false

	-- FIXME: ContextProviders having an error won't fail tests. We really need
	-- a smoketest for this file
	local app = React.createElement(ContextProviders, {
		plugin = appOptions.plugin or defaultPlugin,
		overlayGui = appOptions.overlayGui or container,
		agentController = appOptions.agentController,
	}, {
		FlipbookApp = React.createElement(FlipbookApp, {
			launchData = appOptions.launchData,
			mode = appOptions.mode,
		}),
	})

	local function unmount()
		logger:Info("unmounting app...")
		local elapsedMs = stopwatch(function()
			root:unmount()
		end)
		logger:Info(`unmounted app in {elapsedMs}`)

		if trackLifecycleTelemetry then
			task.spawn(function()
				fireEventAsync({
					eventName = "AppClosed",
				})
			end)
		end
	end

	local function mount()
		logger:Info("mounting app...")
		local elapsedMs = stopwatch(function()
			root:render(app)
		end)
		logger:Info(`mounted app in {elapsedMs}`)

		if trackLifecycleTelemetry then
			task.spawn(function()
				fireEventAsync({
					eventName = "AppOpened",
				})
			end)
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
