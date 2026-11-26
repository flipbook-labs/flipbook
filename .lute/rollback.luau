--[[
	Rolls a Flipbook plugin on the Creator Store back to an earlier build, and
	reports whether prod is currently rolled back.

	Usage:
	  lute run rollback restore --channel <prod | beta> [--version <version>] [--dry-run]
	  lute run rollback banner

	- restore, for prod: publishes the Flipbook.rbxm attached to an earlier
	  GitHub release to the prod asset, then marks that release as Latest, the
	  release GitHub badges on the repository page. The publish pull request
	  uses Latest to tell that a rollback is in effect, through
	  readRollbackState in .lute/lib/releases/. --version names the
	  release by tag, such as v2.4.0. Without it, the release before the current
	  Latest is restored, so each run steps back one more release. The
	  restored tag is also written as the `tag` step output.
	- restore, for beta: beta builds have no releases, so this asks Open Cloud to
	  publish an earlier version of the dev asset again as a new version.
	  --version is that asset version's number. Without it, the version before
	  the latest is restored.

	  --dry-run prints what restore would do and changes nothing on the Creator
	  Store or GitHub. restore reads ROBLOX_API_KEY.
	- banner: while prod is rolled back, a caution admonition for the top of
	  the publish pull request's body, which release.yml writes for the next
	  release. Otherwise, an empty string. The admonition ends with a blank
	  line, so the body can follow it directly. It prints the banner, and also
	  writes it as the `banner` step output to the file named by GITHUB_OUTPUT
	  when that's set. The next release becomes Latest and clears it.

	`banner` and prod restores read GITHUB_REPOSITORY (owner/name) and need `gh`
	to be signed in, through GH_TOKEN in CI.
]]
local Assets = require("@lpm/open-cloud-assets@v0.2.0")
local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local process = require("@std/process")

local assets = require("@scripts/lib/creator-store/assets")
local createOpenCloudClient = require("@scripts/lib/creator-store/createOpenCloudClient")
local project = require("@repo/project")
local publishPluginAsync = require("@scripts/lib/creator-store/publishPluginAsync")
local readLatestReleaseTag = require("@scripts/lib/releases/readLatestReleaseTag")
local readPublishedReleases = require("@scripts/lib/releases/readPublishedReleases")
local readRollbackState = require("@scripts/lib/releases/readRollbackState")

local run = FlipbookBatteries.run

type AssetVersion = {
	number: number,
	createTime: string,
}

local function assertEnv(name: string): string
	local value = process.env[name]
	assert(value ~= nil and value ~= "", `{name} must be set`)
	return value
end

-- Every value uses GitHub's delimiter syntax, which keeps blank lines.
local function writeOutput(name: string, value: string)
	print(`{name}={value}`)

	local outputPath = process.env.GITHUB_OUTPUT
	if outputPath and outputPath ~= "" then
		local file = fs.open(outputPath, "a")
		fs.write(file, `{name}<<ROLLBACK_EOF\n{value}\nROLLBACK_EOF\n`)
		fs.close(file)
	end
end

-- Picks the release to restore: the one named by tag, or the one before the
-- current Latest release.
local function chooseRelease(repo: string, requestedTag: string?): string
	local published = readPublishedReleases(repo)

	if requestedTag then
		for _, release in published do
			if release.tag == requestedTag then
				return requestedTag
			end
		end
		error(`{requestedTag} is not a published release`, 0)
	end

	local latestTag = assert(readLatestReleaseTag(repo), "The repository has no Latest release to step back from")
	for index, release in published do
		if release.tag == latestTag then
			local previous = published[index - 1]
			assert(previous, `No published release comes before {latestTag}`)
			return previous.tag
		end
	end
	error(`The Latest release, {latestTag}, is not among the published releases`, 0)
end

-- The release's own Flipbook.rbxm is published to the prod asset the same
-- way a release is.
local function restoreProd(requested: string?, dryRun: boolean)
	local apiKey = assertEnv("ROBLOX_API_KEY")
	local repo = assertEnv("GITHUB_REPOSITORY")
	local tag = chooseRelease(repo, requested)
	print(`Republishing the Flipbook.rbxm attached to {tag} to the prod asset`)
	writeOutput("tag", tag)

	if dryRun then
		return
	end

	run("gh", {
		"release",
		"download",
		tag,
		"--pattern",
		project.PLUGIN_FILENAME,
		"--clobber",
	})
	publishPluginAsync(project.PLUGIN_FILENAME, "prod", apiKey)
	run("gh", {
		"release",
		"edit",
		tag,
		"--latest",
	})
	print(`Restored {tag} and marked it as the Latest release`)
