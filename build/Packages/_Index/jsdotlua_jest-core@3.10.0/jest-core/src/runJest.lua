-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-core/src/runJest.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local LuauPolyfill = require(script.Parent.Parent:WaitForChild('luau-polyfill'))
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object
local Set = LuauPolyfill.Set
local console = LuauPolyfill.console
local Boolean = LuauPolyfill.Boolean
type Array<T> = LuauPolyfill.Array<T>
type Object = LuauPolyfill.Object
type Promise<T> = LuauPolyfill.Promise<T>
local Promise = require(script.Parent.Parent:WaitForChild('promise'))

local exports = {}

-- ROBLOX deviation START: unused
-- local path = require("@pkg/@jsdotlua/path")
-- local chalk = require("@pkg/@jsdotlua/chalk")
-- local exit = require("@pkg/exit")
-- local fs = require("@pkg/graceful-fs")
-- ROBLOX deviation END
local CustomConsole = require(script.Parent.Parent:WaitForChild('jest-console')).CustomConsole
local test_resultModule = require(script.Parent.Parent:WaitForChild('jest-test-result'))
type AggregatedResult = test_resultModule.AggregatedResult
type Test = test_resultModule.Test
type TestContext = test_resultModule.TestContext
-- ROBLOX deviation START: not needed
-- local TestResultsProcessor = test_resultModule.TestResultsProcessor
-- ROBLOX deviation END
local formatTestResults = test_resultModule.formatTestResults
local makeEmptyAggregatedTestResult = test_resultModule.makeEmptyAggregatedTestResult
-- ROBLOX deviation START: not needed
-- local test_sequencerModule = require(Packages["@jest"]["test-sequencer"])
-- type TestSequencer = test_sequencerModule.default
-- ROBLOX deviation END
local jestTypesModule = require(script.Parent.Parent:WaitForChild('jest-types'))
type Config_GlobalConfig = jestTypesModule.Config_GlobalConfig
type Config_Path = jestTypesModule.Config_Path
-- ROBLOX deviation START: changed files not supported
-- local jest_changed_filesModule = require("@pkg/jest-changed-files")
-- type ChangedFiles = jest_changed_filesModule.ChangedFiles
type ChangedFiles = nil
-- type ChangedFilesPromise = jest_changed_filesModule.ChangedFilesPromise
type ChangedFilesPromise = Promise<ChangedFiles>
-- local Resolver = require("@pkg/jest-resolve").default
-- ROBLOX deviation END
local jest_runtimeModule = require(script.Parent.Parent:WaitForChild('jest-runtime'))
type Context = jest_runtimeModule.Context
-- ROBLOX deviation START:
-- local jest_utilModule = require("@pkg/@jsdotlua/jest-util")
-- local requireOrImportModule = jest_utilModule.requireOrImportModule
-- local tryRealpath = jest_utilModule.tryRealpath
-- local jest_watcherModule = require("@pkg/jest-watcher")
-- local JestHook = jest_watcherModule.JestHook
-- local JestHookEmitter = jest_watcherModule.JestHookEmitter
type JestHookEmitter = nil
-- local FailedTestsCacheModule = require("./FailedTestsCache")
-- type FailedTestsCache = FailedTestsCacheModule.FailedTestsCache
type FailedTestsCache = nil
-- ROBLOX deviation END
local searchSourceModule = require(script.Parent:WaitForChild('SearchSource'))
local SearchSource = searchSourceModule.default
type SearchSource = searchSourceModule.SearchSource
local TestSchedulerModule = require(script.Parent:WaitForChild('TestScheduler'))
type TestSchedulerContext = TestSchedulerModule.TestSchedulerContext
local createTestScheduler = TestSchedulerModule.createTestScheduler
local TestWatcherModule = require(script.Parent:WaitForChild('TestWatcher'))
type TestWatcher = TestWatcherModule.TestWatcher
-- ROBLOX deviation START: collectHandles not supported
-- local collectHandlesModule = require("./collectHandles")
-- local collectNodeHandles = collectHandlesModule.default
-- type HandleCollectionResult = collectHandlesModule.HandleCollectionResult
type HandleCollectionResult = nil
-- ROBLOX deviation END
local getNoTestsFoundMessage = require(script.Parent:WaitForChild('getNoTestsFoundMessage')).default
-- ROBLOX deviation START: no global hooks supported yet
-- local runGlobalHook = require("./runGlobalHook").default
-- ROBLOX deviation END
local typesModule = require(script.Parent:WaitForChild('types'))
type Filter = typesModule.Filter
type TestRunData = typesModule.TestRunData

