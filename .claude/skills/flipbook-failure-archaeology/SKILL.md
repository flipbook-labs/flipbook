---
name: flipbook-failure-archaeology
description: Chronicle of all major Flipbook investigations, dead ends, reverted features, and unresolved bugs with evidence and current status. Check this before attempting a "new" fix to avoid re-fighting settled battles and knowing why workarounds exist.
---

# Flipbook Failure Archaeology

This skill chronicles every major investigation, dead end, rejected fix, and known persistent bug in Flipbook's history. Use it to:

1. **Before attempting any "new" fix**: Search here for related incidents. Windows MAX_PATH, module reload crashes, control re-renders, and deployment race conditions have histories.
2. **When inheriting workarounds**: Understand why `Charm.flags.frozen = false` exists in PluginStarterScript or why dependency bundling is necessary.
3. **When a fix keeps breaking**: Check if this is a repeat failure (BUILD_HASH broke twice 6 weeks apart; nightly builds needed 3 fixes; fork workflows needed 5 PRs).

Every entry is dated, cited to commits/PRs, and includes root cause analysis and current status. Inferences are labeled. Do not retry a "do not retry" verdict without re-examining the root cause first.

---

## How to Use This Skill

**When you suspect a bug is old:** Search this document by symptom (crash, path, deploy, render, etc.). If an incident is listed with "do not retry" or "resolved via X," that verdict stands unless new evidence contradicts it.

**When you're adding a workaround:** Cite the incident here with evidence so future maintainers know why the code exists.

