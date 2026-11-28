local Charm = require("@pkg/Charm")
local Storyteller = require("@pkg/Storyteller")

type LoadedStorybook = Storyteller.LoadedStorybook
type StoryModuleRecord = Storyteller.StoryModuleRecord
type StoryModuleRecords = Storyteller.StoryModuleRecords
type StoryModuleRequestPriority = Storyteller.StoryModuleRequestPriority
type StoryRequest = Storyteller.StoryRequest

--[=[
	The parts of Storyteller's shared runtime that the store reads Storybooks and
	records from, and requests Story modules through. They default to
	Storyteller's own functions, which ignore a custom store given to
	`StorytellerProvider`, so specs pass their own to control what loads.
]=]
export type Runtime = {
	getLoadedStorybooks: () -> { LoadedStorybook },
	getOrphanedStoryModules: () -> { ModuleScript },
	requestStoryModule: (request: StoryRequest) -> () -> (),
	getStoryModuleRecord: (request: StoryRequest) -> StoryModuleRecord?,
}

export type Options = {
	-- The Storybook that Story modules outside every Storybook's roots load with.
	orphanedStorybook: LoadedStorybook,
	-- Returns true for requests someone is waiting to see, which load ahead of
	-- the rest. Charm tracks the getters it reads, so priorities update when
	-- they change.
	isInteractive: ((request: StoryRequest) -> boolean)?,
	runtime: Runtime?,
}

export type StoryModuleRecordsStore = {
	getRequests: () -> { StoryRequest },
	getRecords: () -> StoryModuleRecords,
	start: () -> (),
	releaseAll: () -> (),
}

type ActiveRequest = {
	request: StoryRequest,
	release: () -> (),
}

local function areSameRequests(previous: { StoryRequest }?, current: { StoryRequest }): boolean
	if not previous or #previous ~= #current then
		return false
	end
	for index, request in previous do
		local nextRequest = current[index]
		if request.storyModule ~= nextRequest.storyModule or request.storybook ~= nextRequest.storybook then
			return false
		end
	end
	return true
end

local function hasEveryRecord(records: StoryModuleRecords, other: StoryModuleRecords): boolean
	for storybookSource, otherForStorybook in other do
		local recordsForStorybook = records[storybookSource]
		if not recordsForStorybook then
			return false
		end
		for storyModule, record in otherForStorybook do
			if recordsForStorybook[storyModule] ~= record then
				return false
			end
		end
	end
	return true
end

local function areSameRecords(previous: StoryModuleRecords?, current: StoryModuleRecords): boolean
	return previous ~= nil and hasEveryRecord(previous, current) and hasEveryRecord(current, previous)
end

