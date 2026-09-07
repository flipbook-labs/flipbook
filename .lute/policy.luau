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

local parser = cli.parser()
parser:add("action", "positional", { help = 'Can be "validate", "plan", or "apply"', default = "validate" })
parser:add("confirm", "flag", { help = "Required to apply changes to GitHub" })

local arguments = { ... }
table.remove(arguments, 1)
parser:parse(arguments)

local action = parser:get("action")
assert(action == "validate" or action == "plan" or action == "apply", `unsupported action "{action}"`)
if action == "apply" then
	assert(parser:has("confirm"), "refusing to apply without --confirm")
end

local config = readRulesetConfig()
if action == "validate" then
	print(`Repository policy is valid ({#config.reviewers} reviewers, {#config.requiredChecks} required checks).`)
else
	local ruleset = findRuleset(config)
	local desired = buildRulesetPayload(config)
	local live = normalizeRuleset(fetchRuleset(config, ruleset.id))
	local hasDrift = showRulesetPlan(desired, live)

	if action == "apply" and hasDrift then
		local payloadPath = writeTemporaryJson("apply", desired)
		updateRuleset(config, ruleset.id, tostring(payloadPath))
		fs.remove(payloadPath)
		print("Ruleset applied.")
	end
end
