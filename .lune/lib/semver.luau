local fs = require("@lune/fs")
local serde = require("@lune/serde")

export type VersionComponent = "major" | "minor" | "patch"

-- Needs to support Wally and Rotriever manifests

local function getVersionFromManifest(manifestPath: string)
	local manifestContent = fs.readFile(manifestPath)
	local manifest = serde.decode("toml", manifestContent)

	if manifest.workspace then
		return manifest.workspace.version
	elseif manifest.package then
		return manifest.package.version
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
