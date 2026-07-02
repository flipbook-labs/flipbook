---
name: flipbook-domain-reference
description: "Story/Storybook formats and contracts, Storyteller architecture, module reload semantics, plugin security contexts, React-in-Roblox essentials, 11 control types. Use when: explaining how stories work, debugging story loading, learning the UI framework contract, understanding why hot-reload can break, implementing new story/control features, or advising on embedding."
---

# Flipbook Domain Reference

This skill covers the storybook domain concepts you need to debug, extend, or validate Flipbook at a production standard. Audience: zero-context mid-level Roblox engineer already fluent in Luau, the Instance model, Rojo, and Wally.

## Stories and Storybooks: The Contract

A **story** is a ModuleScript whose filename ends in `.story.luau` that exports a table with a `story` function. A **storybook** is a ModuleScript with filename ending in `.storybook.luau` that tells Flipbook where to find stories and what packages to make available.

Discovery patterns (from `wally.toml`-pinned Storyteller 1.12.0; as of 2026-07-01, `Packages/_Index/` contains built cache with 1.11.0):
- Story pattern: `%.story$` (file ends with `.story.luau`)
- Storybook pattern: `%.storybook$` (file ends with `.storybook.luau`)

### Story Format (The Return Value)

A story module returns a table (type `Storyteller.Story<T>`) with this shape:

```luau
return {
  story = function(props: Storyteller.StoryProps) -> T end,  -- Required.
  name = string?,        -- Optional; display name (defaults to module name)
  summary = string?,     -- Optional; brief description
  controls = Storyteller.StoryControlsSchema?,  -- Optional; control definitions
  packages = Storyteller.StoryPackages?,        -- Optional; override storybook packages
  props = { [string]: any }?,                   -- Optional; static props merged before controls
}
```

