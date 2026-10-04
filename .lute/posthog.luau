-- Reports release pipeline events to PostHog so release health can be charted
-- next to product telemetry.
--
-- Usage: lute run posthog <check | pending-changes | beta-published | prod-released> [--dry-run]
--
-- Capturing reads POSTHOG_PROJECT_TOKEN, and the prod release annotation also
-- reads POSTHOG_PERSONAL_API_KEY and POSTHOG_PROJECT_ID. --dry-run prints each
-- request instead of sending it and needs none of these.
local FlipbookBatteries = require("@luaupkg/flipbook-batteries@v0.12.0")
local cli = require("@batteries/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local process = require("@std/process")

local annotateAsync = require("@scripts/lib/posthog/annotateAsync")
local captureAsync = require("@scripts/lib/posthog/captureAsync")
local checkPersonalApiKeyAsync = require("@scripts/lib/posthog/checkPersonalApiKeyAsync")
local checkProjectTokenAsync = require("@scripts/lib/posthog/checkProjectTokenAsync")
local types = require("@scripts/lib/posthog/types")

local run = FlipbookBatteries.run

local CHANGES_DIR = ".changes"

local dryRun = false

local function readSecret(name: string): string
	if dryRun then
		return `<{name}>`
	end
	local value = process.env[name]
	assert(value ~= nil and value ~= "", `{name} is not set`)
	return value
end

-- Changewrite's gate reports the version its configured source currently holds.
local function readVersion(): string
	local gate = json.asObject(json.deserialize(assert(run("changewrite", { "gate" }, { captureOutput = true }))))
	local version = if gate then gate.version else nil
	return assert(if typeof(version) == "string" then version else nil, "changewrite gate reported no version")
end

local function readLockedVersion(packageName: string): string
	local pattern = `name = "{packageName:gsub("%-", "%%-")}"%s*\nversion = "([^"]+)"`
	local version = fs.readFileToString("wally.lock"):match(pattern)
	return assert(version, `Could not find {packageName} in wally.lock`)
end

-- Each event reports one commit, so its commit time stands in for when it
-- happened and stays the same across re-runs. `build_hash` matches the
-- BUILD_HASH that `lute run build` bakes into the plugin, so CI events join
-- product events.
local function buildEvent(name: string): types.Event
	local commit = assert(run("git", { "rev-parse", "HEAD" }, { captureOutput = true }))
	local buildHash = assert(run("git", { "rev-parse", "--short", "HEAD" }, { captureOutput = true }))
	local timestamp = assert(run("git", { "log", "-1", "--format=%cI", "HEAD" }, { captureOutput = true }))
	local version = readVersion()

	local properties: { [string]: json.Value } = {
		version = version,
		build_hash = buildHash,
		commit = commit,
	}

	local server = process.env.GITHUB_SERVER_URL
	local repository = process.env.GITHUB_REPOSITORY
	local runId = process.env.GITHUB_RUN_ID
	if server and repository and runId then
		properties.run_url = `{server}/{repository}/actions/runs/{runId}`
	end

	return {
		name = name,
		commit = commit,
		timestamp = timestamp,
		properties = properties,
	}
end

local function check()
	checkProjectTokenAsync(readSecret("POSTHOG_PROJECT_TOKEN"), dryRun)
	print("PostHog accepted the project token")

	if dryRun or process.env.POSTHOG_PERSONAL_API_KEY then
		checkPersonalApiKeyAsync(readSecret("POSTHOG_PERSONAL_API_KEY"), readSecret("POSTHOG_PROJECT_ID"), dryRun)
		print("PostHog accepted the personal API key and project ID")
	end
end

local function reportPendingChanges()
	local total = 0
	for _, entry in fs.listDirectory(CHANGES_DIR) do
		local name = entry.name:lower()
		if entry.type == "file" and path.extname(name) == ".md" and name ~= "readme.md" then
			total += 1
		end
	end

	local event = buildEvent("ci_pending_changes")
	event.properties.total = total
	captureAsync(readSecret("POSTHOG_PROJECT_TOKEN"), event, dryRun)
	print(`Reported {total} pending changes`)
end

local function reportBetaPublished()
	captureAsync(readSecret("POSTHOG_PROJECT_TOKEN"), buildEvent("ci_beta_published"), dryRun)
	print("Reported the beta publish")
end

-- The release event is captured before its annotation. If the annotation
-- fails, a re-run sends the same event again and PostHog drops the duplicate.
local function reportProdReleased()
	local event = buildEvent("ci_prod_released")
	local storyteller = readLockedVersion("flipbook-labs/storyteller")
	local moduleLoader = readLockedVersion("flipbook-labs/module-loader")
	event.properties.storyteller_version = storyteller
	event.properties.module_loader_version = moduleLoader
	captureAsync(readSecret("POSTHOG_PROJECT_TOKEN"), event, dryRun)

	local version = event.properties.version
	annotateAsync(
		readSecret("POSTHOG_PERSONAL_API_KEY"),
		readSecret("POSTHOG_PROJECT_ID"),
		`Flipbook v{version} released (Storyteller {storyteller}, ModuleLoader {moduleLoader})`,
		dryRun
	)
	print(`Reported the v{version} release`)
end

-- The battery's subcommands only parse arguments, so each one's handler sits
-- beside it here and runs once parsing picks it.
local COMMANDS = {
	{ name = "check", help = "Confirm PostHog accepts the credentials without sending any data", run = check },
	{
		name = "pending-changes",
		help = "Report how many change entries are waiting on a release",
		run = reportPendingChanges,
	},
	{
		name = "beta-published",
		help = "Report a beta build publishing to the Creator Store",
		run = reportBetaPublished,
	},
	{ name = "prod-released", help = "Report a release and annotate it", run = reportProdReleased },
}

local args = cli.parser()
args:add("script", "positional", {
	help = "Path to the script being run. Provided automatically by Lute",
})
for _, command in COMMANDS do
	args:subcommand(command.name, { help = command.help })
		:add("dry-run", "flag", { help = "Print each request instead of sending it" })
end
args:parse({ ... })

local selected, commandArgs = args:selected()
assert(selected and commandArgs, `Expected a command:\n{args:help()}`)
dryRun = commandArgs:has("dry-run")

for _, command in COMMANDS do
	if command.name == selected then
		command.run()
	end
end
