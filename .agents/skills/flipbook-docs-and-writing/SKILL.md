---
name: flipbook-docs-and-writing
description: "Flipbook documentation estate: Docusaurus site, code-sample extraction, Obsidian vault (flipbook-docs branch), and house style. Use when maintaining or extending the docs of record, writing new user or contributor docs, enforcing prose/markdown conventions, or creating templates for documentation pages and skills."
type: process
---

# Flipbook Docs and Writing

This skill covers the Flipbook documentation estate, publication workflow, house style and conventions, and templates for creating new docs pages and skills. Use this when maintaining the site, writing new docs, enforcing prose rules, or helping new contributors author documentation.

## Documentation Estate Map

The Flipbook docs have three layers, each with distinct purpose and audience:

### Layer 1: Docusaurus Site (User-Facing)

**Location:** `docs/` directory at repo root.

**Build system:** Docusaurus 3.6.1 (verified 2026-07-01 in `docs/package.json`). Config in `docs/docusaurus.config.ts`, sidebars in `docs/sidebars.ts`.

**Deployment:** `docs.yml` workflow builds on PR and release; deploys to `flipbook-labs.github.io/flipbook` on release or manual dispatch. Build runs `npm ci` + `npm run build` in `docs/` directory.

**Content root:** `docs/docs/` with sections:
- `intro.md` — product intro and features.
- `install.md` — setup instructions.
- `creating-stories/` — user guide: writing stories, controls, typechecking, story format (MDX with embedded code samples).
- `frameworks/` — per-framework integration (React, Roact, Fusion, etc., auto-discovered).
- `contributing/` — contributor onboarding and release workflow (auto-discovered).
- `migration-guides/` — for users migrating from UI Labs, Hoarcekat, etc.

**Code samples:** Live in `workspace/code-samples/` and are embedded in docs via `raw-loader` Webpack imports or Docusaurus remark plugin. Samples are real, working code; if source changes, docs automatically reflect it. Never hardcode examples — pull them live.

**Verification command:** `lute run serve-docs` (verified in `.lute/serve-docs.luau`) runs `npm install` + `npm start` in `docs/` to start local dev server; browser opens automatically.

### Layer 2: Obsidian Vault (Institutional Knowledge — Pending Merge)

**Status:** Branch `flipbook-docs` (unmerged as of 2026-07-01) contains comprehensive Obsidian vault at `docs/obsidian-vault/` with 8,500+ lines across engineering, product, usage, and concepts.

**Staleness check:** Branch is current (merged main 2026-06-28, 3 days old); no conflicting API changes; vault is production-ready for publication.

**Structure (from the vault on the `flipbook-docs` branch, as of 2026-07-01 — browse with `git ls-tree -r --name-only flipbook-docs -- docs/obsidian-vault`):**
- `engineering/` — architecture decisions, build pipeline, module loader design, story controls revamp, changewrite workflow, telemetry strategy.
- `product/` — roadmap, northstars, product vision, UX ideas.
- `usage/` — user guides complementing public docs (story format, controls, component library).
- `concepts/` — story, storybook, module-loader, and renderer concepts (bridge between user and engineer).
- `contributing/` — maintainer onboarding, testing architecture, CI flow.
- `drafts/` — pending work (docs overhaul plan, research notes, stale proposals).

**Publication pathway:** Vault is build-excluded from public site now; remark plugin `docs/site/src/remark/obsidian.mjs` and sidebar builder `docs/site/src/sidebar/obsidian.mjs` are configured to ingest it. To publish: merge flipbook-docs to main, run `lute run serve-docs`, deploy via `docs.yml`.

**Pre-merge checklist (from docs overhaul plan):**
- W1: Strip notion-id + linter-yaml-title-alias metadata; keep aliases only when distinct from H1.
- W2: Fix engineering MOC (delete tech-1.md stub, rebuild engineering/index.md).
- W3: Convert Obsidian Bases to static Markdown tables.
- W4: Normalize index notes to intro + blurbed-bullet-list format.
- Validate all wikilinks resolve; check code sample paths in workspace/code-samples/.

### Layer 3: Agent Skills and Runbooks

**Location:** `.agents/skills/` — canonical, vendor-neutral home for agent-facing procedures, maintainer playbooks, and reference. Routed via the Project Skills index in `AGENTS.md`; conventions in `.agents/skills/README.md`.

**Audience:** Sonnet-class model, zero-context mid-level engineer.

**Each skill has:** frontmatter (`name`, `description`, `type: process | knowledge`), when-not-to-use section, provenance/verification commands, date-stamped volatile facts. New/renamed skills must update the AGENTS.md index in the same commit.

**One home per fact:** Docs layer owns user-facing knowledge; skills layer owns agent/maintainer procedures. Cross-reference by repo-relative path instead of restating (e.g., "For user story format, see `docs/docs/creating-stories/story-format.mdx`").

