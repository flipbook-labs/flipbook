local cli = require("@luaupkg/lute@v1.0.0/batteries/cli")
local fs = require("@std/fs")

local github = require("@scripts/lib/ruleset/github")
local payload = require("@scripts/lib/ruleset/payload")
local plan = require("@scripts/lib/ruleset/plan")
local readConfig = require("@scripts/lib/ruleset/config")

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
if action == "validate" then
	print(`Ruleset config is valid ({#config.reviewers} reviewers, {#config.requiredChecks} required checks).`)
else
	local ruleset = github.findRuleset(config)
	local desired = payload.build(config)
	local live = payload.normalize(github.fetchRuleset(config, ruleset.id))
	local hasDrift = plan.show(desired, live)

	if action == "apply" and hasDrift then
		local payloadPath = plan.writeTemporaryJson("apply", desired)
		github.updateRuleset(config, ruleset.id, tostring(payloadPath))
		fs.remove(payloadPath)
		print("Ruleset applied.")
	end
end
