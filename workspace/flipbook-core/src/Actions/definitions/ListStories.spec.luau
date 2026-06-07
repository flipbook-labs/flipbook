local JestGlobals = require("@pkg/JestGlobals")

local ListStories = require("./ListStories")
local types = require("@root/Actions/types")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("returns the controller's story list", function()
	local ctx: types.ActionContext = {
		plugin = nil :: any,
		controller = {
			listStories = function()
				return { { path = "ReplicatedStorage/Button.story", name = "Button" } }
			end,
		} :: any,
	}

	local result = ListStories.run(ctx, nil)

	expect(#result).toBe(1)
	expect(result[1].path).toBe("ReplicatedStorage/Button.story")
	expect(result[1].name).toBe("Button")
end)
