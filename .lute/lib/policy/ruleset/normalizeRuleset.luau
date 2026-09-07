local json = require("@std/json")

local function normalizeRuleset(live: any): any
	local knownRules = {
		deletion = true,
		non_fast_forward = true,
		pull_request = true,
		required_status_checks = true,
		required_linear_history = true,
	}
	local rulesByType = {}
	for _, rule in live.rules do
		assert(knownRules[rule.type], `refusing to discard unrecognized live rule "{rule.type}"`)
		rulesByType[rule.type] = rule
	end

	local pullRequest = assert(rulesByType.pull_request, "live ruleset is missing pull_request")
	local checks = assert(rulesByType.required_status_checks, "live ruleset is missing required_status_checks")
	local reviewers = {}
	for _, reviewer in pullRequest.parameters.required_reviewers do
		table.insert(reviewers, {
			reviewer = { id = reviewer.reviewer.id, type = reviewer.reviewer.type },
			minimum_approvals = reviewer.minimum_approvals,
			file_patterns = reviewer.file_patterns,
		})
	end

	local bypassActors = {}
	for _, actor in live.bypass_actors do
		local normalized = { actor_type = actor.actor_type, bypass_mode = actor.bypass_mode }
		if actor.actor_id ~= json.null then
			normalized.actor_id = actor.actor_id
		end
		table.insert(bypassActors, normalized)
	end

	return {
		name = live.name,
		target = live.target,
		enforcement = live.enforcement,
		bypass_actors = bypassActors,
		conditions = live.conditions,
		rules = {
			{ type = "deletion" },
			{ type = "non_fast_forward" },
			{
				type = "pull_request",
				parameters = {
					required_approving_review_count = pullRequest.parameters.required_approving_review_count,
					dismiss_stale_reviews_on_push = pullRequest.parameters.dismiss_stale_reviews_on_push,
					required_reviewers = reviewers,
					require_code_owner_review = pullRequest.parameters.require_code_owner_review,
					dismissal_restriction = pullRequest.parameters.dismissal_restriction,
					require_last_push_approval = pullRequest.parameters.require_last_push_approval,
					required_review_thread_resolution = pullRequest.parameters.required_review_thread_resolution,
					require_extra_approval_for_unattributed_changes = pullRequest.parameters.require_extra_approval_for_unattributed_changes,
					allowed_merge_methods = pullRequest.parameters.allowed_merge_methods,
				},
			},
			{ type = "required_status_checks", parameters = checks.parameters },
			{ type = "required_linear_history" },
		},
	}
end

return normalizeRuleset
