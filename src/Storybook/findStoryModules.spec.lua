return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local Sift = require(flipbook.Packages.Sift)
	local newFolder = require(flipbook.Testing.newFolder)
	local findStoryModules = require(script.Parent.findStoryModules)

	it("should return an array of story modules", function()
		local storyModule = Instance.new("ModuleScript")
		local nestedStoryModule = Instance.new("ModuleScript")

		local root = newFolder({
			["Foo.story"] = storyModule,

			Level1 = newFolder({
				Level2 = newFolder({
					Level3 = newFolder({
						["Bar.story"] = nestedStoryModule,
					}),
				}),
			}),

			NotIncluded = Instance.new("ModuleScript"),
		})

		local modules = findStoryModules(root)

		expect(modules).to.be.ok()
		expect(#modules).to.equal(2)
		expect(Sift.Array.contains(modules, storyModule)).to.equal(true)
		expect(Sift.Array.contains(modules, nestedStoryModule)).to.equal(true)
	end)

	it("should return an empty array if no story modules are found", function()
		local root = Instance.new("Folder")

		local modules = findStoryModules(root)

		expect(modules).to.be.ok()
		expect(#modules).to.equal(0)
	end)
end
