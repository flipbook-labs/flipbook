local flipbook = script:FindFirstAncestor("flipbook")

return function()
	local React = require(flipbook.Packages.React)
	local ReactRoblox = require(flipbook.Packages.ReactRoblox)
	local newFolder = require(flipbook.TestHelpers.newFolder)
	local useDescendants = require(script.Parent.useDescendants)

	local container = Instance.new("ScreenGui")
	local root = ReactRoblox.createRoot(container)

	afterEach(function()
		ReactRoblox.act(function()
			root:unmount()
		end)
	end)

	it("should return an initial list of descendants that match the predicate", function()
		local tree = newFolder({
			Match = Instance.new("Part"),
			Foo = Instance.new("Part"),
		})

		local descendants
		local function HookTester()
			descendants = useDescendants(tree, function(descendant)
				return descendant.Name == "Match"
			end)

			return nil
		end

		ReactRoblox.act(function()
			root:render(React.createElement(HookTester))
		end)

		expect(descendants).to.be.ok()
		expect(#descendants).to.equal(1)
		expect(descendants[1]).to.equal(tree:FindFirstChild("Match"))
	end)

	it("should respond to changes in descendants that match the predicate", function()
		local tree = newFolder({
			Match = Instance.new("Part"),
			Foo = Instance.new("Part"),
		})

		local descendants
		local function HookTester()
			descendants = useDescendants(tree, function(descendant)
				return descendant.Name == "Match"
			end)

			return nil
		end

		ReactRoblox.act(function()
			root:render(React.createElement(HookTester))
		end)

		expect(descendants).to.be.ok()
		expect(#descendants).to.equal(1)

		local folder = newFolder({
			Match = Instance.new("Part"),
		})

		ReactRoblox.act(function()
			folder.Parent = tree
		end)

		expect(#descendants).to.equal(2)
	end)

	it("should force an update when a matching descendant's name changes", function()
		local descendants

		local tree = newFolder({
			Match = Instance.new("Part"),
		})

		local function HookTester()
			descendants = useDescendants(tree, function(descendant)
				return descendant:IsA("Part")
			end)

			return nil
		end

		ReactRoblox.act(function()
			root:render(React.createElement(HookTester))
		end)

		expect(descendants).to.be.ok()
		expect(#descendants).to.equal(1)

		local prev = descendants
		local match = tree:FindFirstChild("Match")

		ReactRoblox.act(function()
			match.Name = "Changed"
		end)

		expect(descendants).never.to.equal(prev)
		expect(descendants[1]).to.equal(match)
	end)
end
