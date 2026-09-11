return {
	package = {
		name = "Flipbook",
		version = "2.5.0",
		dependencies = {
			["flipbook-batteries"] = {
				rev = "v0.9.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			["lute"] = {
				rev = "v1.0.0",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
			},
			["dotenv"] = {
				rev = "v0.1.0",
				sourceKind = "github",
				source = "https://github.com/erlcx/lute-dotenv",
			},
		},
	},
}
