local types = require("@root/types")

type AgentController = types.AgentController
type AppImplementation = types.AppImplementation
type Controls = types.Controls
type StoryImplementation = types.StoryImplementation

local function createAgentController(widget: DockWidgetPluginGui): AgentController
	local appImplementation: AppImplementation? = nil
	local storyImplementation: StoryImplementation? = nil

	local function getAppImplementation(): AppImplementation
		if appImplementation == nil then
			error("Flipbook app is not mounted")
		end
		return appImplementation
	end

	local function getControls(): Controls
		if storyImplementation == nil then
			return {}
		end
		return storyImplementation.getControls()
	end

	return {
		openWidget = function()
			widget.Enabled = true
		end,

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
			widget.Enabled = true
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
				isMounted = storyImplementation ~= nil and storyImplementation.path == story.path,
			}
		end,

		getControls = getControls,

		setControls = function(controls: Controls)
			if storyImplementation == nil then
				error("setControls requires the story view to be mounted")
			end
			return storyImplementation.setControls(controls)
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
