return {
  version = 3,
  dependencies = {
    FlipbookBatteries = "FlipbookBatteries@v0.10.1",
    Lute = "Lute@v1.0.1-nightly.20260508",
  },
  packages = {
    ["FlipbookBatteries@v0.10.1"] = {
      installPath = "@pkg/FlipbookBatteries@v0.10.1",
      name = "FlipbookBatteries",
      rev = "v0.10.1",
      source = "https://github.com/flipbook-labs/flipbook-batteries",
      sourceKind = "github",
      dependencies = {
        Lute = "Lute@v1.0.1-nightly.20260508",
      },
    },
    ["Lute@v1.0.1-nightly.20260508"] = {
      installPath = "@pkg/Lute@v1.0.1-nightly.20260508",
      name = "Lute",
      rev = "v1.0.1-nightly.20260508",
      source = "https://github.com/luau-lang/lute",
      sourceKind = "github",
      dependencies = {},
    },
  },
}
