export type Channel = "prod" | "dev"
export type Target = "roblox" | "rotriever"

export type BuildContext = {
	channel: Channel,
	target: Target,
	env: { [string]: string },
}

export type BuildCache = {
	hashes: {
		[string]: string,
	},
}

return nil
