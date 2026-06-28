---
aliases: [Pre-v1.5 Controls]
linter-yaml-title-alias: Pre-v1.5 Controls
---

# Pre-v1.5 Controls

Before v1.5, Flipbook used a simpler controls format where arrays were treated as implicit selection lists. This format is still supported at runtime — Flipbook automatically migrates it when loading your stories — but upgrading to the current syntax is recommended for clarity and type-safety.

## What Changed

In the old format, you could pass an array directly as a control value. Flipbook would interpret it as a list of options with the first item selected by default:

```code-sample
workspace/code-samples/src/MigrationStorytellerV15/BeforeImplicitSelect.luau
```

The equivalent in the current format uses an explicit constructor:

```code-sample
workspace/code-samples/src/MigrationStorytellerV15/AfterExplicitSelect.luau
```

Primitive values (`string`, `number`, `boolean`) work the same in both formats and do not need to be changed.

## Upgrading

Here's a story using the old format alongside its equivalent using the current constructors:

```code-sample
workspace/code-samples/src/MigrationStorytellerV15/UpgradingBefore.luau
```

```code-sample
workspace/code-samples/src/MigrationStorytellerV15/UpgradingAfter.luau
```

> [!tip]
> The explicit constructor functions unlock additional options that aren't available in the old format, such as custom sort functions, display label overrides via `tostring`, and the full range of new control types like Color, Date, Slider, Radio, MultiSelect, and Check.

## No Action Required

If you're not ready to upgrade, your existing stories will continue to work without any changes. Flipbook performs the migration automatically at load time, so there's no breaking change.

> [!seealso]
> [[usage/controls|Controls]] · [[usage/migration-guides/index|Migration Guides]]
