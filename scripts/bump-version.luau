local cli = require("@batteries/cli")
local fs = require("@lute/fs")

local semver = require("./lib/semver")

type VersionComponent = semver.VersionComponent

local function validateVersionBump(versionBump: string): VersionComponent
	versionBump = versionBump:lower()

	if versionBump == "major" or versionBump == "minor" or versionBump == "patch" then
		return versionBump
	else
		error(`invalid version bump, must be "major", "minor", or "patch" (got "{versionBump}")`)
	end
end

local function getNextVersion(currentVersion: string, versionBump: VersionComponent)
	local versionParts = semver.splitVersionComponents(currentVersion)

	if versionBump == "major" then
		versionParts = { versionParts[1] + 1, 0, 0 }
	elseif versionBump == "minor" then
		versionParts = { versionParts[1], versionParts[2] + 1, 0 }
	elseif versionBump == "patch" then
		versionParts = { versionParts[1], versionParts[2], versionParts[3] + 1 }
	end
	return table.concat(versionParts, ".")
end

local args = cli.parser()

args:add("versionBump", "positional", {
	help = `Can be one of "major", "minor", or "patch"`,
	required = true,
})

local argsNoScript = { ... }
table.remove(argsNoScript, 1)
args:parse(argsNoScript)

-- The only package we publish is FlipbookCore, so the following makes no
-- attempt to bump the version of any of our other workspace members
do
	local MANIFEST_PATHS = {
		"wally.toml",
		"workspace/flipbook-core/wally.toml",
		"workspace/flipbook-core/rotriever.toml",
	}

	local bumpedVersionComponent = args:get("versionBump")
	print("bumpedVersionComponent")
	local versionBump: VersionComponent = validateVersionBump(bumpedVersionComponent)

	-- The root Wally manifest is the source of truth for the current version
	local wallyPath = MANIFEST_PATHS[1]
	assert(fs.exists(wallyPath), `no wally.toml found at the root of the repo`)

	local currentVersion = semver.getVersionFromManifest(wallyPath)
	local nextVersion = getNextVersion(currentVersion, versionBump)

	for _, manifestPath in MANIFEST_PATHS do
		local manifestVersion = semver.getVersionFromManifest(manifestPath)

		if fs.exists(manifestPath) then
			local manifestHandle = fs.open(manifestPath, "w+")
			local manifestContent = fs.read(manifestHandle)
			manifestContent = manifestContent:gsub(`version = "{manifestVersion}"`, `version = "{nextVersion}"`)
			fs.write(manifestHandle, manifestContent)
			fs.close(manifestHandle)

			print(`bumped version in {manifestPath} to {nextVersion} (was {manifestVersion})`)
		end
	end
end
