local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local CONFIG_PATH = path.resolve(".github/ruleset.json")

local function readRulesetConfig(configPath: path.Pathlike?): any
	local config = json.deserialize(fs.readFileToString(configPath or CONFIG_PATH)) :: any
	assert(typeof(config) == "table", "ruleset config must be a table")

	local repository: any = config.repository
	assert(typeof(repository) == "table", "repository must be a table")
	for _, key in { "owner", "name", "ruleset", "target", "enforcement" } do
		assert(typeof(repository[key]) == "string", `repository.{key} must be a string`)
	end
	assert(typeof(repository.includeRefs) == "table", "repository.includeRefs must be a table")

	local pullRequest: any = config.pullRequest
	assert(typeof(pullRequest) == "table", "pullRequest must be a table")
	assert(typeof(pullRequest.requiredApprovals) == "number", "pullRequest.requiredApprovals must be a number")
	for _, key in
		{
			"dismissStaleApprovals",
			"requireCodeOwnerReview",
			"requireLastPushApproval",
			"requireResolvedThreads",
			"requireExtraApprovalForUnattributedChanges",
		}
	do
		assert(typeof(pullRequest[key]) == "boolean", `pullRequest.{key} must be a boolean`)
	end
	assert(typeof(pullRequest.allowedMergeMethods) == "table", "pullRequest.allowedMergeMethods must be a table")

	local reviewers: any = config.reviewers
	assert(typeof(reviewers) == "table", "reviewers must be a table")
	assert(#reviewers > 0, "at least one reviewer is required")
	for index, reviewer in reviewers do
		local reviewerConfig: any = reviewer
		assert(typeof(reviewerConfig) == "table", `reviewers[{index}] must be a table`)
		assert(typeof(reviewerConfig.team) == "string", `reviewers[{index}].team must be a string`)
		assert(
			typeof(reviewerConfig.minimumApprovals) == "number",
			`reviewers[{index}].minimumApprovals must be a number`
		)
		assert(typeof(reviewerConfig.filePatterns) == "table", `reviewers[{index}].filePatterns must be a table`)
		assert(#reviewerConfig.filePatterns > 0, `reviewers[{index}] must include file patterns`)
	end

	local checks: any = config.requiredChecks
	assert(typeof(checks) == "table", "requiredChecks must be a table")
	assert(#checks > 0, "at least one required check is required")
	for index, check in checks do
		local checkConfig: any = check
		assert(typeof(checkConfig) == "table", `requiredChecks[{index}] must be a table`)
		assert(typeof(checkConfig.context) == "string", `requiredChecks[{index}].context must be a string`)
		if checkConfig.integrationId ~= nil then
			assert(
				typeof(checkConfig.integrationId) == "number",
				`requiredChecks[{index}].integrationId must be a number`
			)
		end
	end

	assert(typeof(config.bypassActors) == "table", "bypassActors must be a table")
	for index, actor in config.bypassActors do
		local actorConfig: any = actor
		assert(typeof(actorConfig) == "table", `bypassActors[{index}] must be a table`)
		assert(typeof(actorConfig.actorType) == "string", `bypassActors[{index}].actorType must be a string`)
		assert(typeof(actorConfig.bypassMode) == "string", `bypassActors[{index}].bypassMode must be a string`)
	end

	return config
end

return readRulesetConfig
