# Docs Overhaul Plan

> [!note]
> Working plan for the vault-wide cohesion pass + documentation gap-fill. Lives in
> `drafts/` (build-excluded) so it's a scratchpad, not a published page. Leave comments
> inline — anything in a `<!-- comment -->` or a `> [!question]` block is fair game.
> Status: **awaiting review**. Nothing in the vault has been edited yet.

## Decisions locked in (from scoping)

- **Publish-all**, minus a short list of sensitive pages I'll propose for exclusion (Workstream 8).
- **Bases → static Markdown tables**, collapsing one-line stub notes into the table.
- **New-repo docs split by audience**: deploy workflow under `usage/`, tooling + ecosystem under `engineering/`.
- **Plan-only for now** — full review before any edits.

## Guiding principles

Two rules make the site cohere, both already enforced by the build layer:

1. **Every folder's `index.md` is its Map of Content** — intro sentence + bulleted link
   list with em-dash blurbs. The list's order _is_ the sidebar order
   ([src/sidebar/obsidian.mjs](../../site/src/sidebar/obsidian.mjs)). Root order lives in `README.md`.
2. **Pure Obsidian, free of Notion residue** — H1 drives the title/label; `.base` files
   and `notion-id` / `linter-yaml-title-alias` frontmatter are noise on the site.

## Target conventions (the "norm")

- **Frontmatter:** drop `notion-id` and `linter-yaml-title-alias`. Keep `aliases` only when
  it meaningfully differs from the H1. No `base:` keys.
- **Filenames:** kebab-case; every folder owns an `index.md`.
- **Index notes:** intro + blurbed bullet list (the `usage`/`concepts`/`api` style). Retire
  the raw Notion "## Pages + naked wikilinks" style.
- **One H1 per note; no duplicated sections.**
- **Ordering:** comes from `index.md` link order, never `sidebar_position`.
- **`> [!seealso]` blocks live at the bottom of the page.**
- **Reference data is static Markdown tables**, never Obsidian Bases.

---

# Workstreams

Each workstream is intended as one reviewable PR. Sequenced so the spec (W0) lands first
and the safe mechanical passes precede content writing.

## W0 — Write the conventions down first

Capture every decision in writing _before_ touching content, so subsequent PRs follow an
agreed spec (and so a fresh agent could pick up any workstream).

- [ ] Update **`.agents/skills/write-docs/SKILL.md`** (edit in place; git keeps history).
      It is currently stale and contradicts our decisions:
  - `notion-id` / `linter-yaml-title-alias`: change "preserve, don't strip" → **strip them**.
  - Ordering: replace "public pages set `sidebar_position`" → **order comes from `index.md`
    link lists** (commit `ae50c7b0` already dropped `sidebar_position`).
  - Paths: `tech/` → `engineering/`; fix `proposals/` → `engineering/proposals/`,
    `ideas/` → `product/ideas/` (commit `538ce510`).
  - Add: **no `.base` files / `base:` frontmatter**; reference data goes in static tables.
  - Add: **`> [!seealso]` blocks go at the bottom of the page.**
  - Loosen the "mid-migration, don't convert Obsidian-isms" note once cleanup lands.
- [ ] Decide whether to also add a reader-facing **`contributing/documentation.md`**
      ("how these docs work": vault → Docusaurus model, index-note ordering, adding a page),
      thin and linking to the skill rather than restating it.
      <!-- OPEN QUESTION 5: skill-only, or skill + reader-facing page? -->

