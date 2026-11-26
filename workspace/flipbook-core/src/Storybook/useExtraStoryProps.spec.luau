local Charm = require("@pkg/Charm")
local JestGlobals = require("@pkg/JestGlobals")
local ReactRoblox = require("@pkg/ReactRoblox")
local Sift = require("@pkg/Sift")

local renderHook = require("@root/Testing/renderHook")

local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

type Settings = {
	colorMode: string,
	themeName: string,
}

local getSettings: () -> Settings
local setSettings: (settings: Settings) -> Settings

-- Required in beforeEach, after UserSettingsStore is mocked.
local useExtraStoryProps: typeof(require("./useExtraStoryProps"))

beforeEach(function()
	getSettings, setSettings = Charm.signal({
		colorMode = "dark",
		themeName = "Default",
	})

	jest.mock(script.Parent.Parent.UserSettings.UserSettingsStore, function()
		return {
			get = function()
				return {
					getStorage = getSettings,
				}
			end,
		}
	end)

	useExtraStoryProps = require("./useExtraStoryProps")
end)

afterEach(function()
	jest.resetAllMocks()
end)

test("passes the color mode and theme name from settings", function()
	local getProps = renderHook(function()
		return useExtraStoryProps({})
	end)

	expect(getProps().colorMode).toBe("Dark")
	expect(getProps().themeName).toBe("Default")
	expect(getProps().theme).toBe("Dark")
end)

test("updates when the color mode and theme name change", function()
	local getProps = renderHook(function()
		return useExtraStoryProps({})
	end)

	act(function()
		setSettings(Sift.Dictionary.join(getSettings(), {
			colorMode = "light",
			themeName = "CosmicDust",
		}))
	end)

	expect(getProps().colorMode).toBe("Light")
	expect(getProps().themeName).toBe("CosmicDust")
	expect(getProps().theme).toBe("Light")
end)
