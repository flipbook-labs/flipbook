local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Storyteller = require("@pkg/Storyteller")

local FlipbookAgents = require("@workspace/flipbook-agents/src")
local constants = require("@root/constants")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")

local StoryStatus = FlipbookAgents.StoryStatus

type AppAdapter = FlipbookAgents.AppAdapter
type StorybookInfo = FlipbookAgents.StorybookInfo
type StoryInfo = FlipbookAgents.StoryInfo
type LoadedStory = Storyteller.LoadedStory<unknown>
type LoadedStorybook = Storyteller.LoadedStorybook
type StoryModuleRecord = Storyteller.StoryModuleRecord
type StoryModuleRequestPriority = Storyteller.StoryModuleRequestPriority
type UnavailableStorybook = Storyteller.UnavailableStorybook

type Storybooks = {
	available: { LoadedStorybook },
	unavailable: { UnavailableStorybook },
}

type HeldRequest = {
	storybook: LoadedStorybook,
	priority: StoryModuleRequestPriority,
	release: () -> (),
}

export type Dependencies = {
	embedFlipbook: (destination: Instance) -> Instance,
	getStorybooks: () -> Storybooks,
	getCurrentStory: () -> (ModuleScript?, LoadedStorybook?, string?),
	openStory: (storyModule: ModuleScript, storybook: LoadedStorybook?, storyId: string?) -> (),
}

local function serializeStorybook(storybook: LoadedStorybook): StorybookInfo
	return {
		name = storybook.name,
		path = getInstancePath(storybook.source),
	}
end

local function getStorybookPath(storybook: LoadedStorybook?): string?
	return if storybook then getInstancePath(storybook.source) else nil
end

local function serializeStory(story: LoadedStory, storybook: LoadedStorybook?): StoryInfo
	return {
		id = story.id,
		name = story.name,
		path = getInstancePath(story.source),
		storybook = getStorybookPath(storybook),
		status = StoryStatus.Loaded,
	}
end

--[[
	Describes a Story module whose Stories aren't known: it's still loading,
	or it failed to load and `problem` says why. `storyId` carries the Story
	someone asked for, if any, so it reads back once the module loads.
]]
local function serializeModule(
	storyModule: ModuleScript,
	storybook: LoadedStorybook?,
	record: StoryModuleRecord?,
	storyId: string?
): StoryInfo
	return {
		id = storyId,
		name = storyModule.Name:gsub("%.story$", ""),
		path = getInstancePath(storyModule),
		storybook = getStorybookPath(storybook),
		status = if record then StoryStatus.Unavailable else StoryStatus.Loading,
		problem = if record and record.status == "Unavailable" then record.problem else nil,
	}
end

local function findStory(stories: { LoadedStory }, storyId: string?): LoadedStory?
	if storyId == nil then
		return stories[1]
	end
	for _, story in stories do
		if story.id == storyId then
			return story
		end
	end
	return nil
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

