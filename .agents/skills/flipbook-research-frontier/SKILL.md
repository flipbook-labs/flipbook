---
name: flipbook-research-frontier
description: "Open research problems where Flipbook advances SOTA beyond web Storybook and uilabs: in-experience collaboration, automated visual regression, agent-driven development. First steps, blockers, milestones."
type: knowledge
---

# Flipbook Research Frontier

This skill documents three distinguished-engineer-level research frontiers where Flipbook has unique assets and the potential to advance the state of the art beyond web Storybook and uilabs. Each frontier includes current SOTA gaps, Flipbook's specific advantage, first-order blockers, and falsifiable milestones. **All frontiers are open/candidate** — nothing here is shipped. Ground every claim in the repo; external-world assertions (web Storybook capabilities, uilabs scope) are labeled unverified-from-repo.

Sibling skills: `flipbook-failure-archaeology` (dead ends), `flipbook-story-controls-campaign` (hardest live problem), `flipbook-docs-and-writing` (publication). For questions about what lands when and under what conditions, see `flipbook-change-control` (PR workflow) and `flipbook-release-and-operations` (artifact/deployment conventions).

## Frontier 1: In-Experience Collaboration

### Problem: Why Current SOTA Fails

Web Storybook's shareable preview links (unverified-from-repo: Storybook Cloud, Netlify integration) exist as static web renderings — they are not running *inside* the Roblox runtime or the place where the UI will actually appear. Designers, product managers, and stakeholders reviewing candidate UI must either (1) ask developers to manually deploy the experience and open it in Studio (friction, latency), or (2) review flat screenshots/videos (static, no interaction). This creates a deployment-to-feedback cycle measured in minutes or hours, not seconds.

### Flipbook's Specific Asset

- **#582 Embedding (shipped on main):** Flipbook can run as an embedded runtime inside a place (not just as a plugin in Studio). Verified in main commit 78d71e8f ("Embed Flipbook in the DataModel"): `src/EmbeddedClientStarterScript.client.luau`, `src/EmbeddedServerStarterScript.server.luau`, `workspace/flipbook-core/src/Embedding/`.
- **Per-PR preview places:** `.github/workflows/storybook.yml` deploys a fresh Storybook place on every PR via `flipbook-labs/deploy-storybook@v0.4.0` action (verified in CI), making each PR's UI testable live inside Roblox without manual setup.
- **HTTP access problem (candidate/open):** The embedded context loses Studio's implicit HTTP access for reaching `flipbooklabs.com` backend. Branch `embedded-http-proxy` (75 commits, last activity 2026-06-19) proposes a server-side proxy (unmerged, requires security review).

### Open Problem: Lower-Security-Context HTTP Access

When Flipbook runs embedded in a place (not as a plugin), it loses Studio's implicit HTTP/HTTPS access. The embedding cannot reach its backend (`flipbooklabs.com`) for telemetry, update checks, or API calls. Core issue: **embedded scripts run in a lower-permission context than plugin scripts**; `HttpService:RequestAsync` requires the place's HTTP allow-list to include `flipbooklabs.com`, which defeats the point of per-PR ephemeral preview places (why should each temporary place whitelist a backend?).

### First Steps (In This Repo)

**Step 1: Understand the proxy approach** (characterization from read-only git, no build/test)

Branch: `embedded-http-proxy` (75 commits, last activity 2026-06-19). Main commit: `7f076c51` ("Route embedded HTTP requests through a server-side proxy").

