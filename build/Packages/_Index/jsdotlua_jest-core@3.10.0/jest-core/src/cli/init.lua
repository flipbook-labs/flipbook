-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-core/src/cli/index.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local LuauPolyfill = require(script.Parent.Parent:WaitForChild('luau-polyfill'))
local Array = LuauPolyfill.Array
local Boolean = LuauPolyfill.Boolean
local Error = LuauPolyfill.Error
local console = LuauPolyfill.console
type Array<T> = LuauPolyfill.Array<T>
type Promise<T> = LuauPolyfill.Promise<T>
local Promise = require(script.Parent.Parent:WaitForChild('promise'))

local exports = {}

local chalk = require(script.Parent.Parent:WaitForChild('chalk'))-- ROBLOX deviation START: not needed
-- local exit = require("@pkg/exit")
-- local rimraf = require("@pkg/rimraf")
-- local CustomConsole = require("@pkg/@jsdotlua/jest-console").CustomConsole
-- ROBLOX deviation END

local test_resultModule = require(script.Parent.Parent:WaitForChild('jest-test-result'))
type AggregatedResult = test_resultModule.AggregatedResult
type TestContext = test_resultModule.TestContext
local jestTypesModule = require(script.Parent.Parent:WaitForChild('jest-types'))
type Config_Argv = jestTypesModule.Config_Argv
type Config_GlobalConfig = jestTypesModule.Config_GlobalConfig
type Config_ProjectConfig = jestTypesModule.Config_ProjectConfig
-- ROBLOX deviation START: not used
-- local jest_changed_filesModule = require("@pkg/jest-changed-files")
-- type ChangedFilesPromise = jest_changed_filesModule.ChangedFilesPromise
type ChangedFilesPromise = Promise<any>
local readConfigs = require(script.Parent.Parent:WaitForChild('jest-config')).readConfigs
-- local jest_haste_mapModule = require("@pkg/jest-haste-map")
-- type HasteMap = jest_haste_mapModule.default
type HasteMap = any
-- ROBLOX deviation END
local Runtime = require(script.Parent.Parent:WaitForChild('jest-runtime'))
type Context = Runtime.Context
local jest_utilModule = require(script.Parent.Parent:WaitForChild('jest-util'))-- ROBLOX deviation START: not needed
-- local createDirectory = jest_utilModule.createDirectory
-- ROBLOX deviation END

local preRunMessage = jest_utilModule.preRunMessage
local TestWatcher = require(script.Parent:WaitForChild('TestWatcher')).default
local formatHandleErrors = require(script.Parent:WaitForChild('collectHandles')).formatHandleErrors
local getChangedFilesPromise = require(script.Parent:WaitForChild('getChangedFilesPromise')).default
local getProjectNamesMissingWarning = require(script.Parent:WaitForChild('getProjectNamesMissingWarning')).default
local getSelectProjectsMessage = require(script.Parent:WaitForChild('getSelectProjectsMessage')).default
local createContext = require(script.Parent:WaitForChild('lib'):WaitForChild('createContext')).default
-- ROBLOX deviation START: not needed
-- local handleDeprecationWarnings = require("./lib/handleDeprecationWarnings").default
-- ROBLOX deviation END
local logDebugMessages = require(script.Parent:WaitForChild('lib'):WaitForChild('logDebugMessages')).default
local pluralize = require(script.Parent:WaitForChild('pluralize')).default
local runJest = require(script.Parent:WaitForChild('runJest')).default
local typesModule = require(script.Parent:WaitForChild('types'))
type Filter = typesModule.Filter
-- ROBLOX deviation START: not needed
-- local watch = require("./watch").default
-- ROBLOX deviation END
local preRunMessagePrint = preRunMessage.print

type OnCompleteCallback = (results: AggregatedResult) -> ...nil

-- ROBLOX deviation START: added missing variables to limit nr deviations
local RobloxShared = require(script.Parent.Parent:WaitForChild('jest-roblox-shared'))
local nodeUtils = RobloxShared.nodeUtils
local process = nodeUtils.process
local exit = nodeUtils.exit
type NodeJS_WriteStream = RobloxShared.NodeJS_WriteStream
-- ROBLOX deviation END

-- ROBLOX deviation START: predefine functions
local _run10000
local runWithoutWatch
-- ROBLOX deviation END

