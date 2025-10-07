-- ROBLOX upstream: https://github.com/facebook/jest/blob/v28.0.0/packages/jest-config/src/constants.ts
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates. All Rights Reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 ]]

local exports = {}

-- ROBLOX deviation START: not needed
-- local path = require("@pkg/@jsdotlua/path")
-- local NODE_MODULES = tostring(path.sep) .. "node_modules" .. tostring(path.sep)
-- exports.NODE_MODULES = NODE_MODULES
-- local DEFAULT_JS_PATTERN = "\\.[jt]sx?$"
-- exports.DEFAULT_JS_PATTERN = DEFAULT_JS_PATTERN
-- local DEFAULT_REPORTER_LABEL = "default"
-- exports.DEFAULT_REPORTER_LABEL = DEFAULT_REPORTER_LABEL
-- local PACKAGE_JSON = "package.json"
-- exports.PACKAGE_JSON = PACKAGE_JSON
-- ROBLOX deviation END
local JEST_CONFIG_BASE_NAME = "jest.config"
exports.JEST_CONFIG_BASE_NAME = JEST_CONFIG_BASE_NAME
-- ROBLOX deviation START: not supported
-- local JEST_CONFIG_EXT_CJS = ".cjs"
-- exports.JEST_CONFIG_EXT_CJS = JEST_CONFIG_EXT_CJS
-- local JEST_CONFIG_EXT_MJS = ".mjs"
-- exports.JEST_CONFIG_EXT_MJS = JEST_CONFIG_EXT_MJS
-- local JEST_CONFIG_EXT_JS = ".js"
-- exports.JEST_CONFIG_EXT_JS = JEST_CONFIG_EXT_JS
-- local JEST_CONFIG_EXT_TS = ".ts"
-- exports.JEST_CONFIG_EXT_TS = JEST_CONFIG_EXT_TS
-- ROBLOX deviation END
local JEST_CONFIG_EXT_JSON = ".json"
exports.JEST_CONFIG_EXT_JSON = JEST_CONFIG_EXT_JSON
-- ROBLOX deviation START: support Lua and Luau extensions
local JEST_CONFIG_EXT_LUA = ".lua"
exports.JEST_CONFIG_EXT_LUA = JEST_CONFIG_EXT_LUA
local JEST_CONFIG_EXT_LUAU = ".luau"
exports.JEST_CONFIG_EXT_LUAU = JEST_CONFIG_EXT_LUAU
-- ROBLOX deviation END
local JEST_CONFIG_EXT_ORDER = {
	-- ROBLOX deviation START: support Lua and Luau extensions
	JEST_CONFIG_EXT_LUA,
	JEST_CONFIG_EXT_LUAU,
	-- ROBLOX deviation END
	-- ROBLOX deviation START: not supported
	-- JEST_CONFIG_EXT_JS,
	-- JEST_CONFIG_EXT_TS,
	-- JEST_CONFIG_EXT_MJS,
	-- JEST_CONFIG_EXT_CJS,
	-- ROBLOX deviation END
	-- ROBLOX deviation START: not supported (but for now)
	-- JEST_CONFIG_EXT_JSON,
	-- ROBLOX deviation END
}
exports.JEST_CONFIG_EXT_ORDER = JEST_CONFIG_EXT_ORDER

return exports
