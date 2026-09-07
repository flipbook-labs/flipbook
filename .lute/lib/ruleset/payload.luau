local json = require("@std/json")

local github = require("@scripts/lib/ruleset/github")

local function buildReviewers(config: any): { any }
	local result = {}
	for _, reviewer in config.reviewers do
		table.insert(result, {
			reviewer = { id = github.resolveTeamId(config, reviewer.team), type = "Team" },
			minimum_approvals = reviewer.minimumApprovals,
			file_patterns = reviewer.filePatterns,
		})
	end
	return result
end

local function buildChecks(config: any): { any }
	local result = {}
	for _, check in config.requiredChecks do
		local requiredCheck = { context = check.context }
		if check.integrationId ~= nil then
			requiredCheck.integration_id = check.integrationId
		end
		table.insert(result, requiredCheck)
	end
	return result
end

local function buildBypassActors(config: any): { any }
	local result = {}
	for _, actor in config.bypassActors do
		local bypassActor = { actor_type = actor.actorType, bypass_mode = actor.bypassMode }
		if actor.actorId ~= nil then
			bypassActor.actor_id = actor.actorId
		end
		table.insert(result, bypassActor)
	end
	return result
end

local function build(config: any): any
	local pullRequest = config.pullRequest
	return {
		name = config.repository.ruleset,
		target = config.repository.target,
		enforcement = config.repository.enforcement,
		bypass_actors = buildBypassActors(config),
		conditions = { ref_name = { exclude = {}, include = config.repository.includeRefs } },
		rules = {
			{ type = "deletion" },
			{ type = "non_fast_forward" },
			{
				type = "pull_request",
				parameters = {
					required_approving_review_count = pullRequest.requiredApprovals,
					dismiss_stale_reviews_on_push = pullRequest.dismissStaleApprovals,
					required_reviewers = buildReviewers(config),
					require_code_owner_review = pullRequest.requireCodeOwnerReview,
					dismissal_restriction = { enabled = false, allowed_actors = {} },
					require_last_push_approval = pullRequest.requireLastPushApproval,
					required_review_thread_resolution = pullRequest.requireResolvedThreads,
					require_extra_approval_for_unattributed_changes = pullRequest.requireExtraApprovalForUnattributedChanges,
					allowed_merge_methods = pullRequest.allowedMergeMethods,
				},
			},
			{
				type = "required_status_checks",
				parameters = {
					strict_required_status_checks_policy = false,
					do_not_enforce_on_create = false,
					required_status_checks = buildChecks(config),
				},
			},
			{ type = "required_linear_history" },
		},
	}
end

local function normalize(live: any): any
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

return {
	build = build,
	normalize = normalize,
}
