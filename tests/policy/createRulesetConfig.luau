local function createRulesetConfig(): any
	return {
		repository = {
			owner = "flipbook-labs",
			name = "flipbook",
			ruleset = "main",
			target = "branch",
			enforcement = "active",
			includeRefs = { "~DEFAULT_BRANCH" },
		},
		pullRequest = {
			requiredApprovals = 0,
			dismissStaleApprovals = true,
			requireCodeOwnerReview = false,
			requireLastPushApproval = false,
			requireResolvedThreads = true,
			requireExtraApprovalForUnattributedChanges = false,
			allowedMergeMethods = { "squash" },
		},
		reviewers = {
			{ team = "flipbook-app", minimumApprovals = 1, filePatterns = { "workspace/**/*" } },
		},
		requiredChecks = {
			{ context = "analyze", integrationId = 15368 },
			{ context = "Greptile Review" },
		},
		bypassActors = {
			{ actorType = "OrganizationAdmin", actorId = 1, bypassMode = "pull_request" },
			{ actorType = "RepositoryRole", bypassMode = "always" },
		},
	}
end

return createRulesetConfig