**When you see a stale branch:** Check the "Stalled Branch Inventory" section for status. Many branches are blocked on upstream issues (e.g., `uilabs-controls-support` is stale because it predates control refactors #576/#579/#597; the story-controls-campaign skill owns the current plan).

**When a fix recurs:** Example: BUILD_HASH broke twice in 6 weeks (PRs #426 and #444). This indicates Lute's stdio behavior is version-sensitive. The second fix added CI assertions to catch future regressions.

---

## A. WINDOWS PATH-LENGTH SAGA (PRs #518→#523→#529→#530)

### Symptom

Builds fail when consuming FlipbookCore via Rotriever on Windows due to MAX_PATH ceiling (260 characters). A typical nested path:

```
Flipbook\Packages\_Index\FlipbookCore\FlipbookCore\Packages\_Index\flipbook-labs_storyteller@1.8.1\storyteller\dist\controls\migrations\storyteller-v1.5.0\isStorytellerControlsSchema.lua
```

With an 80-character CI workspace prefix, this exhausts the budget.

### Root Cause

Combining two package managers (Wally + Loom) doubled directory nesting. Rotriever outputs `Flipbook\Packages\_Index\FlipbookCore\FlipbookCore\` (unavoidable), and nested dependencies stacked on top.

### Evidence & Timeline

**PR #518 (commit b841b0a2, 2026-03-10):** "Include a path length check"
- Added non-blocking GitHub Actions detector that warns on PRs when artifact paths exceed 260 chars.
- Detective only—did not prevent builds, merely commented.

**PR #523 (commit 7a6c69b5, 2026-03-12):** "Attempt to defeat path length limit by bundling package blobs as rbxms"
- **The fix that worked.** Root cause analysis: bundled `Packages/` and `RobloxPackages/` into `.rbxms` format before packaging for Rotriever.
- Rationale: "Rotriever isn't picky about what lives in the content root."
- Changed `compileAsync.luau` to call new `packToRbxm()` helper.

**PR #529 (commit 25bd4ccc, 2026-03-18):** "Store build artifacts in a temp dir"
- Complementary fix: moved intermediate artifacts (e.g., `globalDefTypes.d.luau`, `RobloxPackagesTmp`) to `system.tmpdir()` to reduce surface area.
- Changed `.lute/analyze.luau` and `.lute/install.luau`.

**PR #530 (commit 3834640a, 2026-03-18):** "Remove all the path length garbage"
- Declared victory and deleted path-check logic following #523's success.
- Removed `.github/actions/check-path-lengths/`, `.lute/check-path-lengths.luau`, and CI workflow integration (111 lines deleted).
- Commit message: "Thanks to #523 we no longer have to worry about path limits... (Please do not make me regret saying that)"

### Current Status

**Verified (2026-07-01):** Path-length check artifacts no longer exist on main; no `.github/actions/check-path-lengths/` directory. Rbxm bundling remains permanently active in `.lute/lib/build-system/compileAsync.luau` lines 99–110:

```luau
-- Bundle up the gigantic dependency bundles into rbxms to alleviate
-- path length limit issues that crop up when consuming internally
for _, absPackagesPath in { project.PACKAGES_PATH, project.ROBLOX_PACKAGES_PATH } do
  local relPackagesPath = path.relative(project.REPO_PATH, absPackagesPath)
  local packagesPath = path.resolve(path.join(dest, "src", relPackagesPath))
  packToRbxm(packagesPath)
  fs.removeDirectory(packagesPath, { recursive = true })
end
```

**Resolution verdict:** Windows MAX_PATH is solved via bundling. Do not re-introduce path-length checks; they would be redundant.

---

## B. MODULE RELOAD & STATE BUGS DOSSIER

### B1. Charm.flags.frozen Workaround — Unresolved Upstream Bug

**Location:** `src/PluginStarterScript.plugin.luau` lines 16–31

**Symptom:** "Attempt to modify a readonly table" crash when previewing stories in Flipbook after Storyteller migrated to Charm state library (PR #509, 2026-03-10).

**Root Cause Analysis (storyteller/issues/100):** Storyteller internally mutates immutable state that Charm has marked frozen. All Storyteller unit tests pass, so the mutation is context-dependent (triggered only in Flipbook's state setup flow). The bug lives upstream in Storyteller's StorytellerStore state mutation path.

**Evidence:** Storyteller PR #509 switched from Signals to Charm as the state library. Flipbook adopted the change, but crashes followed. Issue filed at flipbook-labs/storyteller#100 remains open.

**Workaround Code (verified in main):**

```luau
--[[
  Normally we want this to be `true` but there is a really nasty bug in
  Storyteller that is causing story previewing to crash. Relating to "attempt
  to modify a readonly table"

  This means Storyteller is doing something it shouldn't that is violating
  immutability, _but_ everything seems to work fine in practice, so we're
  accepting the tradeoff of having Flipbook work in the shortterm while the
  evil state bug will lurk in the shadows until it reveals itself (or we
  remove this line, whichever comes first)

  Track the issue here:
  https://github.com/flipbook-labs/storyteller/issues/100
]]
Charm.flags.frozen = false
```

**Current Status:** Workaround remains on main. Trade-off accepted: "everything seems to work fine in practice." The comment explicitly flags this as an "evil state bug" that will "lurk in the shadows." Unresolved upstream; requires Storyteller refactor to fix structurally.

**Inference:** Indicates architectural mismatch between Charm's immutability guarantees and Storyteller's internal mutation patterns.

**Verdict:** Do not remove this line. Removal will crash story preview. Block Storyteller upgrade until storyteller#100 is resolved.

---

### B2. Signals-to-Charm Migration & Edge Cases

**PR #509 (commit acf0fa29, 2026-03-10):** "Switch from Signals to Charm"

**Rationale:** Adopt Charm (community alternative) instead of Roblox's Signals library; reduce dependency bloat from week-to-week roblox-packages changes.

**Changes:** 1:1 API mapping across 40 files: `createSignal()` → `Charm.new({...})`, `signal:Connect()` → `charm:subscribe()`. 394 insertions, 284 deletions (bulk refactor).

**Risk Assessment in PR:** "There are likely to still be some edge cases from swapping out the underlying implementation of our state management though, so this could get hairy later."

**Outcome:** That prediction proved accurate. The Charm.flags.frozen workaround emerged shortly after, validating the edge-case concern.

---

### B3. Control Re-rendering Regression (PR #576)

**Symptom:** After state management changes (PR #509), any control modification triggered full re-render of the entire controls panel, causing visual artifacts and output window spam from React scheduler warnings.

**Solution (commit 371d7752, 2026-05-30):** "Fix all control elements rerendering when one is changed"
- Created dedicated Charm store (`createStoryControlsStore.luau`) for controls state.
- Added React context (`StoryControlsContext.luau`) to isolate control updates from broader state.
- Localized updates now propagate only to affected components.

**Evidence:** 280 insertions in new files; refactored StoryView.luau (135 lines removed). Significant architectural restructuring.

**Current Status:** Resolved and merged to main. Problem no longer occurs.

---

### B4. ModuleLoader Require-Cache Bypass — Intentional Design

**Location:** `Packages/_Index/flipbook-labs_module-loader@<version>/module-loader/dist/createModuleLoader.luau`

**Purpose:** Enables hot-reload-aware module requires with on-demand compilation via loadstring. Critical to Flipbook's development workflow.

**Key Mechanism:**

1. **Weak-keyed registry** (line 96): `setmetatable({}, { __mode = "k" })` — modules auto-GC'd when source changes.
2. **Module caching** (lines 126–130): checks registry before re-require; cached exports returned if found.
3. **Immutability tolerance** (lines 36–58): wraps module source in double-closure to bypass Luau's 200 locals limit (issue in React/ReactFiberWorkLoop).
4. **Error recovery** (lines 158–161): clears registry entry if require fails, preventing stale cache on retry.

**Inference:** Designed specifically for Flipbook's story-reload workflow without Roblox's native module cache interfering. Weak-key behavior is intentional.

**Current Status:** Remains active in build artifacts. Critical to hot-reload story updates in development.

**Verdict:** Do not remove or refactor the weak-registry pattern. It is fundamental to the reload mechanism.

---

## C. REVERT & INCIDENT CATALOG

### Parallelize Build Tasks — Reverted (PR #405)

**Symptom:** Build parallelization was supposed to cut build time from ~10s to ~5s but caused reliability issues on some developer machines.

**PR #405 (commit 1cd83177, 2025-11-02):** "Parallelize build tasks"
- Modified `scripts/lib/compile.luau` + added `waitForTasks.luau`.
- Attempted concurrent compilation of multiple targets.

**Revert #405 (commit 68b0e2f4, 2025-11-03):** "Revert 'Parallelize build tasks (#405)'"
- Reverted within 1 day; no explanation in commit message.
- Inference: race condition or process-ordering dependency.
- Later tied to PR #437's work-laptop issues (process spawning brittleness in Lute).

**Verdict:** Do not re-enable parallelization. Sequential builds are standard through current main. The Lute process-spawning abstraction is brittle; parallelization exposes that brittleness.

---

### BUILD_HASH Broken Twice (PRs #426 & #444)

**First Breakage (commit 1863e994, 2025-11-02, PR #426):** "Fix BUILD_HASH not getting set"
- After Lute migration, `BUILD_HASH` global stopped getting set at compile time.
- Root cause: Incorrect Lute `stdio` parameter default; result.stdout not propagated.
- Solution: Used Lute's actual default which propagates stdout, enabling hash extraction.
- Bonus: Added pretty-printing of environment globals.

**Second Breakage (commit 704fbd5b, 2025-12-15, PR #444):** "Fix the build hash not being set (again)"
- Same symptom recurred 6 weeks later.
- Root cause: Lute stdio behavior varies between versions.
- Solution: Explicitly set stdio to `default` and added CI assertion to catch future regressions.

**Evidence of Brittleness:** Two identical failures 6 weeks apart indicates fragile abstraction. Lute's stdio behavior is version-sensitive.

**Verdict:** Lute abstraction is fragile. CI assertions (added in #444) help. Check Lute version when BUILD_HASH build stops working; may require explicit stdio parameter tuning.

---

### BACKEND_URL Not Baked Into Build (PR #479)

**Commit:** d313d7b6 (2026-01-11)

**Symptom:** Nightly plugin shows warning "failed to communicate with backend: URL must be http" — BACKEND_URL resolves to nil at runtime.

**Root Cause:** CI didn't copy `.env.template` → `.env` before build; BACKEND_URL undefined at compile time (Darklua's build-time globals).

**Solution:**
1. Updated CI to copy `.env.template` to `.env` before build.
2. Added assertion in the build script (then `scripts/build.luau`; today the guard lives at `.lute/build.luau:100` as `if not process.env.BASE_URL`, after the scripts moved in #521 and the variable was renamed).
3. Duplicate fix in release.yml.

**Verdict:** Resolved via CI guardrails + runtime assertion.

---

### Logs Routing to Output Window (PR #484)

**Commit:** 23b60801 (2026-01-15)

**Symptom:** Flipbook logs appeared in Roblox Studio Output window instead of console.

**Root Cause:** 1-line change in `workspace/flipbook-core/src/logger.luau` (related to issue #483).

**Solution:** 1-line fix (restored correct logger routing).

**Verdict:** Trivial fix; resolved.

---

### Nightly Build Failures (PRs #432, #433, #535)

**First Attempt (commit 0dc71327, 2025-11-11, PR #432):** "Try to fix publishing the nightly plugin"
- Symptom: `publish-nightly-plugin` job fails on ubuntu-latest.
- Root cause: Lute process-spawning bug #440 specific to Ubuntu.
- Solution: Switched CI job to macos-latest (workaround, not root fix).

**Second Fix (commit 6dc6d490, 2025-11-18, PR #433):** "Upgrade Lute to a newer nightly version"
- Upgraded Lute to newer nightly version.
- Removed `analysis.project.json`, simplified setup.
- Status: Attempted fix; unclear if nightly builds stabilized after.

**Third Breakage & Fix (commit 8c386f75, 2026-03-20, PR #535):** "Fix broken nightly build"
- Symptom: Darklua failing to resolve string requires with absolute paths (from sourcemap).
- Root cause: Darklua behavior sensitivity to path format.
- Solution: Massaged SOURCE_PATH into relative path before passing to Darklua.
- Status: Resolved via path normalization.

**Verdict:** Nightly builds are fragile. Darklua is sensitive to path format; always pass relative paths. Lute stdio/process spawning varies between versions—pin Lute version carefully.

---

### Smoketest & Deployment Orchestration (PRs #561–562)

**Parallel Cancellation (commit 64ed0047, 2026-04-18, PR #562):** "Fix smoketest deployments cancelling each other"
- Symptom: Concurrency config for smoketest + approval gates interact badly; multiple plugin deployments interfere.
- Solution: Removed smoketest from Release workflow, moved to CI/tests job (end-to-end test role); consolidated pull_request_target logic.

**Dev Deployment Leakage (commit b89c5adb, 2026-04-18, PR #561):** "Fix dev deployments triggering for all PRs"
- Symptom: After fork-workflow switch (#559), dev build deployed from every PR.
- Root cause: Condition changed from "run from main" to "always true" (pull_request_target always runs).
- Solution: Flipped logic to "deploy for non-PR events only."

**Verdict:** Pull_request_target event is overly permissive. CI event logic requires careful auditing.

---

### Fork Workflow Support Saga (PRs #559–563)

**PR #559 (commit 6896cca5, 2026-04-18):** "Try to support fork workflows"
- Symptom: Fork-based contributions fail in CI (permissions issues).
- Solution: Switched to `pull_request_target` event + added environment gating for ROBLOX_API_KEY.
- Trade-off: Broader permissions (pull_request_target) mitigate fork isolation at cost of security surface.

**PR #563 (commit 5c997592, 2026-05-21):** "Isolate the surface area of pull_request_target"
- Reduced blast radius by constraining pull_request_target usage to specific CI jobs only.
- Inference: PR #559's blanket pull_request_target was overly broad; narrowed in #563.

**Verdict:** Fork workflows require pull_request_target, but constrain it aggressively. Use environment gates for secrets.

---

### Flipbook Auto-Launch Bug (PR #593)

**Commit:** e62eb043 (2026-06-15)

**Symptom:** Users report Flipbook reopening unexpectedly when Studio layout resets.

**Root Cause:** DockWidgetPluginGuiInfo had `initEnabled=true`; Studio layout resets lose state and trigger widget reload.

**Solution:**
- Set `initEnabled=false` (only open on toolbar button click).
- Changed initial mount from Top to Float with default sizing (UX improvement).
- Verified via manual testing: deleted .rbxm, rebuilt, checked widget sizing.

**Current Status:** Merged; likely resolves accidental launches.

---

### Dev Build Deployment Failure (PR #596)

**Commit:** 0d045ce9 (2026-06-21)

**Symptom:** Dev build fails to deploy after PR #583 introduced "beta" channel.

**Root Cause:** publish-plugin script maps `--channel` directly to asset name; "beta" asset doesn't exist in rbxasset.toml (only dev/prod).

**Solution:** Added channel routing logic in `.lune/publish-plugin.luau`: `beta → dev`.

**Verdict:** Resolved; routing correctly maps non-standard channels. Test channel routing if adding new channels.

---

### Rotriever Iteration Loop Fix & Revert (commits 389a0891 & 2626cdae)

**Commit 389a0891 (2026-05-15):** "Fix iteration loop with Rotriever"
- Made unspecified changes to `compileAsync.luau` + `rotriever.toml`.

**Revert 2626cdae (2026-05-30):** "Revert 'Fix iteration loop with Rotriever'"
- Reverted within 15 days; no explanation in commit message.
- Inference: fix introduced regression or wasn't needed.

**Verdict:** Rotriever iteration semantics are unclear. Do not retry this fix without deeper investigation into the actual iteration issue.

---

### Deploy-Storybook Rollback (commit 7436205f, 2026-06-13)

**Message:** "Revert deploy-storybook back to v0.2.0"
- v0.2.1 tag was deleted — fix will ship through proper release workflow.
- Inference: v0.2.1 pre-release was broken; rolled back to stable v0.2.0.

**Verdict:** Use proper release workflow; do not pre-release tags.

---

### Beta Build Channel Naming (commit e9a1dbff, 2026-06-15)

**Context:** Related to PR #596; beta→dev routing still had edge cases.
- Updated `.lune/publish-plugin.luau` with additional routing logic (11 lines).

**Verdict:** Channel routing is fragile; test all channels before merge.

---

## D. STALLED BRANCH INVENTORY

Sixteen branches with work-in-progress status. Last activity ranges from 3 days to 7 months ago. Categorized by status.

### Nearly-Ready (Few Commits, Recent Activity)

#### adopt-changewrite

- **Last activity:** 2026-06-28 (3 days ago)
- **Commits:** 1 (92fd7caa)
- **Status:** Appears feature-complete; small surface area; may need final review/merge.
- **Verdict:** Viable for immediate merge review.

#### agent-actions-registry

- **Last activity:** 2026-06-18 (10 days ago)
- **Commits:** 2 (fc2a79bc + merge)
- **Attempt:** Central Actions registry with PluginAction + Bindable routing.
- **Status:** Stalled at review stage; likely blocked on PR feedback or merge queue.
- **Verdict:** Still-viable; awaiting review.

#### update-darklua-0.19-loaders

- **Last activity:** 2026-06-11 (17 days ago)
- **Commits:** 1 (6289bf76)
- **Attempt:** Update Darklua to 0.19.0 and declare content loaders.
- **Status:** Stalled; unclear why not merged; may await integration testing.
- **Verdict:** Still-viable; test before merge.

---

### Blocked / Work-in-Progress (Moderate-to-Heavy Commits, Stalled)

#### embedded-http-proxy

- **Last activity:** 2026-06-19 (9 days ago)
- **Commits:** 75 (heavy work: 7f076c51 + 19f25ecc + 73 others)
- **Attempt:** Route embedded HTTP requests through server-side proxy.
- **Status:** Substantial feature; 75 commits suggests major architectural addition; no recent activity.
- **Verdict:** Blocked; awaiting design review or infrastructure support.

#### shrink-ui

- **Last activity:** 2026-06-19 (9 days ago)
- **Commits:** 13 (84be51a3, b7d9a61e, 8c96cd0b + others)
- **Attempt:** UI layout optimizations (sizing tweaks).
- **Status:** Incremental feature; stalled after initial work; likely low priority.
- **Verdict:** Low priority; may be superseded.

#### telemetry-source-and-is-studio

- **Last activity:** 2026-05-31 (31 days ago)
- **Commits:** 35 (4b6e25ae, 066a6699, e4415a3d + others)
- **Attempt:** Back telemetry source store with Charm signal; add source/isStudio fields.
- **Status:** Moderate-scope feature; dormant for month; deprioritized or superseded.
- **Verdict:** Abandoned or superseded.

#### uilabs-controls-support

- **Last activity:** 2026-05-09 (53 days ago)
- **Commits:** 3 (66f14210, 2757a881, 9d570e0e)
- **Attempt:** Support UI Labs controls (upgrade Storyteller for patches).
- **Status:** Stalled after exploratory work; control breakage noted in commit message "ControlGroup and Object are broken."
- **Inference:** This branch predates the control refactors in PRs #576 (state isolation), #579 (object control), and #597 (extract InstancePicker). Those PRs substantially restructured controls.
- **Verdict:** STALE. Do not retry. The story-controls-campaign skill owns the current plan for controls fixes. Uilabs controls support strategy is superseded by the campaign's gated decision process.

#### upgrade-loom-dependencies

- **Last activity:** 2026-05-09 (53 days ago)
- **Commits:** 6 (1852d77b, f91d28dc, 8eaabc0e + others)
- **Attempt:** Upgrade Lute version and fix cascading dependency breakage.
- **Status:** Infrastructure upgrade; painful (commit message: "Bumping Lute version and fixing the nightmare it spawned"); multiple cascading fixes needed; stalled waiting for full integration test results.
- **Verdict:** Abandoned. Lute upgrade pain is severe; do not retry without full downstream testing. Version pins in rokit.toml are carefully chosen.

#### panel-layout

- **Last activity:** 2026-05-04 (58 days ago)
- **Commits:** 18 (243325c0, d09c5dd0, 8f456b97 + others)
- **Attempt:** Panel layout refactor (offload work to GroupContext).
- **Status:** Stalled after refactor; unknown why not merged; moderate complexity.
- **Verdict:** Blocked or deprioritized; status unclear.

#### story-controls-documentation

- **Last activity:** 2026-05-04 (58 days ago)
- **Commits:** 88 (58e6579c, 84ac52fe, 225f9474 + others)
- **Attempt:** Documentation + controls component reorganization.
- **Status:** Large feature (88 commits); documentation + code moves; stalled.
- **Verdict:** Blocked or deprioritized; overshadowed by controls refactoring in #576/#579/#597.

#### locale-switcher

- **Last activity:** 2026-04-18 (74 days ago)
- **Commits:** 4 (98845d5e, 8ae91b19, 5b6b64e4 + merge)
- **Attempt:** Add locale/theme switcher components.
- **Status:** Exploratory; stalled; deprioritized for i18n work.
- **Verdict:** Abandoned.

#### package-upgrade-body-updates

- **Last activity:** 2026-03-20 (103 days ago)
- **Commits:** 2 (097a49ff, 8fef6415)
- **Attempt:** Automate dependency upgrade PR bodies using app token.
- **Status:** Small feature; stalled at edge; awaiting token setup or schema finalization.
- **Verdict:** Low priority; still-viable if needed.

#### flipbook-api

- **Last activity:** 2026-03-12 (111 days ago)
- **Commits:** 4 (8ebecbac, 0f78e88f, 05060db9 + merge)
- **Attempt:** Export FlipbookCore APIs (remove Storyteller-specific exports).
- **Status:** API surface work; stalled; unknown why not merged; may await consumer usage.
- **Verdict:** Blocked or awaiting consumer.

---

### Exploratory / Kept Current (Heavy Commits, Recent or Ongoing Activity)

#### flipbook-docs

- **Last activity:** 2026-06-28 (3 days ago)
- **Commits:** 44 (f01f8179, 106024f0, a8cdf667 + 41 more)
- **Attempt:** Documentation vault overhaul (Obsidian setup, Docusaurus integration).
- **Status:** Large ongoing documentation project; kept current with main merge (commit f01f8179 is merge of main).
- **Verdict:** Still-viable; active documentation work. May be stable feature branch awaiting final review/merge. Note: shared brief mentions this branch contains "unmerged information" to fold in.

#### automated-story-snapshots

- **Last activity:** 2026-06-28 (3 days ago)
- **Commits:** 11 (9e1a5923, 5be55aa7, a8b1a133 + others)
- **Attempt:** Auto-capture story screenshots (WebSocket-based capture, skill integration).
- **Status:** Features have been merged to main; branch still open, kept current (likely experimental tracking branch).
- **Verdict:** Experimental; being maintained but not primary path.

#### docs-in-studio

- **Last activity:** 2025-12-26 (187 days ago)
- **Commits:** 8 (75b02bf5, a254bfae, ba86de9e + others)
- **Attempt:** Embed documentation in Roblox Studio (workspace member).
- **Status:** Forgotten; large feature not completed.
- **Verdict:** Abandoned.

#### storybook-onboarding

- **Last activity:** 2025-11-02 (242 days ago)
- **Commits:** 7 (dc078b2f, 86695947, 8801c8b1 + others)
- **Attempt:** Storybook onboarding flow improvements.
- **Status:** Forgotten; stalled for 8+ months.
- **Verdict:** Abandoned; superseded or deprioritized.

#### vscode-workspace

- **Status:** Identical to main (commit 14bbd2cd); 0 commits ahead.
- **Verdict:** Branch exists but tracks no separate work; likely created in error.

---

## Incidents & Lessons Summary

1. **Path-length saga is over.** Windows MAX_PATH is solved via rbxm bundling (PR #523, permanent in compileAsync.luau). Do not re-introduce path checks.
2. **Charm.flags.frozen workaround persists.** Storyteller mutation bug (storyteller/issues/100) forces this disable. Do not remove; unresolved upstream.
3. **State management is stable, but edge cases linger.** Signals→Charm swap (PR #509) was 1:1 compatible but triggered mutation edge cases (fixed in PR #576).
4. **Lute is brittle.** Build parallelization (PR #405) reverted within 1 day; BUILD_HASH broke twice 6 weeks apart (version-sensitive stdio); nightly builds needed 3 fixes; Lute version bumps cascade.
5. **Deployment orchestration is fragile.** Fork workflows, smoketest concurrency, and channel routing required 6 fixes (PRs #559–563, #596, #561–562) in 2 months. Event logic demands careful auditing.
6. **Stalled branches indicate deprioritization or design uncertainty.** `uilabs-controls-support` is STALE (predates #576/#579/#597 refactors; story-controls-campaign owns the plan). `upgrade-loom-dependencies` is abandoned ("nightmare" fixes). `flipbook-docs` is actively maintained.

---

## Provenance and Maintenance

This document was authored 2026-07-01 with commit verification via git log and show. Re-verify key claims before updating:

```bash
# Verify path-length fixes
git show 7a6c69b5 --stat | grep -E "compileAsync|packToRbxm"
git show 3834640a --stat | grep -E "check-path-lengths"

# Verify Charm.flags.frozen workaround location
grep -r "Charm.flags.frozen" src/

# Verify PR #576 control re-render fix
git show 371d7752 --stat | grep -E "StoryControlsContext|createStoryControlsStore"

# Check branch status
git branch --list -a | grep -E "uilabs-controls-support|upgrade-loom-dependencies|flipbook-docs"
git log -1 --format="%ai %s" uilabs-controls-support

# Verify stalled branches by activity
git log -1 --format="%ai" embedded-http-proxy upgrade-loom-dependencies docs-in-studio
```

Update this skill whenever: a major incident is resolved and merged to main, a stalled branch is merged or abandoned, or upstream issues (e.g., storyteller#100) are fixed.
