# Changelog

All notable changes to this project will be documented in this file.


## v2.6.0

### Dependencies

- Update Flipbook's build and development dependencies, including FlipbookBatteries, Darklua, Luau LSP, Rojo, Selene, StyLua, and wally-package-types.

- Upgrade Lute to the latest nightly while keeping dependency installation reliable when the shared package store is incomplete.

### Features

- Populate embedded Flipbook search and story selection from preview launch data so shared links open with the intended stories visible.

### Fixes

- Keep story controls connected to the active story after reloading it.

### Internal

- Automate release-note assembly, version synchronization, GitHub releases, and downstream Creator Store publishing through the Changewrite release flow.

- Give automated Roblox package upgrade pull requests structured Studio verification steps and a link to the generating workflow run.

- Route workspace release manifests to the engine owners so automated release updates do not require application review.

- Use the shared, versioned AgentSkills package for agent guidance instead of maintaining a separate copy in the Flipbook repository.
