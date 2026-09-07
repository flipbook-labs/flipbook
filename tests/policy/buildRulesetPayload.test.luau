local test = require("@std/test")

local buildRulesetPayload = require("@scripts/lib/policy/buildRulesetPayload")
local createRulesetConfig = require("./createRulesetConfig")

test.case("translates policy config into a GitHub ruleset payload", function(assert)
	local requestedTeam
	local payload = buildRulesetPayload(createRulesetConfig(), function(_, team)
		requestedTeam = team
		return 42
	end)

	assert.eq(requestedTeam, "flipbook-app")
	assert.eq(payload.name, "main")
	assert.eq(payload.rules[3].parameters.required_reviewers[1].reviewer.id, 42)
	assert.eq(payload.rules[3].parameters.required_reviewers[1].minimum_approvals, 1)
	assert.eq(payload.rules[4].parameters.required_status_checks[1].integration_id, 15368)
	assert.eq(payload.rules[4].parameters.required_status_checks[2].integration_id, nil)
	assert.eq(payload.bypass_actors[1].actor_id, 1)
	assert.eq(payload.bypass_actors[2].actor_id, nil)
end)
