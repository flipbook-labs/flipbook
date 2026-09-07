local json = require("@std/json")

local requestGitHub = require("@scripts/lib/policy/ruleset/requestGitHub")

local function resolveTeamId(config: any, teamSlug: string): number
	local ok, response = pcall(requestGitHub, { `orgs/{config.repository.owner}/teams/{teamSlug}` })
	assert(ok, `team @{config.repository.owner}/{teamSlug} must exist before the policy can be planned or applied`)
	local team = json.deserialize(response :: string) :: any
	assert(typeof(team.id) == "number", `GitHub did not return an id for team {teamSlug}`)
	return team.id
end

return resolveTeamId
