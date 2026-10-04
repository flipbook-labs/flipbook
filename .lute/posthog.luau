-- Reports release pipeline events to PostHog so release health can be charted
-- next to product telemetry.
--
-- Usage: lute run posthog <pending-changes | beta-published | prod-released> [--dry-run]
--
-- Capturing reads POSTHOG_PROJECT_TOKEN, and the prod release annotation also
-- reads POSTHOG_PERSONAL_API_KEY and POSTHOG_PROJECT_ID. POSTHOG_HOST and
-- POSTHOG_APP_HOST override the US cloud hosts. --dry-run prints each request
-- instead of sending it and needs none of these.
local fs = require("@std/fs")
local json = require("@std/json")
local process = require("@std/process")

local countPendingChanges = require("@scripts/lib/countPendingChanges")
local postHog = require("@scripts/lib/postHog")

local CHANGES_DIR = ".changes"

-- `lute run` passes the script name first, then the arguments after it.
local args = { ... }
local subcommand = args[2]
local options: postHog.Options = { dryRun = table.find(args, "--dry-run") ~= nil }

local function git(gitArgs: { string }): string
	local command = { "git" }
	table.move(gitArgs, 1, #gitArgs, 2, command)
	local result = process.run(command)
	assert(result.ok, `git {table.concat(gitArgs, " ")} failed: {result.stderr}`)
	return (result.stdout:gsub("%s+$", ""))
end

local function readVersion(): string
	local version = fs.readFileToString("changewrite.toml"):match('current%s*=%s*"([^"]+)"')
	return assert(version, "Could not read the current version from changewrite.toml")
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

	postHog.capture(options, "ci_pending_changes", properties)
	print(`Reported {counts.total} pending changes`)
end

local function reportBetaPublished()
	postHog.capture(options, "ci_beta_published", getBuildProperties())
	print("Reported the beta publish")
end

local function reportProdReleased()
	local properties = getBuildProperties()
	local storyteller = readLockedVersion("flipbook-labs/storyteller")
	local moduleLoader = readLockedVersion("flipbook-labs/module-loader")
	properties.storyteller_version = storyteller
	properties.module_loader_version = moduleLoader

	postHog.capture(options, "ci_prod_released", properties)
	postHog.annotate(
		options,
		`Flipbook v{properties.version} released (Storyteller {storyteller}, ModuleLoader {moduleLoader})`
	)
	print(`Reported the v{properties.version} release`)
end

if subcommand == "pending-changes" then
	reportPendingChanges()
elseif subcommand == "beta-published" then
	reportBetaPublished()
elseif subcommand == "prod-released" then
	reportProdReleased()
else
	error(`Expected pending-changes, beta-published, or prod-released, got {subcommand or "nothing"}`, 0)
end
