return {
	package = {
		name = "Flipbook",
		version = "2.5.0",
		dependencies = {
			["flipbook-batteries"] = {
				rev = "v0.12.0",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/flipbook-batteries",
			},
			["lute"] = {
				rev = "v1.0.1-nightly.20260909",
				sourceKind = "github",
				source = "https://github.com/luau-lang/lute",
			},
			["dotenv"] = {
				rev = "v0.1.0",
				sourceKind = "github",
				source = "https://github.com/erlcx/lute-dotenv",
			},
		},
		dev_dependencies = {
			["AgentSkills"] = {
				rev = "b493b071ce0aa4ab6a84433a8a2fde1536c55d12",
				sourceKind = "github",
				source = "https://github.com/flipbook-labs/agent-skills",
			},
		},
	},
}