--[=[
	Requests every Story module the sidebar lists from Storyteller, and keeps
	the records they load. The store holds one request for a Story module per
	Storybook whose roots contain it, and one with `orphanedStorybook` when no
	Storybook's roots do.

	Nothing is requested until `start` is called. From then on the store
	requests modules as they're discovered and releases them as they go away,
	until `releaseAll` releases every request.

	`getRecords` groups records by Storybook source, then keys them by Story
	module. A module that hasn't loaded yet has no record. The table stays the
	same until one of its records is added, replaced, or removed.
]=]
local function createStoryModuleRecordsStore(options: Options): StoryModuleRecordsStore
	local runtime: Runtime = options.runtime or Storyteller

	local getRequests = Charm.computed(function(previous: { StoryRequest }?): { StoryRequest }
		local requests: { StoryRequest } = {}
		local seen: { [ModuleScript]: boolean } = {}

		for _, storybook in runtime.getLoadedStorybooks() do
			for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook) do
				seen[storyModule] = true
				table.insert(requests, {
					storyModule = storyModule,
					storybook = storybook,
				})
			end
		end

		for _, storyModule in runtime.getOrphanedStoryModules() do
			if not seen[storyModule] then
				seen[storyModule] = true
				table.insert(requests, {
					storyModule = storyModule,
					storybook = options.orphanedStorybook,
				})
			end
		end

		-- Storyteller publishes a new orphan list whenever any Story module
		-- changes, such as on every edit to one. Keeping the previous list leaves
		-- anything that depends on it alone.
		if previous and areSameRequests(previous, requests) then
			return previous
		end
		return requests
	end)

	local getRecords = Charm.computed(function(previous: StoryModuleRecords?): StoryModuleRecords
		local records: StoryModuleRecords = {}
		for _, request in getRequests() do
			local record = runtime.getStoryModuleRecord(request)
			if record then
				local storybookSource = request.storybook.source
				local recordsForStorybook = records[storybookSource]
				if not recordsForStorybook then
					recordsForStorybook = {}
					records[storybookSource] = recordsForStorybook
				end
				recordsForStorybook[request.storyModule] = record
			end
		end

		-- Storyteller replaces its whole record map whenever any record
		-- publishes, including records requested elsewhere. Keeping the previous
		-- table means only changes to these records reach the sidebar.
		if previous and areSameRecords(previous, records) then
			return previous
		end
		return records
	end)

	-- Requests held right now, by Story module and then Storybook source.
	local activeRequests: { [ModuleScript]: { [ModuleScript]: ActiveRequest } } = {}

	local function getPriority(request: StoryRequest): StoryModuleRequestPriority
		return if options.isInteractive and options.isInteractive(request) then "Interactive" else "Background"
	end

	-- A list can name the same module and Storybook source more than once. They
	-- share one request, at the highest priority any of them asks for.
	local function getPriorities(
		requests: { StoryRequest }
	): { [ModuleScript]: { [ModuleScript]: StoryModuleRequestPriority } }
		local priorities: { [ModuleScript]: { [ModuleScript]: StoryModuleRequestPriority } } = {}
		for _, request in requests do
			local prioritiesForModule = priorities[request.storyModule]
			if not prioritiesForModule then
				prioritiesForModule = {}
				priorities[request.storyModule] = prioritiesForModule
			end
			if prioritiesForModule[request.storybook.source] ~= "Interactive" then
				prioritiesForModule[request.storybook.source] = getPriority(request)
			end
		end
		return priorities
	end

	local function holdRequests(
		requests: { StoryRequest },
		priorities: { [ModuleScript]: { [ModuleScript]: StoryModuleRequestPriority } }
	)
		for _, request in requests do
			local storyModule = request.storyModule
			local storybookSource = request.storybook.source
			local priority: StoryModuleRequestPriority = priorities[storyModule][storybookSource]

			local requestsForModule = activeRequests[storyModule]
			if not requestsForModule then
				requestsForModule = {}
				activeRequests[storyModule] = requestsForModule
			end

			local activeRequest = requestsForModule[storybookSource]
			if
				activeRequest
				and activeRequest.request.storybook == request.storybook
				and activeRequest.request.priority == priority
			then
				continue
			end

			-- Storyteller drops a module's record when its last request is
			-- released. Making the replacement request first keeps the record,
			-- so a priority change doesn't load the module again.
			local nextRequest: StoryRequest = {
				storyModule = storyModule,
				storybook = request.storybook,
				priority = priority,
			}
			requestsForModule[storybookSource] = {
				request = nextRequest,
				release = runtime.requestStoryModule(nextRequest),
			}
			if activeRequest then
				activeRequest.release()
			end
		end

		for storyModule, requestsForModule in activeRequests do
			local prioritiesForModule = priorities[storyModule]
			for storybookSource, activeRequest in requestsForModule do
				if not prioritiesForModule or not prioritiesForModule[storybookSource] then
					activeRequest.release()
					requestsForModule[storybookSource] = nil
				end
			end
			if next(requestsForModule) == nil then
				activeRequests[storyModule] = nil
			end
		end
	end

	local stopHolding: (() -> ())?

	local function start()
		if stopHolding then
			return
		end
		stopHolding = Charm.effect(function()
			local requests = getRequests()
			local priorities = getPriorities(requests)
			-- Requesting a module reads and writes Storyteller's own state, which
			-- this effect shouldn't rerun for.
			Charm.untracked(holdRequests, requests, priorities)
		end)
	end

	local function releaseAll()
		if stopHolding then
			stopHolding()
			stopHolding = nil
		end
		for _, requestsForModule in activeRequests do
			for _, activeRequest in requestsForModule do
				activeRequest.release()
			end
		end
		table.clear(activeRequests)
	end

	return {
		getRequests = getRequests,
		getRecords = getRecords,
		start = start,
		releaseAll = releaseAll,
	}
end

return createStoryModuleRecordsStore
