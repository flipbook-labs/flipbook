local fs = require("@lute/fs")
local toml = require("@batteries/toml")

export type VersionComponent = "major" | "minor" | "patch"

local function getVersionFromManifest(manifestPath: string)
	local manifestContent = fs.readfiletostring(manifestPath)
	local manifest = toml.deserialize(manifestContent)

	if manifest.workspace then
		return (manifest.workspace :: any).version
	elseif manifest.package then
		return (manifest.package :: any).version
	else
		error(`Could not find a 'version' field in {manifestPath}`)
	end
end

local function splitVersionComponents(version: string): { number }
	local stringVersionParts = version:split(".")

	local versionParts: { number } = {}
	for _, stringVersionPart in stringVersionParts do
		local versionPart = tonumber(stringVersionPart)
		assert(
			versionPart,
			`Invalid version part '{stringVersionPart}' in version '{version}' (could not convert to number)`
		)
		table.insert(versionParts, versionPart)
	end

	return versionParts
end

return {
	getVersionFromManifest = getVersionFromManifest,
	splitVersionComponents = splitVersionComponents,
}
