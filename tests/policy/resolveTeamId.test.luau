local test = require("@std/test")

local createRulesetConfig = require("./createRulesetConfig")
local resolveTeamId = require("@scripts/lib/policy/resolveTeamId")

test.suite("resolveTeamId", function(suite)
	suite:case("resolves the configured organization team", function(assert)
		local requestedPath
		local id = resolveTeamId(createRulesetConfig(), "flipbook-app", function(arguments)
			requestedPath = arguments[1]
			return '{"id":42}'
		end)

		assert.eq(requestedPath, "orgs/flipbook-labs/teams/flipbook-app")
		assert.eq(id, 42)
	end)

	suite:case("explains the team prerequisite", function(assert)
		assert.throwsWith(
			"team @flipbook-labs/flipbook-app must exist before the policy can be planned or applied",
			function()
				resolveTeamId(createRulesetConfig(), "flipbook-app", function()
					error("missing")
				end)
			end
		)
	end)

	suite:case("requires a numeric team id", function(assert)
		assert.throwsWith("GitHub did not return an id for team flipbook-app", function()
			resolveTeamId(createRulesetConfig(), "flipbook-app", function()
				return '{"id":"42"}'
			end)
		end)
	end)
end)
