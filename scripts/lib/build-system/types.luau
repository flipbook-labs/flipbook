export type Channel = "prod" | "dev"
export type Target = "roblox" | "rotriever"

export type BuildCache = {
	-- Maps file path to MD5 hash
	[string]: string,
}

export type BuildContext = {
	channel: Channel,
	target: Target,
	dest: string,
	env: { [string]: string },
	shouldRebuild: boolean,
	cache: BuildCache,
}

export type BuildGroup = {
	name: string,
	paths: { string },
	context: BuildContext,
	step: (self: BuildGroup) -> (),
}

return nil
