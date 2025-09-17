local JestGlobals = require("@pkg/JestGlobals")
local Signals = require("@rbxpkg/Signals")

local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local test = JestGlobals.test

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")

local createPinnedInstanceStore = require("./createPinnedInstanceStore")

local pinnedInstanceStore

beforeEach(function()
	local getPinnedInstanceStore = Signals.createComputed(createPinnedInstanceStore)
	pinnedInstanceStore = getPinnedInstanceStore(false)
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
		path = "Workspace.Folder",
		instance = instance,
	})
end)

test("changing pins is persisted to local storage", function()
	local instance = Instance.new("Folder")
	instance.Parent = workspace

	pinnedInstanceStore.pin(instance)

	-- Wait for Signal effects
	task.wait()

	local localStorage = LocalStorageStore.get(false).getStorage(false)
	expect(localStorage.pinnedInstancePaths).toEqual({ "Workspace.Folder" })
end)

test("check if an instance has been pinned", function()
	local instance = Instance.new("Folder")
	instance.Parent = workspace

	expect(pinnedInstanceStore.isPinned(instance)).toBe(false)

	pinnedInstanceStore.pin(instance)

	expect(pinnedInstanceStore.isPinned(instance)).toBe(true)
end)