## House Style and Conventions

### Prose Rules

**Unwrapped lines:** Each paragraph or bullet list is one long line. No hard line breaks mid-sentence. Prettier enforces this for markdown.

**Avoid rule-of-three:** Don't use rhetorical tricolon constructions ("A, B, and C") for emphasis. List items or numbered steps are fine; rhetorical emphasis via three-item parallelism is discouraged.

**Jargon on first use:** Define every term on first mention. Example: "Darklua is a Luau-to-Roblox-require transpiler that rewrites string imports (`@pkg/Charm`) to property-access requires during build."

**Comments describe the present:** In source code, comments explain why the code is written this way *now* — for a reader who has never seen a prior version. Never write comments that narrate a refactor (e.g., "This used to be inline" or "Where did all the logic go? It moved to X"). See AGENTS.md for full doctrine.

### Markdown Formatting

**Tool:** Prettier (verified in `lute run lint` which runs `npx prettier --check "**/*.md"` and can auto-fix via `npx --yes prettier --write "**/*.md"`).

**Frontmatter:** Docusaurus pages use YAML frontmatter. Minimal example:
```yaml
---
sidebar_position: 1
---
```

Standard keys: `sidebar_position` (sort order in category), `id` (for stable URLs), `title` (defaults to H1; rarely needed). Obsidian vault also uses `aliases` (alternate names, only when distinct from H1).

**One H1 per page.** Never use multiple top-level headings.

