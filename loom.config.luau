return {
	package = {
		name = "Flipbook",
		version = "2.4.0",
		dependencies = {
			["flipbook-batteries"] = {
				rev = "bump-lute-and-fix-api-usage",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			["lute"] = {
				rev = "0.1.0-nightly.20260408",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
			},
		},
	},
}
