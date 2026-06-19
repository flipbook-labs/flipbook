local JestGlobals = require("@pkg/JestGlobals")

local types = require("@root/Actions/types")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

local fakeCtx: types.ActionContext = {
	plugin = nil :: any,
	controller = nil :: any,
}

local function withDefinitions(definitions: { types.Action })
	jest.mock(script.Parent.definitions, function()
		return definitions
	end)
	return require("./createActionRegistry")
end

beforeEach(function()
	jest.resetModules()
end)

test("errors on duplicate action ids", function()
	local dup: types.Action = {
		id = "Flipbook/Dup",
		text = "",
		statusTip = "",
		run = function()
			return nil
		end,
	}
	local createActionRegistry = withDefinitions({ dup, dup })

	expect(function()
		createActionRegistry(fakeCtx)
	end).toThrow()
end)

test("returns a failure result for an unknown action", function()
	local createActionRegistry = withDefinitions({})
	local registry = createActionRegistry(fakeCtx)

	local result = registry.dispatch("Flipbook/Nope", nil)

	expect(result.ok).toBe(false)
	expect(result.error).never.toBeNil()
end)

test("wraps a thrown error into a failure result", function()
	local boom: types.Action = {
		id = "Flipbook/Boom",
		text = "",
		statusTip = "",
		run = function()
			error("kaboom")
		end,
	}
	local createActionRegistry = withDefinitions({ boom })
	local registry = createActionRegistry(fakeCtx)

	local result = registry.dispatch("Flipbook/Boom", nil)

	expect(result.ok).toBe(false)
	local found = string.find(result.error :: string, "kaboom")
	expect(found).never.toBeNil()
end)

test("dispatches to the matching action with ctx and payload", function()
	local received: { ctx: types.ActionContext, payload: any }? = nil
	local action: types.Action = {
		id = "Flipbook/Echo",
		text = "",
		statusTip = "",
		run = function(ctx, payload)
			received = { ctx = ctx, payload = payload }
			return payload.value
		end,
	}
	local createActionRegistry = withDefinitions({ action })
	local registry = createActionRegistry(fakeCtx)

	local result = registry.dispatch("Flipbook/Echo", { value = 42 })

	expect(result.ok).toBe(true)
	expect(result.result).toBe(42)
	expect((received :: any).ctx).toBe(fakeCtx)
	expect((received :: any).payload.value).toBe(42)
end)

test("manifest exposes id, text, statusTip, and params", function()
	local action: types.Action = {
		id = "Flipbook/M",
		text = "Label",
		statusTip = "Tip",
		params = { { name = "x", type = "string" } },
		run = function()
			return nil
		end,
	}
	local createActionRegistry = withDefinitions({ action })
	local registry = createActionRegistry(fakeCtx)

	local manifest = registry.manifest()

	expect(#manifest).toBe(1)
	expect(manifest[1].id).toBe("Flipbook/M")
	expect(manifest[1].text).toBe("Label")
	expect(manifest[1].statusTip).toBe("Tip")
	expect((manifest[1].params :: any)[1].name).toBe("x")
end)
