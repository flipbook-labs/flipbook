local flipbook = script:FindFirstAncestor("flipbook")

local JestGlobals = require(flipbook.Packages.JestGlobals)
local newFolder = require(script.Parent.newFolder)

local expect = JestGlobals.expect
local test = JestGlobals.test

test("return a folder named 'Root'", function()
	local folder = newFolder({})
	expect(folder:IsA("Folder")).toBe(true)
	expect(folder.Name).toBe("Root")
end)

test("name children after the dictionary keys", function()
	local child1 = Instance.new("Part")
	local child2 = Instance.new("Model")

	local folder = newFolder({
		Child1 = child1,
		Child2 = child2,
	})

	expect(folder.Child1).toBe(child1)
	expect(folder.Child2).toBe(child2)
end)

test("support nesting newFolder as children", function()
	local folder = newFolder({
		Child = newFolder({
			AnotherChild = newFolder({
				Module = Instance.new("ModuleScript"),
			}),
		}),
	})

	expect(folder.Child.AnotherChild.Module).toBeDefined()
end)
