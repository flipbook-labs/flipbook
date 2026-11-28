local Charm = require("@pkg/Charm")
local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local createStoryModuleRecordsStore = require("./createStoryModuleRecordsStore")

local afterEach = JestGlobals.afterEach
local expect = JestGlobals.expect
local test = JestGlobals.test

type LoadedStorybook = Storyteller.LoadedStorybook
type StoryModuleRecord = Storyteller.StoryModuleRecord
type StoryRequest = Storyteller.StoryRequest

local cleanups: { () -> () } = {}

afterEach(function()
	for _, cleanup in cleanups do
		cleanup()
	end
	table.clear(cleanups)
end)

local function createStoryModule(name: string, parent: Instance?): ModuleScript
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = `{name}.story`
	storyModule.Source = "return { story = function() end }"
	storyModule.Parent = parent
	return storyModule
end

local function createStorybook(name: string, storyRoots: { Instance }): LoadedStorybook
	local source = Instance.new("ModuleScript")
	source.Name = `{name}.storybook`
	table.insert(cleanups, function()
		source:Destroy()
	end)
	return {
		name = name,
		source = source,
		storyRoots = storyRoots,
	}
end

local function createFolder(): Folder
	local folder = Instance.new("Folder")
	table.insert(cleanups, function()
		folder:Destroy()
	end)
	return folder
end

-- Stands in for Storyteller's shared runtime. Each request and release is
-- written to `log` as "request <module> <priority>" or "release <module>
-- <priority>", and records are set by hand with `setRecord`.
local function createFakeRuntime()
	local getStorybooks, setStorybooks = Charm.signal<<{ LoadedStorybook }>>({})
	local getOrphans, setOrphans = Charm.signal<<{ ModuleScript }>>({})
	local getRecordsByModule, setRecordsByModule = Charm.signal<<{ [ModuleScript]: StoryModuleRecord? }>>({})
	local log: { string } = {}

	local runtime: createStoryModuleRecordsStore.Runtime = {
		getLoadedStorybooks = getStorybooks,
		getOrphanedStoryModules = getOrphans,
		requestStoryModule = function(request: StoryRequest)
			local entry = `{request.storyModule.Name} {request.priority}`
			table.insert(log, `request {entry}`)
			return function()
				table.insert(log, `release {entry}`)
			end
		end,
		getStoryModuleRecord = function(request: StoryRequest)
			return getRecordsByModule()[request.storyModule]
		end,
	}

	return {
		runtime = runtime,
		log = log,
		setStorybooks = setStorybooks,
		setOrphans = setOrphans,
		setRecord = function(storyModule: ModuleScript, record: StoryModuleRecord?)
			setRecordsByModule(function(previous)
				local nextRecords = table.clone(previous)
				nextRecords[storyModule] = record
				return nextRecords
			end)
		end,
	}
end

