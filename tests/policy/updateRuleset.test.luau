local test = require("@std/test")

local createRulesetConfig = require("./createRulesetConfig")
local updateRuleset = require("@scripts/lib/policy/updateRuleset")

test.case("updates the selected ruleset from a JSON payload", function(assert)
	local requestArguments
	updateRuleset(createRulesetConfig(), 17, "/tmp/payload.json", function(arguments)
		requestArguments = arguments
		return ""
	end)

	assert.eq(requestArguments[1], "--method")
	assert.eq(requestArguments[2], "PUT")
	assert.eq(requestArguments[3], "repos/flipbook-labs/flipbook/rulesets/17")
	assert.eq(requestArguments[4], "--input")
	assert.eq(requestArguments[5], "/tmp/payload.json")
end)