> [!question] OQ4 — Skill authority
> OK to edit the existing `write-docs` skill in place (it'll contradict its current text),
> or do you want the current version preserved somewhere first?

## W1 — Mechanical cohesion pass (low risk, high coverage)

- [ ] Strip `notion-id` + `linter-yaml-title-alias` across the vault (nearly all files).
- [ ] Delete `product/2025-flipbook-product-spec/flipbook-product-wishlist/untitled.md` (junk).
- [ ] Fix the stale Notion-path wikilink in
      `engineering/storybook-embedding/index.md` (`[[flipbook/Tech/Storybook Embedding/...]]`).
- [ ] De-duplicate the doubled sections in `engineering/story-controls/index.md`
      (Problems / Implementation / Stretch Goals appear twice).
- [ ] Move the 2 existing `> [!seealso]` blocks to the bottom of their pages
      (`api/storybook-format.md`, `api/story-format.md`).

## W2 — Fix `tech-1` and the engineering MOC

- [ ] Delete `engineering/tech-1.md` (junk Notion title acting as a second, competing MOC).
- [ ] Rebuild `engineering/index.md` so nothing it linked is orphaned — fold in
      documentation-sharing, luau-api-diffing, flipbook-for-foundation,
      flipbook-roblox-internal-deployments, storybook-embedding, and proposals.

## W3 — Bases → static tables, collapse stubs

- [ ] `control-data-types.base` → one comparison table in `engineering/story-controls/index.md`;
      **delete all 22 stub child notes** + the `control-data-types/` folder.
- [ ] `flipbook-product-wishlist.base` → a status table in the product-spec index;
      **delete the ~26 stub child notes**.
- [ ] `proposals.base` → a status table in `engineering/proposals/index.md`, **but keep the
      8 real proposal docs** as pages (167–367 lines each — substantial, not stubs).
- [ ] `task-breakdown.base` → handled in W5 (it's changewright scaffolding).
- [ ] Remove every `base:` frontmatter key and all four `.base` files.

> [!question] OQ — Wishlist table fidelity
> The wishlist stubs carry `Details / Estimate (Days) / Ticket / STATUS / Priority`. Keep
> all columns in the table, or trim to the useful few?

## W4 — Normalize the remaining index notes

Bring these to the blurbed-list style: `product/index.md`, `product/ideas/index.md`,
`engineering/roblox-internal-support/index.md`, `engineering/storybook-embedding/index.md`,
and the now-empty `contributing/index.md` and `engineering/proposals/index.md`.

- [ ] Convert "## Pages + naked wikilinks" → intro + blurbed bullets.
- [ ] Ensure root `README.md` MOC surfaces every top-level section (currently misses
      Concepts as top-level, Engineering, and Product).

## W5 — Reconcile changewright → changewrite

The `engineering/changewright-cli/` tree is an obsolete pre-build spec for the shipped repo
[`flipbook-labs/changewrite`](https://github.com/flipbook-labs/changewrite) (note: no second
"r", no `-cli`).

- [ ] Create `engineering/changewrite.md` from the repo README (the real, shipped tool).
- [ ] Move the original spec + task-breakdown to `drafts/` for history.
      <!-- OPEN QUESTION 1: move to drafts/, or delete outright (git keeps it)? -->
- [ ] Delete the `engineering/changewright-cli/` tree once content is relocated.

## W6 — New-repo docs (split by audience)

- [ ] **Usage:** new `usage/deploying-storybooks.md` — user-facing deploy workflow covering
      `flipbook-cli` (local/Rokit) and the `deploy-storybook` Action (CI + per-PR previews),
      sourced from their READMEs. Capture the Open Cloud setup once, link from both.
- [ ] **Engineering:** `engineering/changewrite.md` (from W5) + new
      `engineering/ecosystem.md` mapping all active org repos and how they fit:
      flipbook, storyteller, module-loader, changewrite, flipbook-cli, deploy-storybook,
      flipbook-batteries, flipbook-backend.

> [!question] OQ3 — Ecosystem map depth
> One page linking out to repo READMEs, or a fuller "what each repo does + dependency
> relationships" with a diagram?

## W7 — Maintainer gap-fill (the bus-factor core)

New `contributing/` pages:

- [ ] `architecture.md` — codebase shape + the darklua → Lute → Rojo → loom build pipeline,
      and _why_ string-requires need darklua.
- [ ] Expand testing/CI coverage in `contributing/onboarding.md`.
- [ ] (`documentation.md` from W0 if we decide to add it.)

## W8 — Sensitivity proposal (publish-all minus a short list)

Recommend **keeping in the vault but excluding from the public build** (same mechanism as
`drafts/` in `docusaurus.config.ts`):

- [ ] `engineering/roblox-internal-support/developer-storybook-notes.md` — names a Roblox
      employee and quotes internal strategy verbatim. **Strongest candidate for exclusion.**
- [ ] Review the rest of `engineering/roblox-internal-support/` for internal deployment
      specifics (mirroring workflow, release strategy, internal Slack archive links).

I'll produce the exact file list for your sign-off before excluding anything. Everything
else publishes.

> [!question] OQ — Internal-support handling
> Exclude the whole `roblox-internal-support/` section from the public build, or cherry-pick
> only the few pages with sensitive detail?

---

# Knowledge-extraction checklist (what's in your head → paper)

Net-new pages where I'll draft a scaffold + interview you to fill it. These are the
bus-factor items, not mechanical cleanup:

- [ ] **Story Controls revamp** — your own note says "I'm already starting to forget how
      this all works." High priority.
- [ ] **Storyteller ↔ Flipbook split** — what lives where, and why.
- [ ] **module-loader sandboxing model** — how story isolation actually works.
- [ ] **Internal-vs-community release / mirroring strategy** — the mental model behind the
      internal-support notes.
- [ ] **Build pipeline rationale** — darklua/Lute/Rojo/loom, beyond the mechanics.

---

# Open questions (consolidated)

1. **changewright spec history** — move obsolete spec to `drafts/`, or delete (git keeps it)?
2. **Sequencing** — PR-per-workstream as listed, or bundle W1–W4 (cohesion) into one PR and
   W5–W8 (content) into another?
3. **Ecosystem map depth** — link-out index vs. full dependency map + diagram?
4. **Skill authority** — edit `write-docs` in place, or preserve the current version first?
5. **Conventions home** — skill-only, or skill + reader-facing `contributing/documentation.md`?
6. **Wishlist table** — keep all base columns or trim?
7. **Internal-support** — exclude the whole section or cherry-pick sensitive pages?

# Sign-off

<!-- Leave a note here when you're happy for me to start executing, and in what order. -->
