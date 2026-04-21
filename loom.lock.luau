return {
  version = 2,
  dependencies = {
    ["Lute@v1.0.1-nightly.20260420"] = {
      installPath = "Packages/Lute@v1.0.1-nightly.20260420",
      name = "Lute",
      rev = "v1.0.1-nightly.20260420",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
    ["flipbook-batteries@bump-lute-to-1.0.1-nightly"] = {
      installPath = "Packages/flipbook-batteries@bump-lute-to-1.0.1-nightly",
      name = "flipbook-batteries",
      rev = "bump-lute-to-1.0.1-nightly",
      source = "https://github.com/flipbook-labs/flipbook-batteries",
      sourceKind = "github",
      dependencies = {
        Lute = "Lute@v1.0.1-nightly.20260420",
      },
    },
    ["lute@v1.0.1-nightly.20260420"] = {
      installPath = "Packages/lute@v1.0.1-nightly.20260420",
      name = "lute",
      rev = "v1.0.1-nightly.20260420",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
  },
  packages = {"flipbook-batteries@bump-lute-to-1.0.1-nightly", "lute@v1.0.1-nightly.20260420"},
}
