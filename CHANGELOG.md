# Changelog

All notable changes to this project will be documented in this file.


## v2.6.0

### Changes

- Use the theme-aware BuilderIcons GitHub logo in the About view instead of a bundled image.

### Dependencies

- Update Flipbook's build and development dependencies, including FlipbookBatteries, Darklua, Luau LSP, Rojo, Selene, StyLua, and wally-package-types.

- Upgrade the documentation site to Docusaurus 3.10.1 and its current Markdown and Node.js configuration.

- Upgrade to Lute 1.0.0 and FlipbookBatteries 0.9.0, including the current Lute API and Loom package layout.

- Upgrade Lute to the latest nightly while keeping dependency installation reliable when the shared package store is incomplete.

- Upgrade RobloxPackages to 0.716.0.7160873.

- Upgrade RobloxPackages to 0.733.0.7330989.

- Upgrade RobloxPackages to 0.735.0.7351131.

- Upgrade RobloxPackages to 0.736.0.7361342.

- Upgrade Selene to 0.31.1 and adopt its require-by-string and UDim2 linting support.

- Replace the custom dotenv helper with the maintained dotenv package from the Lute ecosystem.

### Features

- Add development, beta, and embedded environment badges so special Flipbook builds are identifiable at a glance.

- Add a reusable Flipbook agent runtime for discovering stories, opening them, embedding Flipbook, and controlling mounted stories.

- Add an Object control that lets stories receive Instances selected from the DataModel.

- Add an embedded Flipbook runtime for Roblox experiences, including in-Studio installation and pull request preview deployments.

- Populate embedded Flipbook search and story selection from preview launch data so shared links open with the intended stories visible.

- Expand story controls with color, date, multi-select, slider, and richer primitive inputs while preserving legacy schemas.

### Fixes

- Map beta builds to the development Creator Store asset so development plugin deployment succeeds.

- Keep Flipbook closed until explicitly opened and give first-time dock widgets a more useful floating size.

- Keep story controls connected to the active story after reloading it.

- Prevent pull requests from triggering development Creator Store deployments.

- Update only the affected story control when its value changes, eliminating panel-wide rerenders and their visual artifacts.

- Remove excess padding around the story preview so more space remains available on smaller screens.

### Internal

- Add repository guidance for agents working with Flipbook's build, validation, and cross-repository dependency workflows.

- Add a repository-local agent skill library covering Flipbook architecture, operations, validation, research, and contribution workflows.

- Add a searchable development story for browsing the complete BuilderIcons catalog.

- Decouple the Flipbook app from Studio's Plugin instance through a shared Pluginlike boundary.

- Give GitHub and Roblox publishing jobs enough time to complete while retaining shorter limits for deterministic automation.

- Automate release-note assembly, version synchronization, GitHub releases, and downstream Creator Store publishing through the Changewrite release flow.

- Let the automated RobloxPackages workflow update an existing pull request and trigger downstream CI.

- Consolidate Rojo model building behind a shared helper and simplify the project files used for local development and packaging.

- Define separate ownership and review policies for Flipbook application, engine, and repository administration changes.

- Allow the CI and release workflows to be dispatched manually when automated runs need to be retried or verified.

- Document durable code-commenting standards for automated contributors.

- Extract the reusable InstancePicker from Object controls for use in other DataModel selection flows.

- Make the built Flipbook Rotriever bundle usable as a path dependency by packaging the canonical manifest with the correct source path.

- Give automated Roblox package upgrade pull requests structured Studio verification steps and a link to the generating workflow run.

- Isolate secret-backed pull request automation from normal CI so contributed code is tested without granting it deployment credentials.

- Restore CODEOWNERS routing for Flipbook application and engine changes while keeping merge enforcement in the central repository ruleset.

- Route workspace release manifests to the engine owners so automated release updates do not require application review.

- Move the Creator Store publishing smoketest into the gated CI flow so concurrent runs do not cancel each other while awaiting approval.

- Support pull requests from forks while requiring approval before secret-backed deployment jobs can run.

- Use the shared, versioned AgentSkills package for agent guidance instead of maintaining a separate copy in the Flipbook repository.
