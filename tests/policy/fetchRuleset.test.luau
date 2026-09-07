local test = require("@std/test")

local createRulesetConfig = require("./createRulesetConfig")
local fetchRuleset = require("@scripts/lib/policy/fetchRuleset")

test.case("fetches and decodes a ruleset", function(assert)
	local requestedPath
	local ruleset = fetchRuleset(createRulesetConfig(), 17, function(arguments)
		requestedPath = arguments[1]
		return '{"id":17,"name":"main"}'
	end)

	assert.eq(requestedPath, "repos/flipbook-labs/flipbook/rulesets/17")
	assert.eq(ruleset.id, 17)
	assert.eq(ruleset.name, "main")
end)
