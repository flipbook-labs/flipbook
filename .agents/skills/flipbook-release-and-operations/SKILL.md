---
name: flipbook-release-and-operations
description: Release runbooks, deployment orchestration, artifact conventions, CI/CD environments, and operational history; for releasing versions and managing production deployments
type: process
---

# Flipbook Release and Operations

**When to use this skill:** running release commands, understanding the deployment pipeline, creating GitHub Releases, publishing to Creator Store, nightly builds, smoketest deployments, storybook preview orchestration, navigating artifact conventions and CI environments, or investigating operational failures.

**When NOT to use this skill:** for local development builds (→ flipbook-build-and-toolchain); for debugging Luau code or tests (→ flipbook-debugging-playbook); for architecture decisions (→ flipbook-architecture-contract); for telemetry/user-facing settings (→ flipbook-config-and-flags).

---

## Release Runbook (End-to-End)

### 1. Version Bump via `lute run bump-version`

Bump the version in all manifest files (wally.toml, loom.config.luau, rotriever.toml). This is the first step and creates a draft PR.

```sh
lute run bump-version <major|minor|patch>
```

**Implementation:** `.lute/bump-version.luau` reads current version from wally.toml (source of truth), calculates next semver, and updates all three manifests in place. Examples:
- `lute run bump-version patch` → 2.5.0 → 2.5.1
- `lute run bump-version minor` → 2.5.0 → 2.6.0
- `lute run bump-version major` → 2.5.0 → 3.0.0

**Next steps:**

1. Create and push a feature branch:
```bash
git checkout -b release/2.6.0
git push -u origin release/2.6.0
```

2. Open a draft PR using the repo template:
```bash
gh pr create --draft --title "Bump to 2.6.0" --template .github/pull_request_template.md
```

3. Fill in the PR body with release notes. Ensure CI passes, then merge to main.

