-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-environment/src/index.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]
local LuauPolyfill = require(script.Parent:WaitForChild('luau-polyfill'))
type Array<T> = LuauPolyfill.Array<T>
type Object = LuauPolyfill.Object
type Promise<T> = LuauPolyfill.Promise<T>

type Console = Object
type NodeModule = Object
type Record<T, U> = { [T]: U }
type void = nil

-- ROBLOX deviation START: module not available
-- local vmModule = require(rootWorkspace.vm)
-- type Context = vmModule.Context
type Context = Object
-- ROBLOX deviation END

local FakeTimersModule = require(script.Parent:WaitForChild('jest-fake-timers'))-- ROBLOX deviation START: no Legacy/Modern timers
-- type LegacyFakeTimers<TimerRef> = FakeTimersModule.LegacyFakeTimers<TimerRef>
-- type ModernFakeTimers = FakeTimersModule.ModernFakeTimers

type FakeTimers = FakeTimersModule.FakeTimers
-- ROBLOX deviation END

local typesModule = require(script.Parent:WaitForChild('jest-types'))-- ROBLOX deviation START: Import types with namespace

type Circus_EventHandler = typesModule.Circus_EventHandler
type Config_Path = typesModule.Config_Path
type Config_ProjectConfig = typesModule.Config_ProjectConfig
type Global_Global = typesModule.Global_Global
-- ROBLOX deviation END

local jestMockModule = require(script.Parent:WaitForChild('jest-mock'))-- ROBLOX deviation START: can't export globals from jest mock

type JestFuncFn = jestMockModule.JestFuncFn
type JestFuncMocked = jestMockModule.JestFuncMocked
type JestFuncSpyOn = jestMockModule.JestFuncSpyOn
-- ROBLOX deviation END

type ModuleMocker = jestMockModule.ModuleMocker

-- ROBLOX deviation: mocking globals
local jestMockGenvModule = require(script.Parent:WaitForChild('jest-mock-genv'))

export type EnvironmentContext = {
	console: Console,
	-- docblockPragmas: Record<string, string | Array<string>>,
	-- ROBLOX deviation: accept ModuleScript instead of string
	testPath: ModuleScript
}

-- Different Order than https://nodejs.org/api/modules.html#modules_the_module_wrapper , however needs to be in the form [jest-transform]ScriptTransformer accepts
export type ModuleWrapper = (
	this: any, --[[ ROBLOX TODO: Unhandled node for type: TSIndexedAccessType ]] --[[ Module['exports'] ]]
	module: Module,
	exports: any, --[[ ROBLOX TODO: Unhandled node for type: TSIndexedAccessType ]] --[[ Module['exports'] ]]
	require: Object, --[[ ROBLOX TODO: Unhandled node for type: TSIndexedAccessType ]] --[[ Module['require'] ]]
	__dirname: string,
	__filename: string, --[[ ROBLOX TODO: Unhandled node for type: TSIndexedAccessType ]] --[[ Module['filename'] ]]
	jest: Jest?,...
any --[[ ROBLOX CHECK: check correct type of elements. Upstream type: <Array<Global.Global[keyof Global.Global]>> ]]
) -> any

export type JestEnvironment<Timer = any> = {
	new: (config: Config_ProjectConfig, context: EnvironmentContext?) -> JestEnvironment<Timer>,
	global: Global_Global,
	-- ROBLOX deviation START: no modern/legacy timers
	-- fakeTimers: LegacyFakeTimers<Timer> | nil,
	-- fakeTimersModern: ModernFakeTimers | nil,
	fakeTimers: FakeTimers | nil,
	-- ROBLOX deviation END
	moduleMocker: ModuleMocker | nil,
	getVmContext: (self: JestEnvironment<Timer>) -> Context | nil,
	setup: (self: JestEnvironment<Timer>) -> Promise<void>,
	teardown: (self: JestEnvironment<Timer>) -> Promise<void>,
	handleTestEvent: Circus_EventHandler?,
	exportConditions: (() -> Array<string>)?
}

export type Module = NodeModule