Approach:
- When embedded, `src/EmbeddedServerStarterScript.server.luau` creates a `RemoteFunction` tagged `FlipbookHttpProxy` (verified in branch diff on `embedded-http-proxy`; the file ships on main via #582, but the `FlipbookHttpProxy` tag is branch-only — do not expect to grep it on main).
- Client's `workspace/flipbook-core/src/Http/requestAsync.luau` detects the proxy via `CollectionService` and invokes it server-to-server instead of calling `HttpService` directly (verified in branch diff on `embedded-http-proxy`).
- Server-side proxy filters all requests through an allowlist (grep `ALLOWED_HOST` on the branch) + host-parsing logic to defeat spoofing (URL parsing stripping userinfo and port; grep `userinfo` in the same file on the branch).

What it solves: Flipbook can reach its backend even when the place does not have HTTP enabled, because the server script (trusted Roblox engine code) makes the request.

What remains unresolved (inference from diff scope): **design review of allowlist strategy.** Is flipbooklabs.com the right single-point trust anchor? What happens when a PR preview place is public and a malicious player inside it tries to trigger DNS rebinding or header injection via the proxy? The code shows guards (host parsing, scheme restriction to HTTPS) but the architectural trade-off (who is allowed to invoke the proxy, what can they learn from response timing) is not yet reviewed.

**Step 2: Read the embedding safety context** (characterize what makes embedded different from plugin)

File: `workspace/flipbook-core/src/Embedding/createEmbeddedFlipbookApp.luau` (verified in main, commit 78d71e8f).

Questions to answer by reading:
- What permission surface do embedded client and server scripts have vs. plugin code?
- Are there shared ContextProviders (auth, permissions, theme) that assume a plugin context and will break embedded?
- How does the story renderer (React, Roact, Fusion) behave when mounted in a place (not a plugin)?

Command (read-only git, no checkout):
```bash
git show 78d71e8f:workspace/flipbook-core/src/Embedding/createEmbeddedFlipbookApp.luau | head -100
```

**Step 3: Set up a test place with embedded Flipbook** (build + manual verification)

Command (from main branch, `lute run build storybook` is verified in build.luau):
```bash
lute run build storybook --channel dev
# Creates: build/flipbook-storybook.rbxl

# Open the place in Studio, inspect console for warnings about missing HTTP proxy.
# Try to navigate to a story; check network tab (Roblox Studio output) for proxy invocation.
```

Acceptance: A place runs embedded Flipbook; stories load and telemetry calls work even though place's `HttpService` allows nothing.

**Step 4: Design review and security audit**

Blocker: Before any PR, the allowlist design must be reviewed by someone familiar with Roblox permission contexts and DNS rebinding. The current approach (single HTTPS domain + host-only comparison) is sound for basic cases but needs threat modeling: Can a player manipulate response times? Can they pivot to other services via subdomains? Is the place's server running untrusted code?

### Blockers & Prerequisites

1. **Architectural review of proxy allowlist:** Who approves the security posture? Is Flipbook willing to accept the risk of a proxy in a place (even if allowlisted)? What does internal Roblox security say about this?
2. **Design decision on access control:** Should per-PR previews be public (anyone with place link can use Flipbook), private (internal only), or auth-gated? This determines whether we need rate-limiting or identity tracking on the proxy.
3. **Backend support for PR-scoped API keys:** Even with HTTP access, telemetry from PR previews will pollute production data. Do we need per-place or per-PR API keys? Or a separate telemetry sink?

### Falsifiable Milestone: You Have a Result When…

✓ Embedded Flipbook (in a test place with no HTTP allow-list) successfully logs a telemetry session event to `apis.flipbooklabs.com`.

✓ A security review document (internal, not necessarily public) outlines the allowlist design rationale and approved threat model.

✓ The `embedded-http-proxy` branch either lands on main with a design review record, or is declared out-of-scope with a written decision (e.g., "Roblox internal will own this" or "require places to whitelist flipbooklabs.com").

---

## Frontier 2: Automated Visual Regression (Story Snapshots)

### Problem: Why Current SOTA Fails

Web Storybook's Chromatic integration (unverified-from-repo) allows teams to snapshot every story on every build, compare pixel-diffs, and detect unintended UI changes. Roblox has **no equivalent tool**. Visual regression testing for Roblox UI is manual: screenshot a story, commit the baseline, then developers manually eyeball screenshots on each change. This scales poorly (can't diff large UI suites, false positives from minor rendering quirks, no way to gate PRs on visual regressions).

### Flipbook's Specific Asset

