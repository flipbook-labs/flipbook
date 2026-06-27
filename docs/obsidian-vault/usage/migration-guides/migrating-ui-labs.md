---
aliases: [UI Labs]
linter-yaml-title-alias: UI Labs
---

# Migrating from UI Labs

[UI Labs](https://github.com/PepeElToro41/ui-labs) is another storybook plugin for Roblox. Flipbook's compatibility with it centers on **controls**: when Flipbook loads a Story whose controls are written the UI Labs way, it migrates them to its own format automatically, so existing controls keep working without changes.

## Controls Migrate Automatically

A UI Labs controls schema is a table where each entry is an object with a `ControlValue`. Flipbook detects that shape when it loads the Story and converts each control to the matching native one:

| UI Labs control | Flipbook control | Notes                                                                       |
| --------------- | ---------------- | --------------------------------------------------------------------------- |
| `String`        | String           |                                                                             |
| `Number`        | Number           | `Min`/`Max` become the `range`, `Step` becomes `step`                       |
| `Boolean`       | Boolean          |                                                                             |
| `Slider`        | Slider           | `Min`/`Max` become the `range`, `Step` becomes `step`                       |
| `Choose`        | Select           | the choices become the `items`; the default comes from `DefIndex`           |
| `EnumList`      | Select           | the `items` are the list's keys (sorted); the default comes from `DefIndex` |
| `RGBA`          | Color            | only the color carries over, so **transparency is dropped**                 |
| `Object`        | (none)           | **not migrated**; rewrite it as a different control or remove it            |

Because this happens automatically, a Story brought over from UI Labs will often render with working controls as soon as Flipbook discovers it.

## Writing Controls Natively

To move off the UI Labs schema entirely, rewrite your controls with Flipbook's own constructors. For example, a UI Labs `Choose` becomes a `createSelectControl`:

```lua
-- UI Labs
controls = {
	variant = UILabs.Choose({ "Primary", "Secondary" }),
}

-- Flipbook
local Storyteller = require(path.to.Storyteller)

controls = {
	variant = Storyteller.createSelectControl({ "Primary", "Secondary" }),
}
```

See [[usage/controls|Controls]] for the full set of control types and their constructors.

## Converting the Story

UI Labs and Flipbook both use the `.story` extension, but the module's return shape differs. Write your Story in Flipbook's [[api/story-format|Story Format]] (a table with a `story` function) and add a [[concepts/storybook|Storybook]] with `storyRoots` so Flipbook can discover it. See [[usage/writing-stories|Writing Stories]] for the details.

> [!seealso]
> [[usage/controls|Controls]] · [[usage/writing-stories|Writing Stories]] · [[usage/migration-guides/migrating-hoarcekat|Migrating from Hoarcekat]]
