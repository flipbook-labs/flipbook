local JestGlobals = require("@pkg/JestGlobals")

local createAppController = require("./createAppController")
local types = require("@root/Actions/types")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local widget: { Enabled: boolean }
local controller: types.AppController

local function fullImpl(overrides: { [string]: any }?): types.AppControllerImpl
	local impl: types.AppControllerImpl = {
		navigateTo = function() end,
		selectStory = function()
			return { ok = true }
		end,
		listStories = function()
			return {}
		end,
		getState = function()
			return { screen = "Home", selectedStory = nil }
		end,
	}
	if overrides then
		for key, value in overrides do
			(impl :: any)[key] = value
		end
	end
	return impl
end

beforeEach(function()
	widget = { Enabled = false }
	controller = createAppController(widget :: any)
end)

test("toggleWidget flips Enabled when no argument is given", function()
	controller.toggleWidget()
	expect(widget.Enabled).toBe(true)
	controller.toggleWidget()
	expect(widget.Enabled).toBe(false)
end)

test("toggleWidget forces the given state", function()
	controller.toggleWidget(true)
	expect(widget.Enabled).toBe(true)
	controller.toggleWidget(true)
	expect(widget.Enabled).toBe(true)
	controller.toggleWidget(false)
	expect(widget.Enabled).toBe(false)
end)

test("returns a failure result when the app is not mounted", function()
	expect(controller.navigateTo("Home").ok).toBe(false)
	expect(controller.selectStory("x").ok).toBe(false)
	expect(controller.listStories()).toEqual({})
end)

test("delegates to the registered impl", function()
	local navigatedTo: string?
	controller.register(fullImpl({
		navigateTo = function(screen: string)
			navigatedTo = screen
		end,
		selectStory = function(path: string)
			return { ok = true, result = path }
		end,
		listStories = function()
			return { { path = "a", name = "a" } }
		end,
	}))

	expect(controller.navigateTo("Logs").ok).toBe(true)
	expect(navigatedTo).toBe("Logs")
	expect(controller.selectStory("p").result).toBe("p")
	expect(#controller.listStories()).toBe(1)
end)

test("getState merges widget state with app state", function()
	widget.Enabled = true
	controller.register(fullImpl({
		getState = function()
			return { screen = "About", selectedStory = "Foo" }
		end,
	}))

	local state = controller.getState()

	expect(state.widgetOpen).toBe(true)
	expect(state.screen).toBe("About")
	expect(state.selectedStory).toBe("Foo")
end)

test("getState defaults to Home with no impl", function()
	local state = controller.getState()
	expect(state.screen).toBe("Home")
	expect(state.selectedStory).toBeNil()
end)

test("unregister clears the impl", function()
	local unregister = controller.register(fullImpl())
	unregister()
	expect(controller.navigateTo("Home").ok).toBe(false)
end)
