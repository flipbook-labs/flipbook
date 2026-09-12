# Creating Releases

Releases are automated via [Changewrite](https://github.com/flipbook-labs/changewrite). Every release-worthy pull request adds a Markdown entry under [`.changes/`](https://github.com/flipbook-labs/flipbook/tree/main/.changes) describing the change and whether it warrants a major, minor, or patch release.

Every push to `main` collects the pending entries and opens or updates a `Publish v{version}` pull request. Merging that pull request:

1. Tags the commit and creates the GitHub release with `Flipbook.rbxm` attached.
2. Triggers the `publish-plugin` job, which publishes to the Roblox Creator Store.

To cut a release, review the assembled notes and version in the auto-generated publish pull request, then merge it. To preview that pull request without publishing, add the `debug:release-pr` label to a pull request; Changewrite uses a separate debug branch and prepare-only mode.

Check out the [Actions tab](https://github.com/flipbook-labs/flipbook/actions) after merging to monitor the deployment.

## Wally registry credential recovery

Some Flipbook Labs repositories publish packages to the Wally registry. If those workflows begin failing authentication, create a replacement registry token with `wally login`, update its 1Password record, and then update the `WALLY_REGISTRY_TOKEN` organization secret at the execution boundary.

Limit GitHub access to the repositories whose workflows publish to Wally. Do not commit the token or pass its plaintext through OpenTofu inputs or state.
