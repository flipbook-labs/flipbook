local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local ReactRoblox = require("@pkg/ReactRoblox")

local CommonTypes = require("@root/Common/types")

local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

type Pluginlike = CommonTypes.Pluginlike

-- Required in beforeEach, after it mocks the modules the app depends on.
local createFlipbookApp: typeof(require("./createFlipbookApp"))

local container: ScreenGui
local shouldAppThrow: boolean
local fallbackProblem: string?
local reloadApp: (() -> ())?

beforeEach(function()
	shouldAppThrow = false
	fallbackProblem = nil
	reloadApp = nil

	jest.mock(script.Parent.Http.requestAsync, function()
		return function()
			return nil
		end
	end)

	-- Stands in for Flipbook's UI, and throws while `shouldAppThrow` is set.
	jest.mock(script.Parent.FlipbookApp, function()
		local React = require("@pkg/React")

		return function()
			if shouldAppThrow then
				error("app failed")
			end
			return React.createElement("Frame", {
				Name = "App",
			})
		end
	end)

	-- Stands in for the fallback, and keeps the callback its Reload Flipbook
	-- button calls. Specs run with no mouse, so they can't press the button.
	jest.mock(script.Parent.Common.AppErrorFallback, function()
		local React = require("@pkg/React")

		return function(props: { problem: string, onReload: () -> () })
			fallbackProblem = props.problem
			reloadApp = props.onReload
			return React.createElement("Frame", {
				Name = "AppErrorFallback",
			})
		end
	end)

	createFlipbookApp = require("./createFlipbookApp")

	container = Instance.new("ScreenGui")
	container.Parent = CoreGui
end)

afterEach(function()
	container:Destroy()
end)

local function createPlugin(): Pluginlike
	local settings: { [string]: unknown } = {}
	return {
		GetSetting = function(_self, key: string)
			return settings[key]
		end,
		SetSetting = function(_self, key: string, value: unknown)
			settings[key] = value
		end,
	} :: Pluginlike
end

test("shows a way to reload when an error escapes the app, and reloads it", function()
	shouldAppThrow = true
	local app = createFlipbookApp(container, {
		plugin = createPlugin(),
		trackLifecycleTelemetry = false,
	})

	act(function()
		app.mount()
	end)

	expect(container:FindFirstChild("App", true)).toBeUndefined()
	expect(container:FindFirstChild("AppErrorFallback", true)).toBeDefined()
	local problemStart = (fallbackProblem or ""):find("app failed", 1, true)
	expect(problemStart).toBeDefined()

	local reload = reloadApp
	assert(reload, "expected the fallback to get a reload callback")
	shouldAppThrow = false
	act(function()
		reload()
	end)

	expect(container:FindFirstChild("App", true)).toBeDefined()
	expect(container:FindFirstChild("AppErrorFallback", true)).toBeUndefined()

	act(function()
		app.destroy()
	end)
end)
