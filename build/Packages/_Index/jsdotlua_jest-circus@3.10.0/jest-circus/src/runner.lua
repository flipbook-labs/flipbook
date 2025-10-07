-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-circus/runner.js

--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]
-- Allow people to use `jest-circus/runner` as a runner.
local runner = require(script.Parent:WaitForChild('circus'):WaitForChild('legacy-code-todo-rewrite'):WaitForChild('jestAdapter'))
return runner
