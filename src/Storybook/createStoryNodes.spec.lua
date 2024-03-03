return function()
	local types = require("@root/Storybook/types")
	local newFolder = require("@root/Testing/newFolder")
	local createStoryNodes = require("./createStoryNodes")

	local mockStoryModule = Instance.new("ModuleScript")

	local mockStoryRoot = newFolder({
		Components = newFolder({
			["Component"] = Instance.new("ModuleScript"),
			["Component.story"] = mockStoryModule,
		}),
	})

	local mockStorybook: types.Storybook = {
		name = "MockStorybook",
		storyRoots = { mockStoryRoot },
	}

	it("should use an icon for storybooks", function()
		local nodes = createStoryNodes({ mockStorybook })

		local storybook = nodes[1]
		expect(storybook).to.be.ok()
		expect(storybook.icon).to.equal("storybook")
	end)

	it("should use an icon for container instances", function()
		local nodes = createStoryNodes({ mockStorybook })

		local storybook = nodes[1]
		local components = storybook.children[1]

		expect(components).to.be.ok()
		expect(components.icon).to.equal("folder")
	end)

	it("should use an icon for stories", function()
		local nodes = createStoryNodes({ mockStorybook })

		local storybook = nodes[1]
		local components = storybook.children[1]
		local story = components.children[1]

		expect(story).to.be.ok()
		expect(story.icon).to.equal("story")
	end)

	it("should ignore other ModuleScripts", function()
		local nodes = createStoryNodes({ mockStorybook })

		local storybook = nodes[1]
		local components = storybook.children[1]

		-- In mockStoryRoot, there is a Component module and an accompanying
		-- story. We only want stories in the node tree, so we only expect to
		-- get one child
		expect(#components.children).to.equal(1)
	end)
end