**Key constraint (maintainer doctrine; the `flipbook-change-control` skill is the in-repo home for it):** Never push git tags directly. Releases go through `bump-version` PR → merge → manual GitHub Release creation. The rationale is the deployment-orchestration history in `flipbook-failure-archaeology` (incidents #535, #596): direct tag pushes bypass the changelog/version gating and can fire deploy workflows unexpectedly.

### 2. Merge Bump PR to Main

Once the bump PR is approved and CI passes, merge it to main. This is a regular code review checkpoint — the bump PR should have no other changes.

```sh
# After merge, you're ready for step 3.
```

### 3. Create GitHub Release Matching the Tag

**Manual step:** Navigate to [github.com/flipbook-labs/flipbook/releases](https://github.com/flipbook-labs/flipbook/releases) and click "Create a new release".

- **Tag version:** Create a new tag matching the bumped version exactly (e.g., `v2.6.0` if you bumped to 2.6.0; the `v` prefix is required).
- **Target:** Confirm it's set to `main`.
- **Title:** Use the version number (e.g., `2.6.0`).
- **Description:** Add release notes summarizing the changes in human-readable form (e.g., "Added support for X, fixed Y bug, improved Z performance"). Reference related PRs and issues as needed.
- **Publish:** Click "Publish release" (not "Save as draft").

**Why manual?** The maintainer uses GitHub's UI for final review; automation handles the rest.

### 4. Release CI Publishes (Automatic)

Once the release is published, GitHub Actions triggers:

#### `release.yml → publish-github-release` job
- **Condition:** Only runs if `github.event.release` exists (i.e., release was published, not a push to main).
- **What it does:** Builds prod Flipbook.rbxm, attaches it to the release's Assets.
- **Artifact:** `Flipbook.rbxm` (renamed to `Flipbook-<sha>.rbxm` in CI, then downloaded and renamed back for the release).

#### `release.yml → publish-plugin` job
- **Condition:** Only runs on release events.
- **Environment gate:** `roblox-creator-store` (requires approval secret `ROBLOX_API_KEY`).
- **What it does:** Calls `lune run publish-plugin --channel prod --apiKey <key>`, which invokes rbxasset to publish to the Creator Store asset `8517129161` (Flipbook prod).
- **Concurrency:** `production` group (one release at a time; blocks nightly builds).

#### `release.yml → publish-nightly-plugin` job (automatic per-push to main)
- **Condition:** Runs only on pushes to main (not releases).
- **Environment gate:** `roblox-creator-store-dev` (separate secret, separate Creator Store asset).
- **What it does:** Calls `lune run publish-plugin --channel beta --apiKey <key>`, publishing to asset `88523969718241` (Flipbook dev/nightly).
- **Concurrency:** `nightly` group (independent of release, but serialized with itself).

**Asset mapping (in `.lune/publish-plugin.luau`)**
```
channel dev  → asset dev
channel beta → asset dev  (reuses dev asset; this is intentional)
channel prod → asset prod
```
When `--smoketest` flag is passed (strict.yml tests job), it publishes to asset `smoketest` instead.

---

## Build Pipeline & Artifact Conventions

### Artifact Locations

Build outputs land in `build/` with the following structure:

```
build/
├── build-cache.json          # Incremental build state (do not edit)
├── <channel>/
│   ├── Flipbook.rbxm         # Default output location
│   ├── flipbook-core-rotriever/
│   │   ├── flipbook-core/
│   │   │   └── [package source]
│   │   └── [dependencies bundled as rbxms to mitigate Windows path-length limits]
│   └── flipbook-storybook.rbxl # Storybook place for previewing
├── flipbook-plugin-dev        # Artifact upload name (CI)
├── flipbook-plugin-prod
└── flipbook-plugin-beta
```

**Never edit `build/` or `dist/` directly.** They are generated artifacts. To rebuild, run `lute run build` with appropriate flags.

### Rbxm Naming Convention

In CI, rbxm files are renamed to include a 7-character commit SHA for traceability:
```
Flipbook-<sha>.rbxm  # e.g., Flipbook-a1b2c3d.rbxm (in CI)
Flipbook.rbxm        # default name locally and in release assets
```

The SHA helps trace which commit produced a given binary when debugging.

### Build Provenance Attestation

CI jobs use `actions/attest-build-provenance@v3` to create SLSA provenance attestations for both:
- Plugin .rbxm files (build-plugin matrix)
- Flipbook-core rotriever packages (build-package matrix)

These attestations prove the artifacts were built in CI and can be verified by Rotriever consumers.

### Channels: Dev, Beta, Prod

Each build channel has different behavior:

| Channel | Contents | Use Case | Default |
|---------|----------|----------|---------|
| dev | Includes test files, storybooks, stories | Flipbook development; `--watch` for incremental | `plugin` subcommand default |
| beta | Prod build shipped to nightly asset | Nightly CI builds (maps to dev asset) | `release.yml` nightly job |
| prod | Strips code-samples, example, template, test-runner, *.spec.luau, *.story.luau | Public releases | `release.yml` release job |

---

## Nightly Builds

**Trigger:** Every push to main (via release.yml).

**What happens:**
1. `publish-nightly-plugin` job runs (independent of release events).
2. Builds `--channel beta` (which publishes to dev asset).
3. Uses concurrency group `nightly` (serialized; one at a time).
4. Updates Creator Store asset `88523969718241` (Flipbook dev / nightly channel).

**Visibility:** Visible in the Creator Store under "Developer" section. Users can opt into nightly builds for testing latest changes.

**Historical issue (archaeology):** PR #596 "Fix the dev build failing to deploy" — channel routing was broken after "beta" was introduced. Solution: added `beta → dev` mapping in `publish-plugin.luau` so channel names don't leak into asset selection.

---

## Smoketest Deployments

**Purpose:** Validate that the plugin publishes and loads without crashing (end-to-end test).

**Trigger:** `strict.yml` tests job (pull_request_target + push to main, behind environment gates).

**What it does:**
```sh
lune run publish-plugin --smoketest --channel prod --apiKey <key>
```

**Behavior:** Builds prod channel, publishes to asset `smoketest` (defined in rbxasset.toml), validates the publish succeeded. Does not test actual loading in Studio (offline validation only).

**Historical lessons:**
- PR #562 "Fix smoketest deployments cancelling each other" — early smoketest logic in `release.yml` had concurrency bugs when combined with approval gates. Solution: moved smoketest to `strict.yml` tests job (its proper role as an end-to-end test).
- PR #561 "Fix dev deployments triggering for all PRs" — dev deployments leaked into all PRs. Solution: flipped logic to deploy only on non-PR events (push to main).

---

## Storybook Preview Deployments

**Purpose:** Deploy each PR's storybook to a Roblox place for visual preview; main builds get a fresh Flipbook runtime.

**Trigger:** `storybook.yml` (push to main + pull_request).

**Implementation:** Uses `flipbook-labs/deploy-storybook@v0.4.0` GitHub Action (checkout at `../deploy-storybook`).

### Main Branch Storybook Deploy

On `main` only:
1. Build prod Flipbook.rbxm (`lute run build plugin --channel prod --skip-reload --clean`).
2. Deploy to place ID `139676401890813` (from `project.luau`, stored in `ROBLOX_STORYBOOK_PLACE_ID`).
3. Pass local Flipbook.rbxm as runtime (`flipbook-rbxm: build/prod/Flipbook.rbxm`).

**Why local runtime?** Catches embedding issues before release (Flipbook loaded as service inside the storybook place). A fresh build on each main push ensures preview reflects latest code.

### PR Storybook Deploy

On each PR:
1. Build storybook place only (no fresh Flipbook build).
2. Deploy to per-PR place named `Flipbook Preview <PR number>`.
3. Let deploy-storybook fetch latest Flipbook release from GitHub (don't pass `flipbook-rbxm`).

**Why release instead of local?** PR UI changes should not be hidden under a custom runtime; the latest public Flipbook shows the baseline.

### Universe & Place IDs

From `project.luau`:
- Universe ID: `10262009842` (experience/game)
- Place ID: `139676401890813` (main storybook place)

These are hardcoded in the action inputs and also resolved dynamically in storybook.yml via grep on project.luau.

### Deploy-Storybook Action Anatomy

**Tool:** flipbook-labs/flipbook-cli (installed via Rokit).

**Inputs:**
- `api-key`: Open Cloud API key (stored as `ROBLOX_STORYBOOK_PREVIEW_API_KEY` secret in environment `storybook-preview`).
- `universe-id`: Experience ID.
- `place-name`: Display name for the place (e.g., "Flipbook Stories" for main, "Flipbook Preview <N>" for PRs).
- `place-file`: Built .rbxl (e.g., `build/flipbook-storybook.rbxl`).
- `flipbook-rbxm`: (Optional) Local Flipbook runtime; if omitted, action downloads latest release.
- `cli-version`: Version of flipbook-cli to use (default 0.6.0).
- `comment`: Post preview link comment on PR (default true).

**Outputs:** Updates or creates the place via Open Cloud, posts comment with preview link if requested.

---

## CI/CD Workflow Matrix

### CI Job Schedule

**File:** `.github/workflows/ci.yml`

Runs on every PR and push to main:

| Job | Channels | Targets | Notes |
|-----|----------|---------|-------|
| build-plugin | dev, beta, prod | plugin (default) | 3 matrix runs; attests provenance |
| build-package | flipbook-core | rotriever | 3 channel runs; zips for Rotriever consumers |
| analyze | — | — | Runs lute lint, lune setup, lute setup, lute analyze; single run |

### Strict Job Schedule

**File:** `.github/workflows/strict.yml`

Runs on pull_request_target and push to main (secrets gated):

| Job | Condition | Environment | Notes |
|-----|-----------|-------------|-------|
| tests | all PRs / main | `luau-execution-gated` (fork) or `luau-execution` (internal) | Runs `lute run test`, then smoketest publish |

Fork PRs require explicit approval before running (environment gate); internal PRs run automatically.

### Release Job Schedule

**File:** `.github/workflows/release.yml`

Triggered by GitHub release events AND push to main:

| Job | Trigger | Environment | Concurrency |
|-----|---------|-------------|-------------|
| publish-github-release | release event only | — | Attaches .rbxm to release assets |
| publish-plugin | release event only | roblox-creator-store | production (blocks nightly) |
| publish-nightly-plugin | push to main only | roblox-creator-store-dev | nightly (serialized) |

### Storybook Job Schedule

**File:** `.github/workflows/storybook.yml`

Runs on push to main and every PR:

| Job | Trigger | Environment | Concurrency |
|-----|---------|-------------|-------------|
| deploy | main + PR | storybook-preview | storybook-preview-<PR#> (cancel in-progress on PR) |

Concurrency ensures one deployment per PR at a time; main pushes run independently.

---

## Environments & Secrets Map

**Key constraint:** Never hardcode secrets in workflows. Always use `environment:` to gate and require approval.

### GitHub Environments (Gating Points)

| Environment | Used By | Secret | Purpose |
|-------------|---------|--------|---------|
| luau-execution | strict.yml tests | ROBLOX_API_KEY | Internal PR test runs (auto-approve) |
| luau-execution-gated | strict.yml tests | ROBLOX_API_KEY | Fork PR test runs (require approval) |
| roblox-creator-store | release.yml publish-plugin | ROBLOX_API_KEY | Prod asset publish (8517129161); requires approval |
| roblox-creator-store-dev | release.yml publish-nightly | ROBLOX_API_KEY | Dev/nightly asset publish (88523969718241); requires approval |
| storybook-preview | storybook.yml deploy | ROBLOX_STORYBOOK_PREVIEW_API_KEY | Storybook place deployment; separate API key and environment |

**Why separate keys?** Storybook preview is lower-risk (internal-only) than Creator Store publish; separate keys allow fine-grained permission scoping at the Roblox API level.

### Secrets (in GitHub Actions)

| Secret | Scope | Value | Source |
|--------|-------|-------|--------|
| ROBLOX_API_KEY | org (flipbook-labs) | Open Cloud API key | Manually generated at https://create.roblox.com/dashboard/credentials |
| WALLY_REGISTRY_TOKEN | org (flipbook-labs) | GitHub PAT for Wally registry publish | From `wally login` → `~/.wally/auth.toml` |
| ROBLOX_STORYBOOK_PREVIEW_API_KEY | org | Open Cloud API key for storybook universe | Same process as ROBLOX_API_KEY |

### Variables (in GitHub Actions)

| Variable | Scope | Value | Notes |
|----------|-------|-------|-------|
| ROBLOX_STORYBOOK_UNIVERSE_ID | org | 10262009842 | From project.luau; used by storybook.yml |

---

## Creator Store Asset Configuration

**File:** `rbxasset.toml`

Defines metadata and publish targets for each asset (prod, dev, smoketest):

```toml
[assets.prod]
name = "Flipbook"
description = "..."
model = "Flipbook.rbxm"
environment = "prod"
type = "Plugin"

[assets.dev]
name = "Flipbook (Dev)"
description = "..."
model = "Flipbook.rbxm"
environment = "prod"
type = "Plugin"

[assets.smoketest]
name = "Flipbook"
description = "..."
model = "Flipbook.rbxm"
environment = "prod"
type = "Plugin"

[environments.prod]
creatorId = 1343930
creatorType = "User"
universeId = 6599100156
placeId = 84837374448022
```

**Asset IDs (from shared brief & create.roblox.com):**
- Prod: 8517129161
- Dev (nightly): 88523969718241
- Smoketest: (internal, not published to store)

The script `.lune/publish-plugin.luau` reads rbxasset.toml and publishes to the corresponding asset based on channel mapping (dev → dev asset, beta → dev asset, prod → prod asset).

---

## Wally Registry Token Rotation

**When needed:** If `WALLY_REGISTRY_TOKEN` expires or is compromised, update it.

**Steps:**
1. Run `wally login` locally; authenticate via GitHub device flow.
2. Copy the generated token from `~/.wally/auth.toml`:
   ```toml
   [tokens]
   "https://api.wally.run/" = "gho_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
   ```
3. Update the secret in GitHub org settings: [github.com/organizations/flipbook-labs/settings/secrets/actions](https://github.com/organizations/flipbook-labs/settings/secrets/actions).
4. Name: `WALLY_REGISTRY_TOKEN`.

**Why org-level?** All flipbook-labs repos publish to the same Wally scope; the token must be shareable.

---

## Operational Failure History

### Windows Path-Length Saga (PRs #518→#523→#530)

**Symptom:** CI running on Windows hit MAX_PATH (260 chars) failures. Note: OS-level long-path settings were already enabled — individual tools in the pipeline enforce their own hardcoded MAX_PATH, so the OS setting does not save you.

**Root cause:** Huge unbundled `Packages/`/`RobloxPackages/` hierarchies (Wally + Loom), plus FlipbookCore being packaged as a Rotriever package — which layers another Wally-like packaging structure on top — massively inflated total path depth.

**Solution (PR #523):** Bundle `Packages/` and `RobloxPackages/` dirs into .rbxms before packaging for Rotriever (the `packToRbxm(packagesPath)` call in `.lute/lib/build-system/compileAsync.luau`, grep `packToRbxm`). Reduces path depth.

**Cleanup (PR #530):** Removed defensive path-length checker; declared victory.

**Residue:** Comment in compileAsync.luau: "Bundle up the gigantic dependency bundles into rbxms to alleviate path length limit issues."

**Lesson:** Windows path length is a real constraint even with OS long-path support enabled, because tools hardcode their own limits; solutions that compact artifact structure (bundling) are better than detection-only approaches. The bundling was a last-resort bet that has held up well so far — treat it as load-bearing.

### Build-Hash Version Sensitivity (PRs #426, #444)

**Problem 1 (PR #426):** After Lute migration, BUILD_HASH global stopped getting set; root cause was Lute's `stdio` parameter default behavior.

**Fix 1:** Corrected Lute call to match actual defaults; hash extraction resumed.

**Problem 2 (PR #444):** Same symptom recurred 6 weeks later; Lute version-bumped and stdio behavior changed again.

**Fix 2:** Explicitly set stdio to `default` + added CI assertion to catch future regressions.

**Lesson:** Lute is young software; minor version bumps can break abstractions. Assertions in CI catch these earlier.

### Deployment Orchestration (PRs #559–563, #561–562, #596)

**Fork workflow support (PR #559):** Switched to `pull_request_target` to support fork contributions, but opened broader permissions surface.

**Narrow scope (PR #563):** Reduced `pull_request_target` to specific jobs; environment gating enforces approval for forks.

**Dev deployment leak (PR #561):** Dev build deployed from every PR; fix: condition to main only.

**Smoketest concurrency (PR #562):** Parallel smoketest deployments interfered; moved from release.yml to strict.yml tests job (proper role).

**Beta channel routing (PR #596):** "beta" channel introduced but asset mapping incomplete; fix: `beta → dev` routing in publish-plugin.luau.

**Lesson:** Deployment concurrency and environment gating are fragile; each new channel or event trigger requires careful condition review.

### Storyteller Mutation Bug (storyteller/issues/100)

**Symptom:** "Attempt to modify a readonly table" crash when previewing stories after Signals→Charm migration.

**Root cause:** Storyteller mutates state inside Charm.flags.frozen = true; architectural mismatch.

**Workaround (in PluginStarterScript.plugin.luau):** Set `Charm.flags.frozen = false` to disable immutability guards.

**Status:** Unresolved upstream; workaround accepted as trade-off ("everything works in practice").

**Lesson:** State library migrations can surface subtle mutations in downstream code; workarounds should be time-limited with upstream issues tracked.

---

## Changewrite Adoption (Candidate / Open)

**Status:** Branch `adopt-changewrite` exists (1 commit, 2026-06-28) but NOT merged to main.

**What it is:** Changewrite is a GitHub Action + CLI for automated release cycle management (replaces manual bump-version + changelog editing with PR-driven workflow).

**Current state:** Flipbook still uses manual `lute run bump-version` + GitHub Release creation. Changewrite is adopted by other flipbook-labs repos (flipbook-cli, deploy-storybook) but not yet flipbook.

**Adoption plan:** Merge `adopt-changewrite` to main (pending review); then release workflow becomes:
1. Contributors add `.changes/*.md` files with semver declarations alongside code changes.
2. Changewrite Action collects entries, bumps version, opens draft PR.
3. Merge PR to create release (no manual GitHub Release step).

**Cross-ref:** See flipbook-docs branch `engineering/changewrite.md` for full specification.

**Why candidate?** Not yet verified on main; open question whether to adopt before or after maintenance transition.

---

## Verification Commands

To keep this skill current and aligned with code changes:

- Verify release.yml event triggers: `grep -A 5 "on:" .github/workflows/release.yml`
- Verify asset IDs in rbxasset.toml: `cat rbxasset.toml | grep -E "name|model|universe"`
- Verify project.luau storybook IDs: `grep ROBLOX_STORYBOOK project.luau`
- Verify bump-version manifest paths: `grep MANIFEST_PATHS .lute/bump-version.luau`
- Verify channel-to-asset mapping: `grep -A 5 "ASSET_NAMES_BY_CHANNEL" .lune/publish-plugin.luau`
- Verify deploy-storybook version pinned in storybook.yml: `grep "deploy-storybook@" .github/workflows/storybook.yml`
- Verify Wally token docs in creating-releases.md: `cat docs/docs/contributing/creating-releases.md`

---

## Provenance and Maintenance

**Last verified:** 2026-07-01 (main branch, commit 78d71e8f "Embed Flipbook in the DataModel")

**Verification scope:**
- All six workflow files (.github/workflows/*.yml) read and command syntax verified
- .lute/bump-version.luau manifest list verified (3 files: wally.toml, loom.config.luau, rotriever.toml)
- rbxasset.toml asset names and environment config read
- project.luau universe/place IDs verified (10262009842, 139676401890813)
- docs/docs/contributing/creating-releases.md release procedure confirmed
- deploy-storybook action.yml inputs and defaults confirmed (v0.4.0 pinned in storybook.yml)
- .lune/publish-plugin.luau channel mapping verified (dev/beta→dev, prod→prod, smoketest→smoketest)

**Known drifts to watch:**
- Changewrite adoption (adopt-changewrite branch status; not yet on main)
- Creator Store asset IDs (8517129161 prod, 88523969718241 dev) — hardcoded in CI, not in code
- Environment secret names (ROBLOX_API_KEY vs ROBLOX_STORYBOOK_PREVIEW_API_KEY) — org settings not read-only, may change without code notice
- Rokit version pinned in workflows (v1.2.0 typical) — minor bumps in action inputs

---

## Crossref to Sibling Skills

- **flipbook-build-and-toolchain:** Darklua pipeline, `lute run build` flags, channel/target mechanics, Rojo, Lute/Loom.
- **flipbook-diagnostics-and-tooling:** Measuring instead of eyeballing; logging, test filtering, sourcemap inspection.
- **flipbook-validation-and-qa:** CI job anatomy, lint/analyze/test evidence bar, acceptance discipline.
- **flipbook-config-and-flags:** .env vars, injected globals, channels, prod pruning, user settings.
- **flipbook-failure-archaeology:** Detailed incident investigations with git history; cross-ref this skill's "Operational Failure History" to archaeology for deep dives.
- **flipbook-change-control:** Git/PR/release doctrine; never-push-tags and never-push-main constraints underlying all release procedures here.
- **AGENTS.md** (repo root): Project overview, layout, tech stack, style; this skill assumes that foundation.
