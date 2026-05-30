local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local CommonTypes = require("@root/Common/Types")
local ContextProviders = require("@root/Common/ContextProviders")
local FlipbookApp = require("@root/FlipbookApp")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local logger = require("@root/logger")

type Pluginlike = CommonTypes.Pluginlike

export type Options = {
	initialStoryPath: string?,
	storyRoot: Instance?,
	plugin: Pluginlike,
	overlayGui: GuiBase2d?,
	viewportGui: ScreenGui?,
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
	local appOptions: Options = options
		or {
			initialStoryPath = nil,
			plugin = defaultPlugin,
			overlayGui = nil,
			viewportGui = nil,
		}

	-- FIXME: ContextProviders having an error won't fail tests. We really need
	-- a smoketest for this file
	local app = React.createElement(ContextProviders, {
		plugin = appOptions.plugin,
		overlayGui = appOptions.overlayGui or container,
	}, {
		FlipbookApp = React.createElement(FlipbookApp, {
			initialStoryPath = appOptions.initialStoryPath,
			storyRoot = appOptions.storyRoot,
			viewportGui = appOptions.viewportGui,
		}),
	})

	local function unmount()
		logger:Info("unmounting app...")
		local elapsedMs = stopwatch(function()
			root:unmount()
		end)
		logger:Info(`unmounted app in {elapsedMs}`)

		task.spawn(function()
			fireEventAsync({
				eventName = "AppClosed",
			})
		end)
	end

	local function mount()
		logger:Info("mounting app...")
		local elapsedMs = stopwatch(function()
			root:render(app)
		end)
		logger:Info(`mounted app in {elapsedMs}`)

		task.spawn(function()
			fireEventAsync({
				eventName = "AppOpened",
			})
		end)
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
