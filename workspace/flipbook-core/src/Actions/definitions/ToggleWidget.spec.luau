local JestGlobals = require("@pkg/JestGlobals")

local ToggleWidget = require("./ToggleWidget")
local types = require("@root/Actions/types")

local expect = JestGlobals.expect
local test = JestGlobals.test

local function ctxWith(controller: { [string]: any }): types.ActionContext
	return { plugin = nil :: any, controller = controller :: any }
end

test("forwards the enabled flag and reports widgetOpen", function()
	local toggledWith: any = "unset"
	local ctx = ctxWith({
		toggleWidget = function(enabled: boolean?)
			toggledWith = enabled
		end,
		getState = function()
			return { widgetOpen = true, screen = "Home" }
		end,
	})

	local result = ToggleWidget.run(ctx, { enabled = false })

	expect(toggledWith).toBe(false)
	expect(result.widgetOpen).toBe(true)
end)

test("passes nil when no payload is given", function()
	local toggledWith: any = "unset"
	local ctx = ctxWith({
		toggleWidget = function(enabled: boolean?)
			toggledWith = enabled
		end,
		getState = function()
			return { widgetOpen = false, screen = "Home" }
		end,
	})

	ToggleWidget.run(ctx, nil)

	expect(toggledWith).toBeNil()
end)
