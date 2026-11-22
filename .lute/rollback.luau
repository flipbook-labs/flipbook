-- Rolls a Flipbook plugin asset on the Creator Store back to an earlier
-- version, and reports whether prod is currently rolled back.
--
-- Roblox keeps every version of an asset. Open Cloud's rollback endpoint
-- publishes an earlier version again as a new one, so rolling back needs no
-- stored build and no rebuild. Each prod version is published by the Release
-- workflow right after its GitHub release, which is how a prod version is
-- traced back to its release tag.
--
-- Usage:
--   lute run rollback restore --channel <prod | beta> [--version <n>] [--dry-run]
--   lute run rollback banner
--
-- - restore: rolls the channel's asset back to version n, or to the version
--   before the latest when n is left out. Running it again with no n restores
--   the version it replaced, which undoes the rollback. For prod, it also marks
--   the restored version's GitHub release as Latest, the release GitHub badges
--   on the repository page, so the publish pull request can tell that a
--   rollback is in effect. When no release matches the version, it says so and
--   leaves Latest alone. --dry-run prints what it would do and changes
--   nothing. Reads ROBLOX_API_KEY.
-- - banner: a caution admonition for the publish pull request body while prod
--   is rolled back, or an empty string otherwise. Prod counts as rolled back
--   when the repository's Latest release is not its newest one. The next
--   release becomes Latest and clears it.
--
-- Each command writes its results as step outputs to the file named by
-- GITHUB_OUTPUT, or prints them when that's unset. The GitHub steps read
-- GITHUB_REPOSITORY (owner/name) and need `gh` to be signed in, through
-- GH_TOKEN in CI.
local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local fs = require("@std/fs")
local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")
local toml = require("@lpm/batteries@v1.0.1-nightly.20261115/toml")

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

-- A multiline value uses GitHub's delimiter syntax, so every value is written
-- that way, including empty ones.
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

-- The versions list starts with the newest version.
local function readRecentVersions(assetId: string, apiKey: string): { AssetVersion }
	local response = requestJson("GET", `{ASSETS_URL}/{assetId}/versions?maxPageSize=2`, apiKey)
	local versions = {}
	for _, value in json.asArray(response.assetVersions) or {} do
		table.insert(versions, parseAssetVersion(value))
	end
	return versions
end

local function readVersion(assetId: string, number: number, apiKey: string): AssetVersion
	return parseAssetVersion(requestJson("GET", `{ASSETS_URL}/{assetId}/versions/{number}`, apiKey))
end

-- The release a prod version came from is the newest published release from
-- before the version was created. Both APIs give UTC timestamps like
-- 2026-04-10T15:51:08Z, but Open Cloud adds fractional seconds. Trimming those
-- lets the two compare as strings.
local function findReleaseTag(createTime: string): string?
	local repo = assertEnv("GITHUB_REPOSITORY")
	local cutoff = `{createTime:sub(1, 19)}Z`
	local tag = run({
		"gh",
		"api",
		`repos/{repo}/releases?per_page=100`,
		"--jq",
		`[.[] | select((.draft | not) and (.prerelease | not) and .published_at <= "{cutoff}")]`
			.. " | sort_by(.published_at) | last | .tag_name // empty",
	})
	return if tag == "" then nil else tag
end

local function restore(commandArgs: cli.Parser)
	local channel = assert(commandArgs:get("channel"))
	local requested = commandArgs:get("version")
	local dryRun = commandArgs:has("dry-run")

	local apiKey = assertEnv("ROBLOX_API_KEY")
	local assetId = readAssetId(channel)

	local recent = readRecentVersions(assetId, apiKey)
	local latest = assert(recent[1], `Asset {assetId} has no versions`)

	local target: AssetVersion
	if requested and requested ~= "" then
		local number = tonumber(requested)
		assert(number and number % 1 == 0, `bad value for version (expected a whole number, got "{requested}")`)
		target = readVersion(assetId, number, apiKey)
	else
		target = assert(recent[2], `Asset {assetId} has no earlier version to roll back to`)
	end
	assert(
		target.number < latest.number,
		`Version {target.number} is not older than the latest version, {latest.number}`
	)

	local tag = if channel == "prod" then findReleaseTag(target.createTime) else nil
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
		elseif channel == "prod" then
			print("No release matches the restored version, so the Latest release is unchanged")
		end
	end

	writeOutput("from-version", tostring(latest.number))
	writeOutput("to-version", tostring(target.number))
	writeOutput("tag", tag or "")
end

-- Returns nil when the repository has no Latest release yet.
local function readLatestReleaseTag(repo: string): string?
	local result = process.run({ "gh", "api", `repos/{repo}/releases/latest`, "--jq", ".tag_name" })
	if result.ok then
		return (result.stdout:gsub("%s+$", ""))
	end
	if result.stderr:find("HTTP 404", 1, true) then
		return nil
	end
	error(`Could not read the Latest release: {result.stderr}`)
end

local function banner()
	local repo = assertEnv("GITHUB_REPOSITORY")
	local latest = readLatestReleaseTag(repo)
	local newest = run({
		"gh",
		"api",
		`repos/{repo}/releases?per_page=100`,
		"--jq",
		"[.[] | select((.draft | not) and (.prerelease | not))] | sort_by(.published_at) | last | .tag_name // empty",
	})

	if latest == nil or newest == "" or latest == newest then
		writeOutput("banner", "")
		return
	end

	writeOutput(
		"banner",
		table.concat({
			"> [!CAUTION]",
			`> Flipbook is rolled back to {latest} on the Creator Store after a problem with {newest}.`,
			"> Merging this PR publishes a release that replaces the rollback.",
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
