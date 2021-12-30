return function()
	local newFolder = require(script.Parent.Mocks.newFolder)
	local getStories = require(script.Parent.getStories)

	it("should return all descendant stories in an array", function()
		local parent = newFolder({
			Child = newFolder({
				["Foo.story"] = Instance.new("ModuleScript"),
			}),
			["Bar.story"] = Instance.new("ModuleScript"),
		})

		expect(#getStories(parent)).to.equal(2)
	end)

	it("should not match words with 'story' in the name", function()
		local parent = newFolder({
			History = newFolder({}),
		})

		expect(#getStories(parent)).to.equal(0)
	end)
end
