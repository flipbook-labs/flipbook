local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local newFolder = require("@root/Testing/newFolder")

local getInstanceFromFullName = require("./getInstanceFromFullName")

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
	local path = getInstanceFromFullName("ReplicatedStorage")
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

	local path = getInstanceFromFullName(module:GetFullName())
	expect(path).toBe(module)
end)

test("works with spec files", function()
	local module = Instance.new("ModuleScript")

	folder = newFolder({
		foo = newFolder({
			["bar.spec"] = module,
		}),
	})
	folder.Parent = ReplicatedStorage

	local path = getInstanceFromFullName(module:GetFullName())
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

	local path = getInstanceFromFullName(module:GetFullName())
	expect(path).toBe(module)
end)

test("returns nil if the first part of the path is not a service", function()
	expect(getInstanceFromFullName("Part")).toBeUndefined()
end)

test("returns nil when instance with an extension does not exist", function()
	expect(getInstanceFromFullName("foo.story")).toBeUndefined()
	expect(getInstanceFromFullName("Path.To.Foo.story")).toBeUndefined()
end)
