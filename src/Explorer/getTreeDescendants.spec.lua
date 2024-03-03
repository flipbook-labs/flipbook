return function()
	local getTreeDescendants = require("./getTreeDescendants")

	it("should return an empty table when the root has no children", function()
		local root = { name = "root", children = {} }

		local result = getTreeDescendants(root)
		expect(result).to.be.a("table")
		expect(#result).to.equal(0)
	end)

	it("should return a table with all descendants when the root has children", function()
		local child1 = { name = "child1", children = {} }
		local child2 = { name = "child2", children = {} }
		local root = { name = "root", children = { child1, child2 } }

		local result = getTreeDescendants(root)
		expect(result).to.be.a("table")
		expect(#result).to.equal(2)
	end)

	it("should return a table with all descendants when the tree has multiple levels", function()
		local grandchild = { name = "grandchild", children = {} }
		local child = { name = "child", children = { grandchild } }
		local root = { name = "root", children = { child } }

		local result = getTreeDescendants(root)
		expect(result).to.be.a("table")
		expect(#result).to.equal(2)
	end)
end
