local types = require("@root/types")

type AgentController = types.AgentController
type AppImplementation = types.AppImplementation
type Controls = types.Controls
type StoryImplementation = types.StoryImplementation

local function createAgentController(openSurface: () -> ()): AgentController
	local appImplementation: AppImplementation? = nil
	local storyImplementations: { [string]: StoryImplementation } = {}

	local function getAppImplementation(): AppImplementation
		if appImplementation == nil then
			error("Flipbook app is not mounted")
		end
		return appImplementation
	end

	local function getMountedStoryImplementation(): StoryImplementation?
		local currentStory = getAppImplementation().getCurrentStory()
		if currentStory == nil then
			return nil
		end

		return storyImplementations[currentStory.path]
	end

	local function getControls(): Controls
		local mountedStoryImplementation = getMountedStoryImplementation()
		if mountedStoryImplementation == nil then
			return {}
		end
		return mountedStoryImplementation.getControls()
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

		openStory = function(storyPath: string, storybookPath: string?)
			openSurface()
			return getAppImplementation().openStory(storyPath, storybookPath)
		end,

		getCurrentStory = function()
			local story = getAppImplementation().getCurrentStory()
			if story == nil then
				return nil
			end

			return {
				name = story.name,
				path = story.path,
				storybook = story.storybook,
				isMounted = storyImplementations[story.path] ~= nil,
			}
		end,

		getControls = getControls,

		setControls = function(controls: Controls)
			local mountedStoryImplementation = getMountedStoryImplementation()
			if mountedStoryImplementation == nil then
				error("setControls requires the story view to be mounted")
			end
			return mountedStoryImplementation.setControls(controls)
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
			storyImplementations[implementation.path] = implementation
			return function()
				if storyImplementations[implementation.path] == implementation then
					storyImplementations[implementation.path] = nil
				end
			end
		end,
	}
end

return createAgentController
