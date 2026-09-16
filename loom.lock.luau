return {
  version = 3,
  dependencies = {
    AgentSkills = "AgentSkills@b493b071ce0aa4ab6a84433a8a2fde1536c55d12",
    dotenv = "dotenv@v0.1.0",
    ["flipbook-batteries"] = "flipbook-batteries@v0.12.0",
    lute = "lute@v1.0.1-nightly.20260909",
  },
  packages = {
    ["AgentSkills@b493b071ce0aa4ab6a84433a8a2fde1536c55d12"] = {
      installPath = "@pkg/AgentSkills@b493b071ce0aa4ab6a84433a8a2fde1536c55d12",
      name = "AgentSkills",
      rev = "b493b071ce0aa4ab6a84433a8a2fde1536c55d12",
      source = "https://github.com/flipbook-labs/agent-skills",
      sourceKind = "github",
      dependencies = {},
    },
    ["Lute@v1.0.1-nightly.20260701"] = {
      installPath = "@pkg/Lute@v1.0.1-nightly.20260701",
      name = "Lute",
      rev = "v1.0.1-nightly.20260701",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
    ["dotenv@v0.1.0"] = {
      installPath = "@pkg/dotenv@v0.1.0",
      name = "dotenv",
      rev = "v0.1.0",
      source = "https://github.com/erlcx/lute-dotenv",
      sourceKind = "github",
      dependencies = {},
    },
    ["flipbook-batteries@v0.12.0"] = {
      installPath = "@pkg/flipbook-batteries@v0.12.0",
      name = "flipbook-batteries",
      rev = "v0.12.0",
      source = "https://github.com/flipbook-labs/flipbook-batteries",
      sourceKind = "github",
      dependencies = {
        Lute = "Lute@v1.0.1-nightly.20260701",
      },
    },
    ["lute@v1.0.1-nightly.20260909"] = {
      installPath = "@pkg/lute@v1.0.1-nightly.20260909",
      name = "lute",
      rev = "v1.0.1-nightly.20260909",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
  },
}
