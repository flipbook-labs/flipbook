return {
  version = 2,
  dependencies = {
    ["Lute@v1.0.0"] = {
      installPath = "Packages/Lute@v1.0.0",
      name = "Lute",
      rev = "v1.0.0",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
    ["dotenv@v0.1.0"] = {
      installPath = "Packages/dotenv@v0.1.0",
      name = "dotenv",
      rev = "v0.1.0",
      source = "https://github.com/erlcx/lute-dotenv",
      sourceKind = "github",
      dependencies = {},
    },
    ["flipbook-batteries@v0.9.0"] = {
      installPath = "Packages/flipbook-batteries@v0.9.0",
      name = "flipbook-batteries",
      rev = "v0.9.0",
      source = "https://github.com/flipbook-labs/flipbook-batteries",
      sourceKind = "github",
      dependencies = {
        Lute = "Lute@v1.0.0",
      },
    },
    ["lute@v1.0.0"] = {
      installPath = "Packages/lute@v1.0.0",
      name = "lute",
      rev = "v1.0.0",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
  },
  packages = {"flipbook-batteries@v0.9.0", "dotenv@v0.1.0", "lute@v1.0.0"},
}
