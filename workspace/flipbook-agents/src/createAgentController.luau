local types = require("@root/types")

type AgentController = types.AgentController
type AppImplementation = types.AppImplementation
type Controls = types.Controls
type StoryInfo = types.StoryInfo
type StoryImplementation = types.StoryImplementation

local function createAgentController(openSurface: () -> ()): AgentController
	local appImplementation: AppImplementation? = nil
	local storyImplementation: StoryImplementation? = nil

	local function getAppImplementation(): AppImplementation
		if appImplementation == nil then
			error("Flipbook app is not mounted")
		end
		return appImplementation
	end

	local function getMountedStoryImplementation(story: StoryInfo?): StoryImplementation?
		if story == nil or storyImplementation == nil then
			return nil
		end
		if storyImplementation.path ~= story.path or storyImplementation.id ~= story.id then
			return nil
		end
		return storyImplementation
	end

	local function getControls(): Controls
		if appImplementation == nil then
			return {}
		end
		local mountedStory = getMountedStoryImplementation(appImplementation.getCurrentStory())
		return if mountedStory then mountedStory.getControls() else {}
	end

	return {
		openWidget = openSurface,

		embedFlipbook = function(parentPath: string?, overwrite: boolean?)
			return getAppImplementation().embedFlipbook(parentPath, overwrite == true)
		end,

		listStorybooks = function()
			return getAppImplementation().listStorybooks()
		end,

		listStories = function(storybookPath: string)
			return getAppImplementation().listStories(storybookPath)
		end,

		openStory = function(storyPath: string, storybookPath: string?, storyId: string?)
			openSurface()
			return getAppImplementation().openStory(storyPath, storybookPath, storyId)
		end,

		getCurrentStory = function()
			local story = getAppImplementation().getCurrentStory()
			if story == nil then
				return nil
			end

			local isMounted = getMountedStoryImplementation(story) ~= nil

			return {
				id = story.id,
				name = story.name,
				path = story.path,
				storybook = story.storybook,
				controlsReady = isMounted,
				isMounted = isMounted,
			}
		end,

		getControls = getControls,

		setControls = function(controls: Controls)
			local story = if appImplementation then appImplementation.getCurrentStory() else nil
			local mountedStory = getMountedStoryImplementation(story)
			if mountedStory == nil then
				error("setControls requires the story view to be mounted")
			end
			return mountedStory.setControls(controls)
		end,

		registerApp = function(implementation: AppImplementation)
			appImplementation = implementation
			return function()
				if appImplementation == implementation then
					appImplementation = nil
				end
			end
		end,

		registerStory = function(implementation: StoryImplementation)
			storyImplementation = implementation
			return function()
				if storyImplementation == implementation then
					storyImplementation = nil
				end
			end
		end,
	}
end

return createAgentController
