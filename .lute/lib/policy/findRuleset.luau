local json = require("@std/json")

local repositoryPath = require("@scripts/lib/policy/repositoryPath")
local requestGitHub = require("@scripts/lib/policy/requestGitHub")

local function findRuleset(config: any, request: (({ string }) -> string)?): any
	local sendRequest = request or requestGitHub
	local rulesets = json.deserialize(sendRequest({ repositoryPath(config) .. "/rulesets" })) :: any
	for _, ruleset in rulesets do
		if ruleset.name == config.repository.ruleset then
			return ruleset
		end
	end
	assert(false, `ruleset "{config.repository.ruleset}" was not found`)
end

return findRuleset
