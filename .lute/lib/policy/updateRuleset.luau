local repositoryPath = require("@scripts/lib/policy/repositoryPath")
local requestGitHub = require("@scripts/lib/policy/requestGitHub")

local function updateRuleset(config: any, rulesetId: number, payloadPath: string, request: (({ string }) -> string)?)
	local sendRequest = request or requestGitHub
	sendRequest({
		"--method",
		"PUT",
		repositoryPath(config) .. `/rulesets/{rulesetId}`,
		"--input",
		payloadPath,
	})
end

return updateRuleset
