local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local CONFIG_PATH = path.resolve(".github/ruleset.json")

local function trim(value: string): string
	return value:match("^%s*(.-)%s*$") :: string
end

local function run(arguments: { string }): string
	local result = process.run(arguments)
	if not result.ok then
		error(trim(result.stderr), 2)
	end
	return trim(result.stdout)
end

local function gh(arguments: { string }): string
	local command = { "gh", "api", "--header", "X-GitHub-Api-Version: 2026-03-10" }
	for _, argument in arguments do
		table.insert(command, argument)
	end
	return run(command)
end

local function expect(value: any, expectedType: string, name: string): any
	assert(typeof(value) == expectedType, `{name} must be a {expectedType}`)
	return value
end

local function readConfig(): any
	assert(fs.exists(CONFIG_PATH), `missing ruleset config at {CONFIG_PATH}`)
	return json.deserialize(fs.readFileToString(CONFIG_PATH))
end

local function validateConfig(config: any)
	local repository = expect(config.repository, "table", "repository")
	for _, key in { "owner", "name", "ruleset", "target", "enforcement" } do
		expect(repository[key], "string", `repository.{key}`)
	end
	expect(repository.includeRefs, "table", "repository.includeRefs")

	local pullRequest = expect(config.pullRequest, "table", "pullRequest")
	expect(pullRequest.requiredApprovals, "number", "pullRequest.requiredApprovals")
	for _, key in
		{
			"dismissStaleApprovals",
			"requireCodeOwnerReview",
			"requireLastPushApproval",
			"requireResolvedThreads",
			"requireExtraApprovalForUnattributedChanges",
		}
	do
		expect(pullRequest[key], "boolean", `pullRequest.{key}`)
	end
	expect(pullRequest.allowedMergeMethods, "table", "pullRequest.allowedMergeMethods")

	local reviewers = expect(config.reviewers, "table", "reviewers")
	assert(#reviewers > 0, "at least one reviewer is required")
	for index, reviewer in reviewers do
		expect(reviewer.team, "string", `reviewers[{index}].team`)
		expect(reviewer.minimumApprovals, "number", `reviewers[{index}].minimumApprovals`)
		expect(reviewer.filePatterns, "table", `reviewers[{index}].filePatterns`)
		assert(#reviewer.filePatterns > 0, `reviewers[{index}] must include file patterns`)
	end

	local checks = expect(config.requiredChecks, "table", "requiredChecks")
	assert(#checks > 0, "at least one required check is required")
	for index, check in checks do
		expect(check.context, "string", `required_checks[{index}].context`)
		if check.integrationId ~= nil then
			expect(check.integrationId, "number", `requiredChecks[{index}].integrationId`)
		end
	end

	for index, actor in expect(config.bypassActors, "table", "bypassActors") do
		expect(actor.actorType, "string", `bypassActors[{index}].actorType`)
		expect(actor.bypassMode, "string", `bypassActors[{index}].bypassMode`)
	end
end

local function repositoryPath(config: any): string
	return `repos/{config.repository.owner}/{config.repository.name}`
end

local function resolveTeamId(config: any, teamSlug: string): number
	local ok, response = pcall(gh, { `orgs/{config.repository.owner}/teams/{teamSlug}` })
	assert(ok, `team @{config.repository.owner}/{teamSlug} must exist before the ruleset can be planned or applied`)
	local team = json.deserialize(response :: string) :: any
	assert(typeof(team.id) == "number", `GitHub did not return an id for team {teamSlug}`)
	return team.id
end

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

local function buildPayload(config: any): any
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

local function findRuleset(config: any): any
	local rulesets = json.deserialize(gh({ repositoryPath(config) .. "/rulesets" })) :: any
	for _, ruleset in rulesets do
		if ruleset.name == config.repository.ruleset then
			return ruleset
		end
	end
	error(`ruleset "{config.repository.ruleset}" was not found`)
end

local function fetchRuleset(config: any, rulesetId: number): any
	return json.deserialize(gh({ repositoryPath(config) .. `/rulesets/{rulesetId}` }))
end

local function normalizeLiveRuleset(live: any): any
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

local function writeTemporaryJson(name: string, value: any): path.Path
	local filePath = path.join(system.tmpdir(), `flipbook-ruleset-{name}-{math.random(0, 0xffffff)}.json`)
	fs.writeStringToFile(filePath, json.serialize(value, true) .. "\n")
	return filePath
end

local function showPlan(desired: any, live: any): boolean
	if json.serialize(desired) == json.serialize(live) then
		print("Ruleset is in sync.")
		return false
	end

	local livePath = writeTemporaryJson("live", live)
	local desiredPath = writeTemporaryJson("desired", desired)
	print("Ruleset drift detected:")
	process.run({ "git", "diff", "--no-index", "--", tostring(livePath), tostring(desiredPath) }, {
		stdio = "inherit",
	})
	fs.remove(livePath)
	fs.remove(desiredPath)
	return true
end

local parser = cli.parser()
parser:add("action", "positional", { help = 'Can be "validate", "plan", or "apply"', default = "plan" })
parser:add("confirm", "flag", { help = "Required to apply changes to GitHub" })

local arguments = { ... }
table.remove(arguments, 1)
parser:parse(arguments)

local action = parser:get("action")
assert(action == "validate" or action == "plan" or action == "apply", `unsupported action "{action}"`)
if action == "apply" then
	assert(parser:has("confirm"), "refusing to apply without --confirm")
end

local config = readConfig()
validateConfig(config)
if action == "validate" then
	print(`Ruleset config is valid ({#config.reviewers} reviewers, {#config.requiredChecks} required checks).`)
	return
end

local ruleset = findRuleset(config)
local desired = buildPayload(config)
local live = normalizeLiveRuleset(fetchRuleset(config, ruleset.id))
local hasDrift = showPlan(desired, live)

if action == "apply" then
	if not hasDrift then
		return
	end

	local payloadPath = writeTemporaryJson("apply", desired)
	gh({
		"--method",
		"PUT",
		repositoryPath(config) .. `/rulesets/{ruleset.id}`,
		"--input",
		tostring(payloadPath),
	})
	fs.remove(payloadPath)
	print("Ruleset applied.")
end
