export type Channel = "prod" | "dev"
export type Target = "roblox" | "rotriever"

export type BuildContext = {
	channel: Channel,
	target: Target,
	dest: string,
	env: { [string]: string },
	shouldRebuild: boolean,
}

export type BuildCache = {
	hashes: {
		[string]: string,
	},
}

return nil
