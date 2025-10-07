local Foundation = script:FindFirstAncestor("Foundation")
local Utility = script.Parent
local Packages = Foundation.Parent

local BuilderIcons = require(Packages.BuilderIcons)
local migrationLookup = BuilderIcons.Migration["uiblox"]

local Flags = require(Utility.Flags)
local isBuilderIcon = require(Utility.isBuilderIcon)

local function isMigrated(name: string)
	return Flags.FoundationMigrateIconNames and migrationLookup[name] ~= nil
end
local function isBuilderOrMigratedIcon(name: string)
	return isBuilderIcon(name) or isMigrated(name)
end

return {
	isMigrated = isMigrated,
	isBuilderOrMigratedIcon = isBuilderOrMigratedIcon,
}
