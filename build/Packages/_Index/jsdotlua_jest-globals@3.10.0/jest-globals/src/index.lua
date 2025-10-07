-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-globals/src/index.ts
-- /**
--  * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
--  *
--  * This source code is licensed under the MIT license found in the
--  * LICENSE file in the root directory of this source tree.
--  *
--  */

local LuauPolyfill = require(script.Parent.Parent:WaitForChild('luau-polyfill'))
local Error = LuauPolyfill.Error

local JestEnvironment = require(script.Parent.Parent:WaitForChild('jest-environment'))
type Jest = JestEnvironment.Jest
local importedExpect = require(script.Parent.Parent:WaitForChild('expect'))
-- ROBLOX deviation START: additional imports

local jestTypesModule = require(script.Parent.Parent:WaitForChild('jest-types'))
type TestFrameworkGlobals = jestTypesModule.Global_TestFrameworkGlobals

local ExpectModule = require(script.Parent.Parent:WaitForChild('expect'))
type MatcherState = ExpectModule.MatcherState
type ExpectExtended<E, State = MatcherState> = ExpectModule.ExpectExtended<E, State>
-- ROBLOX deviation END

type JestGlobals =
	{
		jest: Jest,
		expect: typeof(importedExpect),
		expectExtended: ExpectExtended<{ [string]: (...any) -> nil }>	
}
	-- ROBLOX deviation START: using TestFrameworkGlobals instead of declaring variables one by one
	& TestFrameworkGlobals
-- ROBLOX deviation END

error(Error.new(
[[Do not import `JestGlobals` outside of the Jest 3 test environment.
Tip: Jest 2 uses a different pattern - check your Jest version.]]	-- ROBLOX deviation END


))

return ({} :: any) :: JestGlobals
