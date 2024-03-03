return function()
	local isStoryModule = require("./isStoryModule")

	it("should return `true` for a ModuleScript with .story in the name", function()
		local module = Instance.new("ModuleScript")
		module.Name = "Foo.story"

		expect(isStoryModule(module)).to.equal(true)
	end)

	it("should return `false` if the given instance is not a ModuleScript", function()
		local folder = Instance.new("Folder")
		folder.Name = "Folder.story"

		expect(isStoryModule(folder)).to.equal(false)
	end)

	it("should return `false` if a ModuleScript does not have .story in the name", function()
		local module = Instance.new("ModuleScript")

		expect(isStoryModule(module)).to.equal(false)
	end)
end
