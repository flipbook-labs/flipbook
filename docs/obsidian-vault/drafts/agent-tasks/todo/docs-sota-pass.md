# Plan — state-of-the-art docs pass (coverage, quality, screenshot affordances)

> [!note]
> Self-contained brief for a fresh agent (written for an Opus-class model). Build-excluded (`drafts/`). Status: **completed 2026-07-02**; see the hand-back at the bottom.
> Three outcomes: (1) user-facing docs cover every core feature, (2) existing pages meet a professional technical-writing bar, (3) machine-readable screenshot placeholders thread through the docs so a separate auto-screenshotting skill can fill them in later. The screenshot skill does not exist yet; your job is only the affordances.

## Read First, in This Order

1. **`.agents/skills/write-docs/SKILL.md`** (this branch). The authoritative house style. The hard rules you will most likely trip on: no em dashes anywhere, Title Case headings, wikilinks for internal links, `> [!seealso]` at the bottom of the page, sidebar order comes from `index.md` link lists (never `sidebar_position`), and the accuracy bar: never state a behavior you have not traced to source.
2. **`docs/code-samples/README.md`**. The `code-sample` fenced-block mechanism that embeds real Luau from `workspace/code-samples/src/`. All new examples use it; never hand-write a fenced `lua` block for anything longer than a fragment.
3. **`drafts/agent-tasks/todo/docs-review-brief.md`**. A prior accuracy pass over the Track A pages came back clean. Do not re-litigate those checks; do preserve their conclusions when you edit those pages.
4. **The knowledgebase branch `origin/claude-skills-library`** (unmerged; do not check it out or merge it). Read skills with `git show origin/claude-skills-library:.agents/skills/<name>/SKILL.md`. Most useful here:
   - `flipbook-domain-reference`: story/storybook contracts, the six rendering paths, the 11 control types, ModuleLoader hot-reload semantics. Your fastest route to domain fluency.
   - `flipbook-architecture-contract`: the Pluginlike abstraction and the embedding architecture behind PR #582 (needed for W2).
   - `run-flipbook-checks` and `flipbook-validation-and-qa`: validation commands and what counts as evidence.
   - `flipbook-docs-and-writing`: useful estate map, but it was written against an older docs layout. Where it conflicts with `.agents/skills/write-docs/SKILL.md` or with the repo as it stands (the site lives at `docs/site/`, not `docs/`), the local skill and the repo win.

> [!warning]
> `wally.toml` pins Storyteller 1.12.0. The vendored copy under `Packages/_Index` can lag behind the pin until an install refreshes it, so confirm the pinned version in `wally.toml` (not the `_Index` folder name) and read the matching source. Treat every factual claim in this brief the same way: it came from an exploration pass, so verify in source before it lands in a page.

## Ground Rules

- **Accuracy bar.** Every behavior, property, default, and signature traces to a specific file in `src/`, `workspace/flipbook-core/src/`, or the pinned Storyteller package. Tag non-obvious claims with `<!-- src: path:line -->` while drafting; strip them before finishing a page.
- **Scope of polish.** `usage/`, `api/`, and `concepts/` get the full treatment. Do not restyle `engineering/` or `product/` working notes. Do not scrub banned words from human-written prose; the banlist constrains only text you generate.
- **New example code** goes in `workspace/code-samples/src/`, must pass `lute run analyze`, and is embedded via `code-sample` fences (line-range fragments like `#L4-L13` where a slice reads better than the whole file).
- **Commits** are granular, forward-only, `docs:`-prefixed, matching the branch's existing log. Never rewrite history.
- **When this brief and the source disagree, the source wins.** When a review suggestion below turns out to be wrong on inspection, drop it and note that in the hand-back.

## The Screenshot Placeholder Convention

This is the contract between the docs and the future auto-screenshotting skill. Design goals: placeholders must be invisible to readers, survive both renderers, be machine-findable, and carry enough context that a capture agent needs nothing but the comment.

