return {
	package = {
		name = "Flipbook",
		version = "2.5.0",
		dependencies = {
			["flipbook-batteries"] = {
				rev = "bump-lute-to-1.0.1-nightly",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			["lute"] = {
				rev = "v1.0.1-nightly.20260420",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
			},
		},
	},
}
