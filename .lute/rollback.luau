-- Rolls a Flipbook plugin asset on the Creator Store back to an earlier
-- version, and reports whether prod is currently rolled back.
--
-- Roblox keeps every version of an asset. Open Cloud's rollback endpoint
-- publishes an earlier version again as a new one, so rolling back needs no
-- stored build and no rebuild.
--
-- Usage:
--   lute run rollback restore --channel <prod | beta> [--version <n>] [--dry-run]
--   lute run rollback banner
--
-- - restore: rolls the channel's asset back to version n. When n is left out,
--   beta restores the version before the latest, and prod restores the release
--   before the current Latest release, the one GitHub badges on the repository
--   page. So each prod run with no n steps back one more release. For prod, it
--   also marks the restored release as Latest, so the publish pull request can
--   tell that a rollback is in effect. When n is a version that no release
--   published, such as a copy an earlier rollback made, it says so and leaves
--   Latest alone. --dry-run prints what it would do and changes nothing on
--   the Creator Store or GitHub. Reads ROBLOX_API_KEY.
-- - banner: while prod is rolled back, a caution admonition for the top of
--   the publish pull request's body, which release.yml writes for the next
--   release. Otherwise, an empty string. The admonition ends with a blank
--   line, so the body can follow it directly. It prints the banner, and also
--   writes it as the `banner` step output to the file named by GITHUB_OUTPUT
--   when that's set. The next release becomes Latest and clears it.
--
-- `banner` and prod restores read GITHUB_REPOSITORY (owner/name) and need `gh`
-- to be signed in, through GH_TOKEN in CI.
local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")
local toml = require("@lpm/batteries@v1.0.1-nightly.20261115/toml")

local githubReleases = require("@scripts/lib/releases")

local ASSETS_URL = "https://apis.roblox.com/assets/v1/assets"

-- Mirrors the prod and beta entries of ASSET_NAMES_BY_CHANNEL in
-- .lune/publish-plugin.luau, which decides where each channel publishes. Beta
-- builds land on the dev asset.
local ASSET_NAMES_BY_CHANNEL = {
	prod = "prod",
	beta = "dev",
}

type AssetVersion = {
	number: number,
	createTime: string,
}

type Release = githubReleases.Release

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

-- A multiline value uses GitHub's delimiter syntax, which keeps blank lines.
local function writeOutput(name: string, value: string)
	print(`{name}={value}`)

	local outputPath = process.env.GITHUB_OUTPUT
	if outputPath and outputPath ~= "" then
		local file = fs.open(outputPath, "a")
		fs.write(file, `{name}<<ROLLBACK_EOF\n{value}\nROLLBACK_EOF\n`)
		fs.close(file)
	end
end

-- rbxasset records each published asset's ID in rbxasset.lock.
local function readAssetId(channel: string): string
	local assetName = ASSET_NAMES_BY_CHANNEL[channel]
	assert(assetName, `bad value for channel (must be "prod" or "beta", got "{channel}")`)

	local lock = toml.deserialize(fs.readFileToString("rbxasset.lock")) :: any
	local assetId = lock.assets and lock.assets[assetName] and lock.assets[assetName].assetId
	assert(typeof(assetId) == "string", `rbxasset.lock has no asset ID for "{assetName}"`)
	return assetId
end

local function requestJson(method: string, url: string, apiKey: string, body: json.Value?): json.Object
	local metadata: net.Metadata = {
		method = method,
		headers = { ["x-api-key"] = apiKey, ["Content-Type"] = "application/json" },
	}
	if body ~= nil then
		metadata.body = json.serialize(body)
	end

	local response = net.request(url, metadata)
	if not response.ok then
		error(`Open Cloud returned {response.status} for {method} {url}\n{response.body}`, 0)
	end
	return assert(json.asObject(json.deserialize(response.body)), `Expected a JSON object from {url}`)
end

-- Versions are named by path, as in "assets/123/versions/16".
local function parseAssetVersion(value: json.Value): AssetVersion
	local object = assert(json.asObject(value), "Expected an asset version object")
	local versionPath = object.path
	local createTime = object.createTime
	assert(typeof(versionPath) == "string" and typeof(createTime) == "string", "Malformed asset version")

	local number = tonumber(versionPath:match("/versions/(%d+)$"))
	return { number = assert(number, `Unexpected version path {versionPath}`), createTime = createTime }
