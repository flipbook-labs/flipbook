return function()
	local flipbook = script:FindFirstAncestor("flipbook")

	local ModuleLoader = require(flipbook.Packages.ModuleLoader)
	local newFolder = require(flipbook.Testing.newFolder)
	local types = require(flipbook.Storybook.types)
	local loadStoriesFromStorybook = require(script.Parent.loadStoriesFromStorybook)

	type Storybook = types.Storybook

	it("should load Story objects from a Storybook", function()
		local loader = ModuleLoader.new()

		local storyModule = Instance.new("ModuleScript")
		storyModule.Source = [[
			return {
				story = function() end
			}
		]]

		local badStoryModule = Instance.new("ModuleScript")
		badStoryModule.Source = [[
			return {
				name = true
			}
		]]

		local root = newFolder({
			Components = newFolder({
				["Foo.story"] = storyModule,

				Nested = newFolder({
					["Bar.story"] = badStoryModule,
				}),
			}),
		})

		local storybook: Storybook = {
			storyRoots = { root },
		}

		local stories, errors = loadStoriesFromStorybook(storybook, loader)

		expect(#stories).to.equal(1)
		expect(#errors).to.equal(1)
	end)
end
