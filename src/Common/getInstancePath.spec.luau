local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require("@pkg/JestGlobals")
local newFolder = require("@root/Testing/newFolder")

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

test("services are treated as the root", function()
	expect(getInstancePath(ReplicatedStorage)).toBe("ReplicatedStorage")
end)

test("works on nested instances", function()
	local module = Instance.new("ModuleScript")

	folder = newFolder({
		foo = newFolder({
			bar = module,
		}),
	})
	folder.Parent = ReplicatedStorage

	expect(getInstancePath(module)).toBe("ReplicatedStorage/Root/foo/bar")
end)

test("works with spec files", function()
	local module = Instance.new("ModuleScript")

	folder = newFolder({
		foo = newFolder({
			["bar.spec"] = module,
		}),
	})
	folder.Parent = ReplicatedStorage

	expect(getInstancePath(module)).toBe("ReplicatedStorage/Root/foo/bar.spec")
end)

test("path separator can be changed", function()
	local module = Instance.new("ModuleScript")

	folder = newFolder({
		foo = newFolder({
			bar = module,
		}),
	})
	folder.Parent = ReplicatedStorage

	expect(getInstancePath(module, " > ")).toBe("ReplicatedStorage > Root > foo > bar")
end)
