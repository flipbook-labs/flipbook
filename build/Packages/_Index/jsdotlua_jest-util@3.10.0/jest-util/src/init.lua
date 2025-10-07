-- ROBLOX upstream: https://github.com/facebook/jest/tree/v28.0.0/packages/jest-util/src/index.ts

--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local LuauPolyfill = require(script.Parent:WaitForChild('luau-polyfill'))
local Object = LuauPolyfill.Object

local exports = {}

exports.clearLine = require(script:WaitForChild('clearLine')).default
exports.createDirectory = require(script:WaitForChild('createDirectory')).default
local ErrorWithStackModule = require(script:WaitForChild('ErrorWithStack'))
exports.ErrorWithStack = ErrorWithStackModule.default
export type ErrorWithStack = ErrorWithStackModule.ErrorWithStack
-- ROBLOX deviation: need to execute the module explicitly
exports.installCommonGlobals = require(script:WaitForChild('installCommonGlobals'))().default
-- ROBLOX deviation not ported as it doesn't seem necessary in Lua
-- exports.interopRequireDefault = require("./interopRequireDefault").default
exports.isInteractive = require(script:WaitForChild('isInteractive')).default
exports.isPromise = require(script:WaitForChild('isPromise')).default
exports.setGlobal = require(script:WaitForChild('setGlobal')).default
exports.deepCyclicCopy = require(script:WaitForChild('deepCyclicCopy')).default
exports.convertDescriptorToString = require(script:WaitForChild('convertDescriptorToString')).default
local specialCharsModule = require(script:WaitForChild('specialChars'))
Object.assign(exports, specialCharsModule)
exports.specialChars = specialCharsModule
-- ROBLOX deviation START: additional assignments for Lua type inferrence to work
exports.ARROW = specialCharsModule.ARROW
exports.ICONS = specialCharsModule.ICONS
exports.CLEAR = specialCharsModule.CLEAR
-- ROBLOX deviation END
-- ROBLOX deviation: not ported as it doesn't seem necessary in Lua
-- exports.replacePathSepForGlob = require("./replacePathSepForGlob").default
exports.testPathPatternToRegExp = require(script:WaitForChild('testPathPatternToRegExp')).default
exports.globsToMatcher = require(script:WaitForChild('globsToMatcher')).default
local preRunMessageModule = require(script:WaitForChild('preRunMessage'))
exports.preRunMessage = preRunMessageModule
-- ROBLOX deviation START: additional assignments for Lua type inferrence to work
exports.print = preRunMessageModule.print
exports.remove = preRunMessageModule.remove
-- ROBLOX deviation END
exports.pluralize = require(script:WaitForChild('pluralize')).default
exports.formatTime = require(script:WaitForChild('formatTime')).default
-- ROBLOX deviation START: not ported as it doesn't seem necessary in Lua
-- exports.tryRealpath = require("./tryRealpath").default
-- exports.requireOrImportModule = require("./requireOrImportModule").default
-- ROBLOX deviation END
return exports
