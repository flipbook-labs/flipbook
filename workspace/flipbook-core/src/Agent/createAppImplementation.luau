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
type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

type Storybooks = {
	available: { LoadedStorybook },
	unavailable: { UnavailableStorybook },
}

export type Options = {
	embedFlipbook: (destination: Instance) -> Instance,
	getStorybooks: () -> Storybooks,
	getCurrentStory: () -> (ModuleScript?, LoadedStorybook?),
	openStory: (ModuleScript, LoadedStorybook?) -> (),
}

local function serializeStorybook(storybook: LoadedStorybook): StorybookInfo
	return {
		name = storybook.name,
		path = getInstancePath(storybook.source),
	}
end

local function serializeStory(story: ModuleScript, storybook: LoadedStorybook?): StoryInfo
	return {
		name = story.Name:gsub("%.story$", ""),
		path = getInstancePath(story),
		storybook = if storybook then getInstancePath(storybook.source) else nil,
	}
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
			for _, story in Storyteller.findStoryModulesForStorybook(storybook) do
				table.insert(result, serializeStory(story, storybook))
			end
			return result
		end,

		openStory = function(storyPath: string, storybookPath: string?)
			local story = resolveModuleScript(storyPath, "story")
			local storybook = if storybookPath then findStorybook(storybookPath) else findStorybookForStory(story)
			options.openStory(story, storybook)
			return serializeStory(story, storybook)
		end,

		getCurrentStory = function()
			local story, storybook = options.getCurrentStory()
			return if story then serializeStory(story, storybook) else nil
		end,
	}
end

return createAppImplementation
