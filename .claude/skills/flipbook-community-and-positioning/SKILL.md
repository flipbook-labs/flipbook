---
name: flipbook-community-and-positioning
description: Community-first doctrine, telemetry/privacy posture, ecosystem positioning vs web Storybook and UI Labs, and claim discipline for Flipbook features
---

# Flipbook: Community-First Doctrine, Telemetry, Privacy, and Positioning

This skill documents Flipbook's commitment to its community, the open obligations around telemetry and privacy, competitive positioning, and the discipline required before claiming features in documentation or release notes.

## The Community-First Doctrine (Maintainer Doctrine, 2026-07-01)

**Binding Rule:** Flipbook is being brought to Builders at Roblox internally, but internal support largely ends at parity with the base plugin. The internal build must NOT gain features the community build cannot have merely because it runs in an elevated context with internal APIs. This is enforceable on all maintainers and contributors.

### Rationale

Flipbook is a community-first project. Feature fragmentation between internal and community builds erodes trust, splinters the developer base, and creates maintenance burden. The Roblox-internal deployment is a *mirror deployment*, not a *privileged tier*.

### What This Forbids (With Evidence)

**Case 1: API-Access-Only Features**
Do not implement a feature in the internal/rotriever build that uses internal Roblox APIs (e.g., `StudioService` private methods, internal plugin contexts, or closed-source internal packages) if the community build cannot have it. The feature must either degrade gracefully to a community-compatible implementation or not be shipped in the internal build at all.

*Example violation:* If the internal build tries to use an internal `PluginContext.getUniverseId()` method to auto-populate a storybook universe ID, but the community plugin has no access to that method, this splits the feature space. Instead: implement a graceful fallback where the community build lets users enter a universe ID manually, and the internal build uses the API if available. Or: don't ship until community API access is provided.

**Case 2: Telemetry Expansion**
Do not add telemetry events or collection strategies in the internal build that the community build cannot opt into or see the code for. See the Telemetry section below for current obligations.

*Example violation:* An internal build collecting "StudioAPI call counts" or "internal universe metadata" without equivalent documentation and opt-out in the community plugin.

**Case 3: Permissions/Service Access Checking**
The `tryGetService` helper in `workspace/flipbook-core/src/Permissions/tryGetService.luau` exists to handle graceful degradation when a service is unavailable (e.g., in sandboxed contexts). Use it; do not paper over missing services with internal-only workarounds.

### How a Reviewer Applies It

Before approving a PR that touches the rotriever build target, the internal-mirroring flow, or uses Roblox-internal APIs:

1. **Is this feature present in the community build?** Check `main` branch code for the same logic. If it's internal-only, escalate to the maintainer for a decision: either backport to community or reject the internal feature.
2. **Does it use internal APIs?** Search `workspace/flipbook-core/src/` for imports from closed-source internal packages. If found and community can't use them, ask: "Can this feature work in the community build?" If no, it should not ship in the internal build until the answer is yes.
3. **Is it a telemetry addition?** Cross-check `workspace/flipbook-core/src/Telemetry/types.luau` and `fireEventAsync.luau` on main. Any new event that exists only in internal must be formally added to community telemetry first, with privacy disclosure written (see below).
4. **Test the feature in the community build.** If a PR is internal-only, check it out locally and validate it works on a standard community Flipbook built with `lute run build plugin --channel prod`.

### Concrete Technical Differences (As of 2026-07-01)

