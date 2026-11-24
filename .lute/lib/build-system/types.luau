local path = require("@std/path")

local types = {}

export type Channel = "prod" | "beta" | "dev"

types.Channel = table.freeze({
	Prod = "prod" :: "prod",
	Beta = "beta" :: "beta",
	Dev = "dev" :: "dev",
})
export type Target = "roblox" | "rotriever"

export type BuildCache = {
	-- Maps file path to MD5 hash
	[string]: string,
}

export type BuildContext = {
	channel: Channel,
	target: Target,
	dest: path.Path,
	env: { [string]: string },
	shouldRebuild: boolean,
	cache: BuildCache,
}

export type BuildGroup = {
	name: string,
	paths: { path.Pathlike },
	context: BuildContext,
	step: (self: BuildGroup) -> (),
}

return types
