local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local newFolder = require("@root/Testing/newFolder")

local getInstanceFromPath = require("./getInstanceFromPath")
local getInstancePath = require("./getInstancePath")

local expect = JestGlobals.expect
local test = JestGlobals.test
local afterEach = JestGlobals.afterEach

local folder: Folder

afterEach(function()
	if folder then
		folder:Destroy()
	end
end)

test("gets services", function()
	local path = getInstanceFromPath("ReplicatedStorage")
	expect(path).toBe(ReplicatedStorage)
end)

test("works on nested instances", function()
	local module = Instance.new("ModuleScript")

	folder = newFolder({
		foo = newFolder({
			bar = module,
		}),
	})
	folder.Parent = ReplicatedStorage

	expect(getInstanceFromPath(getInstancePath(module))).toBe(module)
end)

test("works with spec files", function()
	local module = Instance.new("ModuleScript")

	folder = newFolder({
		foo = newFolder({
			["bar.spec"] = module,
		}),
	})
	folder.Parent = ReplicatedStorage

	local path = getInstanceFromPath(module:GetFullName())
	expect(path).toBe(module)
end)

test("finds spec files BEFORE the module it is associated with", function()
	local module = Instance.new("ModuleScript")

	folder = newFolder({
		foo = newFolder({
			bar = Instance.new("ModuleScript"),
			["bar.spec"] = module,
		}),
	})
	folder.Parent = ReplicatedStorage

	expect(getInstanceFromPath(getInstancePath(module))).toBe(module)
end)

test("returns nil if the first part of the path is not a service", function()
	expect(getInstanceFromPath("Part")).toBeUndefined()
end)

test("returns nil if the path does not exist", function()
	expect(getInstanceFromPath("Foo.story")).toBeUndefined()
	expect(getInstanceFromPath("Path/To/Foo.story")).toBeUndefined()
	expect(getInstanceFromPath("ReplicatedStorage/Foo/Bar/Baz")).toBeUndefined()
	expect(getInstanceFromPath("ReplicatedStorage/Sample.story")).toBeUndefined()
	expect(getInstanceFromPath("ReplicatedStorage/Sample.spec")).toBeUndefined()
end)
