return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local isStoryModule = require(script.Parent.isStoryModule)
	local constants = require(flipbook.constants)

	it("should return `true` for a ModuleScript with .story in the name", function()
		local module = Instance.new("ModuleScript")
		module.Name = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then "Foo.stories" else "Foo.story"

		expect(isStoryModule(module)).to.equal(true)
	end)

	it("should return `false` if the given instance is not a ModuleScript", function()
		local folder = Instance.new("Folder")
		folder.Name = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then "Foo.stories" else "Folder.story"

		expect(isStoryModule(folder)).to.equal(false)
	end)

	it("should return `false` if a ModuleScript does not have .story in the name", function()
		local module = Instance.new("ModuleScript")

		expect(isStoryModule(module)).to.equal(false)
	end)
end
