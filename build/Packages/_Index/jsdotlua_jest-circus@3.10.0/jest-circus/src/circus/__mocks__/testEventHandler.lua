-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-circus/src/__mocks__/testEventHandler.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local exports = {}
local LuauPolyfill = require(script.Parent.Parent.Parent.Parent:WaitForChild('luau-polyfill'))
local console = LuauPolyfill.console

local CircusModule = require(script.Parent.Parent.Parent.Parent:WaitForChild('jest-types'))
type Circus_EventHandler = CircusModule.Circus_EventHandler

local testEventHandler: Circus_EventHandler
function testEventHandler(_self, event, state)
	if event.name == "start_describe_definition" or event.name == "finish_describe_definition" then
		console.log(
			event.name .. ":",
			-- ROBLOX FIXME Luau: Type should be narrowed here to allow for accessing `blockName` property
			(event :: any).blockName
		)
	elseif event.name == "run_describe_start" or event.name == "run_describe_finish" then
		console.log(event.name .. ":", event.describeBlock.name)
	elseif event.name == "test_start" or event.name == "test_retry" or event.name == "test_done" then
		console.log(event.name .. ":", event.test.name)
	elseif event.name == "add_test" then
		console.log(
			event.name .. ":",
			-- ROBLOX FIXME Luau: Type should be narrowed here to allow for accessing `testName` property
			(event :: any).testName
		)
	elseif event.name == "test_fn_start" or event.name == "test_fn_success" or event.name == "test_fn_failure" then
		console.log(event.name .. ":", event.test.name)
	elseif event.name == "add_hook" then
		console.log(
			event.name .. ":",
			-- ROBLOX FIXME Luau: Type should be narrowed here to allow for accessing `hookType` property
			(event :: any).hookType
		)
	elseif event.name == "hook_start" or event.name == "hook_success" or event.name == "hook_failure" then
		console.log(event.name .. ":", event.hook.type)
	else
		console.log(event.name)
	end

	if event.name == "run_finish" then
		console.log("")
		console.log(("unhandledErrors: %d"):format(#state.unhandledErrors))
	end
end

exports.default = testEventHandler
return exports
