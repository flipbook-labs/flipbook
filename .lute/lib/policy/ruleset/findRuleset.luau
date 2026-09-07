local json = require("@std/json")

local repositoryPath = require("@scripts/lib/policy/ruleset/repositoryPath")
local requestGitHub = require("@scripts/lib/policy/ruleset/requestGitHub")

local function findRuleset(config: any): any
	local rulesets = json.deserialize(requestGitHub({ repositoryPath(config) .. "/rulesets" })) :: any
	for _, ruleset in rulesets do
		if ruleset.name == config.repository.ruleset then
			return ruleset
		end
	end
	assert(false, `ruleset "{config.repository.ruleset}" was not found`)
end

return findRuleset
