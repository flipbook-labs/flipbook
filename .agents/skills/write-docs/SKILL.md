---
name: write-docs
description: Write or edit Flipbook documentation that matches the house style. Use when the user asks to write, draft, update, or revise docs, a docs page, a guide, the docs site, or anything under `docs/`.
---

# Write Docs

Flipbook's documentation is authored in the **Obsidian vault at `docs/obsidian-vault/`** as Obsidian-flavored Markdown (`.md`) so the team can edit and cross-link pages quickly in Obsidian. A build step processes the vault into the **Docusaurus site at `docs/site/`**, which is published to GitHub Pages. Author your pages in the vault: use the Obsidian conventions below, and keep pages valid Markdown that Docusaurus can render. This skill keeps new writing accurate and in the existing voice. Read it fully before writing or editing a page.

The hard rule: **never describe behavior you have not confirmed in the source.** Generic, plausible-sounding docs that don't match the code are worse than no docs.

**Not every page is public docs.** `usage/`, `api/`, `concepts/`, and `contributing/` are the high-rigor reference pages — apply the full house style and accuracy bar to them. `engineering/` (including `engineering/proposals/`), `product/`, and `product/ideas/` are living documents, tech specs, and RFCs: freeform, lower bar, often half-finished thoughts. Keep the voice there, but don't polish or "correct" someone's working notes — match the surrounding informality and only change what you were asked to. (Everything publishes except a short sensitivity list excluded in `docs/site/docusaurus.config.ts`.)

