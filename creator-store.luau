--[[
	The Creator Store assets that Flipbook's plugin builds are published to.
	`lute run publish-plugin` and `lute run rollback` read them from here.

	Prod is the public plugin. Dev is the development plugin, which the dev and
	beta channels both publish to, so nightly builds from `main` land there.
	Smoketest is where each pull request's build lands. Each asset already
	exists, so publishing always adds a new version to one of these IDs.

	Publishing runs a Luau script through Open Cloud Luau Execution, which only
	runs scripts inside a place. The task runs in the universe and place below,
	which belong to the same user that owns the assets.
]]

export type AssetName = "Dev" | "Prod" | "Smoketest"

local AssetName = table.freeze({
	Dev = "Dev" :: "Dev",
	Prod = "Prod" :: "Prod",
	Smoketest = "Smoketest" :: "Smoketest",
})

export type ChannelName = "Dev" | "Beta" | "Prod"

local ChannelName = table.freeze({
	Dev = "Dev" :: "Dev",
	Beta = "Beta" :: "Beta",
	Prod = "Prod" :: "Prod",
})

export type Asset = {
	assetId: number,
	displayName: string,
	description: string,
}

local DEV_DESCRIPTION = [[This is a development version of Flipbook for testing out unreleased changes.

View the latest release of Flipbook here: https://create.roblox.com/store/asset/8517129161/flipbook]]

local ASSETS: { [AssetName]: Asset } = {
	[AssetName.Prod] = {
		assetId = 8517129161,
		displayName = "Flipbook",
		description = "Flipbook is a storybook plugin that previews UI components in a sandboxed environment. With it you can isolate distinct parts of your game's UI to hammer out edge cases and complex states without having to run through the whole UI.",
	},
	[AssetName.Dev] = {
		assetId = 88523969718241,
		displayName = "Flipbook (Dev)",
		description = DEV_DESCRIPTION,
	},
	[AssetName.Smoketest] = {
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
