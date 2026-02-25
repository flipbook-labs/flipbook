local Charm = require("@pkg/Charm")
local JestGlobals = require("@pkg/JestGlobals")

local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local test = JestGlobals.test

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")

local createPinnedInstanceStore = require("./createPinnedInstanceStore")

local pinnedInstanceStore

beforeEach(function()
	local getPinnedInstanceStore = Charm.computed(createPinnedInstanceStore)
	pinnedInstanceStore = getPinnedInstanceStore()
end)

test("pin and unpin an instances", function()
	local instance = Instance.new("Folder")
	instance.Parent = workspace

	pinnedInstanceStore.pin(instance)

	-- Wait for Signal effects
	task.wait()

	local pins = pinnedInstanceStore.getPinnedInstances()

	expect(#pins).toBeGreaterThan(0)
	expect(pins[1]).toMatchObject({
		path = "Workspace/Folder",
		instance = instance,
	})

	pinnedInstanceStore.unpin(instance)
	expect(pinnedInstanceStore.getPinnedInstances()).toEqual({})
end)

test("changing pins is persisted to local storage", function()
	local instance = Instance.new("Folder")
	instance.Parent = workspace

	pinnedInstanceStore.pin(instance)

	-- Wait for Signal effects
	task.wait()

	local localStorage = LocalStorageStore.get().getStorage()
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
