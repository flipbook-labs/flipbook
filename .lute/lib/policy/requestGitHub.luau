local process = require("@std/process")

local function trim(value: string): string
	return assert(value:match("^%s*(.-)%s*$"))
end

local function requestGitHub(arguments: { string }): string
	local command = { "gh", "api", "--header", "X-GitHub-Api-Version: 2026-03-10" }
	for _, argument in arguments do
		table.insert(command, argument)
	end

	local result = process.run(command)
	assert(result.ok, trim(result.stderr))
	return trim(result.stdout)
end

return requestGitHub
