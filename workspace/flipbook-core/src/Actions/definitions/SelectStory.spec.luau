local JestGlobals = require("@pkg/JestGlobals")

local SelectStory = require("./SelectStory")
local types = require("@root/Actions/types")

local expect = JestGlobals.expect
local test = JestGlobals.test

local function ctxWith(controller: { [string]: any }): types.ActionContext
	return { plugin = nil :: any, controller = controller :: any }
end

test("requires a string path", function()
	local ctx = ctxWith({
		selectStory = function()
			return { ok = true }
		end,
	})

	expect(function()
		SelectStory.run(ctx, nil)
	end).toThrow()
	expect(function()
		SelectStory.run(ctx, {})
	end).toThrow()
end)

test("forwards the path to controller.selectStory", function()
	local got: string?
	local ctx = ctxWith({
		selectStory = function(path: string)
			got = path
			return { ok = true, result = path }
		end,
	})

	local result = SelectStory.run(ctx, { path = "ReplicatedStorage/Button.story" })

	expect(got).toBe("ReplicatedStorage/Button.story")
	expect(result.ok).toBe(true)
end)
