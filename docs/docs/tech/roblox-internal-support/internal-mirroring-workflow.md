---
aliases: [Internal Mirroring Workflow]
linter-yaml-title-alias: Internal Mirroring Workflow
notion-id: 28595b79-12f8-801f-959f-ca160c75c327
---

# Internal Mirroring Workflow

## Overview

`Roblox/flipbook` is used to deploy the latest `FlipbookCore` package to the Rotriever registry for consumption by [StudioPlugins](https://github.com/Roblox/StudioPlugins).

## Requirements

* Sync latest changes from `flipbook-labs/flipbook`
    * Do this on a schedule and from workflow_dispatch
* Include rotriever.toml file
* Change workflows to only worry about deployment
* A PR in Roblox/flipbook gets automatically created for the upstream changes

`Roblox/flipbook` has two primary branches:

* `roblox`: Equivalent of the `main` branch. This is where our deviations live
* `upstream`: 1:1 mirror of the upstream `main` branch

Merge conflicts should really be contained to `.github/workflows`, everything else we can merge the incoming changes.

For `.github/workflows` we may be able to use `git rm` to remove all the changes coming in.

## Implementation

Two jobs:

`sync-upstream-changes`

1. Triggered on schedule and workflow_dispatch
2. Pulls in the latest changes from the `main` branch of `flipbook-labs/flipbook`
3. Creates a PR to merge the changes to the `upstream` branch of `Roblox/flipbook`

`deploy-upstream-changes`

4. Triggered on push to the `upstream` branch
5. Pulls in the changes from `upstream` to `roblox`
6. Discards any changes made to `.github/workflows`
7. Copies `rotriever.toml` to `workspace/flipbook-core`
8. If version in `wally.toml` has a greater major or minor release than `rotriever.toml`, update `rotriever.toml` to match
9. Else, bump the patch version in `rotriever.toml` to ensure we publish a new version regardless. This intentionally desyncs from upstream
10. Build the release artifact
11. Publish to the Rotriever registry

> [!tip] 💡
> **Versioning decision**
> It would have been ideal to keep the major/minor/patch version in sync between repos and use some extra metadata to define which version we’re on internally. For example if upstream version is `1.2.3` then the internal version would be `1.2.3-roblox.1` where the last number is incremented each time we pull in new changes.
>
> However due to how version resolution works, `1.2.3` takes precedence over `1.2.3-roblox.1`. Consumers would need to pin to the exact internal version to make sure they’re not getting older changes.
>
> To avoid this, we’re intentionally desyncing the patch version between upstream and internal.

## References

* [Allowing github-actions[bot] to push to protected branch · community · Discussion #25305](https://github.com/orgs/community/discussions/25305#discussioncomment-8256560)
*  https://github.com/actions/create-github-app-token

## Notes

Coming back to the syncing workflow:

* Can't figure out a nice way to automate `upstream` getting the latest changes
* With a fresh mind, I'm curious if there's any room to not conform to EE's
standards. Let upstream sit there, and have PRs auto-generated to merge to
`roblox`?
    * This is also tricky because of merge conflicts. Instead, what about keeping
`upstream` mirrored 1:1, then `roblox` is just a job runner, and it will
checkout upstream, add rotriever.toml, bump the version, and then publish
* This is all getting too complicated and I should start diagramming so I can
keep track. And so I can simplify, because I think I'm overengineering
