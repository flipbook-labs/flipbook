# Storybook.js vs. Flipbook docs — coverage & UX-sharp-edges report

> [!note]
> Scratch report comparing Flipbook's user-facing docs against Storybook.js. This is the
> **coverage framing** — "what content/features do the big hitters document that we don't,
> and what rough edges does our site have." A companion report,
> [[storybook-docs-comparison-learning]], reframes the same material around _learning
> effectiveness_ (pedagogy) and is the basis for the implementation plan. Lives in `drafts/`
> (build-excluded). Status: **awaiting review**.

## What was compared

- **Flipbook**: the user-facing slice of the vault — `usage/`, `api/`, `concepts/`, plus the
  `drafts/docs-overhaul-plan.md` for context. Engineering/product/contributing were ignored
  (no Storybook equivalent).
- **Storybook.js**: the published docs at storybook.js.org — Get Started, Stories, Testing,
  Docs, Sharing, Essentials, Addons, Configure, API.

## The two information architectures side by side

| Storybook section                                                                 | Flipbook equivalent                        | State                                    |
| --------------------------------------------------------------------------------- | ------------------------------------------ | ---------------------------------------- |
| Get Started → Why Storybook?                                                      | —                                          | **missing**                              |
| Get Started → Install (CLI, framework picker, tour, example stories)              | `usage/getting-started`                    | hand-written boilerplate, no scaffolding |
| Stories → Args, Parameters, Decorators, Play, Loaders, Tags, Naming/Hierarchy, TS | `usage/writing-stories` + `usage/controls` | covers ~2 of ~8 concepts                 |
| Docs → Autodocs, MDX, Doc Blocks, ArgTypes tables                                 | — (only the `summary` field)               | **missing**                              |
| Testing → interaction, a11y, visual, snapshot, coverage, CI                       | —                                          | **missing entirely**                     |
| Sharing → publish, embed, composition, design integrations                        | `usage/deploying-storybooks`               | **strong** (see below)                   |
| Essentials → Controls, Backgrounds, Viewport, Toolbars, Measure/Outline           | `usage/controls` only                      | 1 of ~7                                  |
| Configure                                                                         | —                                          | n/a (plugin, not config-file driven)     |
| API → CSF, ArgTypes, Parameters, CLI                                              | `api/` (3 short tables)                    | thin but present                         |
| FAQ / Troubleshooting                                                             | —                                          | **missing**                              |

## Content gaps (documented by the big hitters, absent in Flipbook)

1. **No "Why" / mental-model page.** Storybook opens with _Why Storybook?_. Flipbook's
   `usage/getting-started` compresses this into one sentence then jumps to install. The
   `concepts/` pages that should carry the mental model are 1–2 sentences each.
2. **Controls don't document the available control types.** `usage/controls` shows one
   example and never enumerates what control types exist (boolean? select? number? color?).
   The overhaul plan notes a `control-data-types.base` with **22 entries** being collapsed
   into _engineering_ docs — the data exists internally but never reaches the user page.
3. **No testing story at all.** Storybook's largest pillar (interaction, a11y, visual,
   snapshot, coverage, CI). Flipbook has zero; even a "stories + deployed previews for
   visual review/QA" page is unwritten.
4. **No autodocs / args-table concept.** Flipbook's only doc surface is the optional
   `summary: string?` field in `api/story-format`.
5. **No decorators / wrapping concept.** Nothing about wrapping every story in a
   provider/theme/context. Undocumented if supported; a named gap if not.
6. **No naming / hierarchy / organization page.** How stories are named, grouped, and
   ordered in the plugin tree is never explained.
7. **No FAQ / troubleshooting.** "My story isn't appearing" (usually missing `storyRoots`
   or wrong extension), "packages not found," "live-reload not firing."

## UX sharp edges in the docs themselves

1. **Published stubs that dead-end the reader.** `usage/typechecking` is literally a stub
   and `usage/migration-guides/migrating-ui-labs` says "coming in the future!" — yet both
   are linked from nav. Hitting an empty page erodes trust.
2. **Broken/inconsistent code in the Hoarcekat migration.** `migrating-hoarcekat`:
   - Uses legacy `roact = Roact`, which `api/story-format` flags as deprecated.
   - Diff blocks are invalid Luau (missing trailing commas before the next key).
   - Three `<!-- TODO: Add image -->` placeholders ship in the rendered page.
   - It hand-writes inline blocks while the rest of the docs render from real source via
     `code-sample` embeds — which is exactly why these drifted/broke.
3. **No framework/variant switcher — variants are stacked.** `frameworks/react` stacks
   `### Default` then `### Storyteller` code with no prose; a Fusion user reads React
   examples. The framework pages are code dumps with almost no explanatory text.
4. **Empty/placeholder API table cells.** In `api/story-format` the description for the one
   **required** property (`story`) is blank, plus a stray empty column.
5. **Onboarding is "hand-write two files."** No shipped example stories, no generator; the
   reader copies a `.storybook` then a `.story` and places them in ReplicatedStorage.

## Where Flipbook is at parity or ahead — keep these

- **`usage/deploying-storybooks` is excellent** — arguably clearer than Storybook's Sharing
  page for the self-hosted-CI case: two concrete workflows, full inputs table, Open Cloud
  setup captured once, security-relevant Direct-Access-Control note. The model to aspire to.
- **Rendering samples from real Luau source** (`code-sample` embeds) prevents drift — a
  best practice Storybook also uses. Hoarcekat is the one regression.
- **Framework-agnostic positioning** is stated clearly and early.

## Prioritized recommendations

**High leverage, low effort**

1. Un-stub or hide `typechecking` and `migrating-ui-labs` — no visible dead-ends.
2. Fix the Hoarcekat guide (convert to `packages`, fix invalid diffs, replace TODO images,
   or rebuild from real source).
3. Add a control-types table to `usage/controls` (promote the 22-entry data from engineering).
4. Fill the empty `story` description in `api/story-format`.

**Medium effort, high value** 5. A "Why Flipbook / Core Concepts" page that actually explains isolation and the
Storybook→Story model (fold in the thin concept notes). 6. A naming/organization page — how stories appear and group in the sidebar. 7. An FAQ/troubleshooting page.

**Bigger bets (product + docs together)** 8. A testing/QA page positioning stories + deployed previews for visual review. 9. Decorators/global-wrapper docs (if supported). 10. Snippet variant tabs (React/Fusion/Roact, Default/Storyteller) instead of stacked blocks.

## Sources

- https://storybook.js.org/docs
- https://storybook.js.org/docs/get-started/why-storybook
- https://storybook.js.org/docs/get-started/install
- https://storybook.js.org/docs/writing-stories
- https://storybook.js.org/docs/writing-stories/naming-components-and-hierarchy
- https://storybook.js.org/docs/writing-docs/autodocs
- https://storybook.js.org/docs/writing-tests
- https://storybook.js.org/docs/sharing/publish-storybook
