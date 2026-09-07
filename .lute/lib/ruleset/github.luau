local json = require("@std/json")
local process = require("@std/process")

local function trim(value: string): string
	return assert(value:match("^%s*(.-)%s*$"))
end

local function request(arguments: { string }): string
	local command = { "gh", "api", "--header", "X-GitHub-Api-Version: 2026-03-10" }
	for _, argument in arguments do
		table.insert(command, argument)
	end

	local result = process.run(command)
	assert(result.ok, trim(result.stderr))
	return trim(result.stdout)
end

local function repositoryPath(config: any): string
	return `repos/{config.repository.owner}/{config.repository.name}`
end

local function resolveTeamId(config: any, teamSlug: string): number
	local ok, response = pcall(request, { `orgs/{config.repository.owner}/teams/{teamSlug}` })
	assert(ok, `team @{config.repository.owner}/{teamSlug} must exist before the ruleset can be planned or applied`)
	local team = json.deserialize(response :: string) :: any
	assert(typeof(team.id) == "number", `GitHub did not return an id for team {teamSlug}`)
	return team.id
end

local function findRuleset(config: any): any
	local rulesets = json.deserialize(request({ repositoryPath(config) .. "/rulesets" })) :: any
	for _, ruleset in rulesets do
		if ruleset.name == config.repository.ruleset then
			return ruleset
		end
	end
	assert(false, `ruleset "{config.repository.ruleset}" was not found`)
end

local function fetchRuleset(config: any, rulesetId: number): any
	return json.deserialize(request({ repositoryPath(config) .. `/rulesets/{rulesetId}` }))
end

local function updateRuleset(config: any, rulesetId: number, payloadPath: string)
	request({
		"--method",
		"PUT",
		repositoryPath(config) .. `/rulesets/{rulesetId}`,
		"--input",
		payloadPath,
	})
end

return {
	resolveTeamId = resolveTeamId,
	findRuleset = findRuleset,
	fetchRuleset = fetchRuleset,
	updateRuleset = updateRuleset,
}
