--[[
 * Copyright (c) GraphQL Contributors
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
]]
-- ROBLOX upstream: https://github.com/graphql/graphql-js/blob/7b3241329e1ff49fb647b043b80568f0cf9e1a7c/src/validation/rules/UniqueFragmentNamesRule.js

local root = script.Parent.Parent.Parent
local GraphQLError = require(root.error.GraphQLError).GraphQLError

local exports = {}

-- /**
--  * Unique fragment names
--  *
--  * A GraphQL document is only valid if all defined fragments have unique names.
--  */
exports.UniqueFragmentNamesRule = function(context)
	local knownFragmentNames = {}

	return {
		OperationDefinition = function()
			return false
		end,
		FragmentDefinition = function(_self, node)
			local fragmentName = node.name.value
			if knownFragmentNames[fragmentName] then
				context:reportError(
					GraphQLError.new(
						('There can be only one fragment named "%s".'):format(fragmentName),
						{ knownFragmentNames[fragmentName], node.name }
					)
				)
			else
				knownFragmentNames[fragmentName] = node.name
			end

			return false
		end,
	}
end

return exports