**Code blocks:** Use Docusaurus CodeBlock component for embedded examples (MDX), or ` ```lua ` fenced blocks in markdown. For Obsidian, use ` ```code-sample ` fenced blocks with workspace-relative paths (e.g., ` ```code-sample workspace/code-samples/src/React/ReactButton.luau#L4-L13 ` `).

**Tables:** Use Markdown pipe tables; static, never Obsidian Bases. Example:
```markdown
| Control Type | Supported | Notes |
|---|---|---|
| Boolean | Yes | — |
| Color | Yes | Requires Color3 |
```

**See also blocks:** Use `> [!seealso]` callout blocks (Obsidian standard) at the bottom of pages to link related docs.

**Wikilinks:** Obsidian vault uses `[[path/to/page]]`; public site uses standard Markdown `[link text](/docs/path/to/page)`.

## Local Workflow

### Running Docs Locally

Command: `lute run serve-docs` (verified `.lute/serve-docs.luau`).

This command:
1. Runs `npm install` in `docs/` to fetch Docusaurus and plugins.
2. Runs `npm start` to start dev server.
3. Opens browser automatically to `http://localhost:3000/flipbook/`.

Auto-reloads on markdown edits. Press `Ctrl+C` to stop.

### Linting and Formatting

**All together:** `lute run lint` (verified in AGENTS.md, runs Selene + StyLua + Prettier).

**Markdown only:** `npx --yes prettier --write "**/*.md"` (fixes line wrapping and formatting).

**Type check:** `lute run analyze` (checks Luau; not directly docs-related but affects code samples).

## Templates

### New Docusaurus Page Template

Create a new `.mdx` file under `docs/docs/` with this skeleton:

```mdx
---
sidebar_position: 1
---

# Page Title

One-sentence intro describing what the reader will learn.

## Section 1

Paragraph with inline `code`, links to other docs (`[link text](/docs/path)`), and
bullet lists when helpful.

- First item
- Second item
- Third item

## Section 2

Docusaurus supports MDX, so you can embed React components. For code samples, use
the CodeBlock component:

```lua
-- Example code from workspace/code-samples
```

### Subsection

Use `:::tip`, `:::warning`, `:::info`, `:::danger` for callout boxes.

:::tip
This is a helpful tip for users.
:::

:::warning
This is something to be careful about.
:::

## See also

- [Related Page 1](/docs/path/to/page)
- [Related Page 2](/docs/path/to/page)
```

**Frontmatter notes:**
- `sidebar_position` determines sort order within the category (lower numbers come first).
- Omit `title` unless it differs from the H1.
- Most pages don't need `id` (Docusaurus infers it from filename).

### New Skill Template

Create a new SKILL.md under `.agents/skills/<skill-name>/` with this skeleton:

```markdown
---
name: skill-name
description: "Brief trigger-rich description stating exactly when this skill should load. Use when: [specific cases]. Covers: [main topics]."
type: process | knowledge (pick one; see .agents/skills/README.md for the filing rule)
---

# Skill Title

One-sentence statement of what this skill does and who uses it.

## When not to use

Link to related skills in the library that handle adjacent work. Example: "For telemetry implementation, see flipbook-config-and-flags. For release automation, see flipbook-release-and-operations."

## Section 1: Major Topic

Body content with clear examples, copy-pasteable commands, and explanations.

**Verified command:** (command that can be run to validate a claim)
```bash
lute run build --channel dev
```

**Unverified note:** (if you cannot verify a claim, label it explicitly)
This feature is marked as "not yet started" in the 2026 roadmap.

## Section 2: Another Topic

More structured content with tables, checklists, or runbooks where they help.

| Column 1 | Column 2 |
|----------|----------|
| Cell | Cell |

---

## Provenance and Maintenance

**Date stamped:** as of 2026-07-01.

**Re-verify these claims when this skill next loads:**
- `lute run serve-docs` behavior: run and confirm dev server starts
- Docusaurus config: check `docs/docusaurus.config.ts` for layout changes
- Branch status: confirm `flipbook-docs` has not been merged or archived
```

**Frontmatter rules:**
- `name`: slug (kebab-case, matches directory name).
- `description`: trigger-rich, states exactly when to load; use "Use when:" followed by specific scenarios.
- `type`: `process` (runbook — what to do next) or `knowledge` (reference — how the system is and why); filing rule in `.agents/skills/README.md`.

**Structure:**
1. Title and one-sentence summary.
2. "When not to use" section linking siblings.
3. Main body (numbered sections, tables, checklists).
4. "Provenance and Maintenance" footer with date stamp and re-verification commands.

**Audience:** Imperative runbook voice; copy-pasteable commands; every tool/flag/path verified before stating.

## Code Sample Extraction System

**How it works:** Docs reference real Luau from `workspace/code-samples/` using Docusaurus remark plugin and Obsidian plugin.

**Syntax (Obsidian vault):**
```
```code-sample
workspace/code-samples/src/React/ReactButton.luau#L4-L13
```
```

**Syntax (Docusaurus MDX):**
```mdx
import ReactButton from "!!raw-loader!@site/../workspace/code-samples/src/React/ReactButton.luau";

<CodeBlock language="lua" title="ReactButton.luau">
  {ReactButton}
</CodeBlock>
```

**Benefits:**
- Examples never drift from source.
- If code changes, docs automatically reflect it.
- Single source of truth for all sample code.

**Workflow:** Add sample code to `workspace/code-samples/` directory, then reference it from docs.

## Key Files and Paths

| File | Purpose |
|------|---------|
| `docs/docusaurus.config.ts` | Docusaurus config (site title, URLs, plugins, nav) |
| `docs/sidebars.ts` | Sidebar structure and section organization |
| `docs/package.json` | Node dependencies for Docusaurus |
| `docs/docs/` | Markdown/MDX content root |
| `.github/workflows/docs.yml` | CI workflow: build on PR, deploy on release |
| `.lute/serve-docs.luau` | Task runner for local dev server |
| `docs/obsidian-vault/` | Institutional knowledge vault (flipbook-docs branch) |
| `workspace/code-samples/` | Real example code embedded in docs |
| `.github/pull_request_template.md` | PR template (docs go in Problem/Solution sections) |

## Common Patterns

### Linking Between Pages

**Docusaurus (user-facing):** Use root-relative paths with `/docs/` prefix:
```markdown
See [Writing Stories](/docs/creating-stories/writing-stories) for the full guide.
```

**Obsidian (vault):** Use wikilinks:
```markdown
See [[creating-stories/writing-stories]] for the full guide.
```

### Embedding Code Samples

**When the sample is short (< 10 lines):** Inline the code in a fenced block.

**When the sample is long or lives in the repo:** Reference via code-sample or raw-loader so it auto-updates if source changes.

### Callout Boxes

Docusaurus and Obsidian both support callout syntax:

```markdown
:::tip
Helpful information for users.
:::

:::warning
Something to be careful about.
:::

:::danger
Critical warning.
:::

:::info
General information.
:::
```

Or Obsidian callout syntax:
```markdown
> [!tip]
> Helpful information
```

### Sidebars and Navigation

Docusaurus sidebar structure is in `docs/sidebars.ts`. Add new pages by:
1. Create `.mdx` file under appropriate section in `docs/docs/`.
2. Add path to sidebars config (or use `autogenerated` to auto-discover).
3. Set `sidebar_position` in frontmatter to control sort order.

Example sidebar entry:
```typescript
{
  type: 'category',
  label: 'Stories',
  collapsed: false,
  items: [
    'creating-stories/writing-stories',
    'creating-stories/controls',
  ]
}
```

---

## Provenance and Maintenance

**Date stamped:** as of 2026-07-01.

**Re-verify these claims when this skill next loads:**
- Docusaurus version and config: check `docs/package.json` and `docs/docusaurus.config.ts` for breaking changes.
- Serve-docs command: run `lute run serve-docs` and confirm dev server starts and auto-reloads on markdown edits.
- Branch status: confirm `flipbook-docs` branch status (merged, archived, or still pending).
- Sidebar structure: check `docs/sidebars.ts` to ensure sections match current documentation tree.
- Prettier markdown enforcement: run `lute run lint` to confirm markdown formatting is checked.
