local resolveTeamId = require("@scripts/lib/policy/resolveTeamId")

local function buildReviewers(config: any): { any }
	local result = {}
	for _, reviewer in config.reviewers do
		table.insert(result, {
			reviewer = { id = resolveTeamId(config, reviewer.team), type = "Team" },
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

local function buildRulesetPayload(config: any): any
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

return buildRulesetPayload
