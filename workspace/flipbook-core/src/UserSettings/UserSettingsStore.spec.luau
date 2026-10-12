local JestGlobals = require("@pkg/JestGlobals")

local UserSettingsStore = require("./UserSettingsStore")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("migrate the saved theme setting to colorMode", function()
	expect(UserSettingsStore.migrate({
		theme = "light",
		sidebarWidth = 300,
	})).toEqual({
		colorMode = "light",
		sidebarWidth = 300,
	})
end)

test("keep colorMode when both colorMode and theme are saved", function()
	expect(UserSettingsStore.migrate({
		colorMode = "dark",
		theme = "light",
	})).toEqual({
		colorMode = "dark",
	})
end)

test("leave settings without theme unchanged", function()
	local saved = {
		colorMode = "system",
	}

	expect(UserSettingsStore.migrate(saved)).toBe(saved)
end)
