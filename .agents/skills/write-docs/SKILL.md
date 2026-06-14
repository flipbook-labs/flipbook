---
name: write-docs
description: Write or edit Flipbook documentation that matches the house style. Use when the user asks to write, draft, update, or revise docs, a docs page, a guide, the docs site, or anything under `docs/`.
---

# Write Docs

Flipbook's documentation is authored in the **Obsidian vault at `docs/obsidian-vault/`** as Obsidian-flavored Markdown (`.md`) so the team can edit and cross-link pages quickly in Obsidian. A build step processes the vault into the **Docusaurus site at `docs/site/`**, which is published to GitHub Pages. Author your pages in the vault: use the Obsidian conventions below, and keep pages valid Markdown that Docusaurus can render. This skill keeps new writing accurate and in the existing voice. Read it fully before writing or editing a page.

The hard rule: **never describe behavior you have not confirmed in the source.** Generic, plausible-sounding docs that don't match the code are worse than no docs.

**Not every page is public docs.** `usage/`, `api/`, and `contributing/` are the published, high-rigor pages — apply the full house style and accuracy bar to them. `tech/`, `product/`, `proposals/`, and `ideas/` are living documents, tech specs, and RFCs: freeform, lower bar, often half-finished thoughts. Keep the voice there, but don't polish or "correct" someone's working notes — match the surrounding informality and only change what you were asked to.

> [!note]
> This branch is mid-migration from a Moonwave-style site to the Obsidian vault. Docusaurus may not yet render every Obsidian-ism (wikilinks, embeds, `> [!callouts]`). Don't convert Obsidian syntax to Docusaurus syntax to silence a build warning unless the user asks — that's a migration decision, not a docs-writing one. Flag it instead.

## Workflow

1. **Read before you write.** Open the relevant source under `src/` (and existing tests) for anything you intend to document. Open the existing docs page if you are editing one. Do not write from general knowledge of how storybook tools "usually" work.

2. **Ground every claim.** Every behavior, property, default, and signature you state must be traceable to a specific line of source or an existing test. If you can't point to it, don't write it. When unsure, say so to the user instead of inventing.

3. **Cite while drafting.** As you draft, tag non-obvious claims with a source marker, e.g. `<!-- src: src/Storybook/init.luau:42 -->`. These make review trivial. Strip them before the page is final, but keep them in any draft you hand back for review.

4. **Match the house style and banlist** below.

5. **Run a critic pass over your own output.** Before declaring a page done, re-read the prose _you wrote or edited_ with one job: find (a) any sentence making a claim not backed by a cited source, and (b) any phrase matching the banned patterns. Fix those. Doing this as a separate pass catches far more than self-checking while drafting. This pass applies only to text you generated — see the banlist scope below.

6. **Verify it builds** after structural changes: `cd docs/site && npm run build` (or have the user run it). Watch for broken wikilink/embed targets and unresolved references. Mid-migration, some Obsidian-isms may surface as build warnings — per the note above, flag those rather than rewriting them into Docusaurus syntax unprompted.

## House style

**Voice**

- Second person, addressed to the reader: "you can isolate…", "you need a Storybook."
- Warm and approachable. Friendly framing and encouraging closers ("You are now equipped to migrate your other stories") are part of the voice — keep them. Warmth is not the same as hype; see the banlist.
- Plain declarative sentences. State what something does, not how impressive it is.
- Assume a competent Roblox engineer. Don't over-explain Luau or Studio basics.

**Conventions**

- Capitalize Flipbook product nouns: Story, Storybook, Controls, Storyteller. Lowercase generic uses.
- **Title Case for headings** ("Writing Stories", "Using Frameworks"). The page `# H1` is the feature or page name.
- Reference data goes in tables: `| **Property** | **Type** | **Description** |`. Use `string?` / `{ Instance }` style Luau types in the Type column.
- **Callouts use Obsidian syntax, not Docusaurus `:::` admonitions:** `> [!note]`, `> [!tip]`, `> [!warning]`, `> [!seealso]`. Use `> [!warning]` for deprecations and breaking-change notices, and `> [!seealso]` (with wikilinks) for cross-reference blocks.
- **Internal links are Obsidian wikilinks, not absolute paths:** `[[usage/frameworks/react|React]]` — a vault-relative path with an optional `|Label`. Link to a heading with `#`: `[[usage/inspirations#Inspirations]]`. Verify the target page and heading exist.
- **Reuse content with embeds instead of duplicating it.** `![[api/story-format]]` transcludes a whole page; `![[usage/inspirations#Inspirations]]` transcludes a section. Keep a single source of truth and embed it where needed (e.g. `concepts/story` embeds `api/story-format`) rather than copy-pasting.
- **Frontmatter is Obsidian-managed YAML.** Pages carry `aliases` and `linter-yaml-title-alias`, which the Obsidian Linter keeps in sync with the `# H1` — don't hand-edit `linter-yaml-title-alias`. Public pages also set `sidebar_position` for Docusaurus ordering; match the scheme of sibling pages. Preserve existing keys you didn't add (`tags`, `notion-id`, `id`); don't strip them.
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
