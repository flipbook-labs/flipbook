--[[
	The Creator Store assets that Flipbook's plugin builds are published to.

	prod is the public plugin. dev is the development plugin, which the dev and
	beta channels both publish to, so nightly builds from `main` land there.
	smoketest is where each pull request's build lands. Each asset already
	exists, so publishing always adds a new version to one of these IDs.

	Publishing runs a Luau script through Open Cloud Luau Execution, which only
	runs scripts inside a place. The task runs in the universe and place below,
	which belong to the same user that owns the assets.
]]

export type AssetName = "dev" | "prod" | "smoketest"

local AssetName = table.freeze({
	Dev = "dev" :: "dev",
	Prod = "prod" :: "prod",
	Smoketest = "smoketest" :: "smoketest",
})

export type ChannelName = "dev" | "beta" | "prod"

local ChannelName = table.freeze({
	Dev = "dev" :: "dev",
	Beta = "beta" :: "beta",
	Prod = "prod" :: "prod",
})

export type Asset = {
	assetId: number,
	displayName: string,
	description: string,
}

local DEV_DESCRIPTION = [[This is a development version of Flipbook for testing out unreleased changes.

View the latest release of Flipbook here: https://create.roblox.com/store/asset/8517129161/flipbook]]

local ASSETS: { [AssetName]: Asset } = {
	prod = {
		assetId = 8517129161,
		displayName = "Flipbook",
		description = "Flipbook is a storybook plugin that previews UI components in a sandboxed environment. With it you can isolate distinct parts of your game's UI to hammer out edge cases and complex states without having to run through the whole UI.",
	},
	dev = {
		assetId = 88523969718241,
		displayName = "Flipbook (Dev)",
		description = DEV_DESCRIPTION,
	},
	smoketest = {
		assetId = 93737943158055,
		displayName = "Flipbook",
		description = DEV_DESCRIPTION,
	},
}

-- The beta channel has no asset of its own. Nightly builds publish to dev.
local ASSET_NAMES_BY_CHANNEL: { [ChannelName]: AssetName } = {
	[ChannelName.Dev] = AssetName.Dev,
	[ChannelName.Beta] = AssetName.Dev,
	[ChannelName.Prod] = AssetName.Prod,
}

return {
	CREATOR_ID = 1343930,
	CREATOR_TYPE = "User",
	UNIVERSE_ID = 6599100156,
	PLACE_ID = 84837374448022,

	AssetName = AssetName,
	ChannelName = ChannelName,
	ASSETS = ASSETS,
	ASSET_NAMES_BY_CHANNEL = ASSET_NAMES_BY_CHANNEL,
}
