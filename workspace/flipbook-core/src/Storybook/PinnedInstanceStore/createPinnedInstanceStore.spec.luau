local JestGlobals = require("@pkg/JestGlobals")
local Signals = require("@rbxpkg/Signals")

local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local test = JestGlobals.test
local jest = JestGlobals.jest
local afterEach = JestGlobals.afterEach

local LocalStorageStore
local MockPlugin = require("@root/Testing/MockPlugin")

local pinnedInstanceStore

beforeEach(function()
	local mockPlugin = MockPlugin.new()

	jest.mock(script.Parent.Parent.Parent.Plugin.PluginStore, function()
		return {
			get = function()
				return {
					getPlugin = function()
						return mockPlugin
					end,
				}
			end,
		}
	end)

	local createPinnedInstanceStore = require("./createPinnedInstanceStore")
	LocalStorageStore = require("@root/Plugin/LocalStorageStore")

	local getPinnedInstanceStore = Signals.createComputed(createPinnedInstanceStore)
	pinnedInstanceStore = getPinnedInstanceStore(false)

	pinnedInstanceStore.waitForLoaded()
end)

afterEach(function()
	-- Take a beat to allow work to finish. Without this we get some test
	-- failures and output spam from tests ending too early.
	task.wait()
	task.wait()

	jest.resetAllMocks()
end)

test("pin and unpin an instances", function()
	local instance = Instance.new("Folder")
	instance.Parent = workspace

	pinnedInstanceStore.pin(instance)

	-- Wait for Signal effects
	task.wait()

	local pins = pinnedInstanceStore.getPinnedInstances(false)

	expect(#pins).toBeGreaterThan(0)
	expect(pins[1]).toMatchObject({
		path = "Workspace/Folder",
		instance = instance,
	})

	pinnedInstanceStore.unpin(instance)
	expect(pinnedInstanceStore.getPinnedInstances(false)).toEqual({})
end)

test("changing pins is persisted to local storage", function()
	local instance = Instance.new("Folder")
	instance.Parent = workspace

	pinnedInstanceStore.pin(instance)

	-- Wait for Signal effects
	task.wait()

	local localStorage = LocalStorageStore.get(false).getStorage(false)
	expect(localStorage.pinnedInstancePaths).toEqual({ "Workspace/Folder" })

	-- Unpin to make sure it doesn't stick around in local storage
	pinnedInstanceStore.unpin(instance)
end)

test("check if an instance has been pinned", function()
	local instance = Instance.new("Folder")
	instance.Parent = workspace

	expect(pinnedInstanceStore.isPinned(instance)).toBe(false)

	pinnedInstanceStore.pin(instance)

	expect(pinnedInstanceStore.isPinned(instance)).toBe(true)

	-- Unpin to make sure it doesn't stick around in local storage
	pinnedInstanceStore.unpin(instance)
end)
