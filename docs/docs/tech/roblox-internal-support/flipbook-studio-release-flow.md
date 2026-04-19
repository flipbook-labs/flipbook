---
aliases: [Flipbook → Studio release flow]
linter-yaml-title-alias: Flipbook → Studio release flow
notion-id: 2db95b79-12f8-8114-a5c5-ff70517a0e49
---

# Flipbook → Studio Release Flow

**flipbook-labs/flipbook**

* Merge PRs to the main repo like you would any other project

**Roblox/flipbook**

* Every day a PR is generated with all of the changes from the upstream repo
    * The workflow can be kicked off manually in case there are changes that need to be merged ASAP
* Once merged, the FlipbookCore package in the Rotriever registry will be updated

**Roblox/StudioPlugins**

* Take the new version and update `standalone/flipbook/rotriever.toml` so that `FlipbookCore` points to the newest version
* Build the built-in plugin and verify nothing is obviously broken
* Once merged another job will update game-engine to consume the latest Flipbook changes, and it will be bundled up for the next Studio release
