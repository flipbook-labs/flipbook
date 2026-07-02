---
name: flipbook-change-control
description: "Classification, gating, and review discipline for Flipbook changes: branch/PR workflow, version gating, CI gates, change-type decision table, community-first and telemetry-privacy doctrine, and the non-negotiables with their historical incidents. Use when authoring a PR, reviewing change control, understanding release requirements, or evaluating whether a change is safe to merge."
---

# Flipbook Change Control

This skill details how changes to Flipbook are classified, gated, reviewed, and released. It names every non-negotiable and the historical incident that ratified it. Use this when authoring a PR, reviewing a changeset, determining what CI gates must pass, or deciding whether a proposal respects the project's doctrine.

## Branch and PR Workflow

All work proceeds through feature branches and pull requests. **Never commit directly to `main`.**

### Branching

- **Name branches after their purpose**, not random words. Examples: `fix/control-rerender`, `feat/object-picker`, `docs/embedding-guide`.
- All work happens on a feature branch and merges via PR to `main`.
- Never force-push to `main` or rewrite main's history.

### Pull Requests

**Template:** Use the template at `.github/pull_request_template.md` (verified 2026-07-01).

```markdown
## Problem
## Solution
## Testing
## Notes for reviewers
```

Fill every section concisely. The Problem/Solution should describe what the change does in present tense on its own ("Add a foo helper to consolidate X"), not its origin story.

**Status:** All PRs open as **drafts** (`gh pr create --draft`). Never open ready-for-review and never run `gh pr ready` unless the user explicitly asks. Opening a non-draft PR pings reviewers prematurely.

**Disclosure:** Every PR body must disclose AI assistance (e.g., closing line: "🤖 Generated with [Claude Code](https://claude.com/claude-code)"). This is mandatory per user convention and applies even when filling a repo's PR template.

**Review routing:** `CODEOWNERS` at the repo root assigns all paths (`*`) to `@flipbook-labs/flipbook-maintainers` and `@flipbook-labs/flipbook-contributors` (verified 2026-07-01), so every PR automatically requests review from those teams — there is no per-directory ownership split.

### Commit Hygiene

- Make one commit per logical unit; do not squash needlessly.
- **Do not rewrite history** — no `git reset --hard`, rebase, or cherry-pick to rebuild a branch. If reverting, make a new forward commit (`git rm`, `git checkout <base> -- <files>`).
- Commits are collapsed on merge anyway (squash-merge workflow), so intermediate history is acceptable.

---

## Release Gating and Version Control

Releasing Flipbook is gated and automated — no manual tag pushes, no direct version-string edits.

### Version Bumping

**Only method:** `lute run bump-version <major|minor|patch>` (verified in repo `.lute/` scripts).

This is the single authoritative version source. The command:
1. Bumps `package.toml` (or equivalent version file)
2. Creates a release commit
3. Tags the commit with the new version

Never edit version strings by hand or push tags directly.

**Rationale:** Keeps version-of-record in one place and prevents manual tag pushes from diverging from package metadata.

### GitHub Releases

**Only method:** GitHub Release workflow (via `gh release create` or GitHub UI after a version bump).

1. After `lute run bump-version` creates a tag, create a GitHub Release matching that tag.
2. Release workflow (`.github/workflows/release.yml`, verified 2026-07-01) then publishes artifacts (`.rbxm` to Creator Store asset 8517129161, dev plugin nightly asset 88523969718241).
3. Never push git tags directly (`git push origin <tag>`).