local function runCLI(
	cwdInstance: Instance,
	argv: Config_Argv,
	-- ROBLOX deviation: using Instance instead of Config_Path
	projects: Array<Instance>
): Promise<{ results: AggregatedResult, globalConfig: Config_GlobalConfig }>
	return Promise.resolve():andThen(function()
		local results

		-- If we output a JSON object, we can't write anything to stdout, since: AggregatedResult | nil
		-- it'll break the JSON structure and it won't be valid.
		local outputStream = if Boolean.toJSBoolean(argv.json) or Boolean.toJSBoolean(argv.useStderr)
			then process.stderr
			else process.stdout

		local ref = readConfigs(cwdInstance, argv, projects):expect()
		local globalConfig, configs, hasDeprecationWarnings = ref.globalConfig, ref.configs, ref.hasDeprecationWarnings

		if argv.debug then
			logDebugMessages(globalConfig, configs, outputStream)
		end

		if argv.showConfig then
			logDebugMessages(globalConfig, configs, process.stdout)
			exit(0)
		end

		-- ROBLOX deviation START: no cache support
		-- if argv.clearCache then
		-- 	Array.forEach(configs, function(config)
		-- 		rimraf:sync(config.cacheDirectory)
		-- 		process.stdout:write(("Cleared %s\n"):format(tostring(config.cacheDirectory)))
		-- 	end)
		--
		-- 	exit(0)
		-- end
		-- ROBLOX deviation END

		local configsOfProjectsToRun = configs
		if Boolean.toJSBoolean(argv.selectProjects) then
			local namesMissingWarning = getProjectNamesMissingWarning(
				configs,
				{ ignoreProjects = argv.ignoreProjects, selectProjects = argv.selectProjects }
			)
			if Boolean.toJSBoolean(namesMissingWarning) and namesMissingWarning then
				outputStream:write(namesMissingWarning)
			end
			outputStream:write(
				getSelectProjectsMessage(
					configsOfProjectsToRun,
					{ ignoreProjects = argv.ignoreProjects, selectProjects = argv.selectProjects }
				)
			)
		end

		_run10000(globalConfig, configsOfProjectsToRun, hasDeprecationWarnings, outputStream, function(r)
			results = r
		end):expect()

		if argv.watch or argv.watchAll then
			-- If in watch mode, return the promise that will never resolve.
			-- If the watch mode is interrupted, watch should handle the process
			-- shutdown.
			return Promise.new(function() end)
		end

		if not Boolean.toJSBoolean(results) then
			error(Error.new("AggregatedResult must be present after test run is complete"))
		end

		local openHandles = results.openHandles

		if openHandles ~= nil and #openHandles > 0 then
			local formatted = formatHandleErrors(openHandles, configs[1])

			local openHandlesString = pluralize("open handle", #formatted, "s")

			local message = chalk.red(
				("\nJest has detected the following %s potentially keeping Jest from exiting:\n\n"):format(
					openHandlesString
				)
			) .. Array.join(formatted, "\n\n")

			console.error(message)
		end

		return { globalConfig = globalConfig, results = results }
	end)
end
exports.runCLI = runCLI

local function buildContextsAndHasteMaps(
	configs: Array<Config_ProjectConfig>,
	_globalConfig: Config_GlobalConfig,
	_outputStream: NodeJS_WriteStream
)
	return Promise.resolve():andThen(function()
		-- ROBLOX deviation START: no haste maps support
		-- local hasteMapInstances = {}
		local configPromises = Array.map(configs, function(config, index)
			-- createDirectory(config.cacheDirectory)
			-- local hasteMapInstance = Runtime:createHasteMap(config, {
			-- 	console = CustomConsole.new(outputStream, outputStream),
			-- 	maxWorkers = math.max(1, math.floor(globalConfig.maxWorkers / #configs)),
			-- 	resetCache = not Boolean.toJSBoolean(config.cache),
			-- 	watch = Boolean.toJSBoolean(globalConfig.watch) and globalConfig.watch or globalConfig.watchAll,
			-- 	watchman = globalConfig.watchman,
			-- })
			-- hasteMapInstances[index] = hasteMapInstance
			return Promise.resolve(createContext(config, nil))
		end)

		local contexts = Promise.all(configPromises):expect()
		return {
			contexts = contexts,
			-- hasteMapInstances = hasteMapInstances,
		}
		-- ROBLOX deviation END
	end)
end

function _run10000(
	globalConfig: Config_GlobalConfig,
	configs: Array<Config_ProjectConfig>,
	hasDeprecationWarnings: boolean,
	outputStream: NodeJS_WriteStream,
	onComplete: OnCompleteCallback
)
	return Promise.resolve():andThen(function()
		-- Queries to hg/git can take a while, so we need to start the process
		-- as soon as possible, so by the time we need the result it's already there.
		local changedFilesPromise = getChangedFilesPromise(globalConfig, configs)
		-- Filter may need to do an HTTP call or something similar to setup.
		-- We will wait on an async response from this before using the filter.
		local filter: Filter | nil
		if Boolean.toJSBoolean(globalConfig.filter) and not globalConfig.skipFilter then
			local rawFilter =
				-- ROBLOX deviation: need to cast as require doesn't allow to import unknown paths
				(require :: any)(globalConfig.filter)
			local filterSetupPromise: Promise<unknown | nil> | nil
			if Boolean.toJSBoolean(rawFilter.setup) then
				-- Wrap filter setup Promise to avoid "uncaught Promise" error.
				-- If an error is returned, we surface it in the return value.
				filterSetupPromise = Promise.try(function()
					local ok, result = rawFilter:setup():await()
					if not ok then
						return result
					end
					return nil
				end)
			end
			filter = Promise.promisify(function(testPaths: Array<string>)
				if filterSetupPromise ~= nil then
					-- Expect an undefined return value unless there was an error.
					local err = filterSetupPromise:expect()
					if Boolean.toJSBoolean(err) then
						error(err)
					end
				end
				return rawFilter(testPaths)
			end)
		end

		local ref = buildContextsAndHasteMaps(configs, globalConfig, outputStream):expect()
		-- ROBLOX deviation START: not supported: hasteMapInstances
		-- local contexts, hasteMapInstances = ref.contexts, ref.hasteMapInstances
		local contexts = ref.contexts

		-- if globalConfig.watch or globalConfig.watchAll then
		-- 	runWatch(contexts, configs, hasDeprecationWarnings, globalConfig, outputStream, hasteMapInstances, filter):expect()
		-- else
		runWithoutWatch(globalConfig, contexts, outputStream, onComplete, changedFilesPromise, filter):expect()
		-- end
		-- ROBLOX deviation END
	end)
end

-- ROBLOX deviation START: not supported
-- local function runWatch(
-- 	contexts: Array<Context>,
-- 	_configs: Array<Config_ProjectConfig>,
-- 	_hasDeprecationWarnings: boolean,
-- 	_globalConfig: Config_GlobalConfig,
-- 	_outputStream: NodeJS_WriteStream,
-- 	_hasteMapInstances: Array<HasteMap>,
-- 	_filter: Filter?
-- )
-- 	return Promise.resolve():andThen(function()
-- 		error("watch tests is not handled yet")
-- 		-- ROBLOX deviation START: no deprecation warning handling
-- 		-- if hasDeprecationWarnings then
-- 		-- 	local ok, result = pcall(function()
-- 		-- 		handleDeprecationWarnings(outputStream, process.stdin):expect()
-- 		-- 		return watch(globalConfig, contexts, outputStream, hasteMapInstances, nil, nil, filter), true
-- 		-- 	end)
-- 		-- 	if not ok then
-- 		-- 		exit(0)
-- 		-- 	end
-- 		-- 	return result
-- 		-- end
-- 		-- ROBLOX deviation END

-- 		-- return watch(globalConfig, contexts, outputStream, hasteMapInstances, nil, nil, filter)
-- 	end)
-- end
-- ROBLOX deviation END

function runWithoutWatch(
	globalConfig: Config_GlobalConfig,
	contexts: Array<TestContext>,
	outputStream: NodeJS_WriteStream,
	onComplete: OnCompleteCallback,
	changedFilesPromise: ChangedFilesPromise?,
	filter: Filter?
)
	return Promise.resolve():andThen(function()
		local function startRun(): Promise<nil>
			return Promise.resolve():andThen(function()
				if not globalConfig.listTests then
					preRunMessagePrint(outputStream)
				end
				return runJest({
					changedFilesPromise = changedFilesPromise,
					contexts = contexts,
					failedTestsCache = nil,
					filter = filter,
					globalConfig = globalConfig,
					onComplete = onComplete,
					outputStream = outputStream,
					startRun = startRun,
					testWatcher = TestWatcher.new({ isWatchMode = false }),
				})
			end)
		end
		return startRun()
	end)
end

return exports
