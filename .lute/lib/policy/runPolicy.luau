local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local fs = require("@std/fs")

local buildRulesetPayload = require("@scripts/lib/policy/buildRulesetPayload")
local fetchRuleset = require("@scripts/lib/policy/fetchRuleset")
local findRuleset = require("@scripts/lib/policy/findRuleset")
local normalizeRuleset = require("@scripts/lib/policy/normalizeRuleset")
local readRulesetConfig = require("@scripts/lib/policy/readRulesetConfig")
local showRulesetPlan = require("@scripts/lib/policy/showRulesetPlan")
local updateRuleset = require("@scripts/lib/policy/updateRuleset")
local writeTemporaryJson = require("@scripts/lib/policy/writeTemporaryJson")

local function runPolicy(arguments: { string }, dependencies: any?): any
	local deps: any = dependencies or {}
	local parser = cli.parser()
	parser:add("action", "positional", { help = 'Can be "validate", "plan", or "apply"', default = "validate" })
	parser:add("confirm", "flag", { help = "Required to apply changes to GitHub" })
	parser:parse(arguments)

	local action = parser:get("action")
	assert(action == "validate" or action == "plan" or action == "apply", `unsupported action "{action}"`)
	if action == "apply" then
		assert(parser:has("confirm"), "refusing to apply without --confirm")
	end

	local readConfig = (deps.readRulesetConfig or readRulesetConfig) :: () -> any
	local config = readConfig()
	if action == "validate" then
		print(`Repository policy is valid ({#config.reviewers} reviewers, {#config.requiredChecks} required checks).`)
		return { action = action, hasDrift = false, applied = false }
	end

	local find = (deps.findRuleset or findRuleset) :: (any) -> any
	local build = (deps.buildRulesetPayload or buildRulesetPayload) :: (any) -> any
	local fetch = (deps.fetchRuleset or fetchRuleset) :: (any, number) -> any
	local normalize = (deps.normalizeRuleset or normalizeRuleset) :: (any) -> any
	local showPlan = (deps.showRulesetPlan or showRulesetPlan) :: (any, any) -> boolean
	local ruleset = find(config)
	local desired = build(config)
	local live = normalize(fetch(config, ruleset.id))
	local hasDrift = showPlan(desired, live)
	local applied = false

	if action == "apply" and hasDrift then
		local writeJson = (deps.writeTemporaryJson or writeTemporaryJson) :: (string, any) -> any
		local update = (deps.updateRuleset or updateRuleset) :: (any, number, string) -> ()
		local remove = (deps.remove or fs.remove) :: (any) -> ()
		local payloadPath = writeJson("apply", desired)
		update(config, ruleset.id, tostring(payloadPath))
		remove(payloadPath)
		print("Ruleset applied.")
		applied = true
	end

	return { action = action, hasDrift = hasDrift, applied = applied }
end

return runPolicy