**Rationale (from incident #530, #535, #596):** Manual tag pushes have caused CI coordination failures (nightly build failures #432–435, smoketest concurrency bugs #562, deployment-leakage #561, dev-build routing #596). The GitHub Release workflow with environment gating prevents these.

### Channels

Flipbook has three build channels (verified in `ci.yml` matrix: dev/beta/prod, and `.lute/build.luau`):

| Channel | Use | Keeps | Prunes |
|---------|-----|-------|--------|
| **dev** | local dev, CI proof | tests, stories, storybooks, example/ | — |
| **beta** | internal validation (experimental) | same as dev | — |
| **prod** | release to Creator Store, end users | core plugin only | `code-samples/`, `example/`, `template/`, `test-runner/`, `*.spec.luau`, `*.story.luau`, `*.storybook.luau`, `jest.config.luau*` |

Default channel is `prod`. Pass `--channel dev` or `--channel beta` to `lute run build` to retain development files.

**Rationale:** Prod pruning (via `PROD_CONFIG.prunedDirs`/`prunedFiles` in `project.luau`) shrinks end-user plugin size and keeps examples/tests from shipping to users.

---

## CI Gates

Every PR must pass the following gate jobs before merge is recommended:

### `ci.yml` — Standard Build & Attestation

**Trigger:** every push to main, every PR to main, manual dispatch.

**Build matrix:** channels `dev`, `beta`, `prod` × targets `plugin`, `flipbook-core-rotriever`.

**What it proves:**
- Source → Darklua → Rojo pipeline succeeds for all channels.
- Build artifacts are reproducible (provenance attestation via GitHub Attestations API, verified 2026-07-01).
- No syntax errors or broken requires.

**Fails if:**
- `lute run build plugin --channel <X>` fails.
- Sourcemap resolution breaks.
- Darklua dead-code elimination fails.

**When to re-run:** After touching `.lute/`, `darklua.json`, `wally.toml`, `rotriever.toml`, or any `.luau` file.

### `strict.yml` — Tests, Type Checking, Smoketest

**Trigger:** every PR (`pull_request_target` with environment gating; see below), every push to main, manual dispatch.

**Jobs:**

1. **`tests`** — Cloud Jest via Rocale.
   - Builds dev plugin.
   - Runs `lute run test` (requires `ROBLOX_API_KEY` secret).
   - Executes tests inside a Roblox place (test universe 6599100156, place 123506190725771).
   - **Proves:** logic is sound; no runtime crashes; stories load and render.
   - **Fails if:** any `*.spec.luau` test fails.

2. **`smoketest`** — Creator Store smoketest publish.
   - Runs `lune run publish-plugin --smoketest --channel prod --apiKey <key>`.
   - Publishes dev plugin to Creator Store smoketest asset for manual QA.
   - **Proves:** plugin package is valid; Creator Store API accepts the build.
   - **Fails if:** publish fails (e.g., malformed rbxm, asset mismatch).

**Environment Gating:** (verified in `strict.yml`, lines 20–24)
- **Fork PRs** (external contributions): `luau-execution-gated` environment requires approval.
- **Internal PRs** (from flipbook-labs org): `luau-execution` environment (auto-approved).
- **Main/manual:** runs without gating.

**Rationale (from incident #559, #563):** Fork workflows needed special permissions. `pull_request_target` with environment gating isolates the blast radius (PR #563 "Isolate the surface area of pull_request_target").

### `storybook.yml` — Storybook Preview Deployment

**Trigger:** every PR, every push to main.

**What it proves:**
- `lute run build storybook` (the test place bundle) succeeds.
- Storybook can deploy to a place via `flipbook-labs/deploy-storybook@v0.4.0` (verified 2026-07-01).
- Dev/beta builds can sync to Studio without errors.

**Fails if:**
- Rojo workspace sync fails.
- deploy-storybook GitHub Action fails.

**On main:** Also builds a fresh prod Flipbook (`.rbxm`) as the embedded runtime to catch embedding issues pre-release (see shift #582, "Embed Flipbook in the DataModel").

### Linting and Analysis

**Trigger:** every PR, every push to main (as part of `ci.yml`'s `analyze` job).

**What it proves:**
- No Selene lint violations (`std = "roblox"`, `global_usage = "allow"`).
- StyLua formatting (`sort_requires = true`, verified in `stylua.toml`).
- Prettier markdown formatting.
- Luau strict mode type checking (`lute run analyze` → Luau LSP strict; `languageMode: "strict"` in `.luaurc`).

**Fails if:** any linter or formatter would change the code.

---

## Change Classification & Gate Requirements

Use this table to determine which CI gates your change requires and whether it is safe.

| Change Type | Behavior Change | Test Payload | Required Gates | Notes |
|-------------|-----------------|--------------|----------------|-------|
| Plugin code (`.luau` in `src/` or `workspace/flipbook-core/src/`) | Yes | Yes | `ci.yml` + `strict.yml` | All logic changes; story render, controls, theme/locale, navigation, permissions, etc. |
| Build script (`.lute/`, `darklua.json`, `wally.toml`) | Conditional | Varies | `ci.yml` | If it changes build output (e.g., new global, new pruned file), re-run full matrix. If it only touches tooling setup, `ci.yml` alone may suffice; but always err toward strict.yml. |
| Test (`*.spec.luau`) | No | Yes | `ci.yml` + `strict.yml` | New tests; updated test fixtures. Must pass in cloud. |
| Story or storybook (`*.story.luau`, `*.storybook.luau`) | No | No | `storybook.yml` + `ci.yml` | Dev channel only (pruned in prod); no impact on end users. |
| CI workflow (`.github/workflows/*.yml`) | No | No | Manual re-run of affected workflow | Changes to job conditions, artifact handling, secrets wiring, environment gating. |
| Documentation (`.md`, docs vault, AGENTS.md) | No | No | `docs.yml` (if exists); linting only | No code impact. Markdown must pass Prettier. |
| Type definitions, aliases (`.luaurc`) | Conditional | Possibly | `ci.yml` + `strict.yml` | Language mode or alias changes affect all downstream analysis. |
| Dependencies (Wally `wally.toml`, Loom, Rokit versions) | Yes | Maybe | `ci.yml` + `strict.yml` + manual local test | **See "Dependency Change Discipline" below.** |

---

## Safe vs. Unsafe Changes

### Safe (Does Not Require `strict.yml`)

- Documentation-only PRs (fixes to `.md`, docs vault, AGENTS.md).
- Test files (`*.spec.luau`) — already covered by `strict.yml` when code lands.
- Story/storybook files (`*.story.luau`, `*.storybook.luau`) — dev-channel only, pruned from prod builds.
- Non-behavior-affecting refactors (renaming, moving code, extracting helpers that keep the same API).

### Unsafe (Always Requires `strict.yml`)

- Any `.luau` changes in `src/` or `workspace/flipbook-core/src/`.
- Dependency upgrades (Storyteller, ModuleLoader, Wally/Loom pins).
- Build globals or environment variables (Darklua injections).
- Plugin configuration (settings, telemetry, permissions).

---

## Dependency Change Discipline

Flipbook depends on two sibling repos via its dependency chain:

```
Flipbook ← Storyteller ← ModuleLoader
```

(All verified in shared-brief.md and AGENTS.md.)

### Wally Dependency Bumps

When updating a Wally dependency in `wally.toml` (e.g., Storyteller, ModuleLoader, Charm, React):

1. **Rebuild clean:** `lute run build plugin --channel dev --clean` (locally and in CI).
   - The `--clean` flag forces a full rebuild, bypassing the build cache (`build/build-cache.json`).
   - Reason: partial builds can hide missing or broken transitive requires.

2. **Test locally** before opening a PR:
   ```bash
   lute run build plugin --channel dev --clean
   lute run lint
   lute run analyze
   lute run test
   ```

3. **CI will re-run** the full matrix in `ci.yml` (all channels). No additional action needed.

4. **Major version bumps** to Storyteller or ModuleLoader are high-risk.
   - Storyteller and ModuleLoader are load-bearing abstractions (per architecture-contract skill).
   - Use skill `test-dependencies-in-flipbook` (at `.agents/skills/test-dependencies-in-flipbook/SKILL.md`) to overlay local builds into Flipbook and validate in isolation before landing.

### Loom/Lute Dependency Upgrades

Loom manages tooling packages (`.lute/` scripts use these). Upgrades are high-risk because:

- PR #433 "Upgrade Lute version and fixing the nightmare it spawned" notes multiple API breaks.
- PR #437 "Fix builds on my work laptop" traced to Lute process-spawning brittleness (lute-labs/lute#579).
- Branch `upgrade-loom-dependencies` stalled 53 days (as of 2026-07-01) after "nightmare" fixes.

**Discipline:** Upgrade Loom/Lute only if necessary. If you do:
1. Test on macOS and Ubuntu (process spawning differs).
2. Run `--clean` full builds locally.
3. Document breaking API changes in the PR.

### Version Pins in `rokit.toml`

`rokit.toml` pins all CLI tool versions (darklua 0.17.1, luau-lsp 1.60.1, lute 1.0.0, etc.; verified in shared-brief.md).

- Never bump tool versions without CI + local testing.
- Darklua especially needs attention (it has its own dead-code-elimination rules; version changes can alter output semantics).

---

## Community-First Doctrine

**Maintainer Doctrine (dated 2026-07-01):**

Flipbook is being brought to internal Roblox teams, but the internal build must NOT get features the community build can't have just because it runs in an elevated context with internal APIs. This principle is non-negotiable and reflects the project's commitment to serving creators first.

### What This Means

- **No internal-only features.** If the community can't use a feature, don't ship it to the internal build either.
- **Feature parity baseline.** Internal support largely ends at parity with the base plugin. Anything beyond that is a candidate for community release, not an internal-only enhancement.
- **Check before assuming internal APIs.** If a feature idea requires an internal API, file it as future work and let it compete for prioritization against other ideas.

### In Practice

Before merging a feature or fix:
- Ask: "Would a community user (or external creator in Roblox Studio) be able to use this?"
- If no, the feature is either not ready or not appropriate for this repo.
- Blocked features belong on a roadmap or research branch, not main.

**Rationale:** Flipbook's value is in serving creators. Splintering into internal and community variants fractures the ecosystem and makes maintenance harder.

---

## Telemetry and Privacy Gating

**Maintainer Doctrine (dated 2026-07-01):**

Users deserve privacy. Flipbook collects telemetry (opt-in), but there is no public privacy policy and no documented telemetry schema. Treating telemetry expansion as a gated feature, not an afterthought, is non-negotiable.

### Current Telemetry State (Verified 2026-07-01)

- **Opt-in flow:** `TelemetryOptOutDialog` (per shared-brief.md).
- **Backend:** Hypothetical (flipbook-backend Rust service not yet fully operational; see flipbook-docs branch `engineering/anonymized-usage-telemetry.md` for spec).
- **Collected events** (candidate; see branch): session start/end, story open/close, page navigation, time-spent metrics.

### Gating Rules for Telemetry PRs

Any PR that expands telemetry collection (new events, new fields, schema changes) must:

1. **Document the change in the PR body** with a "Telemetry" section:
   - What is being collected (event type, fields, cardinality).
   - Why it's needed (what product question does it answer).
   - How it respects privacy (aggregation, anonymization, retention).

2. **Update privacy policy and telemetry schema** as documentation (in docs vault or AGENTS.md) before or alongside the code change.
   - Users have the right to know what's collected and why.
   - Undocumented telemetry is a trust violation.

3. **Default to OFF** for any new telemetry collection.
   - Existing opt-in status (`TelemetryOptOutDialog`) is the floor, not a waiver for unchecked expansion.

### Historical Context

- No privacy policy currently exists (acknowledged in shared-brief.md).
- No documentation of the telemetry schema (acknowledged).
- These are open obligations.

**Rationale:** Telemetry enables product understanding, but only if users consent and know what they're opting into. Respect that contract.

---

## The Non-Negotiables (With Historical Incidents)

These rules have been tested by production failures and are now enforced.

### 1. All Luau Files Use `.luau`, Never `.lua`

**Rule:** File extension is `.luau` only. Linter (`selene`, invoked via `lute run lint`) will fail on `.lua` files.

**Incident:** Not explicitly named in archaeology, but linter is strict about this (verified in AGENTS.md "Code Style and Conventions").

**Rationale:** Keeps the codebase recognizable as Luau, not legacy Lua. Enables IDE and tooling to route correctly.

### 2. Never Edit `build/` or `dist/` Directly

**Rule:** Build output (`build/<channel>/<target>/` in Flipbook; `dist/` in Storyteller/ModuleLoader) is generated only. Never hand-edit files there.

**Incident (Path-Length Saga, #518–#530):** When MAX_PATH broke Windows builds (260-char limit), the fix was PR #523 "Bundle packages as rbxms" (compileAsync.luau line 99–110, verified 2026-07-01). PR #530 removed the detection logic once bundling worked. The permanent rbxm bundling lives in the build script, not in the output. Editing `build/` directly would lose this on the next rebuild.

**Rationale:** Build output is ephemeral and can be regenerated. Edits there are silently lost. Source-of-truth is the build scripts in `.lute/` and the Darklua/Rojo configuration.

### 3. Never Push Git Tags Directly; Use GitHub Release Workflow

**Rule:** Releases happen via `lute run bump-version` + GitHub Release, never `git push origin <tag>`.

**Incidents:**
- **PR #535 "Fix broken nightly build"** (2026-03-20): Darklua failed to resolve string requires; symptom was nightly builds failing to publish. Root cause was path format sensitivity in Darklua.
- **PR #561 "Fix dev deployments triggering for all PRs"** (2026-04-18): Dev build deployed from every PR after fork-workflow switch. Root cause: `pull_request_target` always runs; condition was broken.
- **PR #562 "Fix smoketest deployments cancelling each other"** (2026-04-18): Smoketest concurrency config interfered with approval gates.
- **PR #596 "Fix the dev build failing to deploy"** (2026-06-21): Beta channel routed wrong (no asset in rbxasset.toml); fixed by adding channel routing logic in publish-plugin.luau.

All of these stemmed from manual coordination between tags, release workflow, and CI. Using the GitHub Release API (via `gh release create` after a version bump tag exists) ensures atomicity.

**Rationale:** GitHub Release workflow is atomic and coordinates with CI environment gates. Manual `git push` can race with CI or skip approval steps.

### 4. Charm.flags.frozen = false Workaround

**Rule:** `src/PluginStarterScript.plugin.luau` (lines 16–31, verified 2026-07-01) sets `Charm.flags.frozen = false`. Do not remove this line.

**Incident (Signals→Charm Migration, PR #509, Storyteller #100):**
- PR #509 migrated from Signals to Charm for state management.
- Storyteller's internal state mutation hits `Charm.flags.frozen = true` and crashes with "Attempt to modify a readonly table."
- Root cause: Storyteller is mutating immutable state in a context-dependent way (lives in storyteller#100).
- **Workaround:** Disable Charm's immutability (`Charm.flags.frozen = false`) as a short-term tradeoff: "everything seems to work fine in practice" but "evil state bug will lurk in the shadows."
- **Status:** Unresolved upstream; no removal attempt on main.

**Rationale:** Storyteller requires this workaround to function. Removing it causes crashes. The upstream fix (Storyteller refactor) is out of scope for this repo.

### 5. Never Commit Directly to `main`; Always Use PRs

**Rule:** All work merges via feature branch + PR. Never `git push` directly to main.

**Incident:** Not a specific named PR, but user convention (see user's global `.claude/CLAUDE.md`: "Never push directly to main; always branch + PR").

**Rationale:** Ensures code is reviewed and CI gates pass before landing. Maintains history and audit trail.

### 6. Comments Describe the Present, Not the History

**Rule:** Comments explain why code is the way it is **now**, for a reader seeing it for the first time. Do not write comments that only make sense as a diff against past shapes.

**Anti-Pattern:**
```luau
-- This used to be inline; the logic now lives in X.
-- Where did all the release logic go? It moved to Y.
-- Previously we did A, but now we do B.
```

**Pattern:**
```luau
-- Charm.flags.frozen = false works around Storyteller issue #100 (readonly table mutation).
```

**Incident (AGENTS.md, lines 128–146):** Formalizes the rule that comments must stand on their own; git history is the source for "how we got here."

**Rationale:** History-relative comments become litter after the next refactor. The old implementation is not coming back; `git log` remembers it.

**See also:** AGENTS.md (repo root, lines 128–146, "Comments explain the present, not the history") for the full doctrine.

---

## Decision Table: Change Type → Required Gates

Quick reference for determining what CI gates a change needs.

| Change Scope | Gate: ci.yml | Gate: strict.yml | Gate: storybook.yml | Notes |
|--------------|--------------|------------------|---------------------|-------|
| Plugin code (logic, UI, telemetry) | ✅ | ✅ | ✅ if affects story render | Always required for user-facing changes |
| Tests (*.spec.luau) | ✅ | ✅ | — | Runs in cloud; must pass |
| Stories/storybooks (*.story.luau, *.storybook.luau) | ✅ | — | ✅ | Dev-only; not in prod builds |
| Build scripts (.lute/, darklua.json) | ✅ | ✅ if output changes | — | Use --clean locally to test |
| Wally/Loom/Rokit versions | ✅ | ✅ | — | High-risk; test local --clean build first |
| CI workflows (.github/workflows/*.yml) | — | Manual re-run | — | Test in draft PR before merging |
| Docs (.md, docs vault) | ✅ linting only | — | — | No code impact; Prettier only |
| `.luaurc`, language config | ✅ | ✅ | — | Language mode changes affect all files |

---

## Provenance and Maintenance

**Last verified:** 2026-07-01 (against shared-brief.md, archaeology, flipbook-docs branch, repo files).

**Re-verification commands:**
```bash
# Confirm PR template exists and is current
cat .github/pull_request_template.md

# Confirm CI/strict/storybook workflows exist
ls -la .github/workflows/{ci,strict,storybook}.yml

# Confirm Charm.flags.frozen workaround in place
grep -n "Charm.flags.frozen = false" src/PluginStarterScript.plugin.luau

# Confirm build output not in git
git status | grep "build/" || echo "build/ correctly ignored"

# Confirm lute run bump-version command
grep -r "bump-version" .lute/ | head -2

# Confirm test-dependencies-in-flipbook skill exists
ls .agents/skills/test-dependencies-in-flipbook/SKILL.md
```

**Known drift risks:**
- Release workflow changes (rbxasset.toml, Creator Store asset IDs): re-check release.yml every quarter.
- CI environment gating (fork vs. internal): re-check strict.yml if fork-workflow issues resurface.
- Storyteller/ModuleLoader APIs: if those skills advance, confirm change-control gates still align.
