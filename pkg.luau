return {
	package = {
		name = "Flipbook",
		version = "2.5.0",
		dependencies = {
			batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
			["flipbook-batteries"] = {
				rev = "v0.13.1",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
		},
		dev_dependencies = {
			["code-quality"] = {
				rev = "v0.7.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/code-quality",
			},
			["agent-skills"] = {
				rev = "v0.7.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
			["code-quality"] = {
				rev = "v0.7.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/code-quality",
			},
		},
	},
}
