return {
  version = 5,
  dependencies = {
    Batteries = "Batteries@v1.0.1-nightly.20261115",
    FlipbookBatteries = "FlipbookBatteries@v0.13.0",
  },
  devDependencies = {
    AgentSkills = "AgentSkills@v0.7.0",
  },
  packages = {
    ["AgentSkills@v0.7.0"] = {
      installPath = "@pkg/agent-skills--github-9a5fa281b004edd0a2d24adfca334a5b9f2dc7230401fbbbd8816c81f971a3ed@50ab7418ec44018e5cfb2826c68fe26616f4ae4399ad5da286264e4e826b123b/.",
      name = "AgentSkills",
      rev = "v0.7.0",
      source = "https://github.com/flipbook-labs/agent-skills",
      sourceKind = "github",
      dependencies = {},
    },
    ["Batteries@v1.0.1-nightly.20261115"] = {
      installPath = "@pkg/lute--github-6e87d56ef86974ca90629c5ef7ab70e40b102f8210ee178dc95916f940d6854e@6dba55fa3cf083d10fb5dcb54a22cb87d3d11735a512215b835f33d3c571033d/batteries",
      name = "Batteries",
      rev = "v1.0.1-nightly.20261115",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      target = "batteries",
      dependencies = {},
    },
    ["FlipbookBatteries@v0.13.0"] = {
      installPath = "@pkg/flipbook-batteries--github-cd561061b96224c3881d0f76944a9bb8bad2d09ff72e9e09eb3cfaa2e62b6613@2f0b52aa834b5bccd5b10d223b712227121916715a67505b557393845d5af93e/.",
      name = "FlipbookBatteries",
      rev = "v0.13.0",
      source = "https://github.com/flipbook-labs/flipbook-batteries",
      sourceKind = "github",
      dependencies = {
        Lute = "Lute@v1.0.1-nightly.20261115",
      },
    },
    ["Lute@v1.0.1-nightly.20261115"] = {
      installPath = "@pkg/lute--github-6e87d56ef86974ca90629c5ef7ab70e40b102f8210ee178dc95916f940d6854e@6dba55fa3cf083d10fb5dcb54a22cb87d3d11735a512215b835f33d3c571033d/batteries",
      name = "Lute",
      rev = "v1.0.1-nightly.20261115",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      target = "batteries",
      dependencies = {},
    },
  },
}
