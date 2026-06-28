return {
  version = 3,
  dependencies = {
    dotenv = "dotenv@v0.1.0",
    ["flipbook-batteries"] = "flipbook-batteries@v0.11.1",
    lute = "lute@v1.0.1-nightly.20260612",
  },
  packages = {
    ["Lute@v1.0.1-nightly.20260612"] = {
      installPath = "@pkg/Lute@v1.0.1-nightly.20260612",
      name = "Lute",
      rev = "v1.0.1-nightly.20260612",
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
    ["flipbook-batteries@v0.11.1"] = {
      installPath = "@pkg/flipbook-batteries@v0.11.1",
      name = "flipbook-batteries",
      rev = "v0.11.1",
      source = "https://github.com/flipbook-labs/flipbook-batteries",
      sourceKind = "github",
      dependencies = {
        Lute = "Lute@v1.0.1-nightly.20260612",
      },
    },
    ["lute@v1.0.1-nightly.20260612"] = {
      installPath = "@pkg/lute@v1.0.1-nightly.20260612",
      name = "lute",
      rev = "v1.0.1-nightly.20260612",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
  },
}
