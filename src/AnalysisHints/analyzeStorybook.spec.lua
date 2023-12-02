return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local types = require(flipbook.types)
	local analyzeStorybook = require(script.Parent.analyzeStorybook)

	type Storybook = types.Storybook

	it("should work with nothing but an empty storyRoots array", function()
		local storybook = Instance.new("ModuleScript")
		storybook.Name = "test.storybook.lua"
		storybook.Source = [[{
			storyRoots = {},
		}]]

		local diagnostics = analyzeStorybook(storybook)

		expect(#diagnostics).to.equal(0)
	end)

	it("should work with nothing but a storyRoots array with an instance inside", function()
		local storybook = Instance.new("ModuleScript")
		storybook.Name = "test.storybook.lua"
		storybook.Source = [[{
			storyRoots = {
				Instance.new("Folder"),
			},
		}]]

		local diagnostics = analyzeStorybook(storybook)

		expect(#diagnostics).to.equal(0)
	end)

	it("should return diagnostics for a bad storyRoots array", function()
		local storybook = Instance.new("ModuleScript")
		storybook.Name = "test.storybook.lua"
		storybook.Source = [[{
			storyRoots = {
				true,
				"foo",
				2,
			},
		}]]

		local diagnostics = analyzeStorybook(storybook)

		expect(#diagnostics).to.equal(1)
	end)

	it("should return diagnostics for a bad storyRoots value", function()
		local storybook = Instance.new("ModuleScript")
		storybook.Name = "test.storybook.lua"
		storybook.Source = [[{
			storyRoots = {
				true,
				"foo",
				2,
			},
		}]]

		local diagnostics = analyzeStorybook(storybook)

		expect(#diagnostics).to.equal(1)
	end)
end
