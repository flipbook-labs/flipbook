return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local Sift = require(flipbook.Packages.Sift)
	local newFolder = require(flipbook.Testing.newFolder)
	local findStorybookModules = require(script.Parent.findStorybookModules)

	it("should return an array of storybook modules", function()
		local storybookModule = Instance.new("ModuleScript")
		local nestedStorybookModule = Instance.new("ModuleScript")

		local root = newFolder({
			["Foo.storybook"] = storybookModule,

			Level1 = newFolder({
				Level2 = newFolder({
					Level3 = newFolder({
						["Bar.storybook"] = nestedStorybookModule,
					}),
				}),
			}),

			NotIncluded = Instance.new("ModuleScript"),
		})

		local modules = findStorybookModules(root)

		expect(modules).to.be.ok()
		expect(#modules).to.equal(2)
		expect(Sift.Array.contains(modules, storybookModule)).to.equal(true)
		expect(Sift.Array.contains(modules, nestedStorybookModule)).to.equal(true)
	end)

	it("should return an empty array if no storybook modules are found", function()
		local root = Instance.new("Folder")

		local modules = findStorybookModules(root)

		expect(modules).to.be.ok()
		expect(#modules).to.equal(0)
	end)
end
