return {
  version = 5,
  dependencies = {
    batteries = "batteries@v1.0.1-nightly.20261115",
    ["flipbook-batteries"] = "flipbook-batteries@v0.13.1",
  },
  devDependencies = {
    ["agent-skills"] = "agent-skills@v0.7.0",
    ["code-quality"] = "code-quality@v0.6.0",
  },
  packages = {
    ["agent-skills@v0.7.0"] = {
      installPath = "@pkg/agent-skills--github-9a5fa281b004edd0a2d24adfca334a5b9f2dc7230401fbbbd8816c81f971a3ed@50ab7418ec44018e5cfb2826c68fe26616f4ae4399ad5da286264e4e826b123b/.",
      name = "agent-skills",
      rev = "v0.7.0",
      source = "https://github.com/flipbook-labs/agent-skills",
      sourceKind = "github",
      dependencies = {},
    },
    ["batteries@v1.0.1-nightly.20261115"] = {
      installPath = "@pkg/lute--github-6e87d56ef86974ca90629c5ef7ab70e40b102f8210ee178dc95916f940d6854e@6dba55fa3cf083d10fb5dcb54a22cb87d3d11735a512215b835f33d3c571033d/batteries",
      name = "batteries",
      rev = "v1.0.1-nightly.20261115",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      target = "batteries",
      dependencies = {},
    },
    ["code-quality@v0.6.0"] = {
      installPath = "@pkg/code-quality--github-1234fc23be7b191af0dfcb12c5bcd80ec53c2a90ee282c59e48cdfd534b41adb@070533466467296d77e7d309371c2c322c9ef7d1f47dade632571711ce1bc5f9/.",
      name = "code-quality",
      rev = "v0.6.0",
      source = "https://github.com/flipbook-labs/code-quality",
      sourceKind = "github",
      dependencies = {},
    },
    ["flipbook-batteries@v0.13.1"] = {
      installPath = "@pkg/flipbook-batteries--github-cd561061b96224c3881d0f76944a9bb8bad2d09ff72e9e09eb3cfaa2e62b6613@2d93695b49e4bf001597267620df22e26d5d15ad61c54a3bb66b60826b4f1c47/.",
      name = "flipbook-batteries",
      rev = "v0.13.1",
      source = "https://github.com/flipbook-labs/flipbook-batteries",
      sourceKind = "github",
      dependencies = {
        batteries = "batteries@v1.0.1-nightly.20261115",
      },
    },
  },
}