The `story` function receives a `props` object and must return one of six supported UI types (see "Story Formats by Framework" below). The `props` object contains:
- `props.container: Instance` — parent GuiObject or Folder to render into (reserved by Storyteller)
- `props.controls: StoryControls?` — current control values after user interaction (reserved by Storyteller)
- `props.theme: string` — "Light" or "Dark" (from Flipbook's theme setting)
- `props.locale: string` — e.g. "en-us" (from Flipbook's locale setting)
- `props.plugin: Pluginlike?` — mock Plugin object (only when Flipbook runs embedded in an experience)
- `props.widget: GuiBase2d?` — containing widget (only when Flipbook runs as a Studio plugin)
- Plus: merged static props from `props` field (story definition) and user-modified controls

The return type `T` depends on the framework: React elements, Roact elements, Fusion values, raw Instances, or functions returning any of those.

**Example (React):**

```luau
local React = require("@pkg/React")
local MyButton = require("./MyButton")

return {
  story = function(props)
    return React.createElement(MyButton, {
      text = props.controls.buttonText,
      onActivated = function()
        print("clicked")
      end,
    })
  end,
  controls = {
    buttonText = Storyteller.createStringControl("Click Me"),
  },
}
```

**Example (Raw Instances):**

```luau
return {
  story = function()
    local button = Instance.new("TextButton")
    button.Text = "Button"
    button.TextSize = 16
    button.Size = UDim2.fromOffset(200, 40)
    return button
  end,
}
```

### Storybook Format (Discovery Metadata)

A storybook module returns a table (type `Storyteller.Storybook`) with:

```luau
return {
  storyRoots = { Instance, ... },  -- Required. Folders where story modules live.
  name = string?,                   -- Optional. Defaults to module name.
  packages = Storyteller.StoryPackages?,  -- Optional. Dict of package name → value.
  mapStory = ((story: any) -> (props: StoryProps) -> any)?,   -- Optional. Transform story.
  mapDefinition = ((story: any) -> any)?,  -- Optional. Transform story table.
}
```

The `storyRoots` array tells Flipbook which folders to scan (recursively) for `.story.luau` modules. If a story declares its own `packages` field, it overrides this storybook's packages for that story only.

**Example:**

```luau
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
  name = "React",
  storyRoots = {
    script.Parent,  -- Scan this folder (and subfolders) for .story.luau
  },
  packages = {
    React = React,
    ReactRoblox = ReactRoblox,
  },
}
```

A story does not strictly need a storybook; Flipbook surfaces orphaned stories under an "Unavailable Stories" folder in the sidebar. But without a storybook, stories cannot access injected packages.

### Stories Without Storybooks

If a story file has no covering storybook (no storybook declares its parent folder in `storyRoots`), Flipbook still discovers and renders it—it simply appears in a special "Unavailable Stories" group in the tree. This is useful for quick prototyping, though production stories should always have a storybook.

## Story Formats by Framework

Flipbook supports six rendering paths. The `story` function's return type determines which.

### React (jsdotlua 17.x)

Return a React element (result of `React.createElement`):

```luau
local React = require("@pkg/React")
local Button = require("./Button")

return {
  story = function()
    return React.createElement(Button, { text = "Click" })
  end,
}
```

Flipbook uses `ReactRoblox` to mount React elements into a container GuiObject. The element lifecycle follows React rules: render, update, unmount.

### Roact (1.4.x)

Return a Roact element (result of `Roact.createElement`):

```luau
local Roact = require("@pkg/Roact")
local Button = require("./Button")

return {
  story = function()
    return Roact.createElement(Button, { text = "Click" })
  end,
}
```

### Fusion (0.2.x)

Return a Fusion value (result of `Fusion.New` or a function returning one):

```luau
local Fusion = require("@pkg/Fusion")

return {
  story = function()
    local value = Fusion.Value(5)
    return Fusion.New "TextButton" {
      Text = "Count: " .. tostring(value:get()),
      Size = UDim2.fromOffset(200, 40),
    }
  end,
}
```

### Functional (GuiObject Constructor)

Return a function that takes `props` and returns an Instance:

```luau
return {
  story = function()
    local container = Instance.new("Frame")
    container.Size = UDim2.fromScale(1, 1)
    return container
  end,
}
```

### Legacy Manual (Function Taking Container)

Return a function with signature `(container: Instance, props: any) -> cleanup_fn?`:

```luau
return {
  story = function(props)
    return function(container)
      local label = Instance.new("TextLabel")
      label.Text = "Manual render"
      label.Parent = container
      
      return function()
        label:Destroy()
      end
    end
  end,
}
```

This signature is deprecated but still supported. The cleanup function is called when the story unmounts.

### Hoarcekat (Story File as Render Function)

If the entire story module exports a render function (no `story` key), Flipbook treats it as a legacy format:

```luau
return function(props)
  return Instance.new("TextLabel") { Text = "Label" }
end
```

Support exists for backward compatibility. New stories should use the `story` key.

## Storyteller Contracts and Lifecycle

**Storyteller** is the library that discovers, loads, and renders stories. Flipbook depends on it for the core story engine. ModuleLoader sits below Storyteller to handle the require-cache bypass.

### Discovery and Loading

Storyteller exports these key discovery functions (wally.toml pins Storyteller 1.12.0; verify installed version with `ls Packages/_Index | grep storyteller`):

- `isStorybookModule(instance: Instance) -> boolean` — test if an Instance is a `.storybook.luau` module
- `isStoryModule(instance: Instance) -> boolean` — test if an Instance is a `.story.luau` module
- `findStorybookModules(parent: Instance) -> { ModuleScript }` — recursive search for storybooks under `parent`
- `loadStorybookModule(loader: ModuleLoader, storybookModule: ModuleScript) -> Storybook` — validate and return storybook table
- `loadStoryModule(loader: ModuleLoader, storyModule: ModuleScript, storybook: Storybook?) -> LoadedStory<T>` — validate and return story table

The `loader` is a ModuleLoader instance (see "ModuleLoader" section below). Storyteller calls `loader:require(moduleScript)` instead of the built-in `require()` to bypass Roblox's cache.

### Render Lifecycle

When you open a story in Flipbook, Storyteller calls the `story` function with a props object, captures the return value, and hands it to a **renderer** (React, Roact, Fusion, or custom). The renderer then mounts the value into a container. This lifecycle supports three operations:

1. **Mount** — call `story()` and render result into container
2. **Update** — (optional) re-render with new control values without full unmount
3. **Unmount** — destroy UI and clean up subscriptions

Storyteller's renderer API (type `Storyteller.StoryRenderer<T>`) looks like:

```luau
type StoryRenderer<T> = {
  mount: (container: Instance, story: LoadedStory<T>, initialProps: StoryProps) -> (),
  update: ((props: StoryProps, prevProps: StoryProps?) -> ())?,
  unmount: (() -> ())?,
}
```

Each renderer (React, Roact, Fusion) implements this interface. Custom renderers can be added by implementing the three callbacks.

### Control Schema and Hydration

When a story declares a `controls` field, Storyteller validates it against the schema (type `Storyteller.StoryControlsSchema`), a dict mapping control names to control definitions. Control definitions are either:
- A control object: `{ type = "Boolean", default = true }` (struct with `type` and optional `default`)
- A primitive value: `true`, `"text"`, `42`, `Color3.new(1, 0, 0)` (inferred as a control)

Storyteller's `hydrateControls(schema, overrides)` function merges schema defaults with user-set control values and returns a flat dict of final values passed to the story function.

#### The 11 Control Types

Flipbook supports 11 control types (on main as of 2026-07-01). Each is a discriminated union keyed on `type`:

1. **Boolean** — toggle on/off
   ```luau
   Storyteller.createBooleanControl(default: boolean?) -> BooleanControl
   ```

2. **String** — text input
   ```luau
   Storyteller.createStringControl(default: string?) -> StringControl
   ```

3. **Number** — numeric input with optional step
   ```luau
   Storyteller.createNumberControl(default: number?, options: {step: number?}?) -> NumberControl
   ```

4. **Slider** — range slider (Number with implicit UI hint)
   ```luau
   Storyteller.createSliderControl(default: number?, range: NumberRange?) -> SliderControl
   ```

5. **Color** — color picker
   ```luau
   Storyteller.createColorControl(default: Color3?) -> ColorControl
   ```

6. **Date** — date/datetime picker
   ```luau
   Storyteller.createDateControl(default: DateTime?) -> DateControl
   ```

7. **Select** — dropdown (single choice from items list)
   ```luau
   Storyteller.createSelectControl(items: { T }, options: {default: T?, tostring: (T) -> string?, sort: (T, T) -> bool?}?) -> SelectControl
   ```

8. **Radio** — radio group (single choice, all visible)
   ```luau
   Storyteller.createRadioControl(items: { T }, options: {...}?) -> RadioControl
   ```

9. **MultiSelect** — multiselect list (multiple choices)
   ```luau
   Storyteller.createMultiSelectControl(items: { T }, options: {default: { T }?, ...}?) -> MultiSelectControl
   ```

10. **Check** — checkbox list (multiple boolean flags)
    ```luau
    Storyteller.createCheckControl(items: { T }, options: {...}?) -> CheckControl
    ```

11. **Object** — instance picker (select an Instance from the DataModel)
    ```luau
    Storyteller.createObjectControl(default: Instance?) -> ObjectControl
    ```

See the `flipbook-story-controls-campaign` skill for the detailed fix roadmap for controls and the data-types matrix.

#### Note on Storybook Types (FIXME)

In `workspace/flipbook-core/src/Storybook/types.luau`, the `ExtraStoryProps` type defines `plugin` and `widget` as optional (`?`). The comment notes: "Make these required in the future. Only reason they're not is because we'll need to massage the types in StoryPreview to clear the nil value." This will be required in a future version once StoryPreview is updated.

## ModuleLoader: Bypassing Roblox's Require Cache

**Problem:** Roblox's built-in `require()` caches module return values globally. Once a module is required, subsequent requires return the cached value. In Flipbook, editing a story file should hot-reload the preview; if the module stays cached, you must reload the entire plugin to see changes.

**Solution:** ModuleLoader (https://github.com/flipbook-labs/module-loader) is a library that bypasses the require cache. It stores its own module cache and clears entries on demand, allowing fresh loads.

### How Flipbook Uses It

1. When the user opens a story, Flipbook creates a ModuleLoader instance
2. Storyteller calls `loader:require(storyModule)` instead of the built-in `require()`
3. ModuleLoader walks the Instance tree to find the module and executes it in a fresh environment
4. The story function is called with fresh props; changes to the file are immediately visible

### Side Effects and State Bugs

ModuleLoader enables hot-reload but introduces a subtle pitfall: **instance-level state persists across reloads**. If your story stores UI state in a Charm signal or Fusion value defined at module scope (not inside the `story` function), that state survives a reload and can go stale.

**Example of a stale-state bug:**

```luau
local Fusion = require("@pkg/Fusion")
local value = Fusion.Value(0)  -- Defined at module scope (bad)

return {
  story = function()
    return Fusion.New "TextButton" {
      Text = Fusion.Computed(function()
        return "Count: " .. tostring(value:get())
      end),
      [Fusion.OnEvent "Activated"] = function()
        value:set(value:get() + 1)
      end,
    }
  end,
}
```

On the first run, clicking increments the count. If you edit the file and Flipbook reloads, the old `value` Fusion value still exists, and the new story function will use it. The count will pick up where it left off, which breaks your mental model that editing should reset state.

**The frozen-table workaround:** In `src/PluginStarterScript.plugin.luau`, there is a line `Charm.flags.frozen = false`. This disables Charm's frozen-table detection, which was causing crashes when stale module-scope tables were accessed after a reload (storyteller issue #100). This is not a clean fix but a necessary workaround for a lurking state bug. Do not remove it.

**Best practice:** Keep module-scope variables immutable (requires, constants). Move stateful values inside the `story` function or use a state library that supports reset-on-reload patterns.

## Plugin Security Contexts and Embedding

Flipbook runs in two contexts: **Studio plugin** and **embedded in an experience**. The security model and available APIs differ.

### Studio Plugin Context

When Flipbook loads as a Studio plugin (the default):
- The plugin runs in the plugin's own thread with elevated APIs: `plugin:OpenScript()`, `plugin:GetSetting()`, `plugin:SetSetting()`, etc.
- The `props.plugin` is a real Plugin object (or Pluginlike mock)
- The `props.widget` is the Studio widget container
- The story code can read/write to ServerScriptService, ReplicatedStorage, etc. (full DataModel access)
- HTTP requests respect plugin allow-lists (Flipbook's backend: `apis.flipbooklabs.com`)

### Embedded in an Experience Context

When Flipbook is embedded in a running experience (via the "Embed into Experience" dialog or deploy-storybook):
- Flipbook runs as a client-side LocalScript or in the player's PlayerGui
- The plugin has no elevated APIs; it uses only client-side APIs
- Stories run in the LocalPlayer's thread, subject to the same sandboxing as any game script
- HTTP requests respect the experience's HTTP allow-lists, not the plugin's
- Some Flipbook features (telemetry, backend features) may not work or may work differently
- See `src/EmbeddedClientStarterScript.client.luau` for the entry point

The type `Pluginlike` (from `workspace/flipbook-core/src/Common/types.luau`) is an interface that bridges these: it exports only the subset of Plugin methods Flipbook uses, so the same story code can run in both contexts. When embedded, a mock Pluginlike is passed instead of the real Plugin.

## React in Roblox: ReactRoblox Essentials

Flipbook uses jsdotlua's React 17.x and ReactRoblox to render React stories. The key differences from web React:

1. **Host instances are Roblox GuiObjects**, not DOM nodes. ReactRoblox maps React elements to Roblox Instance properties.
2. **ReactRoblox.createRoot(container)** is the entry point, not `createRoot(document.getElementById(...))`. The container is a GuiObject or Folder.
3. **Event listeners** use Roblox event names: `OnActivated`, `MouseEnter`, `InputBegan`, etc. (in PascalCase, prefixed with `On`).
4. **Styling** maps to Roblox properties: `BackgroundColor3`, `TextColor3`, `Size`, `Position`, `BorderSizePixel`, etc.
5. **No DOM APIs**. No `document`, no `window`, no global fetch (unless proxied). Use Roblox APIs: `game:GetService()`, `:WaitForChild()`, `:FindFirstChild()`, etc.
6. **Refs work similarly** but target Roblox Instances: `ref.current` is a GuiObject.

**Example:**

```luau
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
  story = function()
    return React.createElement("TextButton", {
      Text = "Click Me",
      Size = UDim2.fromOffset(100, 40),
      BackgroundColor3 = Color3.fromRGB(0, 120, 215),
      [React.Event.Activated] = function()
        print("Clicked!")
      end,
    })
  end,
}
```

## Control Store and UI Integration

When Flipbook opens a story with controls, it uses an internal control store (in `workspace/flipbook-core/src/StoryControls/createStoryControlsStore.luau`) to manage state. The store is built on Charm signals:

- `getControlValue(key: string) -> () -> any` — returns a Charm computed signal for a control's value (resolves override or schema default)
- `setControl(key: string, value: any) -> ()` — updates a control value
- `getControls() -> Storyteller.StoryControls` — returns final merged controls passed to the story function

The store is wrapped in a React context (`StoryControlsContext`) and consumed by individual control UI components. Each control subscribes only to its own value via `useSignalState()`, so changing one control does not re-render siblings. This isolation prevents visual flicker and performance issues.

The 11 control UI components live in `workspace/flipbook-core/src/StoryControls/ControlElements/`. Each one reads its value from the store, renders the appropriate Foundation or custom UI, and calls `setControl()` on user interaction.

## Provenance and Maintenance

Re-verify these commands before trusting them:

```bash
# Verify story/storybook patterns from Storyteller
find Packages/_Index -path "*storyteller*" -name "constants.luau" -exec cat {} \;

# Verify story and storybook type contracts
find Packages/_Index -path "*storyteller*" -name "types.luau" | head -1 | xargs cat

# Verify control type enum
find Packages/_Index -path "*storyteller*" -name "ControlType.luau" -exec cat {} \;

# Verify ModuleLoader README (wally.toml pins 0.11.0)
ls Packages/_Index | grep module-loader

# Verify plugin/widget types (ExtraStoryProps FIXME)
cat workspace/flipbook-core/src/Storybook/types.luau

# Verify embedded context entry point
cat src/EmbeddedClientStarterScript.client.luau

# Verify story examples by framework
cat workspace/code-samples/src/React/ReactButton.story.luau
cat workspace/code-samples/src/Roact/RoactButton.story.luau
cat workspace/code-samples/src/Fusion/FusionButton.story.luau
cat workspace/code-samples/src/Default/Button.story.luau
```

**Last verified:** 2026-07-01. Story patterns, control types, and core Storyteller APIs from wally-pinned Storyteller 1.12.0, ModuleLoader 0.11.0 (per `wally.toml` ground truth; `Packages/_Index/` contains built cache which may be stale until `lute run install` re-runs). Examples from /workspace/code-samples/. Types from source.
