local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local loadStorybooksFromParent = require(flipbook.Storybook.loadStorybooksFromParent)
local loadStoriesFromStorybook = require(flipbook.Storybook.loadStoriesFromStorybook)
local mountStory = require(flipbook.Storybook.mountStory)

return function()
	local loader = ModuleLoader.new()
	local storybooks, storybookErrors = loadStorybooksFromParent(flipbook, loader)

	it("should load all storybooks", function()
		expect(#storybookErrors).to.equal(0)
	end)

	for _, storybook in storybooks do
		local stories, storyErrors = loadStoriesFromStorybook(storybook, loader)

		it(`should load all stories for {storybook.name}`, function()
			expect(#storyErrors).to.equal(0)
		end)

		for _, story in stories do
			it(`should mount/unmount {storybook.name} > {story.name}`, function()
				local controls = {}

				if typeof(story) == "table" and story.controls then
					controls = story.controls
				end

				local cleanup
				expect(function()
					cleanup = mountStory(story, controls, CoreGui)
				end).to.never.throw()

				if cleanup then
					expect(cleanup).to.never.throw()
				end
			end)
		end
	end
end