> [!note]
> Author in Obsidian syntax. The build's remark plugin ([docs/site/src/remark/obsidian.mjs](../../../docs/site/src/remark/obsidian.mjs)) resolves wikilinks, image embeds, and `> [!callouts]`, so don't convert them to Docusaurus `:::` syntax to silence a warning — flag a genuinely unrenderable case instead. Note transclusion (embedding one note's body into another with `![[note]]`) is **not** supported — the plugin only embeds images; a `![[note]]` falls back to a plain link. Don't author Obsidian Bases (`.base`): they don't render on the site (see Conventions).

## Workflow

1. **Read before you write.** Open the relevant source under `src/` (and existing tests) for anything you intend to document. Open the existing docs page if you are editing one. Do not write from general knowledge of how storybook tools "usually" work.

2. **Ground every claim.** Every behavior, property, default, and signature you state must be traceable to a specific line of source or an existing test. If you can't point to it, don't write it. When unsure, say so to the user instead of inventing.

3. **Cite while drafting.** As you draft, tag non-obvious claims with a source marker, e.g. `<!-- src: src/Storybook/init.luau:42 -->`. These make review trivial. Strip them before the page is final, but keep them in any draft you hand back for review.

4. **Match the house style and banlist** below.

5. **Run a critic pass over your own output.** Before declaring a page done, re-read the prose _you wrote or edited_ with one job: find (a) any sentence making a claim not backed by a cited source, and (b) any phrase matching the banned patterns. Fix those. Doing this as a separate pass catches far more than self-checking while drafting. This pass applies only to text you generated — see the banlist scope below.

6. **Use the `obsidian` CLI for vault operations** — reading files, checking backlinks before deleting, moving notes, verifying unresolved links. The CLI connects to the currently active Obsidian window. Two vaults share the name `obsidian-vault` (the personal vault and this one), so first confirm the CLI is pointed at the right one:

   ```sh
   open "obsidian://open?vault=obsidian-vault&path=README.md"
   obsidian vault info=path   # must print .../flipbook/docs/obsidian-vault
   ```

   Key commands (all paths are vault-relative):
   - `obsidian read path=<path>` — read a note
   - `obsidian append path=<path> content=<text>` — append to a note (use `\n` for newlines)
   - `obsidian create path=<path> content=<text>` — create a note
   - `obsidian delete path=<path>` — move to trash (recoverable)
   - `obsidian move path=<path> to=<dest-folder>` — move or rename
   - `obsidian unresolved` — list broken wikilinks vault-wide
   - `obsidian backlinks path=<path>` — check before deleting a note
   - `obsidian orphans` — notes with no incoming links

7. **Verify it builds** after structural changes: `cd docs/site && npm run build` (or have the user run it). Watch for broken wikilink/embed targets and unresolved references. If an Obsidian-ism surfaces as a build warning, flag it rather than rewriting it into Docusaurus syntax unprompted. Docs are also Prettier-formatted (`proseWrap: preserve`, so your line breaks are kept — important, because joining a callout's lines would fold its body into the title) — run `npm run format` in `docs/site`, or let format-on-save handle it; CI runs `prettier --check`.

## House style

**Voice**

- Second person, addressed to the reader: "you can isolate…", "you need a Storybook."
- Warm and approachable. Friendly framing and encouraging closers ("You are now equipped to migrate your other stories") are part of the voice — keep them. Warmth is not the same as hype; see the banlist.
- Plain declarative sentences. State what something does, not how impressive it is.
- Assume a competent Roblox engineer. Don't over-explain Luau or Studio basics.

**Conventions**

- Capitalize Flipbook product nouns: Story, Storybook, Controls, Storyteller. Lowercase generic uses.
- **No em dashes (`—`).** They don't match the voice. Recast the sentence with a period, comma, parentheses, or colon. This is a hard rule, not a generation-only preference like the banlist: it applies to prose and to list blurbs alike. Map of Content and `> [!seealso]` entries use a colon, not an em dash: `[[link|Label]]: blurb`, never `[[link|Label]] — blurb`.
- **Title Case for headings** ("Writing Stories", "Using Frameworks"). The page `# H1` is the feature or page name.
- Reference data goes in **static Markdown tables**: `| **Property** | **Type** | **Description** |`. Use `string?` / `{ Instance }` style Luau types in the Type column. **Never use Obsidian Bases (`.base`)** — they're excluded from the build and render as nothing on the site; hand-write the table instead.
- **Callouts use Obsidian syntax, not Docusaurus `:::` admonitions:** `> [!note]`, `> [!tip]`, `> [!warning]`, `> [!seealso]`. Use `> [!warning]` for deprecations and breaking-change notices, and `> [!seealso]` (with wikilinks) for cross-reference blocks. **Put `> [!seealso]` blocks at the bottom of the page**, after the last content section.
- **Internal links are Obsidian wikilinks, not absolute paths:** `[[usage/frameworks/react|React]]` — a vault-relative path with an optional `|Label`. Link to a heading with `#`: `[[api/storybook-format#Legacy Support]]`. Verify the target page and heading exist.
- **Reuse content by linking to a single source of truth, not by transcluding it.** Note transclusion (`![[note]]` / `![[note#section]]`) is no longer supported — keep each fact on one canonical page and link to it (e.g. `concepts/story` links to `api/story-format` for the full module API). If a page genuinely needs another's content inline, write a short purpose-built summary there and link out for the detail; don't copy-paste the whole section.
- **Sidebar order comes from `index.md` link lists, not frontmatter.** The sidebar generator ([docs/site/src/sidebar/obsidian.mjs](../../../docs/site/src/sidebar/obsidian.mjs)) labels each item from its `# H1` and orders each folder by the wikilink order in that folder's `index.md` (the root order comes from `README.md`). To place or reorder a page, edit the relevant index note's link list — **don't add `sidebar_position`**.
- **Every folder owns an `index.md`** that is its Map of Content: a one-line intro plus a bulleted list of `[[wikilinks]]` to the folder's pages, each followed by a colon and a short blurb (see `usage/index.md`, `concepts/index.md`). New page in a folder → add it to that index.
- **Frontmatter is Obsidian-managed YAML.** Pages carry `aliases` and `linter-yaml-title-alias`, which the Obsidian Linter keeps in sync with the `# H1` — don't hand-edit `linter-yaml-title-alias` (and commit the linter config so this stays shared). **Strip `notion-id`** when you touch a page — it's dead Notion-migration residue. Don't add a `base:` key (that's Obsidian Bases membership). Preserve other existing keys you didn't add (`tags`, `id`).
- Images embed Obsidian-style with an optional size: `![[assets/flipbook-icon.png|32]]`. When you use standard `![alt](path)` syntax instead, write real, descriptive alt text.

**Code samples**

- Vault pages are `.md`, so examples are **inline fenced code blocks** (` ```lua `), not raw-loader imports.
- **Examples must be real, not invented.** Lift them from working modules — `workspace/code-samples/src/...` or actual `src/` — and keep them in sync with the source. Don't hand-write a snippet you haven't confirmed compiles. This is the same accuracy bar as prose: an example that doesn't run is a wrong claim.
- Use ` ```diff ` fences to show migration or before/after steps (see the migration guides).
- The raw-loader `<CodeBlock>` import pattern (importing from `workspace/code-samples/` and rendering with `<CodeBlock>` / `<Tabs>`) **only works in `.mdx` pages.** The Obsidian vault pages are `.md` and can't use JS imports, so don't reach for it here. If a page is genuinely `.mdx`, that pattern is available.

## Banned patterns

**Scope: this list constrains what _you generate_. It is not a linter to run against the docs.**

The point is to make agent output predictable so a human can steer it the rest of the way — not to police prose a person wrote. So:

- Don't produce these patterns in text you write or rewrite.
- **Don't course-correct human prose.** If a person wrote "simply," or any other banned word, in surrounding text, leave it. Only avoid generating it yourself. Editing a page near a human's "simply" is not a signal to go fix it.
- Don't open a PR or task to scrub existing docs of these words unless the user explicitly asks.

The list:

**Antithesis / negation framing** — the most important one to catch:

- "It's not just X, it's Y."
- "This isn't about X — it's about Y."
- "Think of it less as X and more as Y."
- Any "not merely / not simply … but rather" construction.

**Hype and filler adjectives/verbs:**

- powerful, seamless, robust, elegant, effortless, blazing, lightning-fast, game-changing, supercharge, unlock, leverage, delve, crucial, essential, simply, just, simple, easy, easily.
- Note: this is stricter than some existing pages, which use "simply"/"simple." That's expected — the ban is on _your_ output, not theirs. Per the scope note above, leave human-written instances alone.

**Rule-of-three padding:**

- "fast, reliable, and scalable" style triads that add adjectives without adding information.

**Meta-commentary and filler openers:**

- "In this section we'll explore…", "It's worth noting that…", "At its core…", "Let's dive in", "Without further ado."

**Vague benefit-speak:**

- Sentences that sell a feeling instead of conveying a fact the reader can act on. Every sentence should leave the reader knowing something they can do or rely on.

When you catch yourself reaching for one of these, the fix is almost always to state the concrete behavior plainly instead.