- **`automated-story-snapshots` branch** (11 commits, last activity 2026-06-28; kept in sync with main): Implements WebSocket-based story capture directly from Lute scripting (not via browser screenshot).
- **stories.spec harness** (verified in main: `workspace/flipbook-core/src/Storybook/stories.spec.luau`): All stories are renderable in a headless Jest test context; render-all would require iterating this list and calling each story's render function with default controls.
- **Cloud Luau Execution via Rocale** (verified in `.github/workflows/strict.yml`): Tests run inside Roblox (not mocked). We can spawn a place, render stories, capture screenshots server-side, and assert pixel-diffs — all in CI.

### Open Work: Characterize the Branch (Read-Only)

Branch: `automated-story-snapshots` (commit 9e1a5923, merged with main 2026-06-28).

What it ships (verified in commits):
- Lute task that connects to StudioMCP WebSocket proxy (grep `ws://127.0.0.1`), calls `screen_capture` MCP tool, base64-decodes PNG response, writes to disk.
- `.agents/skills/story-snapshot/SKILL.md` (73 lines): Skill documentation for agents; guides snapshot workflows (inference from stat: added, not verified by reading).
- `docs/screenshots/ButtonWithControls.png` (150KB image): Sample captured story screenshot (exists in build artifacts).
- Loom dependency upgrades: upgraded to Lute v1.0.1-nightly + FlipbookBatteries v0.11.1 to support new capture APIs.

What remains speculative (not in branch commits, inference):
- **Pixel-diff engine:** The branch captures PNGs but does not include logic to compare against a baseline or flag regressions. This is *candidate/out-of-scope* for the branch itself — the diff would live in a separate PR or tool.
- **Story iteration in CI:** Branch does not include a `stories.spec` helper to render all stories and capture each one. This is a separate step (inference: would need to iterate `stories.spec.luau`'s test suite, render each story's function with default/candidate controls, capture each, hash/diff the results).
- **CI gate:** No `.github/workflows/` job yet that runs visual regression tests and blocks PRs on mismatches. This is post-capture infrastructure.

