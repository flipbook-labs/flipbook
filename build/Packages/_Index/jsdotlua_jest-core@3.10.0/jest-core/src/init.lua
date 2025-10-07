-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-core/src/jest.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local exports = {}

exports.SearchSource = require(script:WaitForChild('SearchSource')).default
exports.createTestScheduler = require(script:WaitForChild('TestScheduler')).createTestScheduler
exports.TestWatcher = require(script:WaitForChild('TestWatcher')).default
exports.runCLI = require(script:WaitForChild('cli')).runCLI
-- ROBLOX deviation START: not needed
-- exports.getVersion = require("./version").default
-- ROBLOX deviation END
return exports
