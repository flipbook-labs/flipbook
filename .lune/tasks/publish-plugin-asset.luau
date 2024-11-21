local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")

local CREATOR_ID: number = _G.ROBLOX_CREATOR_ID
assert(typeof(CREATOR_ID) == "number", "_G.ROBLOX_CREATOR_ID must be supplied")

local ASSET_ID: number? = _G.ROBLOX_ASSET_ID

local root = ReplicatedStorage:FindFirstChild("flipbook")
assert(root, "no plugin found for upload")

local assetId: number?
local versionNumber = 1

if ASSET_ID == nil then
	print("Creating plugin asset for the first time")
	local _
	_, assetId = AssetService:CreateAssetAsync(root, Enum.AssetType.Plugin, {
		Name = "Simple Plugin",
		CreatorId = CREATOR_ID,
		CreatorType = Enum.CreatorType.User,
	})
else
	print(`Updating asset with ID {ASSET_ID}`)
	assetId = ASSET_ID
	local _
	_, versionNumber = AssetService:CreateAssetVersionAsync(root, Enum.AssetType.Plugin, assetId, {
		CreatorId = CREATOR_ID,
		CreatorType = Enum.CreatorType.User,
	})
	print("Created new version", versionNumber)
end

print("Plugin uploaded successfully! View it on the Creator Store:")
print(`https://create.roblox.com/store/asset/{assetId}`)

return {
	assetId = tostring(assetId), -- we make it a string because the Luau exec API serializes integers as floating points
	versionNumber = tostring(versionNumber),
}
