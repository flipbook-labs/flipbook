local json = require("@std/json")

local repositoryPath = require("@scripts/lib/policy/repositoryPath")
local requestGitHub = require("@scripts/lib/policy/requestGitHub")

local function fetchRuleset(config: any, rulesetId: number, request: (({ string }) -> string)?): any
	local sendRequest = request or requestGitHub
	return json.deserialize(sendRequest({ repositoryPath(config) .. `/rulesets/{rulesetId}` }))
end

return fetchRuleset
