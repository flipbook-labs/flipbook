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

## Known issues to fix (the author already suspects these)

1. **Em dashes are pervasive.** The author used `—` throughout (e.g. "lifted out of your game — ...", "the render container, the current controls, ..."). The style guide bans them as a hard rule. Recast each with a period, comma, parentheses, or colon. This includes maintainer-edited lines, since the em-dash rule is not generation-scoped.
2. **Sentence-case headings.** Many new headings are sentence case and must be Title Case: e.g. "The canvas" → "The Canvas", "Stories without a Storybook" → "Stories Without a Storybook", "Create your first story" → "Create Your First Story", "Using a UI framework", "Simple controls", "Richer controls", "Control types", "Migrating existing controls", "What a Storybook configures". Check every `##` on every page in scope.
3. **Banned word "unlock"** appears in `migrating-hoarcekat.md` ("to unlock Flipbook's controls and other story features"). This line was agent-touched, so rewrite it (e.g. "to use Flipbook's controls and other story features").
4. **Antithesis framing** in `concepts/story.md`: "think of the canvas less as 'one component, alone' and more as a workspace" matches the banned "think of it less as X and more as Y" pattern. Recast. (Note: the maintainer edited this line; confirm with them if unsure, but the pattern is explicitly banned.)
5. **Rule-of-three padding** — scan for tricolons in agent prose and flatten them.

## Accuracy pass (the higher bar)

Per the skill's hard rule, every behavior/signature/default must trace to source. Re-verify, don't trust the draft:

- **`usage/controls.md` control-types table** and **`migrating-ui-labs.md` mapping table** against Storyteller source: `src/controls/ControlTypes.luau`, `src/controls/constructors/*`, and `src/controls/migrations/ui-labs-v2.4.2/migrateUILabsControl.luau`. Confirm the 11 constructors, their signatures, and the UI Labs mapping (note the two caveats already stated: `Object` is not migrated; `RGBA` → Color drops transparency).
- **`concepts/story.md` renderer return shapes** against `src/renderers/createManualRenderer.luau` and `src/loadStoryModule.luau` (Instance / function-with-cleanup / legacy Hoarcekat wrapping).
- **`usage/typechecking.md`** against Storyteller's exported types (`Storyteller.Story<T>`, `Storyteller.Storybook`, `StoryProps`, the control types).
- **`api/story-format.md`** — the `story` row type and the legacy-mapping table.

Two open confirmations the author could not resolve from source (check with the maintainer, then reflect the answers):

- **Rendered-UI coverage:** Storyteller _exports_ constructors for all 11 control types, but does the **v2.5.0 plugin actually render a widget** for each (Slider, Select/Radio/MultiSelect/Check, Color, Date, Object)? If any are schema-only, mark them in the controls table and the UI Labs mapping so the docs don't promise UI that isn't there.
- **UI Labs `before` syntax:** `migrating-ui-labs.md` shows `UILabs.Choose({ ... })`, sourced from a maintainer note rather than UI Labs' own source. Verify the call syntax is current.

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
