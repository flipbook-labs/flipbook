local createFusionRenderer = require(script.Parent.renderers.createFusionRenderer)
local createManualRenderer = require(script.Parent.renderers.createManualRenderer)
local createReactRenderer = require(script.Parent.renderers.createReactRenderer)
local createRoactRenderer = require(script.Parent.renderers.createRoactRenderer)
local types = require(script.Parent.types)

type LoadedStory<T> = types.LoadedStory<T>
type StoryRenderer<T> = types.StoryRenderer<T>

--[[
	This function will do its best to determine which of the renderers to use
	based off the Story’s properties.

	Each renderer is given its own file so that it’s easy to add on new UI
	libraries in the future. See [Story Renderer Spec](https://www.notion.so/Story-Renderer-Spec-4260feeab4574ad68f87006dee57cf75?pvs=21) for more details.

	@tag Rendering
	@tag Story
	@within Storyteller
]]
local function createRendererForStory<T>(story: LoadedStory<T>): StoryRenderer<any>
	local packages = if story.packages then story.packages else story.storybook.packages
	if packages then
		if packages.Roact then
			return createRoactRenderer(packages)
		elseif packages.React and packages.ReactRoblox then
			return createReactRenderer(packages)
		elseif packages.Fusion then
			return createFusionRenderer(packages)
		end
	end

	return createManualRenderer()
end

return createRendererForStory
