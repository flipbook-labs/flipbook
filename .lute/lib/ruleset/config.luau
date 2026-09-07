local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local CONFIG_PATH = path.resolve(".github/ruleset.json")

local function readConfig(): any
	local config = json.deserialize(fs.readFileToString(CONFIG_PATH))
	assert(typeof(config) == "table", "ruleset config must be a table")

	local repository = config.repository
	assert(typeof(repository) == "table", "repository must be a table")
	for _, key in { "owner", "name", "ruleset", "target", "enforcement" } do
		assert(typeof(repository[key]) == "string", `repository.{key} must be a string`)
	end
	assert(typeof(repository.includeRefs) == "table", "repository.includeRefs must be a table")

	local pullRequest = config.pullRequest
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

	local reviewers = config.reviewers
	assert(typeof(reviewers) == "table", "reviewers must be a table")
	assert(#reviewers > 0, "at least one reviewer is required")
	for index, reviewer in reviewers do
		assert(typeof(reviewer) == "table", `reviewers[{index}] must be a table`)
		assert(typeof(reviewer.team) == "string", `reviewers[{index}].team must be a string`)
		assert(typeof(reviewer.minimumApprovals) == "number", `reviewers[{index}].minimumApprovals must be a number`)
		assert(typeof(reviewer.filePatterns) == "table", `reviewers[{index}].filePatterns must be a table`)
		assert(#reviewer.filePatterns > 0, `reviewers[{index}] must include file patterns`)
	end

	local checks = config.requiredChecks
	assert(typeof(checks) == "table", "requiredChecks must be a table")
	assert(#checks > 0, "at least one required check is required")
	for index, check in checks do
		assert(typeof(check) == "table", `requiredChecks[{index}] must be a table`)
		assert(typeof(check.context) == "string", `requiredChecks[{index}].context must be a string`)
		if check.integrationId ~= nil then
			assert(typeof(check.integrationId) == "number", `requiredChecks[{index}].integrationId must be a number`)
		end
	end

	assert(typeof(config.bypassActors) == "table", "bypassActors must be a table")
	for index, actor in config.bypassActors do
		assert(typeof(actor) == "table", `bypassActors[{index}] must be a table`)
		assert(typeof(actor.actorType) == "string", `bypassActors[{index}].actorType must be a string`)
		assert(typeof(actor.bypassMode) == "string", `bypassActors[{index}].bypassMode must be a string`)
	end

	return config
end

return readConfig
