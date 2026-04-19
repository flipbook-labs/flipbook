---
notion-id: 27695b79-12f8-803d-8ad7-c091fc69dea5
aliases: [Overview]
linter-yaml-title-alias: Overview
---

# Overview

Consuming Flipbook in the StudioPlugins repo could be handled by publishing the FlipbookCore package to the Rotriever registry.

This removes the need for an `upgrade.sh` script in StudioPlugins for building and loading the FlipbookCore package. Instead it will already be built and published, just need to fetch it

# Options Considered

| **Option**      | **Option 1: Include a rotriever.toml in the public repo**                                                                                                                                 | **Option 2: Create an internal fork**                                                                                                                                                                                                                                                                                                         | **Option 3: Publish to Wally and have StudioPlugins source from there**                                                                                                                                           |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Description** | Setup the public flipbook-labs/flipbook repo with a rotriever.toml to allow it to be published to the registry                                                                            | Create a fork of Flipbook at Roblox/flipbook that will be extended with a `rotriever.toml` and workflows to auto-publish on a schedule and run manually via workflow_dispatch                                                                                                                                                                 | Publish a FlipbookCore package to the Wally registry and have StudioPlugins source it from there                                                                                                                  |
| **Pros & Cons** | ❇️ Keeps everything in one place<br>⛔ Publishing must be done manually from a local machine since Rotriever cannot be included in `rokit.toml` and as such cannot be run in GH workflows | ❇️ Much easier to update package versions<br>❇️ Can source RobloxPackages from Rotriever with proper deduping, instead of bundling _all_ packages. This would significantly reduce the **33mb** bundle size<br>⛔ A fork could make it too tempting/accessible to start introducing divergent changes, pushing the public repo to the wayside | ❇️ Keeps everything in one place<br>❇️ Automated publishing<br>⛔ Likely a hard sell. There is current no use of Wally in StudioPlugins<br>⛔ StudioPlugins CI would need to be updated to install Wally packages |

Idea for how Option 2 could work:

![[assets/Screenshot_2025-09-22_at_1.46.26_PM.png]]
