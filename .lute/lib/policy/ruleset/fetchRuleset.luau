local json = require("@std/json")

local repositoryPath = require("@scripts/lib/policy/ruleset/repositoryPath")
local requestGitHub = require("@scripts/lib/policy/ruleset/requestGitHub")

local function fetchRuleset(config: any, rulesetId: number): any
	return json.deserialize(requestGitHub({ repositoryPath(config) .. `/rulesets/{rulesetId}` }))
end

return fetchRuleset
