# Brief — capture the screenshots the docs are staged for

> [!note]
> Self-contained brief for the auto-screenshotting agent. Build-excluded (`drafts/`). Status: **not started**. The docs pages already carry machine-readable placeholder manifests at every spot an image belongs; your job is to produce the images and slot them in.

## The Manifest Convention

Every image site in the vault is marked by one HTML comment holding one JSON object:

```
<!-- capture {
  "asset": "assets/controls-panel-all-types.png",
  "kind": "story",
  "story": "workspace/code-samples/src/Controls/AllControls.story.luau",
  "setup": ["open the AllControls story", "expand the controls panel so every control row is visible"],
  "frame": "canvas+controls",
  "theme": "dark",
  "alt": "The controls panel showing one control of every type"
} -->
```

Fields:

- `asset`: vault-relative output path. Write the PNG to `docs/obsidian-vault/assets/<name>.png`, overwriting any existing file (some manifests regenerate screenshots that already exist).
- `kind`: what capture surface is needed.
  - `story`: the Flipbook canvas rendering the referenced story. Your primary case.
  - `plugin`: the whole Flipbook plugin window (topbar, sidebar, and canvas together).
  - `studio`: other Roblox Studio UI, like the Explorer tree.
  - `external`: web pages or code editors. Out of your reach; skip these and list them in your hand-back for a human.
- `story`: repo-root-relative path to the `.story.luau` module that produces the visual. Open it via the Storybook that covers its folder (each `workspace/code-samples/src/<Folder>/` has its own `.storybook` module).
- `setup`: ordered steps to reach the desired state before capturing.
- `frame`: `canvas` (story viewport only), `canvas+controls` (viewport plus the controls panel), or `plugin-window` (everything).
- `theme`: `dark` or `light`. Set Flipbook's theme in Settings before capturing.
- `alt`: descriptive text for the image. Keep it with the manifest; the Obsidian embed syntax cannot carry it.

## What To Do per Manifest

1. Reach the state described by `kind`, `story`, `setup`, `frame`, and `theme`.
2. Capture the PNG and write it to the `asset` path under `docs/obsidian-vault/`.
3. If the line after the closing `-->` is not already an `![[assets/<name>.png]]` embed, insert one there. Leave the comment in place permanently: it is the regeneration manifest that lets a future run recapture every image after a UI change.

## Finding the Manifests

Generate your work list fresh rather than trusting this file to be current:

```sh
grep -rn '<!-- capture {' docs/obsidian-vault --include="*.md" | grep -v drafts/
```

Exclude `drafts/`: the only hits there are the convention examples in these briefs.

As of 2026-07-02 that finds 19 manifests across 11 pages:

| Page                              | Asset                              | Kind     |
| --------------------------------- | ---------------------------------- | -------- |
| `usage/getting-started.md`        | `main-screenshot.png`              | plugin   |
| `usage/getting-started.md`        | `storybook-setup.png`              | studio   |
| `usage/getting-started.md`        | `first-story.png`                  | story    |
| `usage/the-flipbook-interface.md` | `interface-overview.png`           | plugin   |
| `usage/the-flipbook-interface.md` | `interface-sidebar-search.png`     | plugin   |
| `usage/the-flipbook-interface.md` | `interface-settings.png`           | plugin   |
| `usage/controls.md`               | `button-with-controls.png`         | story    |
| `usage/controls.md`               | `button-with-controls-changed.png` | story    |
| `usage/controls.md`               | `controls-panel-all-types.png`     | story    |
| `usage/writing-stories.md`        | `writing-stories-first-render.png` | story    |
| `usage/frameworks/react.md`       | `frameworks-react-button.png`      | story    |
| `usage/frameworks/fusion.md`      | `frameworks-fusion-button.png`     | story    |
| `usage/frameworks/roact.md`       | `frameworks-roact-button.png`      | story    |
| `usage/embedding-flipbook.md`     | `embed-dialog.png`                 | plugin   |
| `usage/embedding-flipbook.md`     | `embedded-in-experience.png`       | external |
| `usage/deploying-storybooks.md`   | `deploy-creator-hub.png`           | external |
| `usage/deploying-storybooks.md`   | `deploy-github-env.png`            | external |
| `usage/typechecking.md`           | `typechecking-editor-error.png`    | external |
| `concepts/story.md`               | `concepts-story-canvas.png`        | story    |

## Environment Notes

- The referenced stories all live under `workspace/code-samples/src/`, which loads into Flipbook when you open this repo's test place. `.agents/skills/setup-flipbook-dev-env` and `.agents/skills/run-flipbook-checks` cover getting a dev build running.
- Capture at a consistent window size across the set so the docs feel uniform. Existing screenshots in `docs/obsidian-vault/assets/` show the established look.
- Five manifests regenerate existing images (`main-screenshot`, `storybook-setup`, `first-story`, `button-with-controls`, `button-with-controls-changed`). Match or improve on what they show; the manifest text is the authority on the desired state.

## Verify

- Every non-`external` manifest has its PNG on disk and an embed line after the comment.
- `cd docs/site && npm run build`, then grep the log for missing-image warnings.

## Hand Back

List each asset written, each `external` manifest skipped for a human, and any manifest whose setup steps did not work as described (fix the manifest text if the UI has drifted, and say so).
