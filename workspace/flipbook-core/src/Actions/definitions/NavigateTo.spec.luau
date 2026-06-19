local JestGlobals = require("@pkg/JestGlobals")

local NavigateTo = require("./NavigateTo")
local types = require("@root/Actions/types")

local expect = JestGlobals.expect
local test = JestGlobals.test

local function ctxWith(controller: { [string]: any }): types.ActionContext
	return { plugin = nil :: any, controller = controller :: any }
end

test("rejects an unknown or missing screen", function()
	local ctx = ctxWith({
		navigateTo = function()
			return { ok = true }
		end,
	})

	expect(function()
		NavigateTo.run(ctx, { screen = "Nope" })
	end).toThrow()
	expect(function()
		NavigateTo.run(ctx, nil)
	end).toThrow()
end)

test("forwards a valid screen to controller.navigateTo", function()
	local got: string?
	local ctx = ctxWith({
		navigateTo = function(screen: string)
			got = screen
			return { ok = true }
		end,
	})

	NavigateTo.run(ctx, { screen = "Settings" })

	expect(got).toBe("Settings")
end)