--[[
	Builds the app adapter, and a function that releases the Story module
	requests it holds. Call that function when the adapter is unregistered.

	Story modules load through Storyteller's shared runtime, the same records
	the Story view reads, so listing Stories never runs a module's code while
	an agent waits. A module that hasn't loaded yet reports `status = "Loading"`
	until a later call finds its record.
]]
local function createAppAdapter(dependencies: Dependencies): (AppAdapter, () -> ())
	--[[
		Orphaned Story modules have no Storybook of their own, so they load
		with an empty one, the same way the sidebar loads them. Keeping one
		table matters: Storyteller treats a new Storybook table as a new
		version and loads the module again.
	]]
	local orphanedStorybook = createLoadedStorybook()
	local heldRequests: { [ModuleScript]: { [ModuleScript]: HeldRequest } } = {}

	--[[
		Requests a Story module from Storyteller's shared runtime and returns
		its record, or nil while it loads. The request stays held until the
		adapter is released, so the record follows edits to the module.

		An Interactive request replaces a held Background one, and a reloaded
		Storybook replaces the request for its previous version. The new
		request is made before the old one is released, so the record isn't
		dropped in between.
	]]
	local function readRecord(
		storyModule: ModuleScript,
		storybook: LoadedStorybook,
		priority: StoryModuleRequestPriority
	): StoryModuleRecord?
		local requestsForStorybook = heldRequests[storybook.source]
		if requestsForStorybook == nil then
			requestsForStorybook = {}
			heldRequests[storybook.source] = requestsForStorybook
		end

		local held = requestsForStorybook[storyModule]
		local nextPriority: StoryModuleRequestPriority = if held and held.priority == "Interactive"
			then "Interactive"
			else priority
		local request = {
			storyModule = storyModule,
			storybook = storybook,
			priority = nextPriority,
		}

		if held == nil or held.storybook ~= storybook or held.priority ~= nextPriority then
			local release = Storyteller.requestStoryModule(request)
			if held then
				held.release()
			end
			requestsForStorybook[storyModule] = {
				storybook = storybook,
				priority = nextPriority,
				release = release,
			}
		end

		return Storyteller.getStoryModuleRecord(request)
	end

	local function releaseRequests()
		for _, requestsForStorybook in heldRequests do
			for _, held in requestsForStorybook do
				held.release()
			end
		end
		table.clear(heldRequests)
	end

	local function isDiscoveredStory(story: ModuleScript, storybook: LoadedStorybook): boolean
		return table.find(Storyteller.findStoryModulesForStorybook(storybook), story) ~= nil
	end

	local function findStorybook(storybookPath: string): LoadedStorybook
		for _, storybook in dependencies.getStorybooks().available do
			if getInstancePath(storybook.source) == storybookPath then
				return storybook
			end
		end
		error(`storybook is unavailable: {storybookPath}`)
	end

	local function findStorybookForStory(story: ModuleScript): LoadedStorybook?
		for _, storybook in dependencies.getStorybooks().available do
			if isDiscoveredStory(story, storybook) then
				return storybook
			end
		end
		return nil
	end

	local adapter: AppAdapter = {
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

			return getInstancePath(dependencies.embedFlipbook(destination))
		end,

		listStorybooks = function()
			local result = {}
			for _, storybook in dependencies.getStorybooks().available do
				table.insert(result, serializeStorybook(storybook))
			end
			return result
		end,

		listStories = function(storybookPath: string?)
			local storybook = if storybookPath then findStorybook(storybookPath) else nil
			local storyModules: { ModuleScript } = if storybook
				then Storyteller.findStoryModulesForStorybook(storybook)
				else Storyteller.findOrphanedStoryModules(game, dependencies.getStorybooks().available)

			local result = {}
			for _, storyModule in storyModules do
				local record = readRecord(storyModule, storybook or orphanedStorybook, "Background")
				if record and record.status == "Loaded" then
					for _, story in record.stories do
						table.insert(result, serializeStory(story, storybook))
					end
				else
					table.insert(result, serializeModule(storyModule, storybook, record, nil))
				end
			end
			return result
		end,

		openStory = function(storyPath: string, storybookPath: string?, storyId: string?)
			local storyModule = resolveModuleScript(storyPath, "story")
			local storybook = if storybookPath then findStorybook(storybookPath) else findStorybookForStory(storyModule)
			if storybook ~= nil and not isDiscoveredStory(storyModule, storybook) then
				error(`story is not discovered by storybook {storybookPath}: {storyPath}`)
			end
			if storybook == nil and not Storyteller.isStoryModule(storyModule) then
				error(`story must be a discovered .story ModuleScript: {storyPath}`)
			end

			local record = readRecord(storyModule, storybook or orphanedStorybook, "Interactive")
			if record and record.status == "Loaded" then
				local story = findStory(record.stories, storyId)
				if story == nil then
					error(`story id not found in {storyPath}: {storyId}`)
				end
				dependencies.openStory(storyModule, storybook, story.id)
				return serializeStory(story, storybook)
			end

			-- A specific Story has to exist to open it. Without one, the module
			-- still opens, and Flipbook shows why it failed to load.
			if record and record.status == "Unavailable" and storyId ~= nil then
				error(record.problem)
			end

			-- While the module loads, the Story view resolves `storyId` itself,
			-- and getCurrentStory reports it once the record arrives.
			dependencies.openStory(storyModule, storybook, storyId)
			return serializeModule(storyModule, storybook, record, storyId)
		end,

		getCurrentStory = function()
			local storyModule, storybook, storyId = dependencies.getCurrentStory()
			if storyModule == nil then
				return nil
			end

			local record = readRecord(storyModule, storybook or orphanedStorybook, "Interactive")
			if record and record.status == "Loaded" then
				local story = findStory(record.stories, storyId)
				if story then
					return serializeStory(story, storybook)
				end

				local missing = serializeModule(storyModule, storybook, record, storyId)
				missing.problem = `story id not found in {getInstancePath(storyModule)}: {storyId}`
				return missing
			end

			return serializeModule(storyModule, storybook, record, storyId)
		end,
	}

	return adapter, releaseRequests
end

return createAppAdapter