end

-- Open Cloud page tokens can hold characters such as "=" that a query string
-- needs escaped.
local function encodeQueryValue(value: string): string
	return (value:gsub("[^%w%-_%.~]", function(char)
		return string.format("%%%02X", string.byte(char))
	end))
end

-- The versions list starts with the newest version and comes in pages. Reading
-- stops once it has at least `limit` versions, or at the end of the list.
local function readVersions(assetId: string, apiKey: string, limit: number?): { AssetVersion }
	local versions = {}
	local pageToken: string? = nil
	repeat
		local url = `{ASSETS_URL}/{assetId}/versions?maxPageSize=50`
		if pageToken then
			url ..= `&pageToken={encodeQueryValue(pageToken)}`
		end

		local response = requestJson("GET", url, apiKey)
		for _, value in json.asArray(response.assetVersions) or {} do
			table.insert(versions, parseAssetVersion(value))
		end

		local nextPageToken = response.nextPageToken
		pageToken = if typeof(nextPageToken) == "string" and nextPageToken ~= "" then nextPageToken else nil
	until pageToken == nil or (limit ~= nil and #versions >= limit)
	return versions
end

local function readVersion(assetId: string, number: number, apiKey: string): AssetVersion
	return parseAssetVersion(requestJson("GET", `{ASSETS_URL}/{assetId}/versions/{number}`, apiKey))
end

-- Both APIs give UTC timestamps like 2026-04-10T15:51:08Z, and Open Cloud adds
-- fractional seconds, which are dropped here. Every timestamp goes through the
-- same conversion, so the results compare and subtract correctly.
local function toSeconds(timestamp: string): number
	local year, month, day, hour, min, sec = timestamp:match("^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
	assert(year, `Unexpected timestamp {timestamp}`)
	return os.time({
		year = tonumber(year) :: number,
		month = tonumber(month) :: number,
		day = tonumber(day) :: number,
		hour = tonumber(hour) :: number,
		min = tonumber(min) :: number,
		sec = tonumber(sec) :: number,
	})
end

-- When a Rollback workflow run was in progress, from start to its last update.
type RollbackRun = {
	startedAt: number,
	endedAt: number,
}

-- The newest 100 runs of the Rollback workflow, each of which may have made a
-- rollback copy. Before the workflow first lands on the default branch, GitHub
-- answers 404 and there are no runs.
local function readRollbackRuns(repo: string): { RollbackRun }
	local result = process.run({
		"gh",
		"api",
		`repos/{repo}/actions/workflows/rollback.yml/runs?per_page=100`,
		"--jq",
		'.workflow_runs[] | "\\(.run_started_at) \\(.updated_at)"',
	})
	if not result.ok then
		if result.stderr:find("HTTP 404", 1, true) then
			return {}
		end
		error(`Could not read Rollback workflow runs: {result.stderr}`)
	end

	local runs = {}
	for startedAt, updatedAt in result.stdout:gmatch("(%S+) (%S+)") do
		table.insert(runs, { startedAt = toSeconds(startedAt :: string), endedAt = toSeconds(updatedAt :: string) })
	end
	return runs
end

local function isRollbackCopy(version: AssetVersion, runs: { RollbackRun }): boolean
	local createdAt = toSeconds(version.createTime)
	for _, rollbackRun in runs do
		if createdAt >= rollbackRun.startedAt and createdAt <= rollbackRun.endedAt then
			return true
		end
	end
	return false
end

-- The Release workflow publishes each release to the prod asset, so a
-- release's own version is created after it and before the next release.
-- Rollbacks create versions in that span too, as copies of earlier ones, so
-- any version made while a Rollback workflow run was in progress is skipped.
-- Of what's left, the oldest is the release's own version. A publish can be
-- retried late and still count. When it never succeeded, this returns nil.
local function findReleaseVersion(
	versions: { AssetVersion },
	releases: { Release },
	index: number,
	runs: { RollbackRun }
): AssetVersion?
	local releasedAt = toSeconds(releases[index].publishedAt)
	local nextRelease = releases[index + 1]
	local nextReleasedAt = if nextRelease then toSeconds(nextRelease.publishedAt) else math.huge

	local found = nil
	for _, version in versions do
		local createdAt = toSeconds(version.createTime)
		if createdAt < releasedAt then
			break
		end
		if createdAt < nextReleasedAt and not isRollbackCopy(version, runs) then
			found = version
		end
	end
	return found
end

-- Finds the release that published this prod version. A rollback copy isn't
-- any release's own version, so it gets nil instead of being mistaken for the
-- release before it.
local function findReleaseOf(
	target: AssetVersion,
	versions: { AssetVersion },
	releases: { Release },
	runs: { RollbackRun }
): Release?
	local createdAt = toSeconds(target.createTime)
	local candidateIndex = nil
	for index, release in releases do
		if toSeconds(release.publishedAt) <= createdAt then
			candidateIndex = index
		end
	end

	if candidateIndex then
		local original = findReleaseVersion(versions, releases, candidateIndex, runs)
		if original and original.number == target.number then
			return releases[candidateIndex]
		end
	end
	return nil
end

-- Picks the prod version to restore and the release it came from, if any.
-- `versions` is the asset's whole history, newest first.
local function chooseProdTarget(versions: { AssetVersion }, requested: number?): (AssetVersion, string?)
	local repo = assertEnv("GITHUB_REPOSITORY")
	local releases = githubReleases.readPublished(repo)
	local runs = readRollbackRuns(repo)

	if requested then
		local target
		for _, version in versions do
			if version.number == requested then
				target = version
			end
		end
		assert(target, `The prod asset has no version {requested}`)

		local release = findReleaseOf(target, versions, releases, runs)
		return target, if release then release.tag else nil
	end

	local latestTag =
		assert(githubReleases.readLatestTag(repo), "The repository has no Latest release to step back from")
	local previousIndex = nil
	for index, release in releases do
		if release.tag == latestTag and index > 1 then
			previousIndex = index - 1
		end
	end
	assert(previousIndex, `No published release comes before {latestTag}`)

	local previous = releases[previousIndex]
	local target = assert(
		findReleaseVersion(versions, releases, previousIndex, runs),
		`No prod asset version was published for {previous.tag}`
	)
	return target, previous.tag
end

local function restore(commandArgs: cli.Parser)
	local channel = assert(commandArgs:get("channel"))
	local requested = commandArgs:get("version")
	local dryRun = commandArgs:has("dry-run")

	local apiKey = assertEnv("ROBLOX_API_KEY")
	local assetId = readAssetId(channel)

	local requestedNumber: number? = nil
	if requested and requested ~= "" then
		requestedNumber = tonumber(requested)
		assert(
			requestedNumber and requestedNumber % 1 == 0,
			`bad value for version (expected a whole number, got "{requested}")`
		)
	end

	-- Matching prod versions to releases needs the whole history. Beta only
	-- needs the latest two.
	local versions = readVersions(assetId, apiKey, if channel == "prod" then nil else 2)
	local latest = assert(versions[1], `Asset {assetId} has no versions`)

	local target: AssetVersion
	local tag: string? = nil
	if channel == "prod" then
		target, tag = chooseProdTarget(versions, requestedNumber)
	elseif requestedNumber then
		target = readVersion(assetId, requestedNumber, apiKey)
	else
		target = assert(versions[2], `Asset {assetId} has no earlier version to roll back to`)
	end
	assert(
		target.number < latest.number,
		`Version {target.number} is not older than the latest version, {latest.number}`
	)

	local releaseNote = if tag then ` from release {tag}` else ""
	print(`Rolling the {channel} asset ({assetId}) back from version {latest.number} to {target.number}{releaseNote}`)

	if not dryRun then
		local restored = requestJson("POST", `{ASSETS_URL}/{assetId}/versions:rollback`, apiKey, {
			assetVersion = `assets/{assetId}/versions/{target.number}`,
		})
		print(`Published version {target.number} again as {restored.path}`)

		if tag then
			run({ "gh", "release", "edit", tag, "--latest" })
			print(`Marked {tag} as the Latest release`)
		end
	end

	if channel == "prod" and tag == nil then
		print("No release published the restored version, so the Latest release is left unchanged")
	end
end

local function banner()
	local state = githubReleases.readRollbackState(assertEnv("GITHUB_REPOSITORY"))
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

local restoreArgs = args:subcommand("restore", { help = "Roll a channel's plugin asset back to an earlier version" })
restoreArgs:add("channel", "option", { help = `The channel to roll back: "prod" or "beta"`, required = true })
restoreArgs:add("version", "option", { help = "The asset version to restore. Defaults to the one before the latest" })
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
