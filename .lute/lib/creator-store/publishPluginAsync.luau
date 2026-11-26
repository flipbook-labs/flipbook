local fs = require("@std/fs")
local path = require("@std/path")
local task = require("@std/task")

local Assets = require("@lpm/open-cloud-assets@v0.2.0")
local createOpenCloudClient = require("./createOpenCloudClient")
local creatorStore = require("@repo/creator-store")
local project = require("@repo/project")
local runLuauTaskAsync = require("./runLuauTaskAsync")

local PUBLISH_TASK_PATH = path.join(project.SCRIPTS_PATH, "tasks", "publish-plugin.luau")

-- How long to wait between checks on whether an asset update has finished.
local POLL_INTERVAL_SECONDS = 2

--[[
	A new version doesn't change the asset's name or description on the Creator
	Store, so this sets them from `creator-store.luau` after each publish. The update
	is an operation that finishes in the background, so this waits for it.
]]
local function updateAssetDetailsAsync(client: Assets.Client, asset: creatorStore.Asset)
	local operation = Assets.updateAsset(client, {
		assetId = asset.assetId,
		updateMask = { "displayName", "description" },
		body = {
			request = {
				assetId = string.format("%d", asset.assetId),
				displayName = asset.displayName,
				description = asset.description,
			},
		},
	})

	while not operation.done do
		task.wait(POLL_INTERVAL_SECONDS)
		operation = Assets.getOperation(client, { operationId = operation.operationId })
	end

	if operation.error then
		error(`Updating the details of asset {asset.assetId} failed: {operation.error.message}`, 0)
	end
end

--[[
	Publishes a plugin build to one of the Creator Store assets in
	`creator-store.luau` and returns the asset version it created.

	The Open Cloud Assets API doesn't accept plugins from an API key, so the
	upload happens in a Luau Execution task that calls `AssetService`. The
	`.rbxm` file goes to that task as its binary input.
]]
local function publishPluginAsync(rbxmPath: path.Pathlike, assetName: creatorStore.AssetName, apiKey: string): number
	local asset = creatorStore.ASSETS[assetName]
	local client = createOpenCloudClient(apiKey)

	local messages = runLuauTaskAsync(client, fs.readFileToString(PUBLISH_TASK_PATH), {
		universeId = creatorStore.UNIVERSE_ID,
		placeId = creatorStore.PLACE_ID,
		globals = {
			ASSET_ID = asset.assetId,
			CREATOR_ID = creatorStore.CREATOR_ID,
			CREATOR_TYPE = creatorStore.CREATOR_TYPE,
		},
		binaryInput = fs.readFileToString(rbxmPath),
	})

	local versionNumber = tonumber((messages[#messages] or ""):match("^VERSION_NUMBER=(%d+)$"))
	assert(versionNumber, "The publish task didn't report the version it created")

	updateAssetDetailsAsync(client, asset)

	return versionNumber
end

return publishPluginAsync
