return {
  version = 3,
  dependencies = {
    ["flipbook-batteries"] = "flipbook-batteries@v0.10.0",
    lute = "lute@v1.0.1-nightly.20260423",
  },
  packages = {
    ["Lute@v1.0.1-nightly.20260422"] = {
      installPath = "Packages/Lute@v1.0.1-nightly.20260422",
      name = "Lute",
      rev = "v1.0.1-nightly.20260422",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
    ["flipbook-batteries@v0.10.0"] = {
      installPath = "Packages/flipbook-batteries@v0.10.0",
      name = "flipbook-batteries",
      rev = "v0.10.0",
      source = "https://github.com/flipbook-labs/flipbook-batteries",
      sourceKind = "github",
      dependencies = {
        Lute = "Lute@v1.0.1-nightly.20260422",
      },
    },
    ["lute@v1.0.1-nightly.20260423"] = {
      installPath = "Packages/lute@v1.0.1-nightly.20260423",
      name = "lute",
      rev = "v1.0.1-nightly.20260423",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
  },
}
