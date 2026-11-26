--[[
	Publishes a plugin build as a new version of a Creator Store asset.

	This runs inside a place through Open Cloud Luau Execution, started by
	`.lute/lib/creator-store/publishPluginAsync.luau`. The Open Cloud Assets
	API can't upload plugins with an API key, but `AssetService` can from here.

	The plugin's `.rbxm` arrives as the task's binary input: a buffer in the
	`BinaryInput` field of the table passed as the script's first argument. The
	caller adds `_G` globals above this script that name the asset to update and
	the user who owns it.
]]

local AssetService = game:GetService("AssetService")
local SerializationService = game:GetService("SerializationService")

local arg = ({ ... })[1]
assert(arg and arg.BinaryInput, "the task was not given a binary input")

local assetId = assert(tonumber(_G.ASSET_ID), "_G.ASSET_ID must be a number")
local creatorId = assert(tonumber(_G.CREATOR_ID), "_G.CREATOR_ID must be a number")
local creatorType =
	assert((Enum.AssetCreatorType :: unknown)[_G.CREATOR_TYPE], "_G.CREATOR_TYPE must name an Enum.AssetCreatorType")

local plugin = SerializationService:DeserializeInstancesAsync(arg.BinaryInput)[1]
assert(plugin, "the binary input has no instances")

local _, versionNumber = AssetService:CreateAssetVersionAsync(plugin, Enum.AssetType.Plugin, assetId, {
	CreatorId = creatorId,
	CreatorType = creatorType,
})

-- publishPluginAsync reads the version from this line, so it must stay the last
-- thing the task prints, in this format.
print(`VERSION_NUMBER={versionNumber}`)
