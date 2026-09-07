local test = require("@std/test")

local createRulesetConfig = require("./createRulesetConfig")
local findRuleset = require("@scripts/lib/policy/findRuleset")

test.suite("findRuleset", function(suite)
	suite:case("finds the configured ruleset by name", function(assert)
		local requestedPath
		local ruleset = findRuleset(createRulesetConfig(), function(arguments)
			requestedPath = arguments[1]
			return '[{"id":1,"name":"other"},{"id":17,"name":"main"}]'
		end)

		assert.eq(requestedPath, "repos/flipbook-labs/flipbook/rulesets")
		assert.eq(ruleset.id, 17)
	end)

	suite:case("fails when the configured ruleset is missing", function(assert)
		assert.throwsWith('ruleset "main" was not found', function()
			findRuleset(createRulesetConfig(), function()
				return "[]"
			end)
		end)
	end)
end)
