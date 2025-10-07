-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-config/src/Defaults.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local exports = {}

-- ROBLOX deviation START: hardcode values
-- local sep = require("@pkg/@jsdotlua/path").sep
-- local isCI = require("@pkg/ci-info").isCI
local isCI = false
-- ROBLOX deviation END
local typesModule = require(script.Parent.Parent:WaitForChild('jest-types'))
type Config_DefaultOptions = typesModule.Config_DefaultOptions
-- ROBLOX deviation START: not needed
-- local replacePathSepForRegex = require("@pkg/jest-regex-util").replacePathSepForRegex
-- local NODE_MODULES = require("./constants").NODE_MODULES
-- local getCacheDirectory = require("./getCacheDirectory").default
-- local NODE_MODULES_REGEXP = replacePathSepForRegex(NODE_MODULES)
-- ROBLOX deviation END
local defaultOptions: Config_DefaultOptions = {
	automock = false,
	bail = 0,
	-- ROBLOX deviation START: caching not supported
	-- cache = true,
	-- cacheDirectory = getCacheDirectory(),
	-- ROBLOX deviation END
	changedFilesWithAncestor = false,
	ci = isCI,
	clearMocks = false,
	-- ROBLOX deviation START: not supported
	-- collectCoverage = false,
	-- ROBLOX deviation END
	coveragePathIgnorePatterns = {
		-- ROBLOX deviation START: no node_modules
		-- NODE_MODULES_REGEXP
		-- ROBLOX deviation END
	},
	-- ROBLOX deviation START: not supported
	-- coverageProvider = "babel",
	-- coverageReporters = { "json", "text", "lcov", "clover" },
	-- detectLeaks = false,
	-- detectOpenHandles = false,
	-- errorOnDeprecated = false,
	-- ROBLOX deviation END
	expand = false,
	-- ROBLOX deviation START: not supported
	-- extensionsToTreatAsEsm = {},
	-- forceCoverageMatch = {},
	-- ROBLOX deviation END
	globals = {},
	-- ROBLOX deviation START: not supported
	-- haste = {
	-- 	computeSha1 = false,
	-- 	enableSymlinks = false,
	-- 	forceNodeFilesystemAPI = false,
	-- 	throwOnModuleCollision = false,
	-- },
	-- ROBLOX deviation END
	injectGlobals = true,
	listTests = false,
	maxConcurrency = 5,
	maxWorkers = "50%",
	-- ROBLOX deviation START: not supported
	-- moduleDirectories = { "node_modules" },
	-- moduleFileExtensions = { "js", "jsx", "ts", "tsx", "json", "node" },
	-- moduleNameMapper = {},
	-- modulePathIgnorePatterns = {},
	-- ROBLOX deviation END
	noStackTrace = false,
	notify = false,
	-- ROBLOX deviation START: not supported
	-- notifyMode = "failure-change",
	-- ROBLOX deviation END
	-- ROBLOX deviation: inject alike types
	oldFunctionSpying = true,
	passWithNoTests = false,
	-- ROBLOX deviation START: not supported
	-- prettierPath = "prettier",
	-- ROBLOX deviation END
	resetMocks = false,
	resetModules = false,
	restoreMocks = false,
	roots = { "<rootDir>" },
	runTestsByPath = false,
	runner = "jest-runner",
	setupFiles = {},
	setupFilesAfterEnv = {},
	skipFilter = false,
	slowTestThreshold = 5,
	snapshotSerializers = {},
	testEnvironment = "jest-environment-roblox", -- Packages.JestEnvironmentLuau,
	testEnvironmentOptions = {},
	testFailureExitCode = 1,
	testLocationInResults = false,
	-- ROBLOX deviation START: using lua files as defaults for tests
	testMatch = { "**/__tests__/**/*", "**/?(*.)+(spec|test)" },
	-- ROBLOX deviation END
	testPathIgnorePatterns = {
		-- ROBLOX deviation START: no node_modules
		-- NODE_MODULES_REGEXP
		-- ROBLOX deviation END
	},
	testRegex = {},
	-- ROBLOX deviation START: not supported
	-- testRunner = "jest-circus/runner",
	-- testSequencer = "@jest/test-sequencer",
	-- testURL = "http://localhost",
	-- ROBLOX deviation END
	timers = "real",
	-- ROBLOX deviation START: not supported
	-- transformIgnorePatterns = {
	-- 	NODE_MODULES_REGEXP,
	-- 	("\\.pnp\\.[^\\%s]+$"):format(tostring(sep)),
	-- },
	-- ROBLOX deviation END
	useStderr = false,
	watch = false,
	watchPathIgnorePatterns = {},
	watchman = true,
}
exports.default = defaultOptions
return exports