**Format.** A single HTML comment holding one JSON object, placed exactly where the image belongs:

```
<!-- capture {
  "asset": "assets/controls-panel-all-types.png",
  "kind": "story",
  "story": "workspace/code-samples/src/Controls/AllControls.story.luau",
  "setup": ["open the story", "expand the controls panel"],
  "frame": "canvas+controls",
  "theme": "dark",
  "alt": "The controls panel showing every control type"
} -->
```

Fields:

- `asset`: vault-relative output path under `assets/`, kebab-case, descriptive, stable across recaptures.
- `kind`: `story` (Flipbook canvas rendering a story; the auto-capture skill's home turf), `plugin` (the whole Flipbook plugin window, e.g. topbar or settings screen), `studio` (other Roblox Studio UI, e.g. the Explorer tree), or `external` (web UIs, code editors; out of reach for the capture skill, filled by a human).
- `story`: repo-relative path to the `.story.luau` that produces the visual. Required for `story` and `plugin` kinds. The story must exist; if no current story renders what the page needs, add one under `workspace/code-samples/src/` (it then doubles as a code sample).
- `setup`: ordered human-readable steps to reach the desired state (control values to set, panels to open, buttons to hover).
- `frame`: `canvas` (story viewport only), `canvas+controls`, or `plugin-window`.
- `theme`: `dark` or `light`. Default `dark` to match the existing screenshots.
- `alt`: the alt/caption text. Obsidian `![[...]]` embeds carry no alt, so the manifest is where it lives.

**Lifecycle.** Before capture, the comment stands alone. The capture agent writes the image to `docs/obsidian-vault/assets/`, then inserts `![[assets/<name>.png]]` on the line directly after the comment. The comment stays permanently: it is the regeneration manifest that lets future runs recapture every image after a UI change.

**Retrofit.** The five existing embeds (`main-screenshot.png`, `storybook-setup.png`, `first-story.png`, `button-with-controls.png`, `button-with-controls-changed.png`) get a `capture` manifest inserted on the line above them, so the pipeline can regenerate them too.

**Build safety.** `docs/site/docusaurus.config.ts` sets `markdown.format: "detect"`, so `.md` pages parse as CommonMark and HTML comments pass through harmlessly. After inserting the first placeholder, run the site build and confirm no warning references it; spot-check one built page to confirm the comment does not render visibly.

**The work list for the capture agent.** After all placeholders are in, write `drafts/agent-tasks/todo/capture-screenshots.md`: a self-contained brief in the style of this one that (a) documents the convention above verbatim, (b) tables every manifest in the vault (page path, section, asset name, kind), and (c) states the recapture rule (comment is the source of truth; embed line follows it). Generate the table by grepping for `<!-- capture`, not from memory.

## Work Items

### W1: The Flipbook Interface Page (New)

The largest coverage gap: nothing documents the plugin UI itself. Create `usage/the-flipbook-interface.md` covering, source-grounded:

- Layout overview: sidebar, canvas, topbar, controls panel, and that the sidebar and controls panel resize by dragging (`workspace/flipbook-core/src/Panels/`).
- Sidebar: the story tree, search filtering, what the icons mean, unavailable/orphaned stories (cross-link `concepts/storybook`).
- Canvas and zoom: zoom in/out controls and live-reload on edit.
- Topbar actions: view source code, preview in viewport, view in explorer, theme selector, embed into experience (cross-link W2), help menu (about, feedback, logs), settings.
- Settings: every entry in `workspace/flipbook-core/src/UserSettings/defaultSettings.luau` (theme, sidebar width, controls height, remember last opened story, anonymous usage data). This is also where telemetry gets its user-facing sentence: what is collected, and that it is opt-out-able. Verify against `workspace/flipbook-core/src/Telemetry/`.

Screenshot placeholders: one `plugin`-kind full-window shot up top, then one per major section (sidebar with search active, topbar, settings screen). Add the page to `usage/index.md` right after Getting Started, and consider a pointer from `getting-started.md`'s Next Steps.

### W2: Embedding Guide (New)

PR #582 shipped "Embed into Experience" with zero user-facing docs; only `engineering/storybook-embedding/` notes exist (background reading, not citable). Create `usage/embedding-flipbook.md`:

- What embedding is and when to reach for it versus [[usage/deploying-storybooks|Deploying Storybooks]]; cross-link both ways.
- How to embed via the topbar dialog (`workspace/flipbook-core/src/Embedding/EmbedIntoExperienceDialog.luau`) and what gets added to the DataModel (starter scripts, the tagged runtime folder).
- What differs in embedded mode (verify in source; the exploration pass says viewport preview is hidden while everything else works, and `AppMode` in `workspace/flipbook-core/src/Enums/AppMode.luau` is the switch).
- How to remove the embedded runtime.

Placeholders: the embed dialog (`plugin`) and Flipbook running inside an experience (`external`). Add to `usage/index.md` under Going Further.

### W3: API Reference Deepening

- **`api/story-props.md`**: currently a bare table with an empty example. Add a sentence per prop explaining when you would use it (e.g. `container` for manual parenting instead of returning an Instance), document the valid `theme` values from source, and replace the empty example with a `code-sample` of a story that actually reads its props (add the backing sample if none exists).
- **`api/story-format.md`**: give the example a real body. Document the cleanup-function return shape here if it is missing (it is currently mentioned in `concepts/story` and the Hoarcekat guide but check whether the format page itself covers it; verify the shape against the pinned Storyteller's renderers before writing).
- **`api/storybook-format.md`**: `mapStory` exists in the pinned Storyteller types and Flipbook's own `workspace/flipbook-core/src/init.storybook.luau` uses it, but the page does not document it. Add it (and `mapDefinition` if the pinned version really supports it) with a real example, likely a slice of Flipbook's own storybook. Expand the main example to show `name` and `packages` alongside `storyRoots`. For the legacy-support note: state that migration to `packages` is recommended and legacy properties are slated for removal, but do not invent a version or timeline the source does not support.

### W4: De-Stub the Concepts Section

- **`concepts/storyteller.md`** is one sentence pointing at an engineering proposal. Write two to three paragraphs: Storyteller is the library that discovers and loads Story and Storybook modules and provides the control constructors and types; you meet it directly in [[usage/controls|Controls]] and [[usage/typechecking|Typechecking]]. Link the proposal as background, not as the content.
- **`concepts/module-loader.md`**: explain locally what it does (fresh `require` on reload, which is why previews update on save) instead of only forward-linking.
- **`concepts/react.md`, `concepts/fusion.md`, `concepts/roact.md`, `concepts/storybook-js.md`, `concepts/hoarcekat.md`, `concepts/ui-labs.md`**: several carry stub notes. Give each two to four grounded sentences (what it is, its relationship to Flipbook, where to go next) and remove the stub notes. If one genuinely has nothing to say, propose deleting it in the hand-back rather than leaving a stub; check `obsidian backlinks` first.
- **Dedupe rule**: concepts pages explain the why and link out; property tables live only in `api/`. Where `concepts/story.md` or `concepts/storybook.md` duplicate format tables, trim to a summary plus a wikilink.

### W5: Usage Page Upgrades

Advisory list from a tech-writer review pass. Verify each against source and current page text before acting; drop what does not hold up.

- **`getting-started.md`**: add a short prerequisites note (Studio, ModuleScript familiarity, Rojo optional); clarify where the Storybook and Story ModuleScripts conventionally live relative to the component; extend Next Steps with a pointer to the frameworks section and the new interface page.
- **`writing-stories.md`**: add a table of what a story function may return (Instance, cleanup function, framework element via the configured packages), verified against the pinned Storyteller's renderers and `loadStoryModule`; settle terminology (pick "UI framework" or "UI library" and use it consistently); make clear which files in the walkthrough the reader creates versus already has.
- **`controls.md`**: state early that constructors come from Storyteller and link [[usage/typechecking|Typechecking]]; call out live-reload on control change as the core workflow beat.
- **`typechecking.md`**: open with the motivation (shape mistakes surface at plugin load time; annotations surface them in the editor); show the Wally dependency line; show what `T` is for each framework variant.
- **`deploying-storybooks.md`**: add a two-sentence intro stating who this is for (sharing live previews with designers and QA without Studio); add guidance on choosing between the production and per-PR environments; add a short troubleshooting subsection for the failure modes the workflow actually reports.
- **`frameworks/index.md`**: expand the Default-versus-Storyteller-variant explanation into when-to-pick-which guidance; verify the claim about a planned dedicated `Flipbook` package (link `engineering/proposals/create-flipbook-package` if that is the source, or cut it).
- **`frameworks/react.md` / `fusion.md` / `roact.md`**: one or two orienting sentences per page about the framework itself (e.g. jsdotlua's React port for React); resolve the Roact page's mixed message into: archived upstream, supported by Flipbook for existing projects, use React or Fusion for new work.
- **Migration guides**: `migrating-hoarcekat.md` gets a sentence on the non-Rojo path; `migrating-ui-labs.md` states what to do about the unmigrated Object control (verify what actually happens in the pinned migration code before advising); `migrating-storyteller-v1.5.md` states up front whether the old format still works.

### W6: Troubleshooting Page (New)

Create `usage/troubleshooting.md`. Only document failure modes you can trace to real error paths: the story error boundary, Storyteller's load/parse errors, and warnings the logger emits (`workspace/flipbook-core/src/`, plus the pinned Storyteller's error messages). For each: the symptom as the user sees it, the likely cause, the fix. Point readers at Help > Logs for diagnostics. Skip internal-only knobs like `LOG_LEVEL` env injection; plugin users cannot set them. Add to `usage/index.md` at the end. If fewer than four genuinely traceable entries survive verification, fold them into the relevant pages as `> [!warning]` callouts instead of shipping a thin page, and say so in the hand-back.

### W7: Screenshot Placeholder Insertion Map

Insert `capture` manifests at these spots (adjust asset names to taste; keep them stable once chosen). Judgment call throughout: a placeholder is cheap, but each future image must earn its scroll. Aim for at most two per short page; the interface page is the exception.

| Page                              | Location                                          | Asset                                                                                      | Kind                          |
| --------------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------------------- |
| `usage/getting-started.md`        | existing three embeds                             | retrofit manifests above each                                                              | `plugin` / `studio` / `story` |
| `usage/the-flipbook-interface.md` | per W1                                            | `interface-overview`, `interface-sidebar-search`, `interface-topbar`, `interface-settings` | `plugin`                      |
| `usage/controls.md`               | existing two embeds, plus the control-types table | retrofits, plus `controls-panel-all-types`                                                 | `story`                       |
| `usage/writing-stories.md`        | after the first rendered example                  | `writing-stories-first-render`                                                             | `story`                       |
| `usage/frameworks/react.md`       | after the story sample                            | `frameworks-react-button`                                                                  | `story`                       |
| `usage/frameworks/fusion.md`      | after the story sample                            | `frameworks-fusion-button`                                                                 | `story`                       |
| `usage/frameworks/roact.md`       | after the story sample                            | `frameworks-roact-button`                                                                  | `story`                       |
| `usage/embedding-flipbook.md`     | per W2                                            | `embed-dialog`, `embedded-in-experience`                                                   | `plugin` / `external`         |
| `usage/deploying-storybooks.md`   | experience creation and env setup steps           | `deploy-creator-hub`, `deploy-github-env`                                                  | `external`                    |
| `usage/typechecking.md`           | after the annotation sample                       | `typechecking-editor-error`                                                                | `external`                    |
| `concepts/story.md`               | the canvas section                                | `concepts-story-canvas`                                                                    | `story`                       |

Backing story for `controls-panel-all-types`: add `workspace/code-samples/src/Controls/AllControls.story.luau` exercising every control type the pinned Storyteller supports (the story-controls campaign skill on the library branch has a template; verify each constructor against the pinned version). It must pass `lute run analyze`.

Finish W7 by writing the capture brief described in the convention section.

### W8: Index and Link Hygiene

New pages go into `usage/index.md`'s link list in reading order (that list is the sidebar order). Update the root `README.md` Usage list if a new page belongs in the top-level map. Run `obsidian unresolved` (after confirming the CLI points at this vault per the write-docs skill) and fix dangling wikilinks. Strip `notion-id` frontmatter from any page you touch that still carries it.

### W9: Validate and Hand Back

- `cd docs/site && npm run build`, then grep the log for broken link/embed warnings (`onBrokenLinks` is `warn`; a zero exit proves nothing).
- `cd docs/site && npm run format` (Prettier preserves prose wrap; do not fold callout lines).
- `lute run analyze` and `lute run lint` if you added or changed any Luau under `workspace/code-samples/`.
- Hand back: pages added and changed with one line of why each, every claim you could not verify (removed or flagged, never left unbacked), review suggestions from W5 you rejected on inspection, and a pointer to the capture brief.

## Suggested Order

W1 and W2 (new coverage, highest value) → W3 and W4 (reference depth) → W5 and W6 (page upgrades) → W7 (placeholders, which depend on final page structure) → W8 and W9. Commit per work item or per page, not one megacommit.

## Hand-Back (2026-07-02)

All nine work items landed, one commit per item.

**Pages added:** `usage/the-flipbook-interface.md` (plugin UI tour with the settings table from `defaultSettings.luau`), `usage/embedding-flipbook.md` (Embed into Experience flow, play-mode behavior including character auto-loading being disabled, removal), `usage/troubleshooting.md` (the story/storybook load errors with their exact message text from Storyteller's loaders).

**Pages deepened:** the three `api/` pages (per-prop StoryProps guidance including the undocumented `widget` prop, story return shapes with the cleanup contract and Hoarcekat arity rule, `mapStory`/`mapDefinition` with a new MapStory sample), six `concepts/` stubs, and targeted edits across `usage/` (prerequisites, next steps, non-Rojo path, `createObjectControl` pointer for UI Labs Object controls, one em-dash fix).

**Samples added:** `workspace/code-samples/src/MapStory/` and `workspace/code-samples/src/Controls/` (the AllControls capture target). Both pass luau-lsp analysis, StyLua, and Selene.

**Capture affordances:** 19 manifests across 11 pages, including retrofits on all five existing screenshots. Work list and convention: [[drafts/agent-tasks/todo/capture-screenshots|capture-screenshots]].

**Claims verified against Storyteller 1.12.0** after discovering the vendored `_Index` copy had been 1.11.0 (stale install, since refreshed): mapStory/mapDefinition types and renderer coverage (React and Roact only), manual-renderer cleanup and arity behavior, theme values, control constructor exports. All held.

**Review suggestions rejected on inspection:** a framework-comparison decision table (readers arrive with a framework; the variant guidance in `usage/frameworks/index.md` already covers the real choice), a deploy-failure troubleshooting subsection (the failure modes live in flipbook-cli's repo, not this one, so nothing was traceable to source), documenting the `props` field on the Story type (present in `types.luau` but no consumer found in the renderers), and a "which environment" guide for the GitHub Action examples (generic GitHub knowledge).

**Known leftovers:** `wally.lock` carries an uncommitted UILabs re-resolution from a parallel session (not committed here; decide its fate separately). `lute run analyze` fails on pre-existing type errors in vendored `LuauPackages` on a clean tree; the new samples were checked directly with luau-lsp instead. The full site build passed with no broken-link warnings and zero capture-comment leakage into the built HTML.
