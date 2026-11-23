local JestGlobals = require("@pkg/JestGlobals")
local newFolder = require("./newFolder")

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

	-- Folder's type doesn't know about the children, so they're indexed through
	-- an untyped value.
	-- lute-lint-ignore(no_any)
	local folder: any = newFolder({
		Child1 = child1,
		Child2 = child2,
	})

	expect(folder.Child1).toBe(child1)
	expect(folder.Child2).toBe(child2)
end)

test("support nesting newFolder as children", function()
	-- Folder's type doesn't know about the children, so they're indexed through
	-- an untyped value.
	-- lute-lint-ignore(no_any)
	local folder: any = newFolder({
		Child = newFolder({
			AnotherChild = newFolder({
				Module = Instance.new("ModuleScript"),
			}),
		}),
	})

	expect(folder.Child.AnotherChild.Module).toBeDefined()
end)
