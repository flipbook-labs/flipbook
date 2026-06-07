local JestGlobals = require("@pkg/JestGlobals")

local MockPlugin = require("@root/Testing/MockPlugin")
local bindPluginActions = require("./PluginActionMirror")
local types = require("@root/Actions/types")

local expect = JestGlobals.expect
local test = JestGlobals.test

local function makeRegistry(dispatch: ((id: string, payload: any) -> types.ActionResult)?): types.ActionRegistry
	return {
		actions = {
			{
				id = "Flipbook/Foo",
				text = "Foo",
				statusTip = "Foo tip",
				allowBinding = true,
				run = function()
					return nil
				end,
			},
			{
				id = "Flipbook/Bar",
				text = "Bar",
				statusTip = "Bar tip",
				allowBinding = false,
				run = function()
					return nil
				end,
			},
		},
		dispatch = dispatch or function()
			return { ok = true }
		end,
		manifest = function()
			return {}
		end,
	}
end

test("creates a PluginAction per action with the right metadata", function()
	local plugin = MockPlugin.new()
	local cleanup = bindPluginActions(plugin, makeRegistry())

	local foo = (plugin :: any):getPluginAction("Flipbook/Foo")
	expect(foo).never.toBeNil()
	expect(foo.Text).toBe("Foo")
	expect(foo.StatusTip).toBe("Foo tip")
	expect(foo.AllowBinding).toBe(true)

	local bar = (plugin :: any):getPluginAction("Flipbook/Bar")
	expect(bar.AllowBinding).toBe(false)

	cleanup()
end)

test("dispatches with no payload when triggered", function()
	local plugin = MockPlugin.new()
	local dispatched: { { id: string, payload: any } } = {}
	local cleanup = bindPluginActions(
		plugin,
		makeRegistry(function(id, payload)
			table.insert(dispatched, { id = id, payload = payload })
			return { ok = true }
		end)
	)
;
	(plugin :: any):getPluginAction("Flipbook/Foo").trigger()
	task.wait()

	expect(#dispatched).toBe(1)
	expect(dispatched[1].id).toBe("Flipbook/Foo")
	expect(dispatched[1].payload).toBeNil()

	cleanup()
end)

test("cleanup disconnects triggers", function()
	local plugin = MockPlugin.new()
	local dispatchCount = 0
	local cleanup = bindPluginActions(
		plugin,
		makeRegistry(function()
			dispatchCount += 1
			return { ok = true }
		end)
	)

	cleanup()
;
	(plugin :: any):getPluginAction("Flipbook/Foo").trigger()
	task.wait()

	expect(dispatchCount).toBe(0)
end)
