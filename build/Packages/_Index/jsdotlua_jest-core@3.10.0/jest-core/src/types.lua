-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-core/src/types.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local LuauPolyfill = require(script.Parent.Parent:WaitForChild('luau-polyfill'))
type Array<T> = LuauPolyfill.Array<T>
type Promise<T> = LuauPolyfill.Promise<T>

local test_resultModule = require(script.Parent.Parent:WaitForChild('jest-test-result'))
type Test = test_resultModule.Test
local typesModule = require(script.Parent.Parent:WaitForChild('jest-types'))
type Config_Path = typesModule.Config_Path
local jest_runtimeModule = require(script.Parent.Parent:WaitForChild('jest-runtime'))
type Context = jest_runtimeModule.Context

-- ROBLOX deviation START: add additional imports and types
local reportersModule = require(script.Parent.Parent:WaitForChild('jest-reporters'))
type JestReporter = reportersModule.BaseReporter
type ReporterContext = reportersModule.ReporterContext
type Config_GlobalConfig = typesModule.Config_GlobalConfig

type Record<K, T> = { [K]: T }
-- ROBLOX deviation END

export type Stats = {
	roots: number,
	testMatch: number,
	testPathIgnorePatterns: number,
	testRegex: number,
	testPathPattern: number?
}

export type TestRunData = Array<{
	context: Context,
	matches: { allTests: number, tests: Array<Test>, total: number?, stats_: Stats? }
}>

-- ROBLOX deviation START: unroll `keyof Stats` as this operation is not supported in Luau
type KeyOfStats = "roots" | "testMatch" | "testPathIgnorePatterns" | "testRegex" | "testPathPattern"
export type TestPathCases = Array<{
	stat: KeyOfStats,
	isMatch: (path: Config_Path) -> boolean
}>
-- ROBLOX deviation END

export type TestPathCasesWithPathPattern = TestPathCases & { testPathPattern: (path: Config_Path) -> boolean }

export type FilterResult = { test: string, message: string }

export type Filter = (testPaths: Array<string>) -> Promise<{ filtered: Array<FilterResult> }>

-- ROBLOX deviation START: add types moved from other files to avoid cyclic dependencies
export type ReporterConstructor = (
	globalConfig: Config_GlobalConfig,
	reporterConfig: Record<string, unknown>,
	reporterContext: ReporterContext
) -> JestReporter
-- ROBLOX deviation END

return {}
