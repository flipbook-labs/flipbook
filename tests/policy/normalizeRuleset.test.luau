local json = require("@std/json")
local test = require("@std/test")

local normalizeRuleset = require("@scripts/lib/policy/normalizeRuleset")

local function createLiveRuleset(): any
	return {
		name = "main",
		target = "branch",
		enforcement = "active",
		bypass_actors = {
			{ actor_type = "OrganizationAdmin", actor_id = 1, bypass_mode = "pull_request" },
			{ actor_type = "RepositoryRole", actor_id = json.null, bypass_mode = "always" },
		},
		conditions = { ref_name = { exclude = {}, include = { "~DEFAULT_BRANCH" } } },
		rules = {
			{ type = "required_linear_history" },
			{
				type = "required_status_checks",
				parameters = {
					strict_required_status_checks_policy = false,
					do_not_enforce_on_create = false,
					required_status_checks = { { context = "analyze", integration_id = 15368 } },
				},
			},
			{ type = "deletion" },
			{
				type = "pull_request",
				parameters = {
					required_approving_review_count = 0,
					dismiss_stale_reviews_on_push = true,
					required_reviewers = {
						{
							reviewer = { id = 42, type = "Team" },
							minimum_approvals = 1,
							file_patterns = { "workspace/**/*" },
						},
					},
					require_code_owner_review = false,
					dismissal_restriction = { enabled = false, allowed_actors = {} },
					require_last_push_approval = false,
					required_review_thread_resolution = true,
					require_extra_approval_for_unattributed_changes = false,
					allowed_merge_methods = { "squash" },
				},
			},
			{ type = "non_fast_forward" },
		},
	}
end

test.suite("normalizeRuleset", function(suite)
	suite:case("keeps only managed fields in a stable rule order", function(assert)
		local normalized = normalizeRuleset(createLiveRuleset())

		assert.eq(normalized.rules[1].type, "deletion")
		assert.eq(normalized.rules[2].type, "non_fast_forward")
		assert.eq(normalized.rules[3].type, "pull_request")
		assert.eq(normalized.rules[3].parameters.required_reviewers[1].reviewer.id, 42)
		assert.eq(normalized.rules[4].type, "required_status_checks")
		assert.eq(normalized.rules[5].type, "required_linear_history")
		assert.eq(normalized.bypass_actors[1].actor_id, 1)
		assert.eq(normalized.bypass_actors[2].actor_id, nil)
	end)

	suite:case("refuses to hide an unmanaged live rule", function(assert)
		local live = createLiveRuleset()
		table.insert(live.rules, { type = "required_signatures" })

		assert.throwsWith('refusing to discard unrecognized live rule "required_signatures"', function()
			normalizeRuleset(live)
		end)
	end)
end)
