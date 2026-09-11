---
name: flipbook-research-methodology
description: The disciplined evidence-bar, hypothesis-prediction, idea-lifecycle, and community-feedback research protocol that turns hunches into accepted changes in Flipbook. Use when designing experiments, evaluating PR readiness, validating mysterious bugs, documenting dead ends, or understanding why certain workarounds exist.
type: process
---

# Flipbook Research Methodology

This skill documents how Flipbook's community and maintainers move from hypothesis to evidence to change — the discipline that guards against false fixes, premature optimization, and abandoning dead ends without a verdict. Every rule is grounded in real incidents from the project's history.

## I. The Evidence Bar: One Mechanism Must Explain All Observations

**The invariant:** A fix or diagnosis is only accepted when a single root-cause explanation accounts for all observed symptoms, including the negatives (what did NOT happen, why some platforms were unaffected, why it worked in one context but failed in another). The explanation must survive an assigned adversarial-refutation pass before landing.

### Pattern: The BUILD_HASH Double Failure (PRs #426 and #444)

**First failure — symptom:** After Lute upgrade, the `BUILD_HASH` global stopped being set at build time. Plugin tagged with empty hash.

**Initial diagnosis (PR #426, commit 1863e994, 2025-11-02):** "I was supplying the wrong default for Lute's `stdio` parameter. We're now properly falling back to its default which propagates `result.stdout`."

**Evidence:** Changed `scripts/lib/run.luau` (grep `stdio = nil`) from `stdio = "inherit"` to `stdio = nil` (let Lute default). Worked locally. Merged.

**Second failure — six weeks later (PR #444, commit 704fbd5b, 2025-12-15):** Same symptom recurred. `BUILD_HASH` nil in CI nightly builds.

**Root cause analysis:** "The build hash comes from a `git rev-parse` command which has been quite brittle from switching between Lute versions and how its stdio behavior works between those versions." The mechanism was NOT "wrong default" but "Lute's stdio behavior varies between versions."

**Revised fix:** Explicitly set `stdio = "default"` in the git call; added assertion `assert(commitHash ~= nil and commitHash ~= "", "commit hash is empty")` to CI so regression is caught immediately.

**Why the first fix failed:** The explanation "wrong Lute default" was incomplete. It happened to work locally because local Lute version (installed via `rokit install`) differed from CI's nightly. The real invariant — "Lute stdio behavior is version-sensitive" — was never isolated. The fix needed to be explicit, not rely on defaults.

### Mechanism Validation Checklist

Before accepting a root-cause explanation:
1. **Collect all observations:** What broke? What didn't? What platforms, Lute versions, contexts were involved?
2. **State the mechanism:** One sentence describing how the bug operates (e.g., "Lute's stdio parameter default changed between v0.1.0-nightly.20251210 and subsequent versions, breaking stdout capture in git rev-parse calls").
3. **Check negatives:** Why didn't this affect local builds? (Answer: rokit pins Lute version; CI's nightly workflow does not.) Why did it work once in #426? (Answer: commit 1863e994 accidentally set a compatible version alongside the fix.)
4. **Assign adversarial review:** A second engineer or model explicitly tries to break the explanation by proposing alternative root causes. ("Could it be git version differences?" — test: git --version consistent in CI and local. "Could it be path escaping?" — test: check commit hash length in logs.)
5. **Accept or refine:** If adversary finds a hole, refine the mechanism and repeat. Only merge when adversary cannot punch through.

### Residue in Codebase

The double failure left permanent evidence. PR #444 added a runtime assertion to CI:

```luau
local commitHash = run("git", { "rev-parse", "--short", "HEAD" }, {
  stdio = "default",
})
assert(commitHash ~= nil and commitHash ~= "", "commit hash is empty")
```

This is **scaffolding**: code added to catch regressions after understanding was achieved. It will remain until the Lute version stabilizes (if ever). Its presence signals "this broke twice; trust the system over your intuition."

---

## II. Hypothesis Predicts Numbers Before Running the Experiment

**The invariant:** Before turning on tracing, adding a counter, or changing code, state the expected quantitative outcome. Run the experiment. Compare prediction to result. Discrepancies uncover misunderstandings.

### Pattern: Localized Control Re-rendering (PR #576)

**Observed problem:** Any time a story control is changed, the entire controls panel re-renders, including controls that were not touched. Users report visual artifacts and excessive console warnings about React scheduler calls.

**Bad hypothesis:** "Re-renders are happening; let's refactor the state store." (Vague; no prediction.)

**Better hypothesis (from PR #576 commit 371d7752, 2026-05-30):** "If controls state is isolated into a dedicated Charm store and accessed via React context, a counter on an untouched control should show 0 re-renders when a sibling control changes."

**Experiment (PR #576):** Created `createStoryControlsStore.luau` (dedicated Charm store for controls state) and `StoryControlsContext.luau` (React context to isolate updates). Refactored `StoryView.luau` to use the context.

**Prediction vs. result:**
- **Predicted:** Individual controls re-render only when their value changes.
- **Actual outcome:** Validated in PR description: "Now we should be getting localized updates only to the components that need to be rerendered." Merged with 280 insertions in new store logic and 135 lines removed from monolithic StoryView.

**Why this pattern works:** The prediction (`counter on untouched control = 0 re-renders`) is testable without instrumenting the codebase. If the refactoring doesn't achieve it, the fix is wrong, not the diagnosis. This prevents shipping fixes that address symptoms without addressing root causes (e.g., adding memoization without isolating the state source).

### Applying the Pattern in Your Work

1. **State the prediction numerically:**
   - Not: "This should be faster."
   - Yes: "If we batch instance updates, the TreeView recompilation count should drop from ~50 per story load to <10."
2. **Instrument before changing code:** Add a counter, timer, or log statement that measures the prediction.
3. **Run a baseline:** Measure the current value (e.g., 50 recompilations).
4. **Apply the fix:** Change code.
5. **Measure again:** Verify the new value matches the prediction (e.g., <10 recompilations). If prediction misses, the mechanism is not what you thought.

---

## III. The Idea Lifecycle: Hunch → Experiment → Adoption or Documented Retirement

**The invariant:** Every idea follows a path. Accepting or retiring an idea without documenting the verdict leaves a mess: stalled branches, cargo-cult code, and future maintainers guessing whether to resurrect or delete.

### Lifecycle Stages

**Stage 1: Hunch (scratch/experiment branch)**
- Hypothesis is untested; mechanism unclear.
- Branching rule: use descriptive names (`fix/story-reload-on-source-change`, not `branchX`).
- Examples: `fix/iteration-loop-with-rotriever` (commit 389a0891, 2026-05-15), `try/fork-workflows` (commit 6896cca5, 2026-04-18).

**Stage 2: Experiment (working branch, often with tests)**
- Implement and measure (use hypothesis-prediction pattern from Section II).
- Collect evidence: test pass/fail, benchmark deltas, real-world validation.
- Examples:
  - `feat/charm-signals-migration` (PR #509, commit acf0fa29, 2026-03-10): "Switch from Signals to Charm" — 394 insertions across 40 files, 1:1 API mapping, shipped with risk noted: "There are likely to still be some edge cases."
  - `fix/story-controls-store` (PR #576, commit 371d7752, 2026-05-30): Dedicated state store + React context (280 insertions, test file 71 lines, measurement validated).

**Stage 3a: Adopted Change (PR merged, code persists)**
- Fix passes adversarial review (Section I), hypothesis validated (Section II), tests added.
- Examples:
  - **Path-length mitigation (PR #523, commit 7a6c69b5, 2026-03-12):** Bundle Wally + Loom packages as `.rbxm` files to defeat Windows MAX_PATH. Mechanism: "Rotriever is not picky about content root format." Result: Permanent fix, rbxm bundling in `compileAsync.luau` (grep `packToRbxm`) still active on current main. Rationale embedded in code comment: "alleviate path length limit issues."
  - **Embedding (PR #582, commit 78d71e8f, 2026-06-21):** Introduced `Pluginlike` abstraction (Section II of `flipbook-architecture-contract`). Shipped with architectural write-up.

**Stage 3b: Documented Retirement (PR merged, code/branch deleted, verdict in archaeology)**
- Idea proved unsound or obsolete; decision captured for future reference.
- Examples:
  - **Build parallelization (PR #405 revert, commit 68b0e2f4, 2025-11-03, 1-day lifetime):** Attempted parallel compilation to cut build time 10s → 5s. Failed within hours; reverted with minimal explanation. Later understood (PR #437): related to Lute's `process.spawn` brittleness. Verdict: parallelization idea abandoned; sequential builds remain standard.
  - **Path-length detection (PR #530, commit 3834640a, 2026-03-18):** After PR #523 succeeded, deleted `.github/actions/check-path-lengths/` and path-checking logic. Commit message: "Thanks to #523 we no longer have to worry about path limits... (Please do not make me regret saying that)." Verdict: defensive code removed after mitigation proved permanent.

### Stalled Branch Graveyard

Flipbook has ~18 stalled branches with work-in-progress; most violate this protocol by existing without a verdict.

**Nearly-ready (awaiting merge review):**
- `adopt-changewrite` (1 commit, 2026-06-28): feature-complete, no obstacles evident.
- `agent-actions-registry` (2 commits, 2026-06-18): stalled at review stage; needs verdict (merge or document why not).
- `update-darklua-0.19-loaders` (1 commit, 2026-06-11): awaiting integration test results; verdict pending.

**Blocked/exploratory (deep work, unclear status):**
- `embedded-http-proxy` (75 commits, 2026-06-19): substantial feature; 75 commits suggests major architectural addition; no recent activity; needs verdict.
- `uilabs-controls-support` (3 commits, 2026-05-09): stalled 53 days; noted "ControlGroup and Object are broken"; verdict: blocked on Storyteller/UI Labs fixes upstream.
- `upgrade-loom-dependencies` (6 commits, 2026-05-09): infrastructure upgrade; described as "nightmare" (cascading API breakage); stalled 53 days; verdict: deprioritized or awaiting full integration.

**Forgotten (dormant 7+ months):**
- `docs-in-studio` (8 commits, 2025-12-26): 187 days dormant; "Embed documentation in Roblox Studio"; unclear if viable; needs verdict.
- `storybook-onboarding` (7 commits, 2025-11-02): 242 days dormant; likely superseded; needs verdict.

### Mandate: Every Stalled Branch Gets a Verdict

When maintaining Flipbook, treat each stalled branch as a debt item:
1. **Assess:** Is the work still aligned with roadmap? Can it ship as-is?
2. **Decide:** Merge (Stage 3a) or retire (Stage 3b).
3. **Document:** If retiring, add a one-line entry to `flipbook-failure-archaeology` SKILL (also in `.agents/skills/flipbook-failure-archaeology/SKILL.md`) explaining the verdict and when, so future maintainers know: "attempted X in branch Y, did not proceed because Z."

Example verdict to add to archaeology:

```
#### `embedded-http-proxy` (stalled, 2026-07-01)
**Status:** Indefinite hold.
**Reason:** Requires architectural buy-in from deployment team; feature value unclear without Roblox-internal roadmap alignment. Revisit Q4 2026.
```

---

## IV. Where Good Ideas Historically Came From

**The invariant:** Track idea sources. Communities, pain-driven tooling, and competitive pressure have each produced shipping features; each source has distinct strengths and failure modes.

### Source 1: Dogfooding (Flipbook develops itself via its own stories)

**Mechanism:** Flipbook's UI is built in React and previewed in Flipbook's own storybook. Pain felt by maintainers developing Flipbook is pain felt by users.

**Example: Controls re-render regression (PR #576)**
- **Pain:** After Signals→Charm migration (PR #509), maintainers noticed story controls became laggy and exhibited visual artifacts when editing controls.
- **Root cause:** State management change exposed architectural issue (controls state coupled to entire panel).
- **Solution:** Dedicated controls store + React context isolation.
- **Outcome:** Shipped in PR #576; maintainers validated fix by developing Flipbook itself via Flipbook.

**Example: DevTools instrumentation (scripts/)**
- Pain: Build times unclear; no visibility into which phases were slow.
- Solution: Lute scripts in `.lute/` added for `analyze`, `lint`, `test` — each solving a specific friction point.
- Outcome: Lute scripts become shared scaffolding; documented in `flipbook-diagnostics-and-tooling`.

### Source 2: Competitive Pressure (UI Labs gap analysis)

**Mechanism:** Community and internal users (Roblox engineers building Universal App) compare Flipbook to alternatives (UI Labs, web Storybook). Gaps identified become roadmap priorities.

**Evidence from vault docs (flipbook-docs branch):** `docs/obsidian-vault/product/2025-flipbook-product-spec/index.md` lists feature matrix:

```
| Feature                  | Priority | Status      |
|--------------------------|----------|-------------|
| Full UI Labs Compatibility| P0       | Not started |
| Controls Revamp          | P1       | In progress |
| Telemetry                | P1       | Not started |
```

Controls revamp (#465, #576, #579) is shipping to close UI Labs gap. Features like `Check` control, `Color` control, sliders exist in UI Labs; Flipbook lacked them.

### Source 3: Community/DevForum Feedback

**Mechanism:** Creators post in DevForum, GitHub issues, Discord. High-signal requests become experiments.

**Example: Auto-launch suppression (PR #593)**
- **Community pain:** Users report Flipbook reopening unexpectedly when Studio layout resets.
- **Root cause:** `DockWidgetPluginGuiInfo` had `initEnabled=true`; Studio's layout recovery re-instantiated the widget.
- **Solution:** Set `initEnabled=false` (toolbar button only); change initial dock state from Top to Float.
- **Outcome:** Merged; likely resolves accidental launches.

### Source 4: Pain-Driven Tooling (.lute scripts)

**Mechanism:** When a developer feels friction repeatedly, they automate. The script becomes shared scaffolding.

**Example 1: Type checking (lute run analyze)**
- **Pain:** Luau strict analysis catching real errors; running manually slow; CI needs it too.
- **Solution:** Lute script `.lute/analyze.luau` encapsulates `lune setup`, Luau language server invocation, artifact cleanup.
- **Outcome:** `lute run analyze` becomes the canonical type-check command; same script runs locally and in CI.

**Example 2: Testing (lute run test)**
- **Pain:** Jest tests run inside Roblox; requires Rocale (Luau Execution), API key, place file. Manual invocation complex.
- **Solution:** `.lute/test.luau` packs the test place, invokes Rocale with environment gating, filters by `--filter <pattern>`.
- **Outcome:** `lute run test --filter Controls` works locally; same script runs in CI with environment-gated API key access.

**Example 3: Build (lute run build plugin --channel dev --watch)**
- **Pain:** Multiple build targets (plugin, workspace, storybook); multiple channels (dev, beta, prod). Manual command fragile.
- **Solution:** Consolidated build system in `.lute/lib/build-system/` with Darklua integration. Single entry point handles all combinations.
- **Outcome:** Developers use `lute run build` idiomatically; no knowledge of Rojo, Darklua, or sourcemap plumbing required.

### Source 5: Upstream Dependency Pressure

**Mechanism:** Library APIs change (Storyteller, Charm, Roblox packages); Flipbook adapts or breaks. The adaptation often surfaces new patterns.

**Example: Charm.flags.frozen workaround (src/PluginStarterScript.plugin.luau, grep `Charm.flags.frozen = false`)**
- **Upstream issue:** Storyteller mutates immutable Charm state (storyteller#100, unresolved).
- **Pain:** Flipbook crashes with "Attempt to modify a readonly table."
- **Solution:** Disable Charm immutability (`Charm.flags.frozen = false`) as temporary workaround.
- **Status:** Documented as "evil state bug"; unresolved upstream dependency; workaround persists.

---

## V. The Promotion Protocol: Experiment → Measurable Result → Change-Control Gates

**The invariant:** Ideas flow through change-control gates (flipbook-change-control skill; CI validation via flipbook-validation-and-qa skill). Never route around them. Routing around gates is how bugs ship.

### Gate 1: CI / Automated Validation (flipbook-validation-and-qa)

**Applies to:** Every PR.

**Checks:**
- `build-plugin` (dev + prod channels): Darklua, Rojo, builds succeed; provenance attestation generated.
- `build-package` (flipbook-core rotriever): Package builds without path-length overflow (validates Section I mechanism from PATH-LENGTH SAGA).
- `analyze` (Luau strict type checking + selene lint).
- `lint` (StyLua, Prettier).

**Gating behavior:** PR cannot merge without passing all checks. No `--force-push` to main; no merging with failing CI.

**Regression gate (from Section I):** PR #444 added runtime assertion for BUILD_HASH. Any future break of the build-hash mechanism will fail CI immediately, catching 2+ week feedback loops like #426 → #444.

### Gate 2: Change-Control Classification (flipbook-change-control)

**Applies to:** PR authoring.

**Decision tree:**
- **Internal refactor** (no user-facing change): standard review.
- **Bug fix**: describe root cause (evidence bar from Section I), link to issue/archaeology, provide test.
- **Feature**: feature-gated via BUILD_CHANNEL or explicit opt-in (telemetry); documented in roadmap.
- **Dependency upgrade**: tested against consuming repos (Storyteller, ModuleLoader).
- **Breaking change to story format or controls schema**: requires 1:1 migration path (documented in docs/obsidian-vault/). No unannounced breaks to community API.

### Gate 3: Testing & Measurement (flipbook-diagnostics-and-tooling + flipbook-validation-and-qa)

**Applies to:** Changes touching story controls, state management, performance-sensitive code.

**Evidence standard:**
- Hypothesis-prediction from Section II validated? (e.g., PR #576: "localized updates to touched controls only").
- Test suite updated to capture new behavior?
- Benchmarks or counter evidence collected?

**Example: PR #576 (controls re-render fix)**
- Added `createStoryControlsStore.spec.luau` (71 lines): tests for state isolation, subscription, re-render prevention.
- Before/after measurement: visually confirmed no artifacts when dragging controls slider (maintainer's dogfooding).
- Test isolation: new store logic testable without React scheduler (deferred from Section II pattern).

**Anti-pattern:** Shipping without measurement. Example: PR #405 (parallelization) claimed ~5s build time but produced unreliable results within hours. No benchmark data collected before merge; revert quick.

### Gate 4: Community Doctrine (flipbook-community-and-positioning)

**Applies to:** Features, telemetry, API changes.

**Doctrine (from shared-brief):**
- **Community-first:** Flipbook is brought to Roblox internal users but internal support ends at parity with community version. No internal-only features.
- **Telemetry/Privacy:** Immediate opt-out dialog exists (TelemetryOptOutDialog). No privacy policy yet (open obligation). No telemetry expansion without written privacy docs.

**Gating:** Features targeting Roblox-internal workflow (e.g., `roblox-internal-support/` docs in flipbook-docs branch) are documented separately. The open-source build and internal build must remain symmetric in capability.

---

## VI. Failure Case: When Retirement is NOT Documented

**The invariant:** Code without a verdict lingers. Stalled branches without a verdict are debt.

### Negative Example: `upgrade-loom-dependencies` Branch

**Branch:** `upgrade-loom-dependencies` (commit 1852d77b, 2026-05-09, 6 commits).

**Context:** Lute version bump required cascading API fixes. Commit message on 1852d77b: "Bumping Lute version and fixing the nightmare it spawned."

**Work:** Multiple fixes across API boundaries; stalled 53 days (as of 2026-07-01).

**Missing verdict:**
- Is the branch viable? (Unknown.)
- Is the work still relevant? (Unknown; newer Lute versions may have released.)
- Should future maintainers attempt this again? (No guidance.)
- Should this work be rebased on main or abandoned? (No decision.)

**Residue:** Stalled branch lingers; future maintainers see "nightmare" comment but no resolution. Do they:
- Resurrect and finish?
- Delete and wait for upstream fix?
- Wait for maintainer guidance that never comes?

**Lesson:** When a branch reaches >1 week stalled, capture a verdict in flipbook-failure-archaeology, even if tentative:

```markdown
#### `upgrade-loom-dependencies` (stalled, 2026-05-09)
**Status:** Abandoned; superseded by `lute@1.0.1` public release.
**Reason:** Manual Lute nightly migration proved fragile. Wait for stable release.
**Verdict:** Do not resurrect. If Lute needs upgrading, start from main with fresh branch.
```

Now future maintainers know.

---

## VII. Integration: Running Experiments Correctly

**Checklist for proposing a change:**

1. **State your hypothesis** (Section II): "If X is the root cause, then Y should measure as Z."
2. **Collect baseline evidence** (Section II): Run the current code; measure Y.
3. **Propose the fix** with root-cause analysis grounded in evidence (Section I).
4. **Implement experiment branch** with descriptive name (Section III, Stage 1-2).
5. **Validate prediction** (Section II): Build/test/measure. Does Y now equal Z?
6. **Assign adversarial review** (Section I, step 4): Have a second engineer try to break your mechanism.
7. **Add tests** (Section V, Gate 3): Capture the new behavior so regression is impossible.
8. **Run through CI gates** (Section V): All checks pass; no workarounds.
9. **Document if retiring** (Section III, Stage 3b): If the idea doesn't ship, add verdict to archaeology.
10. **Merge as PR** with AI authorship disclosed (from flipbook-change-control): "Generated with Claude Code."

---

## VIII. Provenance and Maintenance

This skill is built on real incidents from Flipbook's git history as of 2026-07-01. Re-verify annually or when major failures occur:

- **BUILD_HASH brittleness:** Verify `getCommitHash()` in `.lute/build.luau` still asserts a non-empty hash (grep `commit hash is empty`). If Lute stabilizes `process.run` stdio behavior, this may become unnecessary scaffolding.
- **Path-length mitigation:** Verify rbxm bundling still active in `.lute/lib/build-system/compileAsync.luau` (grep `packToRbxm`). Test Windows CI: no path-length failures in last 6 months?
- **Charm.flags.frozen:** Search `src/PluginStarterScript.plugin.luau` for `Charm.flags.frozen = false`. If Storyteller#100 is resolved upstream, remove workaround and test.
- **Stalled branches:** Run `git branch -a | wc -l` every quarter. Branches >4 weeks stalled should have a verdict in flipbook-failure-archaeology or be merged.
- **Parallelization verdict:** If future Lute versions stabilize process spawning (check `lute/issues/440` upstream), revisit PR #405 ideas; parallel build could ship.

**Commands to verify this skill's claims:**

```bash
# Verify BUILD_HASH mechanism
git show 704fbd5b | grep -A 5 "stdio = \"default\""
git show 704fbd5b | grep "assert.*commit.*hash"

# Verify path-length rbxm bundling
grep -n "alleviate path length" workspace/flipbook-core/src/build-system/compileAsync.luau

# Verify Charm workaround
grep -n "Charm.flags.frozen" src/PluginStarterScript.plugin.luau

# Verify stalled branches
git branch -a | grep -E "(embedded-http-proxy|upgrade-loom|docs-in-studio)" | wc -l

# Verify PR #576 test coverage
find workspace/flipbook-core -name "*StoryControls*.spec.luau" -exec wc -l {} \;
```

**Last verified:** 2026-07-01. Flipbook version 2.5.0. Main branch commit 78d71e8f.
