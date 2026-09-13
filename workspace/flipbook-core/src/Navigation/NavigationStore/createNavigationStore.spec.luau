local JestGlobals = require("@pkg/JestGlobals")

local createNavigationStore = require("./createNavigationStore")
local navigationEnums = require("@root/Navigation/enums")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

type Screen = navigationEnums.Screen

describe("navigation stack", function()
	test("starts on Home", function()
		local store = createNavigationStore()

		expect(store.getCurrentScreen()).toBe(navigationEnums.Screen.Home)
		expect(store.getNavigationStack()).toEqual({ navigationEnums.Screen.Home })
		expect(store.canGoBack()).toBe(false)
	end)

	test("pushes screens onto the stack", function()
		local store = createNavigationStore()

		store.navigateTo(navigationEnums.Screen.Settings)
		store.navigateTo(navigationEnums.Screen.Logs)

		local expectedBreadcrumbs: { Screen } = {
			navigationEnums.Screen.Home,
			navigationEnums.Screen.Settings,
			navigationEnums.Screen.Logs,
		}

		expect(store.getCurrentScreen()).toBe(navigationEnums.Screen.Logs)
		expect(store.getBreadcrumbs()).toEqual(expectedBreadcrumbs)
		expect(store.canGoBack()).toBe(true)
	end)

	test("goes back when there is more than one screen", function()
		local store = createNavigationStore()

		store.navigateTo(navigationEnums.Screen.Settings)
		store.goBack()

		expect(store.getCurrentScreen()).toBe(navigationEnums.Screen.Home)
		expect(store.getNavigationStack()).toEqual({ navigationEnums.Screen.Home })
		expect(store.canGoBack()).toBe(false)
	end)

	test("does not remove the root screen", function()
		local store = createNavigationStore()

		store.goBack()

		expect(store.getCurrentScreen()).toBe(navigationEnums.Screen.Home)
		expect(store.getNavigationStack()).toEqual({ navigationEnums.Screen.Home })
	end)
end)
