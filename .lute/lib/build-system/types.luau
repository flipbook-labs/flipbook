local path = require("@std/path")

export type Channel = "prod" | "dev"
export type Target = "roblox" | "rotriever"

export type BuildCache = {
	-- Maps file path to MD5 hash
	[string]: string,
}

export type BuildContext = {
	channel: Channel,
	target: Target,
	dest: path.path,
	env: { [string]: string },
	shouldRebuild: boolean,
	cache: BuildCache,
}

export type BuildGroup = {
	name: string,
	paths: { path.pathlike },
	context: BuildContext,
	step: (self: BuildGroup) -> (),
}

return nil