end

-- Versions are named by path, as in "assets/123/versions/16".
local function parseAssetVersion(version: Assets.AssetVersion): AssetVersion
	local versionPath = assert(version.path, "The asset version has no path")
	local number = tonumber(versionPath:match("/versions/(%d+)$"))
	return {
		number = assert(number, `Unexpected version path {versionPath}`),
		createTime = assert(version.createTime, "The asset version has no creation time"),
	}
end

local function restoreBeta(requested: string?, dryRun: boolean)
	local client = createOpenCloudClient(assertEnv("ROBLOX_API_KEY"))
	-- Beta builds publish to the dev asset.
	local assetId = assets.ASSETS[assets.ASSET_NAMES_BY_CHANNEL[assets.ChannelName.Beta]].assetId

	-- The versions list starts with the newest version.
	local response = Assets.listAssetVersions(client, { assetId = assetId, maxPageSize = 2 })
	local recent: { AssetVersion } = {}
	for _, version in response.assetVersions or {} do
		table.insert(recent, parseAssetVersion(version))
	end
	local latest = assert(recent[1], `Asset {assetId} has no versions`)

	local target: AssetVersion
	if requested then
		local number = tonumber(requested)
		assert(number and number % 1 == 0, `bad value for version (expected a whole number, got "{requested}")`)
		target = parseAssetVersion(Assets.getAssetVersion(client, { assetId = assetId, versionNumber = number }))
	else
		target = assert(recent[2], `Asset {assetId} has no earlier version to roll back to`)
	end
	assert(
		target.number < latest.number,
		`Version {target.number} is not older than the latest version, {latest.number}`
	)

	print(`Rolling the dev asset ({assetId}) back from version {latest.number} to {target.number}`)
	if dryRun then
		return
	end

	local restored = Assets.rollbackAssetVersion(client, {
		assetId = assetId,
		body = { assetVersion = `assets/{assetId}/versions/{target.number}` },
	})
	print(`Published version {target.number} again as {restored.path}`)
end

local function restore(commandArgs: cli.Parser)
	local channel = assert(commandArgs:get("channel"))
	local version = commandArgs:get("version")
	local requested = if version and version ~= "" then version else nil
	local dryRun = commandArgs:has("dry-run")

	if channel == "prod" then
		restoreProd(requested, dryRun)
	elseif channel == "beta" then
		restoreBeta(requested, dryRun)
	else
		error(`bad value for channel (must be "prod" or "beta", got "{channel}")`, 0)
	end
end

local function banner()
	local state = readRollbackState(assertEnv("GITHUB_REPOSITORY"))
	if state == nil then
		writeOutput("banner", "")
		return
	end

	writeOutput(
		"banner",
		table.concat({
			"> [!CAUTION]",
			`> Flipbook is rolled back to {state.restoredTag} on the Creator Store after a problem with {state.newestTag}.`,
			"> Merging this PR publishes a release that replaces the rollback.",
			"",
			"",
		}, "\n")
	)
end

local args = cli.parser()
args:add("script", "positional", {
	help = "Path to the script being run. Provided automatically by Lute",
})

local restoreArgs = args:subcommand("restore", { help = "Roll a channel's plugin back to an earlier build" })
restoreArgs:add("channel", "option", { help = `The channel to roll back: "prod" or "beta"`, required = true })
restoreArgs:add("version", "option", {
	help = "What to restore: a release tag for prod, or an asset version number for beta",
})
restoreArgs:add("dry-run", "flag", { help = "Print what would happen without changing anything" })

args:subcommand("banner", { help = "The publish pull request's rollback warning, if prod is rolled back" })

args:parse({ ... })

local selected, commandArgs = args:selected()
assert(selected and commandArgs, `Expected a command:\n{args:help()}`)

if selected == "restore" then
	restore(commandArgs)
elseif selected == "banner" then
	banner()
end
