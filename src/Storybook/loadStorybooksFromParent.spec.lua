return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local ModuleLoader = require(flipbook.Packages.ModuleLoader)
	local newFolder = require(flipbook.Testing.newFolder)
	local loadStorybooksFromParent = require(script.Parent.loadStorybooksFromParent)

	it("should load Storybook objects from a parent", function()
		local loader = ModuleLoader.new()

		local storybookModule = Instance.new("ModuleScript")
		storybookModule.Source = [[
			return {
				storyRoots = {}
			}
		]]

		local nestedStorybookModule = Instance.new("ModuleScript")
		nestedStorybookModule.Source = [[
			return {
				storyRoots = {}
			}
		]]

		local badStorybookModule = Instance.new("ModuleScript")
		badStorybookModule.Source = [[
			return {
				storyRoots = true
			}
		]]

		local root = newFolder({
			["Foo.storybook"] = storybookModule,

			Level1 = newFolder({
				Level2 = newFolder({
					Level3 = newFolder({
						["Bar.storybook"] = nestedStorybookModule,
					}),
				}),
			}),

			["Bad.storybook"] = badStorybookModule,

			NotIncluded = Instance.new("ModuleScript"),
		})

		local storybooks, errors = loadStorybooksFromParent(root, loader)

		expect(#storybooks).to.equal(2)
		expect(#errors).to.equal(1)
	end)
end
