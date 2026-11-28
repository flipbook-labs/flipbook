local types = require("@root/types")

type AgentController = types.AgentController
type AppAdapter = types.AppAdapter
type Controls = types.Controls
type StoryAdapter = types.StoryAdapter
type StoryInfo = types.StoryInfo

local function createAgentController(surface: LayerCollector): AgentController
	local appAdapter: AppAdapter? = nil
	local storyAdapter: StoryAdapter? = nil

	local function openSurface()
		surface.Enabled = true
	end

	local function getAppAdapter(): AppAdapter
		if appAdapter == nil then
			error("Flipbook app is not mounted")
		end
		return appAdapter
	end

	--[[
		Returns the registered story adapter only when it belongs to `story`.
		Stories from one module share a path, so the id has to match too. While
		the selection moves between them, the outgoing Story stays registered
		until its view unmounts.
	]]
	local function getStoryAdapterFor(story: StoryInfo?): StoryAdapter?
		if story == nil or storyAdapter == nil then
			return nil
		end
		if storyAdapter.path ~= story.path or storyAdapter.id ~= story.id then
			return nil
		end
		return storyAdapter
	end

	local function getMountedStoryAdapter(): StoryAdapter?
		return getStoryAdapterFor(getAppAdapter().getCurrentStory())
	end

	local function getControls(): Controls
		local mountedStoryAdapter = getMountedStoryAdapter()
		if mountedStoryAdapter == nil then
			return {}
		end
		return mountedStoryAdapter.getControls()
	end

	return {
		openWidget = openSurface,

		embedFlipbook = function(parentPath: string?, overwrite: boolean?)
			return getAppAdapter().embedFlipbook(parentPath, overwrite == true)
		end,

		listStorybooks = function()
			return getAppAdapter().listStorybooks()
		end,

		listStories = function(storybookPath: string?)
			return getAppAdapter().listStories(storybookPath)
		end,

		openStory = function(storyPath: string, storybookPath: string?, storyId: string?)
			openSurface()
			return getAppAdapter().openStory(storyPath, storybookPath, storyId)
		end,

		getCurrentStory = function(): types.CurrentStory?
			local story = getAppAdapter().getCurrentStory()
			if story == nil then
				return nil
			end

			return {
				id = story.id,
				name = story.name,
				path = story.path,
				storybook = story.storybook,
				status = story.status,
				problem = story.problem,
				isMounted = getStoryAdapterFor(story) ~= nil,
			}
		end,

		getControls = getControls,

		setControls = function(controls: Controls)
			local mountedStoryAdapter = getMountedStoryAdapter()
			if mountedStoryAdapter == nil then
				error("setControls requires the story view to be mounted")
			end
			return mountedStoryAdapter.setControls(controls)
		end,

		registerApp = function(adapter: AppAdapter)
			appAdapter = adapter
			return function()
				if appAdapter == adapter then
					appAdapter = nil
				end
			end
		end,

		registerStory = function(adapter: StoryAdapter)
			storyAdapter = adapter
			return function()
				if storyAdapter == adapter then
					storyAdapter = nil
				end
			end
		end,
	}
end

return createAgentController
