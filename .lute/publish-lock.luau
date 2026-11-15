-- Checks that decide when CI posts Changewrite's `publish-lock` status. That
-- status is a required check on main. The Release workflow fails it on the
-- publish pull request while regenerating that pull request, and the Publish
-- Lock workflow passes it on every other pull request.
--
-- Usage: lute run publish-lock <is-publish-head | record-main | main-moved>
--
-- Each command writes its answer as a step output to the file named by
-- GITHUB_OUTPUT, or prints it when that's unset, so it can also run locally.
-- Commands that call the GitHub API read GITHUB_REPOSITORY (owner/name) and
-- need `gh` to be signed in, through GH_TOKEN in CI.
--
-- - is-publish-head: whether HEAD_SHA is the publish branch's current commit.
--   A commit status belongs to a commit, not to a pull request, so a pull
--   request whose head is that commit, such as one from a fork branch pushed
--   from it, must not get a passing status. That status would unlock the
--   publish pull request too.
-- - record-main: the commit checked out in the current directory, which the
--   Release workflow refreshes the publish pull request from.
-- - main-moved: whether main has moved past REFRESHED_SHA, the commit that
--   record-main wrote. A push during a Release run starts a newer run whose
--   lock can land before this run's unlock, which then overwrites it. When
--   main has moved, the publish pull request is missing that change, so the
--   Release workflow locks it again.
local fs = require("@std/fs")
local process = require("@std/process")

local PUBLISH_BRANCH = "publish-next-version"
local BASE_BRANCH = "main"

local function assertEnv(name: string): string
	local value = process.env[name]
	assert(value ~= nil and value ~= "", `{name} must be set`)
	return value
end

local function run(command: { string }): string
	local result = process.run(command)
	assert(result.ok, `{table.concat(command, " ")} failed: {result.stderr}`)
	return (result.stdout:gsub("%s+$", ""))
end

local function writeOutput(name: string, value: string)
	local line = `{name}={value}`
	print(line)

	local outputPath = process.env.GITHUB_OUTPUT
	if outputPath and outputPath ~= "" then
		local file = fs.open(outputPath, "a")
		fs.write(file, line .. "\n")
		fs.close(file)
	end
end

-- Returns nil when the branch doesn't exist, such as when no publish pull
-- request is open. Any other API failure stops the script, so a network error
-- can't be mistaken for a missing branch.
local function readBranchHead(branch: string): string?
	local repo = assertEnv("GITHUB_REPOSITORY")
	local result = process.run({
		"gh",
		"api",
		`repos/{repo}/git/ref/heads/{branch}`,
		"--jq",
		".object.sha",
	})
	if result.ok then
		return (result.stdout:gsub("%s+$", ""))
	end
	if result.stderr:find("HTTP 404", 1, true) then
		return nil
	end
	error(`Could not read the head of {branch}: {result.stderr}`)
end

local function boolString(value: boolean): string
	return if value then "true" else "false"
end

local commands: { [string]: () -> () } = {
	["is-publish-head"] = function()
		local headSha = assertEnv("HEAD_SHA")
		writeOutput("is-publish-head", boolString(readBranchHead(PUBLISH_BRANCH) == headSha))
	end,

	["record-main"] = function()
		writeOutput("sha", run({ "git", "rev-parse", "HEAD" }))
	end,

	["main-moved"] = function()
		local refreshedSha = assertEnv("REFRESHED_SHA")
		local mainSha = assert(readBranchHead(BASE_BRANCH), `{BASE_BRANCH} does not exist`)
		writeOutput("moved", boolString(mainSha ~= refreshedSha))
	end,
}

-- The first argument is the script's own name.
local _, name = ...
local command = commands[name]
if not command then
	error("Usage: lute run publish-lock <is-publish-head | record-main | main-moved>")
end
command()
