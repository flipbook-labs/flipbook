# Review brief — critical pass over the new Track A docs

> [!note]
> Self-contained brief for a fresh agent. Job: critically review the docs pages listed below against the house style guide and the source-accuracy bar, and fix what's off. Build-excluded (`drafts/`). These pages were drafted by an AI agent (with maintainer answers folded in), so treat every claim as unverified until you check it.

## Read first

**`.agents/skills/write-docs/SKILL.md`** is the house style guide. Read it fully before touching anything. The two rules most likely to be violated below are the **no-em-dash hard rule** and **Title Case headings**.

Note the skill's scope rule on the banlist: the _banned words_ list (powerful, simply, unlock, etc.) constrains only AI-generated text and you should **not** course-correct human-written prose. But the **em-dash ban is explicitly a hard rule that applies to all prose**, human or not. So: fix em dashes everywhere; only fix banned _words_ in agent-written text.

## Pages in scope

All changed during this effort:

- `concepts/story.md`, `concepts/storybook.md`
- `api/story-format.md`
- `usage/typechecking.md`
- `usage/getting-started.md`, `usage/writing-stories.md`, `usage/controls.md`
- `usage/frameworks/index.md` (+ the pointer paragraphs added to `react.md`, `fusion.md`, `roact.md`)
- `usage/migration-guides/migrating-hoarcekat.md`, `usage/migration-guides/migrating-ui-labs.md`, `usage/migration-guides/index.md`

## Known issues to fix

> [!note]
> The items that were here (em dashes, sentence-case headings, "unlock" word, antithesis framing, rule-of-three padding) were resolved in the committed Track A work. A follow-up session confirmed the sweep landed cleanly — no em dashes, Title Case on all headings, banned words and patterns gone. Skip this section and go straight to the accuracy pass below.

## Accuracy pass (the higher bar)

Per the skill's hard rule, every behavior/signature/default must trace to source. Re-verify, don't trust the draft:

- **`usage/controls.md` control-types table** and **`migrating-ui-labs.md` mapping table** against Storyteller source: `src/controls/ControlTypes.luau`, `src/controls/constructors/*`, and `src/controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau`. Confirm the 11 constructors, their signatures, and the UI Labs mapping (note the two caveats already stated: `Object` is not migrated; `RGBA` → Color drops transparency).
- **`concepts/story.md` renderer return shapes** against `src/renderers/createManualRenderer.luau` and `src/loadStoryModule.luau` (Instance / function-with-cleanup / legacy Hoarcekat wrapping).
- **`usage/typechecking.md`** against Storyteller's exported types (`Storyteller.Story<T>`, `Storyteller.Storybook`, `StoryProps`, the control types).
- **`api/story-format.md`** — the `story` row type and the legacy-mapping table.

**Status (verified in a follow-up session against Storyteller source and the flipbook plugin):**

- All 11 constructor signatures match exactly.
- Renderer return shapes (Instance / cleanup fn / legacy Hoarcekat function wrap) are accurate.
- All types mentioned in `typechecking.md` are exported from Storyteller's `init.luau`.
- Story format fields match `types.luau`; legacy property mapping is accurate.
- UI Labs migration table is accurate per `migrateUILabsControl.luau`.
- **All 11 control types render a UI widget** — confirmed in `workspace/flipbook-core/src/StoryControls/StoryControls.luau` via `resolveControlFromValue` and `StoryControlRow.luau`. The "rendered-UI coverage" concern is resolved; no caveats needed in the table.
- **`UILabs.Choose({ ... })` syntax is correct** — confirmed in `Packages/_Index/pepeeltoro41_ui-labs@2.4.2/ui-labs/src/Controls/AdvancedControls.luau` and the UI Labs docs. Signature is `Choose(list, defIndex?)`.

Nothing to fix. The accuracy pass came back clean.

## Style-guide specifics to spot-check

- `> [!seealso]` blocks are at the **bottom** of the page and use `[[link|Label]]: blurb` (colon, not em dash).
- Internal links are wikilinks with verified targets; product nouns (Story, Storybook, Controls, Storyteller) are capitalized.
- Code examples are real and lifted from `workspace/code-samples/src/...` (these pages use the ` ```code-sample ` path-embed mechanism, which is current — newer than the skill's "inline fenced block" wording; the spirit is the same: never hand-write an unverified snippet). The few hand-written ` ```lua ` fragments in `controls.md` and `migrating-ui-labs.md` are illustrative; confirm they're correct or replace with real samples.

## Verify

- `cd docs/site && npm run build` is clean (the author confirmed it builds, but re-check after your edits — watch for broken wikilink/embed warnings; `onBrokenLinks` is `warn`, so grep the log, don't trust a zero exit).
- `cd docs/site && npm run format` (Prettier, `proseWrap: preserve` — don't fold callout lines).
- Optionally `obsidian unresolved` to catch broken wikilinks vault-wide.

## Hand back

List what you changed and why, and surface anything you could not verify against source rather than leaving an unbacked claim in place.