**Embedding Feature (Shipped in Main, #582):**
- The embedded starter scripts (`EmbeddedClientStarterScript.client.luau`, `EmbeddedServerStarterScript.server.luau` in `src/`) enable in-experience Flipbook.
- This feature exists in *both* community and internal builds because no internal APIs are required. The community plugin can embed itself into a place just as the internal build can.
- The rotriever build (`--target rotriever`) is identical to the roblox build (`--target roblox` default) in terms of features; it's just packaged for Rotriever dependency consumption by internal StudioPlugins.

**Service Availability (Via `tryGetService`):**
- Some Roblox services may not be available in all contexts (e.g., sandboxed play or user-mode plugins).
- The single-file `tryGetService` wrapper attempts `game:GetService()` first, then `game:FindFirstChild()` as fallback.
- No features are gated to service availability; the plugin degrades gracefully.

**What the Internal Build Must NOT Do (Red Lines):**
1. Use `game:GetService()` for internal-only services (e.g., internal stats collectors, closed-source plugin contexts).
2. Implement UI or behavior specific to internal universe detection (e.g., "in a Roblox-internal universe, show extra stats").
3. Add telemetry events that are not documented and opted-into in the community build.

---

## Telemetry and Privacy Posture (As of 2026-07-01)

### What is Collected Today

The telemetry system in Flipbook is implemented in `workspace/flipbook-core/src/Telemetry/`. Here is what is actually collected:

**Event Types (from `Telemetry/types.luau`):**
- `AppOpened` — plugin opened (no properties)
- `AppClosed` — plugin closed (no properties)
- `StoryOpened` — user opened a story (no properties)
- `StoryClosed` — user closed a story (no properties)
- `PageChanged` — user navigated to a page (property: `page` string)
- `NodePinned` — user pinned a storybook node (no properties)
- `NodeUnpinned` — user unpinned a storybook node (no properties)
- `TelemetryOptedIn` — user opted in (no properties)
- `TelemetryOptedOut` — user opted out (no properties)
- `FeedbackDialogOpened` — user opened feedback dialog (no properties)
- `FeedbackSubmitted` — user submitted feedback (no properties)
- `FeedbackDiscarded` — user discarded feedback (no properties)

**Per-Event Envelope (from `fireEventAsync.luau`):**
Each event is sent as JSON with:
```
{
  eventName: string,           -- The event type above
  properties: {...},           -- Event-specific properties (page name, etc.)
  anonymizedUserId: sha256(string), -- Hashed local UserId (see below)
  buildVersion: string,        -- E.g., "2.5.0"
  buildChannel: string,        -- "dev", "beta", or "prod"
  buildHash: string,           -- Short git commit hash
}
```

**Anonymous User ID Scheme (from `Telemetry/getAnonymizedUserId.luau`):**
- Gets the local Roblox UserId (via `getLocalUserId`, which reads from `game:GetService("RunService"):GetUserId()`)
- Hashes it with SHA256
- Sends the hash, never the raw UserId
- This allows grouping events per user without Flipbook knowing who they are
- If a user clears plugin settings, the ID is regenerated on next use

**Where it Goes:**
- Endpoint: `{_G.BASE_URL}/telemetry` (default: `https://apis.flipbooklabs.com/telemetry`)
- Method: POST
- Transport: HTTPS + JSON

**Opt-Out Mechanism (from `TelemetryOptOutDialog.luau`):**
- On first open, Flipbook shows a dialog asking to opt in to "anonymized usage data"
- Dialog is shown only once (tracked via `LocalStorageStore.wasUserPromptedForTelemetry`)
- User can check "Help improve Flipbook by sending anonymous usage data"
- If unchecked, `UserSettingsStore.collectAnonymousUsageData` is set to false
- Once set to false, `fireEventAsync` returns early and sends nothing
- User can re-enable in settings (UI currently in plugin settings, exact location TBD)

### Open Obligations (Binding Constraints)

**These must be satisfied before any telemetry expansion or public promotion of the telemetry feature:**

1. **Privacy Policy Does Not Exist**
   - There is no published privacy policy for Flipbook.
   - No documentation of what data is collected, how long it is retained, or who has access to it.
   - **Obligation:** Write and publish a privacy policy before expanding telemetry. Any PR adding new telemetry events is blocked until the policy exists.

2. **No Public Disclosure of Collection Strategy**
   - No public documentation of *which events are collected* or *why*.
   - This matters for user trust. A user opting in should know exactly what "anonymized usage data" means.
   - **Obligation:** Write user-facing documentation (e.g., in Docusaurus docs/privacy) listing the 12 events above, explaining what each measures, and confirming hashing and opt-out.

3. **Backend Telemetry Ingestion Incomplete**
   - The `https://apis.flipbooklabs.com/telemetry` endpoint exists and receives events (verified in code).
   - Backend storage, retention, and analysis logic are not documented in this repo (they live in `flipbook-backend`, a separate Rust service).
   - **Obligation:** Backend telemetry service must be production-hardened, and a data retention + processing policy must be documented before marketing the feature.

### How Telemetry Expansion is Gated (Binding Requirement)

**No PR that adds telemetry may land until:**

1. **Privacy policy is published** at an accessible public URL (e.g., GitHub Pages or flipbook-labs.github.io)
2. **Event list is documented** in public-facing docs with the exact payloads users can inspect via developer tools
3. **Opt-out path is documented** with screenshots showing exactly where in the UI to disable telemetry
4. **Code review confirms no PII escapes:** New events must not collect UserIds, usernames, file paths, or universe/place IDs (only page names, etc.)

---

## Ecosystem Positioning

### Flipbook vs Web Storybook (Storybook.js)

**What Parity Means:**

Flipbook is *not* trying to be a feature-complete Roblox port of Storybook. Parity is:

- **Story format:** Users write stories in a compatible shape — a module returning a table with a `story` function and optional `controls` field. Web Storybook's [Component Story Format](https://storybook.js.org/docs/react/api/csf) (CSF) inspired this.
- **Controls/ArgTypes:** Flipbook supports a controls schema (see `flipbook-story-controls-campaign` for the revamp). This mirrors Storybook's ArgTypes but adapted to Roblox data types.
- **Multiple renderers:** Flipbook supports React, Roact, Fusion, and functional renderers. Storybook supports React, Vue, Angular, Web Components, etc. Both allow plugging in UI libraries.
- **Story discovery:** Both scan a codebase for story files and surface them in a tree UI.

**What is Genuinely Novel Here (In-Experience Embedding):**

- **Flipbook can embed into a running Roblox experience**, not just as a Studio plugin. This allows designers and engineers to collaborate on UI *inside the game*, opening the experience in Studio and seeing Flipbook alongside it.
- Web Storybook runs in a separate browser tab. Roblox games can't open web pages. Flipbook bridged this gap (commit `78d71e8f`, PR #582) by cloning Flipbook into the DataModel and running it client-side, with server-side HTTP proxy for telemetry/feedback.
- This in-experience embedding is shipped in main and available to community users. It's not an internal-only feature.

**Known Gaps vs Web Storybook (Unverified Claims Labeled):**

| Feature | Flipbook | Storybook | Notes |
|---------|----------|-----------|-------|
| Story Format | Supported (Luau table) | Supported (CSF) | Flipbook format is simpler; CSF is more JS-idiomatic |
| Controls | In progress (Q1 2026) | Rich (addons, custom types) | Flipbook targeting UI Labs parity, not full Storybook parity |
| Visual Regression | Not implemented | Chromatic integration | Stalled branch `automated-story-snapshots` |
| Addons | None | Rich ecosystem | Out of scope; Flipbook is monolithic |
| Docs in Plugin | Not implemented | Docs addon | Stalled branch `docs-in-studio` |
| Multiple Renderers | React, Roact, Fusion, functional | React, Vue, Angular, Web Components, etc. | Flipbook covers main Roblox libraries |
| In-experience Preview | Unique to Flipbook | Not applicable | Novel differentiator |

---

### Flipbook vs UI Labs (Roblox Plugin)

UI Labs is a competing Roblox storybook plugin. A gap analysis lives in the Obsidian vault on the unmerged `flipbook-docs` branch (browse with `git ls-tree -r --name-only flipbook-docs -- docs/obsidian-vault`, read files via `git show flipbook-docs:<path>`). Here is what can be verified from the Flipbook repo and what remains unverified:

**Verified from Flipbook Codebase:**

1. **In-experience embedding:** Flipbook uniquely supports embedding into a running experience (commit `78d71e8f`, PR #582). UI Labs does not (to the author's knowledge, but this claim is not verified in this repo).
2. **Controls revamp in progress:** Flipbook is actively revamping controls (see `flipbook-story-controls-campaign` skill, Q1 2026, in-progress). The target is UI Labs parity for controls types.
3. **Multiple renderers:** Flipbook supports React, Roact, Fusion, and functional renderers. UI Labs supports UI Libraries (React-style). Both cover the main Roblox UI libraries.
4. **Story hot-reload:** Flipbook uses ModuleLoader to bypass the require cache. Stories hot-reload on save. UI Labs approach to this is not documented in this repo.

**Unverified (Cannot Claim Without External Research):**

- "UI Labs has N times more users than Flipbook" — repo does not contain usage metrics; this is unverified without telemetry.
- "UI Labs controls are more powerful" — no detailed feature matrix in this repo; the vault has a matrix but it's aspirational (what Flipbook *targets*), not verified.
- "UI Labs has a larger community" — repo does not document community size; unverified.
- "UI Labs maintainers are more responsive on Discord" — documented in vault (`product/2025-product-spec/index.md`) as user sentiment, but not verified by this repo.

**Labeling Rule:**
Any claim about UI Labs in documentation or release notes must be labeled **(unverified)** unless the repo itself provides evidence (e.g., a working code sample, a test, a deployed feature). Competitive claims are marketing risk; verify before asserting.

---

## Claim Discipline: What Must Be Proven Before Shipping

### Evidence Bar

Before labeling a feature as shipped, production-ready, or documented in release notes, it must pass this checklist:

**For Features:**
1. ✅ **Code exists on main branch** — not on a draft branch, not WIP, not stalled
2. ✅ **Tests pass** (if applicable) — `lute run test` succeeds; or no test exists because the feature is UI-only and manually verified
3. ✅ **Builds without error** — `lute run build plugin --channel prod` succeeds
4. ✅ **Working code sample or demo** — either a `.story.luau` file showing the feature in action (in `workspace/code-samples/` or sibling Storybook) or documented reproduction steps
5. ✅ **Deployed example** (if relevant) — for embedding or in-experience features, a deployed storybook place demonstrating the feature (via `deploy-storybook`)

**For Documentation/Release Notes:**
1. ✅ **Feature is on main** — no "coming soon" claims without a PR merged
2. ✅ **Docs are written and accurate** — docs reference the feature correctly; they don't promise behavior that doesn't exist
3. ✅ **No conflicting open bugs** — if a known issue is tracked, the docs must acknowledge it (e.g., "Known limitation: X")

**For Claims About Compatibility/Parity:**
1. ✅ **Test or example proves it** — e.g., "Flipbook supports UI Labs controls" requires a story using UI Labs control types that renders correctly
2. ✅ **Verified against the thing you're claiming parity with** — not just "we implemented it locally"; actually test against a real UI Labs story if claiming interop

### Examples

**Example 1: In-Experience Embedding (Shipped, Meets Bar)**
- Code: `EmbeddedClientStarterScript.client.luau`, `EmbeddedServerStarterScript.server.luau` in `src/`
- PR: `#582`, merged to main
- Tests: Integration tested via `deploy-storybook` CI job (`storybook.yml`); places deployed to `ROBLOX_STORYBOOK_PLACE_ID = 139676401890813`
- Example: Any storybook deployed via `deploy-storybook` is a live example
- Release notes can claim: "Flipbook can now embed into experiences"

**Example 2: Story Controls Revamp (In Progress, NOT Shipping Yet)**
- Code: Exists on branch `uilabs-controls-support`, merged to main in parts (e.g., PR #597 "Extract InstancePicker from ObjectControl")
- Status: Q1 2026, *in progress*. Not all control types are shipped.
- What can be claimed: "New control types (Color, Date, Slider, etc.) are coming in the next release" — must say *coming*, not shipped
- What cannot be claimed: "Flipbook has full UI Labs parity" — incomplete; test shows gaps remain

**Example 3: Automated Story Snapshots (Stalled, NOT Shipping)**
- Code: Branch `automated-story-snapshots` exists, not merged to main
- Status: Stalled; not being actively developed
- What can be claimed: Nowhere in docs or release notes — this is a research branch
- Exception: In a research/frontier skill, you can document it as "exploratory" with caveats

### Enforcement (For Reviewers)

Before approving a PR that updates docs, README, or release notes:

1. **Check the feature exists on main.** If the PR is for a new feature in the same PR, that's okay (feature code + docs together). If docs reference something on a branch, the branch must be merged to main as a prerequisite.
2. **Cross-check against this skill.** Does the claim pass the bar above? If not, request it be softened ("coming soon", "in progress", "experimental").
3. **For competitive claims** (vs UI Labs, vs web Storybook), require either (a) a test/code sample in the repo proving it, or (b) explicit **(unverified)** label if it's aspirational.

---

## House Rules: Writing About Flipbook

When authoring docs, blog posts, or release notes:

1. **Label unreleased work:** If a feature is on a branch or incomplete, call it "experimental" or "in progress", not "released" or "shipped".
2. **Disclose AI assistance:** Every PR is marked with 🤖 and a link to Claude Code.
3. **No oversell:** Avoid "Flipbook is the best storybook plugin" or "faster than X" without numbers. Stick to factual features and design principles.
4. **Community-first framing:** When describing Flipbook, emphasize that it's open-source, community-driven, and built for all Roblox developers — not just Roblox-internal use.
5. **Cite the repo:** If claiming a fact about Flipbook (e.g., "supports React, Roact, Fusion"), cite the code or a test that proves it.

---

## Privacy Roadmap (Open Items)

**Immediate (Required Before Marketing Telemetry):**
- [ ] Write privacy policy document (target audience: Flipbook users; include data retention, opt-out, third-party disclosure)
- [ ] Publish at flipbook-labs.github.io/privacy or similar
- [ ] Add telemetry opt-out instructions to plugin settings UI
- [ ] Document telemetry events in user-facing docs (link in README?)
- [ ] Audit backend service (flipbook-backend repo) for data handling practices

**Medium-term (Nice-to-Have):**
- [ ] Telemetry dashboard (show top stories, pages, etc. — anonymized aggregates only)
- [ ] User survey on data collection concerns
- [ ] Export telemetry data (let users see what was sent about their account)

---

## Provenance and Maintenance (Re-Verification Commands)

To verify the facts in this skill remain current:

**Telemetry Event Types:**
```bash
cat workspace/flipbook-core/src/Telemetry/types.luau | grep "eventName"
```

**Telemetry Base URL:**
```bash
grep "BASE_URL" .env.template
```

**Embedding Feature Status:**
```bash
git log --oneline main | grep -i "embed" | head -5
ls -la src/EmbeddedClientStarterScript.client.luau
```

**Rotriever Build Target:**
```bash
git log --oneline main | grep -i "rotriever" | head -5
lute run build --target rotriever --channel prod  # Should build without error
```

**Community-First Doctrine (Binding):**
Check `.claude/skills/flipbook-community-and-positioning/SKILL.md` (this file). Date-stamped 2026-07-01. Review any changes to internal-mirroring workflow against the rules in "The Community-First Doctrine" section.

---

## When NOT to Use This Skill

- For **architecture decisions** about *how* Flipbook works: use `flipbook-architecture-contract`
- For **release workflows** (GitHub Release, Creator Store, Rotriever publish): use `flipbook-release-and-operations`
- For **testing and validation** (what counts as proof): use `flipbook-validation-and-qa`
- For **change control and gating discipline**: use `flipbook-change-control`
- For **documentation house style** (prose rules, markdown conventions): use `flipbook-docs-and-writing`

---

**Last Updated:** 2026-07-01  
**Maintainer Doctrine:** Binding as stated  
**Status:** Live (enforces community-first principle, gates telemetry expansion, documents positioning)
