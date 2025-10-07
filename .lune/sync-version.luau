local fs = require("@lune/fs")
local process = require("@lune/process")

local semver = require("./lib/semver")

local MANIFEST_PATH = "rotriever.toml"

local upstreamVersion = process.args[1]

local upstreamVersionParts = semver.splitVersionComponents(upstreamVersion)
local currentVersion = semver.getVersionFromManifest(MANIFEST_PATH)
local currentVersionParts = semver.splitVersionComponents(currentVersion)

local majorChanged = upstreamVersionParts[1] > currentVersionParts[1]
local minorChanged = upstreamVersionParts[2] > currentVersionParts[2]
if majorChanged or minorChanged then
	print("Upstream version is newer, updating rotriever.toml to match")
	local manifestContent = fs.readFile(MANIFEST_PATH)
	manifestContent = manifestContent:gsub(`version = "{currentVersion}"`, `version = "{upstreamVersion}"`)
	fs.writeFile(MANIFEST_PATH, manifestContent)
else
	print("No changes to upstream's major or minor version, keeping the same version in rotriever.toml")
end
