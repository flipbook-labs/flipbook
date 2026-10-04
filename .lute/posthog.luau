-- Reports release pipeline events to PostHog so release health can be charted
-- next to product telemetry.
--
-- Usage: lute run posthog <check | pending-changes | beta-published | prod-released> [--dry-run]
--
-- Capturing reads POSTHOG_PROJECT_TOKEN, and the prod release annotation also
-- reads POSTHOG_PERSONAL_API_KEY and POSTHOG_PROJECT_ID. POSTHOG_HOST and
-- POSTHOG_APP_HOST override the US cloud hosts. --dry-run prints each request
-- instead of sending it and needs none of these.
--
-- `check` confirms PostHog accepts the credentials without sending any data.
-- It checks the personal API key only when POSTHOG_PERSONAL_API_KEY is set.
local cli = require("@batteries/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local process = require("@std/process")

local countPendingChanges = require("@scripts/lib/countPendingChanges")
local postHog = require("@scripts/lib/postHog")

local CHANGES_DIR = ".changes"

local args = cli.parser()
args:add("script", "positional", {
	help = "Path to the script being run. Provided automatically by Lute",
})

local COMMANDS = {
	{ "check", "Confirm PostHog accepts the credentials without sending any data" },
	{ "pending-changes", "Report how many change entries are waiting on a release" },
	{ "beta-published", "Report a beta build publishing to the Creator Store" },
	{ "prod-released", "Report a release and annotate it" },
}
for _, entry in COMMANDS do
	local command = args:subcommand(entry[1], { help = entry[2] })
	command:add("dry-run", "flag", { help = "Print each request instead of sending it" })
end

args:parse({ ... })

local subcommand, commandArgs = args:selected()
assert(subcommand and commandArgs, `Expected a command:\n{args:help()}`)
local options: postHog.Options = { dryRun = commandArgs:has("dry-run") }

local function git(gitArgs: { string }): string
	local command = { "git" }
	table.move(gitArgs, 1, #gitArgs, 2, command)
	local result = process.run(command)
	assert(result.ok, `git {table.concat(gitArgs, " ")} failed: {result.stderr}`)
	return (result.stdout:gsub("%s+$", ""))
end

-- Changewrite's gate reports the version its configured source currently holds.
local function readVersion(): string
	local result = process.run({ "changewrite", "gate" })
	assert(result.ok, `changewrite gate failed: {result.stderr}`)
	local gate = json.asObject(json.deserialize(result.stdout))
	local version = if gate then gate.version else nil
	return assert(if typeof(version) == "string" then version else nil, "changewrite gate reported no version")
end

local function readLockedVersion(packageName: string): string
	local pattern = `name = "{packageName:gsub("%-", "%%-")}"%s*\nversion = "([^"]+)"`
	local version = fs.readFileToString("wally.lock"):match(pattern)
	return assert(version, `Could not find {packageName} in wally.lock`)
end

-- Properties every event carries. `build_hash` matches the BUILD_HASH that
-- `lute run build` bakes into the plugin, so CI events join product events.
local function getBuildProperties(): { [string]: json.Value }
	local properties: { [string]: json.Value } = {
		version = readVersion(),
		build_hash = git({ "rev-parse", "--short", "HEAD" }),
		commit = git({ "rev-parse", "HEAD" }),
	}

	local server, repository, runId =
		process.env.GITHUB_SERVER_URL, process.env.GITHUB_REPOSITORY, process.env.GITHUB_RUN_ID
	if server and repository and runId then
		properties.run_url = `{server}/{repository}/actions/runs/{runId}`
	end

	return properties
end

-- Each event reports one commit, so the commit identifies it and its commit
-- time stands in for when it happened. Both stay the same across re-runs.
local function buildEvent(name: string, properties: { [string]: json.Value }): postHog.Event
	return {
		name = name,
		dedupeKey = properties.commit :: string,
		timestamp = git({ "log", "-1", "--format=%cI", "HEAD" }),
		properties = properties,
	}
end

local function toPropertyKey(prefix: string, name: string): string
	return `{prefix}_{name:lower():gsub("[^%w]+", "_")}`
end

local function reportPendingChanges()
	local counts = countPendingChanges(CHANGES_DIR)
	local properties = getBuildProperties()
	properties.total = counts.total
	for category, count in counts.byCategory do
		properties[toPropertyKey("category", category)] = count
	end
	for bump, count in counts.byBump do
		properties[toPropertyKey("bump", bump)] = count
	end

	postHog.capture(options, buildEvent("ci_pending_changes", properties))
	print(`Reported {counts.total} pending changes`)
end

local function reportBetaPublished()
	postHog.capture(options, buildEvent("ci_beta_published", getBuildProperties()))
	print("Reported the beta publish")
end

local function check()
	postHog.checkProjectToken(options)
	print("PostHog accepted the project token")

	if options.dryRun or process.env.POSTHOG_PERSONAL_API_KEY then
		postHog.checkPersonalApiKey(options)
		print("PostHog accepted the personal API key and project ID")
	end
end

-- The release event is captured before its annotation. If the annotation
-- fails, a re-run sends the same event again and PostHog drops the duplicate.
local function reportProdReleased()
	local properties = getBuildProperties()
	local storyteller = readLockedVersion("flipbook-labs/storyteller")
	local moduleLoader = readLockedVersion("flipbook-labs/module-loader")
	properties.storyteller_version = storyteller
	properties.module_loader_version = moduleLoader

	postHog.capture(options, buildEvent("ci_prod_released", properties))
	postHog.annotate(
		options,
		`Flipbook v{properties.version} released (Storyteller {storyteller}, ModuleLoader {moduleLoader})`
	)
	print(`Reported the v{properties.version} release`)
end

if subcommand == "check" then
	check()
elseif subcommand == "pending-changes" then
	reportPendingChanges()
elseif subcommand == "beta-published" then
	reportBetaPublished()
elseif subcommand == "prod-released" then
	reportProdReleased()
end
