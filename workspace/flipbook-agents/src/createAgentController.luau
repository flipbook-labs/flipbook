local types = require("@root/types")

type AgentController = types.AgentController
type AppAdapter = types.AppAdapter
type Controls = types.Controls
type MovableSurface = types.MovableSurface
type StoryAdapter = types.StoryAdapter

local function createAgentController(surface: LayerCollector, movableSurface: MovableSurface?): AgentController
	local appAdapter: AppAdapter? = nil
	local storyAdapter: StoryAdapter? = nil

	local function openWidget()
		if movableSurface then
			movableSurface.openWidget()
		else
			surface.Enabled = true
		end
	end

	local function openViewport()
		if movableSurface == nil then
			error("openViewport is only available in the Flipbook plugin")
		end
		movableSurface.openViewport()
	end

	-- Opening a story leaves the app in the viewport if it's already there.
	local function ensureVisible()
		if movableSurface == nil or not movableSurface.isVisible() then
			openWidget()
		end
	end

	local function getAppAdapter(): AppAdapter
		if appAdapter == nil then
			error("Flipbook app is not mounted")
		end
		return appAdapter
	end

	local function getMountedStoryAdapter(): StoryAdapter?
		local currentStory = getAppAdapter().getCurrentStory()
		if currentStory == nil or storyAdapter == nil or storyAdapter.path ~= currentStory.path then
			return nil
		end

		return storyAdapter
	end

	local function getControls(): Controls
		local mountedStoryAdapter = getMountedStoryAdapter()
		if mountedStoryAdapter == nil then
			return {}
		end
		return mountedStoryAdapter.getControls()
	end

	return {
		openWidget = openWidget,

		openViewport = openViewport,

		embedFlipbook = function(parentPath: string?, overwrite: boolean?)
			return getAppAdapter().embedFlipbook(parentPath, overwrite == true)
		end,

		listStorybooks = function()
			return getAppAdapter().listStorybooks()
		end,

		listStories = function(storybookPath: string?)
			return getAppAdapter().listStories(storybookPath)
		end,

		openStory = function(storyPath: string, storybookPath: string?)
			ensureVisible()
			return getAppAdapter().openStory(storyPath, storybookPath)
		end,

		getCurrentStory = function(): types.CurrentStory?
			local story = getAppAdapter().getCurrentStory()
			if story == nil then
				return nil
			end

			return {
				name = story.name,
				path = story.path,
				storybook = story.storybook,
				isMounted = storyAdapter ~= nil and storyAdapter.path == story.path,
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