-- ROBLOX deviation START: added missing variables to limit nr deviations
local RobloxShared = require(script.Parent.Parent:WaitForChild('jest-roblox-shared'))
local nodeUtils = RobloxShared.nodeUtils
local process = nodeUtils.process
local exit = nodeUtils.exit
type NodeJS_WriteStream = RobloxShared.NodeJS_WriteStream
local JSON = nodeUtils.JSON
local ensureDirectoryExists = RobloxShared.ensureDirectoryExists
local getDataModelService = RobloxShared.getDataModelService
local FileSystemService = getDataModelService("FileSystemService")
local CoreScriptSyncService = getDataModelService("CoreScriptSyncService")
-- ROBLOX deviation END

local function getTestPaths(
	globalConfig: Config_GlobalConfig,
	source: SearchSource,
	_outputStream: NodeJS_WriteStream,
	changedFiles: ChangedFiles | nil,
	_jestHooks: JestHookEmitter,
	filter: Filter?
)
	return Promise.resolve():andThen(function()
		local data = source:getTestPaths(globalConfig, changedFiles, filter):expect()

		-- ROBLOX deviation START: no support for running only changed files
		-- if #data.tests ~= 0 and globalConfig.onlyChanged and data.noSCM then
		-- 	CustomConsole.new(outputStream, outputStream):log(
		-- 		"Jest can only find uncommitted changed files in a git or hg "
		-- 			.. "repository. If you make your project a git or hg "
		-- 			.. "repository (`git init` or `hg init`), Jest will be able "
		-- 			.. "to only run tests related to files changed since the last "
		-- 			.. "commit."
		-- 	)
		-- end
		-- ROBLOX deviation END

		local shouldTestArray = Promise.all(Array.map(data.tests, function(_test)
			-- ROBLOX deviation START: no jestHooks support
			return Promise.resolve(true)
			-- return jestHooks:shouldRunTestSuite({
			-- 	config = test.context.config,
			-- 	duration = test.duration,
			-- 	testPath = test.path,
			-- })
			-- ROBLOX deviation END
		end)):expect()

		local filteredTests = Array.filter(data.tests, function(_test, i)
			return shouldTestArray[i]
		end)

		return Object.assign({}, data, { allTests = #filteredTests, tests = filteredTests })
	end)
end

type ProcessResultOptions =
	-- ROBLOX deviation START: inline Pick<Config_GlobalConfig, "json" | "outputFile" | "testResultsProcessor"> as Luau doesn't support Pick type
	{
		json: boolean,
		outputFile: Config_Path?		-- testResultsProcessor: string?,
	
}
	-- ROBLOX deviation END
	& {
		-- ROBLOX deviation START: not supported
		-- collectHandles: HandleCollectionResult?,
		-- ROBLOX deviation END
		onComplete: ((result: AggregatedResult) -> ())?		-- ROBLOX deviation START: not supported
		-- outputStream: NodeJS_WriteStream,
		-- ROBLOX deviation END
	
}

local function processResults(runResults: AggregatedResult, options: ProcessResultOptions)
	return Promise.resolve():andThen(function()
		-- ROBLOX deviation START: not supported: outputStream testResultsProcessor, collectHandles
		local _outputFile, isJSON, onComplete --[[ , _outputStream, _testResultsProcessor, _collectHandles ]] =
			options.outputFile, options.json, options.onComplete
		-- options.outputStream,
		-- options.testResultsProcessor,
		-- options.collectHandles
		-- ROBLOX deviation END

		-- ROBLOX deviation START no collectHandles supported
		-- if collectHandles ~= nil then
		-- 	runResults.openHandles = collectHandles():expect()
		-- else
		-- 	runResults.openHandles = {}
		-- end
		runResults.openHandles = {}
		-- ROBLOX deviation END

		-- ROBLOX deviation START: no testResultsProcessor handling
		-- if Boolean.toJSBoolean(testResultsProcessor) then
		-- 	local processor = requireOrImportModule(testResultsProcessor):expect()
		-- 	runResults = processor(runResults)
		-- end
		-- ROBLOX deviation END

		if isJSON then
			if _outputFile and FileSystemService and Boolean.toJSBoolean(_outputFile) then
				ensureDirectoryExists(_outputFile)
				FileSystemService:WriteFile(_outputFile, JSON.stringify(formatTestResults(runResults)))
				process.stdout:write(("Test results written to: %s\n"):format(tostring(_outputFile)))
			else
				process.stdout:write(JSON.stringify(formatTestResults(runResults)))
			end
		end

		if onComplete ~= nil then
			onComplete(runResults)
		end
	end)
end

local testSchedulerContext: TestSchedulerContext = { firstRun = true, previousSuccess = true }

local function runJest(ref: {
	globalConfig: Config_GlobalConfig,
	contexts: Array<TestContext>,
	outputStream: NodeJS_WriteStream,
	testWatcher: TestWatcher,
	jestHooks: JestHookEmitter?,
	startRun: (globalConfig: Config_GlobalConfig) -> (),
	changedFilesPromise: ChangedFilesPromise?,
	onComplete: (testResults: AggregatedResult) -> (),
	failedTestsCache: FailedTestsCache?,
	filter: Filter?
}): Promise<nil>
	-- ROBLOX FIXME Stylua
	-- stylua: ignore
	local contexts, globalConfig, outputStream, testWatcher, startRun, _changedFilesPromise, onComplete, _failedTestsCache, filter ,jestHooks=
		ref.contexts,
		ref.globalConfig,
		ref.outputStream,
		ref.testWatcher,
		-- if ref.jestHooks == nil then JestHook.new():getEmitter() else ref.jestHooks,
		-- ROBLOX deviation END
		

ref.startRun,
		ref.changedFilesPromise,
		ref.onComplete,
		ref.failedTestsCache,(		
ref.filter
)	return Promise.resolve():andThen(function()
		-- Clear cache for required modules - there might be different resolutions
		-- from Jest's config loading to running the tests

		-- ROBLOX deviation START: no Resolver caching and TestSequencer support
		-- Resolver:clearDefaultResolverCache()
		-- local Sequencer: typeof(TestSequencer) = requireOrImportModule(globalConfig.testSequencer):expect()
		-- local sequencer = Sequencer.new()
		-- ROBLOX deviation END
		local allTests: Array<Test> = {}

		-- ROBLOX deviation START: no watch tests supported
		-- if changedFilesPromise ~= nil and globalConfig.watch then
		-- 	local repos = changedFilesPromise:expect().repos
		-- 	local noSCM = Array.every(
		-- 		Object.keys(repos) :: Array<any --[[ ROBLOX TODO: Unhandled node for type: TSTypeOperator ]] --[[ keyof ChangedFiles['repos'] ]]>,
		-- 		function(scm)
		-- 			return repos[scm].size == 0
		-- 		end
		-- 	)
		-- 	if noSCM then
		-- 		process.stderr:write(
		-- 			"\n" .. chalk.bold("--watch") .. " is not supported without git/hg, please use --watchAll " .. "\n"
		-- 		)
		-- 		exit(1)
		-- 	end
		-- end
		-- ROBLOX deviation END

		local searchSources = Array.map(contexts, function(context)
			return SearchSource.new(context)
		end)

		local testRunData: TestRunData = Promise.all(Array.map(contexts, function(context, index)
			return Promise.resolve():andThen(function()
				local searchSource = searchSources[index]
				local matches = getTestPaths(
					globalConfig,
					searchSource,
					outputStream,
					-- ROBLOX deviation START: changed files not supported
					nil,
					-- if changedFilesPromise ~= nil then changedFilesPromise:expect() else changedFilesPromise,
					-- ROBLOX deviation END
					jestHooks,
					filter
				):expect()
				allTests = Array.concat(allTests, matches.tests)

				return { context = context, matches = matches }
			end)
		end)):expect()

		-- ROBLOX deviation START: no TestSequencer support
		allTests = allTests
		-- sequencer:sort(allTests):expect()
		-- ROBLOX deviation END

		if globalConfig.listTests then
			local testsPaths = Array.from(Set.new(Array.map(allTests, function(test)
				-- ROBLOX deviation: resolve to a FS path if CoreScriptSyncService is available
				if CoreScriptSyncService then
					return CoreScriptSyncService:GetScriptFilePath(test.script)
				end
				return test.path
			end)))
			--[[ eslint-disable no-console ]]
			if globalConfig.json then
				console.log(JSON.stringify(testsPaths))
			else
				console.log(Array.join(testsPaths, "\n"))
			end
			--[[ eslint-enable ]]

			if onComplete ~= nil then
				onComplete(makeEmptyAggregatedTestResult())
			end
			return
		end

		-- ROBLOX deviation START: no support for running only failed tests
		-- if Boolean.toJSBoolean(globalConfig.onlyFailures) then
		-- 	if Boolean.toJSBoolean(failedTestsCache) then
		-- 		allTests = failedTestsCache:filterTests(allTests)
		-- 	else
		-- 		allTests = sequencer:allFailedTests(allTests):expect()
		-- 	end
		-- end
		-- ROBLOX deviation END

		local hasTests = #allTests > 0

		if not hasTests then
			local noTestsFound = getNoTestsFoundMessage(testRunData, globalConfig)
			local exitWith0 = noTestsFound.exitWith0
			local noTestsFoundMessage = noTestsFound.message

			if exitWith0 then
				CustomConsole.new(outputStream, outputStream):log(noTestsFoundMessage)
			else
				CustomConsole.new(outputStream, outputStream):error(noTestsFoundMessage)

				exit(1)
			end
		elseif #allTests == 1 and globalConfig.silent ~= true and globalConfig.verbose ~= false then
			local newConfig: Config_GlobalConfig = Object.assign({}, globalConfig, { verbose = true })
			globalConfig = Object.freeze(newConfig)
		end

		-- ROBLOX deviation START: detectOpenHandles not supported
		local collectHandles 
		-- if globalConfig.detectOpenHandles then
		-- 	collectHandles = collectNodeHandles()
		-- end
		-- ROBLOX deviation END

		-- ROBLOX deviation START: no global hooks supported yet
		-- if hasTests then
		-- 	runGlobalHook({
		-- 		allTests = allTests,
		-- 		globalConfig = globalConfig,
		-- 		moduleName = "globalSetup",
		-- 	}):expect()
		-- end
		-- ROBLOX deviation END

		-- ROBLOX deviation START: changedFilesPromise not supported yet
		-- if changedFilesPromise ~= nil then
		-- 	local changedFilesInfo = changedFilesPromise:expect()
		-- 	if Boolean.toJSBoolean(changedFilesInfo.changedFiles) then
		-- 		testSchedulerContext.changedFiles = changedFilesInfo.changedFiles
		-- 		local sourcesRelatedToTestsInChangedFilesArray = Array.reduce(
		-- 			Promise.all(Array.map(contexts, function(_, index)
		-- 				return Promise.resolve():andThen(function()
		-- 					local searchSource = searchSources[index]
		-- 					return searchSource:findRelatedSourcesFromTestsInChangedFiles(changedFilesInfo)
		-- 				end)
		-- 			end)):expect(),
		-- 			function(total, paths)
		-- 				return Array.concat(total, paths)
		-- 			end,
		-- 			{}
		-- 		)
		-- 		testSchedulerContext.sourcesRelatedToTestsInChangedFiles = Set.new(
		-- 			sourcesRelatedToTestsInChangedFilesArray
		-- 		)
		-- 	end
		-- end
		-- ROBLOX deviation END

		
local scheduler =
			createTestScheduler(globalConfig, Object.assign({}, { startRun = startRun }, testSchedulerContext)):expect()

		local results = scheduler:scheduleTests(allTests, testWatcher):expect()

		-- ROBLOX deviation START: no TestSequencer support
		-- sequencer:cacheResults(allTests, results):expect()
		-- ROBLOX deviation END

		-- ROBLOX deviation START: no global hooks supported yet
		-- if hasTests then
		-- 	runGlobalHook({
		-- 		allTests = allTests,
		-- 		globalConfig = globalConfig,
		-- 		moduleName = "globalTeardown",
		-- 	}):expect()
		-- end
		-- ROBLOX deviation END

		processResults(results, {
			collectHandles = collectHandles,
			json = globalConfig.json,
			onComplete = onComplete,
			outputFile = globalConfig.outputFile,
			outputStream = outputStream,
			-- ROBLOX deviation START: not supported
			-- testResultsProcessor = globalConfig.testResultsProcessor,
			-- ROBLOX deviation END
		}):expect()
	end)
end
exports.default = runJest

return exports