What the branch actually does (verified):
1. Connects Lute to Studio's WebSocket MCP proxy (mechanism: JSON-RPC wrapper).
2. Invokes `screen_capture` tool (Storybook-embedded tool provided by Flipbook's embedded runtime).
3. Decodes base64 PNG.
4. Writes to disk.

**Step 1: Run the capture task** (verify mechanism works)

Command (from automated-story-snapshots branch; requires Studio with Flipbook running embedded):
```bash
git checkout automated-story-snapshots
lute run .lute/tasks/capture-story.luau /tmp/test-story.png MyStory
# Spawns WebSocket client, waits for tools_updated, invokes screen_capture, writes file.
```

Acceptance: `/tmp/test-story.png` exists and is valid PNG, not corrupted.

**Step 2: Inventory story files and build a render-all harness** (plan, no build)

Task: Iterate `workspace/flipbook-core/src/**/*.spec.luau` to find all story files.

Command (read-only grep):
```bash
find workspace/flipbook-core/src -name "*.story.luau" | wc -l
# Expected ~40–50 story files in main
```

Question to answer by reading a few story files: Do all stories export a Flipbook.Story type with a `story()` function and optional `controls`? Or are there renderers (Roact, Fusion, manual) with different shapes?

File to read (canonical story format):
```bash
git show main:workspace/flipbook-core/src/Storybook/stories.spec.luau | head -50
```

**Step 3: Design the capture workflow** (design, not build)

Questions (read-only; answer from branch + flipbook-docs vault):
- Should we capture stories before or after story-controls revamp? (Controls change shape; baseline snapshots will be invalidated.)
- What is the canonical "default controls" for a story if the author did not set one? (Answer via `flipbook-docs` branch's controls API docs.)
- How do we handle stories with non-deterministic output (animations, randomness, timestamps)? (Candidate: freeze time, set random seed in test context.)

Pseudo-spec (inference from branch approach):
```
For each Story:
  1. Open the place with Flipbook embedded (automated-story-snapshots does this via Studio boot)
  2. Invoke story.story() with story.controls (defaults or user-specified)
  3. Render result to GuiObject (Story's render function handles library choice)
  4. Capture viewport PNG via screen_capture MCP tool
  5. Hash PNG; store hash + image URL in snapshot table
  6. On next PR, capture again; diff hashes; comment on PR with diffs
```

### Blockers & Prerequisites

1. **Freeze the controls API first:** The controls revamp (flipbook-story-controls-campaign) is not yet stable. Shipping snapshot baselines before controls stabilize means every controls change invalidates all snapshots. Decision needed: land the controls revamp to main first, or snapshot against the Q1 2026 target API (currently in branch)?
2. **Determine canonical capture environment:** Should snapshots run in Studio (using Lute's WebSocket proxy) or in headless Cloud Luau (like tests do)? Studio mode gives pixel-perfect rendering but requires developer machine. Headless is CI-native but rendering may differ. Pick one and design accordingly.
3. **Design snapshot storage:** Where do baseline PNGs live? In git (bloats repo), on S3 (requires credentials), embedded in test data (requires serialization)? Web Storybook embeds them in Chromatic SaaS; Flipbook needs a story.
4. **Set thresholds for "regression":** Pixel-diff is noisy (font rendering, anti-aliasing, compression artifacts). Need to set acceptance thresholds (% of pixels, perceptual diff threshold) so flaky baselines don't spam PRs.

### Falsifiable Milestone: You Have a Result When…

✓ You can run `lute run render-all-stories --capture` and end up with a `snapshots.json` file containing PNG base64 + hash for all stories (5+ stories minimum).

✓ A PR changes a story's visual output (e.g., button color); the CI job detects the regression and comments on the PR with before/after images side-by-side.

✓ Documentation (in `.agents/skills/` or the vault) specifies the capture environment, default controls semantics, and how to update baselines when changes are intentional.

---

## Frontier 3: Agent-Driven UI Development

### Problem: Why Current SOTA Fails

Developers iterating on Roblox UI today must manually create test instances, set properties, trigger event handlers, and inspect the result. No LLM-based tool can ask "build me a dialog with a text input and an OK button that submits form data" and end up with a working Flipbook story or interactive component. Web Storybook's Interactions addon (unverified-from-repo) allows agents to orchestrate clicks, but Roblox has **no story-as-a-contract mechanism**. An agent cannot discover "what Flipbook stories exist and what can I do with them" without reading YAML or markdown.

### Flipbook's Specific Asset

- **`agent-actions-registry` branch** (2 commits, commit fc2a79bc, 2026-06-06): Central action registry with PluginAction + BindableFunction dual-dispatch. Verified in types.luau: Actions expose `params` schema so agents know how to invoke them (e.g., `NavigateTo(screen: string)`, `SelectStory(path: string)`, `ListStories(): { StoryInfo }`). See fc2a79bc Actions/types.luau for full shape.
- **`.agents/` skill infrastructure:** Four existing agent skills (verified in main: `setup-flipbook-dev-env`, `run-flipbook-checks`, `test-dependencies-in-flipbook`, `develop-through-studioplugins`). Agents can read Flipbook's architecture, run commands, analyze code.
- **Stories as a machine-checkable component contract:** Each story defines a `Flipbook.Story` type (verified in vault docs, flipbook-docs branch): `story()` function returns a GuiObject or React/Roact/Fusion element; `controls` schema is machine-readable (after controls revamp lands). This is the skeleton of a machine-checkable contract.

### Open Work: Characterize the Branch (Read-Only)

Branch: `agent-actions-registry` (commit fc2a79bc, 2026-06-06; 25 files added, 1182 lines).

What it ships (verified in commit fc2a79bc --stat):
- `workspace/flipbook-core/src/Actions/` (new directory, 25 files): Central registry + PluginAction + Bindable routers.
- `createActionRegistry.luau` (54 lines): Registers action definitions and dispatches both via `PluginAction:Triggered` and `BindableFunction:Invoke`.
- `BindableRegistry.luau` (60 lines): Exposes `__manifest` endpoint (inference: agents query this to discover available actions).
- `definitions/` subdirectory: Four action implementations: `ToggleWidget`, `NavigateTo`, `SelectStory`, `ListStories` (13–26 lines each).
- Types in `Actions/types.luau` (83 lines): Full schema with `ActionContext`, `ActionParam`, `Action`, `ManifestEntry`, `AppController` (verified above; dual dispatch through both human shortcuts and BindableFunction).
- Tests: 5 spec files (BindableRegistry.spec, PluginActionMirror.spec, createActionRegistry.spec, createAppController.spec, definitions/*.spec) covering registry, dispatch, and action execution (verified in stat: 5 spec files added, ~400 LOC total).

What the branch does (verified):
1. Define actions in `definitions/` (id, text, statusTip, params schema, run function).
2. `createActionRegistry` boots both routers (PluginAction for human, Bindable for agents).
3. `BindableRegistry.__manifest` allows agents to query: "what actions exist and what do they expect?"
4. Both routers converge on a single `dispatch` function, which runs the action's `run` callback and returns `{ ok, result, error }`.

What remains speculative (not in branch):
- **Agent integration:** The branch defines the *contract* (actions + manifest) but does not ship an agent that consumes it. Actual agent code (e.g., Studio Assistant's `execute_luau`) would need to be written.
- **Story mutation actions:** The branch includes `ListStories` and `SelectStory` but not "render a story with these controls" or "set a control value and capture screenshot." These are candidate future actions.
- **Error recovery:** Actions return `{ ok, error }` but there is no retry/backoff logic if, say, selecting a story fails (e.g., story module has a syntax error). Agents would need to handle failures.

**Step 1: Verify action manifest shape** (read-only)

Command:
```bash
git show agent-actions-registry:workspace/flipbook-core/src/Actions/types.luau | grep -A 20 "type ManifestEntry"
```

Expected output (verified in the `agent-actions-registry` branch diff; grep `ManifestEntry` there — the type is not on main):
```luau
export type ManifestEntry = {
    id: string,
    text: string,
    statusTip: string,
    params: { ActionParam }?,
}
```

Question: What does an agent receive when it queries `BindableRegistry.__manifest`? Answer: an array of `ManifestEntry`, one per action. The agent can use `params` to understand call signatures without reading source.

**Step 2: Understand the AppController seam** (read-only)

File: `workspace/flipbook-core/src/Actions/createAppController.luau` (75 lines, verified in branch).

Purpose (inference from code): Actions need to reach React app state (current screen, selected story). The `AppControllerImpl` is registered when the React app mounts and torn down on unmount. This allows actions like `SelectStory` to directly mutate app state without dispatching through Flipbook's event bus (which would require a roundtrip).

Question to answer by reading the file: What happens if an agent tries to call `SelectStory` when the app is unmounted (widget is closed)?

Expected: Action returns `{ ok = false, error = "AppController not registered" }`.

**Step 3: Plan agent-driven story render** (design, no build)

Candidate action (speculative; not yet implemented):

```luau
export type RenderStoryAction = {
  id = "Flipbook/RenderStory",
  text = "Render story",
  params = {
    { name = "storyPath", type = "string", required = true },
    { name = "controls", type = "table", required = false },
  },
  run = function(ctx, payload)
    -- 1. Load story via ModuleLoader (bypasses require cache)
    -- 2. Apply controls (payload.controls)
    -- 3. Call story.story() with controls baked in
    -- 4. Return result (GuiObject or React element)
  end
}
```

Question: Where does the rendered output go? Options: (1) rendered to plugin viewport (in Studio), (2) rendered to a temporary Frame and PNG captured, (3) return a representation (e.g., JSON tree) for agent analysis.

For agent-driven testing, option (2) makes sense (capture result automatically). For agent-assisted UI design, option (1) makes sense (human sees the result in Studio).

This is the highest-priority design question: **what is the agent's output modality?**

**Step 4: Sketch the agent experience** (design, no code)

Pseudo-code (what an agent would do with Flipbook today, post-landing agent-actions-registry):

```
Agent (e.g., Studio Assistant):
1. Query BindableRegistry.__manifest → { actions: [...] }
2. Find "Flipbook/ListStories" action
3. Invoke BindableRegistry with { action = "Flipbook/ListStories" }
4. Get back { ok = true, result = [ { path = "...", name = "Button" }, ... ] }
5. User says "show me the Button story"
6. Agent finds "Flipbook/SelectStory"
7. Invokes with { storyPath = "path/to/Button.story.luau" }
8. Studio displays the story in Flipbook's viewport
```

This is *already enabled by agent-actions-registry* on main. What's missing (candidate): more granular actions (set control value, capture screenshot, list available control types), and actual agent code that consumes this API.

### Blockers & Prerequisites

1. **Finalize what "agent-driven" means for Flipbook:** Is it agents querying stories from outside Flipbook (e.g., CI agent building a test matrix)? Agents editing stories (e.g., "generate a Button story with these props")? Agents reviewing rendered output (e.g., "does this match the design spec")? Different goals need different contracts.
2. **Decide agent output modality:** Should agent actions mutate the Flipbook UI (good for live coding, breaks isolation) or return data (good for headless testing, hard for human inspection)? Or both?
3. **Story format stability:** Before agents can reliably generate or edit stories, the story format (return type, controls schema) must be stable. Linked to controls-revamp completion.
4. **Error semantics:** Agents need clear error messages. If a story render fails (e.g., module load error), should the error include stack trace? Should it be sanitized for external agents?

### Falsifiable Milestone: You Have a Result When…

✓ An agent (or a Lute script simulating one) queries `BindableRegistry.__manifest`, sees at least 5 actions with documented param schemas, and successfully invokes at least 3 of them (e.g., ListStories, SelectStory, NavigateTo) without parsing source code.

✓ A proof-of-concept agent skill or script demonstrates: discover a story via ListStories, render it by invoking a hypothetical "RenderStory" action (or the equivalent), and capture or inspect the result.

✓ Design documentation (in `.agents/skills/flipbook-research-frontier/` or as a branch-level design doc) specifies what "agent-driven UI development" means, what contract stories must expose, and what the first agent integration should look like.

---

## Cross-Frontier Dependencies & Honest Blockers

### The Hidden Order

Frontiers are not independent. **Visual regression depends on stable controls.** Agents need stories with machine-readable contracts. All three benefit from embedding being locked down.

### Gating Factors (Must Be True Before Public Claims)

1. **No internal-only features:** Per `flipbook-community-and-positioning`, Flipbook brings features to Roblox engineers internally, but internal builds must not ship what the community build cannot have (PR #563 incident, fork-workflow saga). If Flipbook's agent actions framework only works with Roblox-internal tools, it is an open blocker to claiming "agent-driven UI development."
2. **Telemetry hygiene:** Embedding and agent-driven work will generate new telemetry events (place previewed, story rendered, control changed). These must respect the opt-out mechanism and privacy doctrine. See `flipbook-config-and-flags` for telemetry strategy; ensure no telemetry expansion without privacy review.
3. **Performance & reliability first:** Do not claim visual regression testing without proving stories capture consistently (no flakes due to render timing). Do not claim agent-driven development without proving action dispatch is reliable under load (agents will hammer it).

---

## Provenance & Re-Verification Commands

Date: 2026-07-01

Verify frontier branch status and commit details (read-only git):
```bash
# Embedded HTTP proxy branch
git log --oneline embedded-http-proxy -1
git show 7f076c51 --stat  # Main commit

# Automated snapshots branch
git log --oneline automated-story-snapshots -1
git show automated-story-snapshots:workspace/flipbook-core/src/Storybook/stories.spec.luau | head -30

# Agent actions registry branch
git log --oneline agent-actions-registry -1
git show fc2a79bc --stat  # Main commit
git show fc2a79bc:workspace/flipbook-core/src/Actions/types.luau
```

Verify embedding in main:
```bash
git show 78d71e8f --stat | grep Embedding
git show main:src/EmbeddedServerStarterScript.server.luau | head -50
```

Verify build commands (Darklua-deep reference):
```bash
grep -r "build storybook" .lute/
```

When foundational assumptions drift (e.g., build breaks, branches cherry-picked to main, controls API changes), re-run the above and update this skill's characterizations.
