local repositoryPath = require("@scripts/lib/policy/ruleset/repositoryPath")
local requestGitHub = require("@scripts/lib/policy/ruleset/requestGitHub")

local function updateRuleset(config: any, rulesetId: number, payloadPath: string)
	requestGitHub({
		"--method",
		"PUT",
		repositoryPath(config) .. `/rulesets/{rulesetId}`,
		"--input",
		payloadPath,
	})
end

return updateRuleset
