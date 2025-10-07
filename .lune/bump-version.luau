local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local semver = require("./lib/semver")

type VersionComponent = semver.VersionComponent

local function validateVersionBump(versionBump: string): VersionComponent
	versionBump = versionBump:lower()

	if versionBump == "major" or versionBump == "minor" or versionBump == "patch" then
		return versionBump
	else
		print(`argument #1 must be "major", "minor", or "patch"`)
		process.exit(1)
		return nil :: never
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

local bumpedVersionComponent = process.args[1]

local manifestPath = `rotriever.toml`

local versionBump: VersionComponent = validateVersionBump(bumpedVersionComponent)
local currentVersion = semver.getVersionFromManifest(manifestPath)
local nextVersion = getNextVersion(currentVersion, versionBump)

print(`Bumping version to {nextVersion} (was {currentVersion})`)

local manifestContent = fs.readFile(manifestPath)
manifestContent = manifestContent:gsub(`version = "{currentVersion}"`, `version = "{nextVersion}"`)
fs.writeFile(manifestPath, manifestContent)
