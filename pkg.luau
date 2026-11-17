return {
	package = {
		name = "Flipbook",
		version = "2.5.0",
		dependencies = {
			Batteries = {
				rev = "v1.0.1-nightly.20261115",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
				target = "batteries",
			},
			FlipbookBatteries = {
				rev = "v0.13.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
		},
		dev_dependencies = {
			AgentSkills = {
				rev = "v0.7.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
		},
	},
}