-- TODO: Move to some separate package
export type Jest = {
	--[[*
	* Advances all timers by the needed milliseconds so that only the next timeouts/intervals will run.
	* Optionally, you can provide steps, so it will run steps amount of next timeouts/intervals.
	]]
	advanceTimersToNextTimer: (steps: number?) -> (),
	--[[*
	* Disables automatic mocking in the module loader.
	]]
	autoMockOff: () -> Jest,
	--[[*
	* Enables automatic mocking in the module loader.
	]]
	autoMockOn: () -> Jest,
	--[[*
	* Clears the mock.calls and mock.instances properties of all mocks.
	* Equivalent to calling .mockClear() on every mocked function.
	]]
	clearAllMocks: () -> Jest,
	--[[*
	* Removes any pending timers from the timer system. If any timers have been
	* scheduled, they will be cleared and will never have the opportunity to
	* execute in the future.
	]]
	clearAllTimers: () -> (),
	--[[*
	* Indicates that the module system should never return a mocked version
	* of the specified module, including all of the specified module's
	* dependencies.
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	deepUnmock: (moduleName: ModuleScript) -> Jest,
	--[[*
	* Disables automatic mocking in the module loader.
	*
	* After this method is called, all `require()`s will return the real
	* versions of each module (rather than a mocked version).
	]]
	disableAutomock: () -> Jest,
	--[[*
	* When using `babel-jest`, calls to mock will automatically be hoisted to
	* the top of the code block. Use this method if you want to explicitly avoid
	* this behavior.
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	doMock: (moduleName: ModuleScript, moduleFactory: (() -> any)?) -> Jest,
	--[[*
	* Indicates that the module system should never return a mocked version
	* of the specified module from require() (e.g. that it should always return
	* the real module).
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	dontMock: (moduleName: ModuleScript) -> Jest,
	--[[*
	* Enables automatic mocking in the module loader.
	]]
	enableAutomock: () -> Jest,
	--[[*
	* Creates a mock function. Optionally takes a mock implementation.
	]]
	-- ROBLOX deviation: can't export globals from jest mock
	fn: JestFuncFn,
	-- ROBLOX deviation START: mocking globals
	--[[*
	* Represents the global environment and its libraries, for use with the
	* `spyOn()` function. This can be used to spy on Lua globals.
	]]
	globalEnv: jestMockGenvModule.GlobalEnv,
	-- ROBLOX deviation END
	--[[*
	* Given the name of a module, use the automatic mocking system to generate a
	* mocked version of the module for you.
	*
	* This is useful when you want to create a manual mock that extends the
	* automatic mock's behavior.
	*
	* @deprecated Use `jest.createMockFromModule()` instead
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	genMockFromModule: (moduleName: ModuleScript) -> any,
	--[[*
	* Given the name of a module, use the automatic mocking system to generate a
	* mocked version of the module for you.
	*
	* This is useful when you want to create a manual mock that extends the
	* automatic mock's behavior.
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	createMockFromModule: (moduleName: ModuleScript) -> any,
	--[[*
	* Determines if the given function is a mocked function.
	]]
	isMockFunction: (fn: (...any) -> any) -> boolean,
	--[[*
	* Mocks a module with an auto-mocked version when it is being required.
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	mock: (moduleName: ModuleScript, moduleFactory: (() -> any)?, options: { virtual: boolean? }?) -> Jest,
	--[[*
	* Mocks a module with the provided module factory when it is being imported.
	]]
	-- ROBLOX TODO: add default generic. <T = any>
	unstable_mockModule: <T>(
		-- ROBLOX deviation: using ModuleScript instead of string
		moduleName: ModuleScript,
		moduleFactory: () -> Promise<T> | T,
		options: { virtual: boolean? }?
	) -> Jest,
	--[[*
	* Returns the actual module instead of a mock, bypassing all checks on
	* whether the module should receive a mock implementation or not.
	*
	* @example
	```
	 jest.mock('../myModule', () => {
	 // Require the original module to not be mocked...
	 const originalModule = jest.requireActual(moduleName);
	   return {
	     __esModule: true, // Use it when dealing with esModules
	     ...originalModule,
	     getRandom: jest.fn().mockReturnValue(10),
	   };
	 });
	  const getRandom = require('../myModule').getRandom;
	  getRandom(); // Always returns 10
	 ```
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	requireActual: (moduleName: ModuleScript) -> any,
	--[[*
	* Returns a mock module instead of the actual module, bypassing all checks
	* on whether the module should be required normally or not.
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	requireMock: (moduleName: ModuleScript) -> any,
	--[[*
	* Resets the state of all mocks.
	* Equivalent to calling .mockReset() on every mocked function.
	]]
	resetAllMocks: () -> Jest,
	--[[*
	* Resets the module registry - the cache of all required modules. This is
	* useful to isolate modules where local state might conflict between tests.
	]]
	resetModules: () -> Jest,
	--[[*
	* Restores all mocks back to their original value. Equivalent to calling
	* `.mockRestore` on every mocked function.
	*
	* Beware that jest.restoreAllMocks() only works when the mock was created with
	* jest.spyOn; other mocks will require you to manually restore them.
	]]
	restoreAllMocks: () -> Jest,
	-- ROBLOX deviation: can't export globals from jest mock
	mocked: JestFuncMocked,
	--[[*
	* Runs failed tests n-times until they pass or until the max number of
	* retries is exhausted. This only works with `jest-circus`!
	]]
	retryTimes: (numRetries: number) -> Jest,
	--[[*
	* Exhausts tasks queued by setImmediate().
	*
	* > Note: This function is not available when using Lolex as fake timers implementation
	]]
	runAllImmediates: () -> (),
	--[[*
	* Exhausts the micro-task queue (usually interfaced in node via
	* process.nextTick).
	]]
	runAllTicks: () -> (),
	--[[*
	* Exhausts the macro-task queue (i.e., all tasks queued by setTimeout()
	* and setInterval()).
	]]
	runAllTimers: () -> (),
	--[[*
	* Executes only the macro-tasks that are currently pending (i.e., only the
	* tasks that have been queued by setTimeout() or setInterval() up to this
	* point). If any of the currently pending macro-tasks schedule new
	* macro-tasks, those new tasks will not be executed by this call.
	]]
	runOnlyPendingTimers: () -> (),
	--[[*
	* Advances all timers by msToRun milliseconds. All pending "macro-tasks"
	* that have been queued via setTimeout() or setInterval(), and would be
	* executed within this timeframe will be executed.
	]]
	advanceTimersByTime: (msToRun: number) -> void,
	--[[*
	* Returns the number of fake timers still left to run.
	]]
	getTimerCount: () -> number,
	--[[*
	* Explicitly supplies the mock object that the module system should return
	* for the specified module.
	*
	* Note It is recommended to use `jest.mock()` instead. The `jest.mock`
	* API's second argument is a module factory instead of the expected
	* exported module object.
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	setMock: (moduleName: ModuleScript, moduleExports: any) -> Jest,
	--[[*
	* Set the default timeout interval for tests and before/after hooks in
	* milliseconds.
	*
	* Note: The default timeout interval is 5 seconds if this method is not
	* called.
	]]
	setTimeout: (timeout: number) -> Jest,
	--[[*
	* Creates a mock function similar to `jest.fn` but also tracks calls to
	* `object[methodName]`.
	*
	* Note: By default, jest.spyOn also calls the spied method. This is
	* different behavior from most other test libraries.
	]]
	-- ROBLOX deviation: can't export globals from jest mock
	spyOn: JestFuncSpyOn,
	--[[*
	* Indicates that the module system should never return a mocked version of
	* the specified module from require() (e.g. that it should always return the
	* real module).
	]]
	-- ROBLOX deviation: using ModuleScript instead of string
	unmock: (moduleName: ModuleScript) -> Jest,
	--[[*
	* Instructs Jest to use fake versions of the standard timer functions.
	]]
	--[[
		ROBLOX deviation: because there is no modern/legacy timers it doesn't make sense to pick one, removing 'implementation' parameter
		Original fn: useFakeTimers: (implementation: ("modern" | "legacy")?) -> Jest,
	]]
	useFakeTimers: () -> Jest,
	--[[*
	* Instructs Jest to use the real versions of the standard timer functions.
	]]
	useRealTimers: () -> Jest,
	--[[*
	* `jest.isolateModules(fn)` goes a step further than `jest.resetModules()`
	* and creates a sandbox registry for the modules that are loaded inside
	* the callback function. This is useful to isolate specific modules for
	* every test so that local module state doesn't conflict between tests.
	]]
	isolateModules: (fn: () -> ()) -> Jest,
	--[[*
	* ROBLOX deviation START: configurable engine frame time
	* Because the Roblox game engine processes things in frames rather than in continuous time, users can configure
	* an engine frame time when using fake timers to more simulate engine timer behavior more accurately.
	]]
	--[[*
	* When using the fake versions of the standard timer functions, returns the frame time (in ms). By default, this is 0 (i.e. continuous time).
	]]
	getEngineFrameTime: () -> number,
	--[[*
	* When using the fake versions of the standard timer functions, set the frame time (in ms) for processing timeouts. Simulates the way
	* the engine scheduler processes timeouts (i.e. in batches delineated by frames). Timers process in the first frame greater than their set time.
	]]
	setEngineFrameTime: (frameTimeMs: number) -> (),
	-- ROBLOX deviation END
	--[[*
	* When mocking time, `Date.now()` will also be mocked. If you for some reason need access to the real current time, you can invoke this function.
	*
	* > Note: This function is only available when using Lolex as fake timers implementation
	]]
	getRealSystemTime: () -> number,
	--[[*
	*  Set the current system time used by fake timers. Simulates a user changing the system clock while your program is running. It affects the current time but it does not in itself cause e.g. timers to fire; they will fire exactly as they would have done without the call to `jest.setSystemTime()`.
	*
	*  > Note: This function is only available when using Lolex as fake timers implementation
	]]
	setSystemTime: (now: (number | DateTime)?) -> ()
}
return {}
