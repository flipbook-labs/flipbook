return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local ModuleLoader = require(flipbook.Packages.ModuleLoader)
	local loadStorybookModule = require(script.Parent.loadStorybookModule)

	it("should load a Storybook object from a ModuleScript", function()
		local loader = ModuleLoader.new()

		local storybookModule = Instance.new("ModuleScript")
		storybookModule.Name = "Foo.storybook"
		storybookModule.Source = [[
			return {
				storyRoots = {}
			}
		]]

		local storybook, err = loadStorybookModule(storybookModule, loader)

		expect(storybook).to.be.ok()
		expect(err).never.to.be.ok()
		expect(storybook.storyRoots).to.be.ok()
		expect(#storybook.storyRoots).to.equal(0)
	end)

	it("should set the name to the module's name", function()
		local loader = ModuleLoader.new()

		local storybookModule = Instance.new("ModuleScript")
		storybookModule.Name = "Foo.storybook"
		storybookModule.Source = [[
			return {
				storyRoots = {}
			}
		]]

		local storybook, err = loadStorybookModule(storybookModule, loader)

		expect(storybook).to.be.ok()
		expect(err).never.to.be.ok()
		expect(storybook.name).to.equal("Foo")
	end)

	it("should return an error message for malformed Storybook object", function()
		local loader = ModuleLoader.new()

		local storybookModule = Instance.new("ModuleScript")
		storybookModule.Name = "Foo.storybook"
		storybookModule.Source = [[
			return {
				storyRoots = true
			}
		]]

		local storybook, err = loadStorybookModule(storybookModule, loader)

		expect(storybook).never.to.be.ok()
		expect(err).to.be.ok()
	end)

	it("should return an error message for malformed source", function()
		local loader = ModuleLoader.new()

		local storybookModule = Instance.new("ModuleScript")
		storybookModule.Name = "Foo.storybook"
		storybookModule.Source = [[
			print(bad)
			return {}
		]]

		local storybook, err = loadStorybookModule(storybookModule, loader)

		expect(storybook).never.to.be.ok()
		expect(err).to.be.ok()
	end)
end
