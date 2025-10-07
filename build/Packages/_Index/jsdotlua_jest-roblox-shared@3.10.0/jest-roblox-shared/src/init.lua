--[[
	* Copyright (c) Roblox Corporation. All rights reserved.
	* Licensed under the MIT License (the "License");
	* you may not use this file except in compliance with the License.
	* You may obtain a copy of the License at
	*
	*     https://opensource.org/licenses/MIT
	*
	* Unless required by applicable law or agreed to in writing, software
	* distributed under the License is distributed on an "AS IS" BASIS,
	* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	* See the License for the specific language governing permissions and
	* limitations under the License.
]]

local nodeUtilsModule = require(script:WaitForChild('nodeUtils'))
export type NodeJS_WriteStream = nodeUtilsModule.NodeJS_WriteStream
local exports = {
	cleanLoadStringStack = require(script:WaitForChild('cleanLoadStringStack')),
	dedent = require(script:WaitForChild('dedent')).dedent,
	escapePatternCharacters = require(script:WaitForChild('escapePatternCharacters')).escapePatternCharacters,
	ensureDirectoryExists = require(script:WaitForChild('ensureDirectoryExists')),
	getDataModelService = require(script:WaitForChild('getDataModelService')),
	getParent = require(script:WaitForChild('getParent')),
	expect = require(script:WaitForChild('expect')),
	getRelativePath = require(script:WaitForChild('getRelativePath')),
	RobloxInstance = require(script:WaitForChild('RobloxInstance')),
	nodeUtils = nodeUtilsModule,
	normalizePromiseError = require(script:WaitForChild('normalizePromiseError')),
	pruneDeps = require(script:WaitForChild('pruneDeps')),
	redactStackTrace = require(script:WaitForChild('redactStackTrace')),
}

local WriteableModule = require(script:WaitForChild('Writeable'))
exports.Writeable = WriteableModule.Writeable
export type Writeable = WriteableModule.Writeable

return exports