--[[
	Splits a fake runtime's log into its first `requestCount` entries, in
	order, and the rest, sorted. The store keeps requests in tables keyed by
	Story module, so requests it releases while walking them can happen in any
	order.
]]
local function splitLog(log: { string }, requestCount: number): ({ string }, { string })
	local releases = table.move(log, requestCount + 1, #log, 1, {})
	table.sort(releases)
	return table.move(log, 1, requestCount, 1, {}), releases
end

local function createRecord(storyModule: ModuleScript): StoryModuleRecord
	local record: Storyteller.UnavailableStoryModule = {
		status = "Unavailable",
		problem = `{storyModule.Name} failed to load`,
	}
	return record
end

test("requests nothing until started", function()
	local fake = createFakeRuntime()
	local root = createFolder()
	createStoryModule("Button", root)
	fake.setStorybooks({ createStorybook("Components", { root }) })

	local store = createStoryModuleRecordsStore({
		orphanedStorybook = createLoadedStorybook(),
		runtime = fake.runtime,
	})

	expect(#store.getRequests()).toBe(1)
	expect(fake.log).toEqual({})
end)

test("requests each module once per Storybook, and orphans with the orphaned Storybook", function()
	local fake = createFakeRuntime()
	local root = createFolder()
	local button = createStoryModule("Button", root)
	local orphan = createStoryModule("Orphan", createFolder())
	local first = createStorybook("First", { root })
	local second = createStorybook("Second", { root })
	local orphanedStorybook = createLoadedStorybook()
	fake.setStorybooks({ first, second })
	fake.setOrphans({ button, orphan })

	local store = createStoryModuleRecordsStore({
		orphanedStorybook = orphanedStorybook,
		runtime = fake.runtime,
	})
	store.start()

	local requests = store.getRequests()
	expect(#requests).toBe(3)
	expect(requests[1]).toEqual({ storyModule = button, storybook = first })
	expect(requests[2]).toEqual({ storyModule = button, storybook = second })
	expect(requests[3]).toEqual({ storyModule = orphan, storybook = orphanedStorybook })
	expect(fake.log).toEqual({
		"request Button.story Background",
		"request Button.story Background",
		"request Orphan.story Background",
	})

	store.releaseAll()
end)

test("holds one request for a module its Storybook lists twice, at the highest priority", function()
	local fake = createFakeRuntime()
	local root = createFolder()
	local nested = createFolder()
	nested.Parent = root
	local button = createStoryModule("Button", nested)
	-- Overlapping roots list the module once for each root.
	local storybook = createStorybook("Components", { root, nested })
	fake.setStorybooks({ storybook })

	local interactiveRequests = 0
	local store = createStoryModuleRecordsStore({
		orphanedStorybook = createLoadedStorybook(),
		runtime = fake.runtime,
		isInteractive = function(request)
			expect(request.storyModule).toBe(button)
			interactiveRequests += 1
			return interactiveRequests == 1
		end,
	})
	store.start()

	expect(#store.getRequests()).toBe(2)
	expect(fake.log).toEqual({ "request Button.story Interactive" })

	store.releaseAll()
end)

test("makes the replacement request before releasing the one it replaces", function()
	local fake = createFakeRuntime()
	local root = createFolder()
	createStoryModule("Button", root)
	fake.setStorybooks({ createStorybook("Components", { root }) })
	local getIsExpanded, setIsExpanded = Charm.signal(false)

	local store = createStoryModuleRecordsStore({
		orphanedStorybook = createLoadedStorybook(),
		runtime = fake.runtime,
		isInteractive = function()
			return getIsExpanded()
		end,
	})
	store.start()
	setIsExpanded(true)
	setIsExpanded(false)

	expect(fake.log).toEqual({
		"request Button.story Background",
		"request Button.story Interactive",
		"release Button.story Background",
		"request Button.story Background",
		"release Button.story Interactive",
	})

	store.releaseAll()
end)

test("releases a module's request when it's no longer listed", function()
	local fake = createFakeRuntime()
	local root = createFolder()
	createStoryModule("Button", root)
	local toggle = createStoryModule("Toggle", root)

	fake.setStorybooks({ createStorybook("Components", { root }) })

	local store = createStoryModuleRecordsStore({
		orphanedStorybook = createLoadedStorybook(),
		runtime = fake.runtime,
	})
	store.start()

	toggle.Parent = nil
	-- Charm doesn't see the module move, so publishing the Storybook list again
	-- has the store look for Story modules again.
	fake.setStorybooks({ createStorybook("Components", { root }) })

	-- The new Storybook has its own source, so Button gets a new request and
	-- both old requests are released.
	local requests, releases = splitLog(fake.log, 3)
	expect(requests).toEqual({
		"request Button.story Background",
		"request Toggle.story Background",
		"request Button.story Background",
	})
	expect(releases).toEqual({
		"release Button.story Background",
		"release Toggle.story Background",
	})

	store.releaseAll()
	toggle:Destroy()
end)

test("keeps its request list when Storyteller publishes an equivalent one", function()
	local fake = createFakeRuntime()
	local root = createFolder()
	createStoryModule("Button", root)
	local storybook = createStorybook("Components", { root })
	fake.setStorybooks({ storybook })

	local store = createStoryModuleRecordsStore({
		orphanedStorybook = createLoadedStorybook(),
		runtime = fake.runtime,
	})
	store.start()
	local requests = store.getRequests()

	fake.setStorybooks({ storybook })

	expect(store.getRequests()).toBe(requests)
	expect(fake.log).toEqual({ "request Button.story Background" })

	store.releaseAll()
end)

test("returns the same records table until one of its records changes", function()
	local fake = createFakeRuntime()
	local root = createFolder()
	local button = createStoryModule("Button", root)
	local unrelated = createStoryModule("Unrelated", createFolder())
	local storybook = createStorybook("Components", { root })
	fake.setStorybooks({ storybook })

	local store = createStoryModuleRecordsStore({
		orphanedStorybook = createLoadedStorybook(),
		runtime = fake.runtime,
	})
	store.start()
	expect(store.getRecords()).toEqual({})

	local record = createRecord(button)
	fake.setRecord(button, record)
	local records = store.getRecords()
	expect(records[storybook.source][button]).toBe(record)

	fake.setRecord(unrelated, createRecord(unrelated))
	expect(store.getRecords()).toBe(records)

	local nextRecord = createRecord(button)
	fake.setRecord(button, nextRecord)
	expect(store.getRecords()).never.toBe(records)
	expect(store.getRecords()[storybook.source][button]).toBe(nextRecord)

	store.releaseAll()
end)

test("releaseAll releases every request and stops following changes", function()
	local fake = createFakeRuntime()
	local root = createFolder()
	createStoryModule("Button", root)
	local orphan = createStoryModule("Orphan", createFolder())
	fake.setStorybooks({ createStorybook("Components", { root }) })
	fake.setOrphans({ orphan })

	local store = createStoryModuleRecordsStore({
		orphanedStorybook = createLoadedStorybook(),
		runtime = fake.runtime,
	})
	store.start()
	store.releaseAll()
	fake.setOrphans({})

	local requests, releases = splitLog(fake.log, 2)
	expect(requests).toEqual({
		"request Button.story Background",
		"request Orphan.story Background",
	})
	expect(releases).toEqual({
		"release Button.story Background",
		"release Orphan.story Background",
	})
end)

test("loads records through Storyteller's shared runtime", function()
	local root = createFolder()
	local button = createStoryModule("Button", root)
	button.Source = [[
		return {
			stories = {
				Primary = function() end,
				Secondary = function() end,
			},
		}
	]]
	local getStorybooks = Charm.signal({ createStorybook("Components", { root }) })

	local store = createStoryModuleRecordsStore({
		orphanedStorybook = createLoadedStorybook(),
		runtime = {
			getLoadedStorybooks = getStorybooks,
			getOrphanedStoryModules = function()
				return {}
			end,
			requestStoryModule = Storyteller.requestStoryModule,
			getStoryModuleRecord = Storyteller.getStoryModuleRecord,
		},
	})
	store.start()

	local request = store.getRequests()[1]
	local record: StoryModuleRecord?
	for _ = 1, 50 do
		record = store.getRecords()[request.storybook.source] and store.getRecords()[request.storybook.source][button]
		if record then
			break
		end
		task.wait()
	end

	assert(record and record.status == "Loaded", "expected the Story module to load")
	expect(record.stories).toEqual({
		expect.objectContaining({ id = "Primary" }),
		expect.objectContaining({ id = "Secondary" }),
	})

	store.releaseAll()
	expect(Storyteller.getStoryModuleRecord(request)).toBeUndefined()
end)
