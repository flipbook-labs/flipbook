local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Storyteller = require("@pkg/Storyteller")

local FlipbookAgents = require("@workspace/flipbook-agents/src")
local constants = require("@root/constants")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")

type AppImplementation = FlipbookAgents.AppImplementation
type StorybookInfo = FlipbookAgents.StorybookInfo
type StoryInfo = FlipbookAgents.StoryInfo
type LoadedStory = Storyteller.LoadedStory<unknown>
type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

type Storybooks = {
	available: { LoadedStorybook },
	unavailable: { UnavailableStorybook },
}

export type Options = {
	embedFlipbook: (destination: Instance) -> Instance,
	getStorybooks: () -> Storybooks,
	getCurrentStory: () -> (ModuleScript?, LoadedStorybook?, string?),
	openStory: (ModuleScript, LoadedStorybook?, string?) -> (),
}

local function serializeStorybook(storybook: LoadedStorybook): StorybookInfo
	return {
		name = storybook.name,
		path = getInstancePath(storybook.source),
	}
end

local function serializeStory(story: LoadedStory): StoryInfo
	return {
		id = story.id,
		name = story.name,
		path = getInstancePath(story.source),
		storybook = getInstancePath(story.storybook.source),
	}
end

local function loadStory(storyModule: ModuleScript, storybook: LoadedStorybook, storyId: string?): LoadedStory
	local stories = Storyteller.loadStoriesFromModule(storyModule, storybook)
	if storyId == nil then
		return stories[1]
	end

	for _, story in stories do
		if story.id == storyId then
			return story
		end
	end

	error(`story id not found in {getInstancePath(storyModule)}: {storyId}`)
end

local function resolveModuleScript(path: string, label: string): ModuleScript
	local instance = getInstanceFromPath(path)
	if instance == nil then
		error(`{label} not found at path: {path}`)
	end
	if not instance:IsA("ModuleScript") then
		error(`{label} must be a ModuleScript: {path}`)
	end
	return instance
end

local function createAppImplementation(options: Options): AppImplementation
	local function findStorybook(storybookPath: string): LoadedStorybook
		for _, storybook in options.getStorybooks().available do
			if getInstancePath(storybook.source) == storybookPath then
				return storybook
			end
		end
		error(`storybook is unavailable: {storybookPath}`)
	end

	local function findStorybookForStory(story: ModuleScript): LoadedStorybook?
		for _, storybook in options.getStorybooks().available do
			for _, storyRoot in storybook.storyRoots do
				if storyRoot == story or storyRoot:IsAncestorOf(story) then
					return storybook
				end
			end
		end
		return nil
	end

	return {
		embedFlipbook = function(parentPath: string?, overwrite: boolean)
			local destination = if parentPath then getInstanceFromPath(parentPath) else ReplicatedStorage
			if destination == nil then
				error(`embedFlipbook parent not found: {parentPath}`)
			end

			local existing = CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG)
			if #existing > 0 and not overwrite then
				error(
					`Flipbook runtime already exists at {getInstancePath(existing[1])}; pass overwrite = true to replace it`
				)
			end

			return getInstancePath(options.embedFlipbook(destination))
		end,

		listStorybooks = function()
			local result = {}
			for _, storybook in options.getStorybooks().available do
				table.insert(result, serializeStorybook(storybook))
			end
			return result
		end,

		listStories = function(storybookPath: string)
			local storybook = findStorybook(storybookPath)
			local result = {}
			for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook) do
				for _, story in Storyteller.loadStoriesFromModule(storyModule, storybook) do
					table.insert(result, serializeStory(story))
				end
			end
			return result
		end,

		openStory = function(storyPath: string, storybookPath: string?, storyId: string?)
			local storyModule = resolveModuleScript(storyPath, "story")
			local storybook = if storybookPath then findStorybook(storybookPath) else findStorybookForStory(storyModule)
			if storybook == nil then
				error(`openStory could not resolve a storybook for: {storyPath}`)
			end

			local story = loadStory(storyModule, storybook, storyId)
			options.openStory(storyModule, storybook, story.id)
			return serializeStory(story)
		end,

		getCurrentStory = function()
			local storyModule, storybook, storyId = options.getCurrentStory()
			if storyModule == nil or storybook == nil then
				return nil
			end
			return serializeStory(loadStory(storyModule, storybook, storyId))
		end,
	}
end

return createAppImplementation
